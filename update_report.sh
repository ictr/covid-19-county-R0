#!/bin/sh
URL=https://www.dshs.state.tx.us/coronavirus/TexasCOVID19DailyCountyCaseCountData.xlsx
# change to the current directory of the script
cd "${0%/*}"
datafile="TSHS_CaseCountData/Texas COVID-19 Case Count Data by County.xlsx"
sumfile=TSHS_CaseCountData/data.md5

# first get the file
echo "Download data"
wget -q $URL -O "$datafile"

# calculate md5
newsum=$(md5sum "$datafile")

# create md5 if not exist
if [ -f $sumfile ]; then
    result=`md5sum -c  --quiet $sumfile`
    if [ "$result" == "" ] ; then
      echo "Data has not been changed"
      exit 0
    fi
fi

echo $newsum > $sumfile
echo "Update md5 file"

# build docker image if has not existed
if [[ "$(docker images -q covid19-r0-sos 2> /dev/null)" == "" ]]; then
   docker build . -t covid19-r0-sos
fi

# process data
docker run --rm -i -v $(pwd):/covid-19-county-R0 covid19-r0-sos sh -c 'cd /covid-19-county-R0/TSHS_CaseCountData; Rscript code.r'
docker run --rm -i -v $(pwd):/covid-19-county-R0 covid19-r0-sos sh -c 'cd /covid-19-county-R0/; papermill --engine sos "Realtime R0_sos.ipynb" Realtime_updated.ipynb'

# update title with the current date and convert to HTML file
sed -i -E "s/in Real-Time \(Until .+\)/in Real-Time \(Until $(date +"%b %d")\)/" Realtime_updated.ipynb
docker run --rm -i -v $(pwd):/covid-19-county-R0 covid19-r0-sos sh -c 'cd /covid-19-county-R0/; sos convert Realtime_updated.ipynb Realtime_updated.html --template sos-report-v2'

# move updated HTML file to webserver
mv Realtime_updated.html "/var/www/web/sites/default/files/r0.html"

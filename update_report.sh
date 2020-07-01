URL=https://www.dshs.state.tx.us/coronavirus/TexasCOVID19DailyCountyCaseCountData.xlsx
datafile="TSHS_CaseCountData/Texas COVID-19 Case Count Data by County.xlsx"
sumfile=TSHS_CaseCountData/data.md5

# first get the file
echo "Download data"
wget -q $URL -O "$datafile"

# calculate md5
newsum=$(md5 "$datafile")

# create md5 if not exist
[ -f $sumfile ] || touch $sumfile

# check if md5 exists
if grep -q "$newsum" $sumfile; then
  echo "Data has not been changed"
  exit 0
else
  echo $newsum > $sumfile
  echo "Update md5 file"
fi

# build docker image if has not existed
if [[ "$(docker images -q covid19-r0 2> /dev/null)" == "" ]]; then
   docker build . -t covid19-r0
fi

# process data
docker run --rm -it -v $(pwd):/covid-19-county-R0 covid19-r0 sh -c 'cd /covid-19-county-R0/TSHS_CaseCountData; Rscript code.r' 
docker run --rm -it -v $(pwd):/covid-19-county-R0 covid19-r0 sh -c 'cd /covid-19-county-R0/; papermill "Realtime R0.ipynb" Realtime_updated.ipynb'
docker run --rm -it -v $(pwd):/covid-19-county-R0 covid19-r0 sh -c 'cd /covid-19-county-R0/; jupyter nbconvert --to html Realtime_updated.ipynb'
mv Realtime_updated.ipynb "Realtime R0.ipynb"
mv Realtime_updated.html "Realtime R0.html"

# git push
#
# COPY TO WEBSERVER

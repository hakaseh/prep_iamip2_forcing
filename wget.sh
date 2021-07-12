#This script assumes that you have a wget*.sh files in the `raw` directory.
#wget*.sh files are the files you generate from the CMIP6 ESGF data archive when you want to download many files.

#User input begins
model=CMCC-ESM2
exp=ssp585

cd ${model}/${exp}/tmp/raw 
for $i in wget*.sh
do
    bash $i -H
done
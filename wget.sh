#This script assumes that you have a wget*.sh files in the `raw` directory.
#wget*.sh files are the files you generate from the CMIP6 ESGF data archive when you want to download many files.

#User input begins

model=EC-Earth3 #CMCC-ESM2 #MRI-ESM2-0
exp=ssp126 #585

#User input ends

cd ${model}/${exp}/tmp/raw 
for i in wget*.sh
do
    #execute in background (&) for parallel computing
    bash $i -H &
done
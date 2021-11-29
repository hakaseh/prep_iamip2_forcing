#This script fixes the chunk size of prra in ssp126.
#
#The issue:
#
#I'm not sure why but the chunk size was set to [2920, 320, 640] for prra of ssp126,
#while it is [1, 320, 640] for ppra of ssp585.
#This caused errors in ACCESS-OM2 simulations, so can potentially cause error in other models.
#Chunk size can be fixed by running this script, after setting your own path to data (path2data).
#Run this script twice; once with model=EC-Earth3 and once more with model=CMCC-ESM2.

#User input begins

path2data=/g/data/v45/hh0162/projects/icebgc/prep_iamip2_forcing
model=CMCC-ESM2

#User input ends

exp=ssp126
var=prra
freq=3hr
variant=r1i1p1f1

for i in {2015..2100}
do
	filename=${path2data}/${model}/${exp}/${var}/${var}_${freq}_${model}_${exp}_${variant}_JRA_${i}.nc
	ncks -O --cnk_dmn time,1 $filename $filename
done

#This script is only relevant to NCI users. If you are not on NCI, then you need to do this step on your own.
#It is easy. It only craetes symbolic links to the original CMIP6 data and store them in the `raw` directory.

#User input begins

insti=EC-Earth-Consortium #CMCC #MRI
model=EC-Earth3 #CMCC-ESM2 #MRI-ESM2-0
mip=ScenarioMIP
exp=ssp126
variant=r1i1p1f1
version=v20200310 #v20210126 #v20191108
moddir=/g/data/oi10/replicas/CMIP6/${mip}/${insti}/${model}/${exp}/${variant}/
#List of variables that are available on NCI and their time frequency.
#For the case of CMCC-ESM2, the only unavailable variable is prsn and psl, which were downloaded in the next step (wget.sh)
#CMCC-ESM2 ssp126: missing prsn, psl, friver
#CMCC-ESM2 ssp585: missing prsn, psl
#EC-Earth3 ssp126: missing prsn, psl, friver
vlist=(huss tas uas vas rsds rlds pr) #friver)
flist=(3hr  3hr 3hr 3hr 3hr  3hr  3hr) #Omon)

#User input ends

outdir=$model/${exp}/tmp/raw
mkdir -p $outdir

for it2 in "${!vlist[@]}"
do
    if [ $model = 'MRI-ESM2-0' ] && [ ${vlist[it2]} = 'friver' ]
    then
        ln -s ${moddir}/${flist[it2]}/${vlist[it2]}/gn/v20210329/${vlist[it2]}_${flist[it2]}_${model}_${exp}_${variant}_gn_*.nc $outdir
    else
        ln -s ${moddir}/${flist[it2]}/${vlist[it2]}/gn/${version}/${vlist[it2]}_${flist[it2]}_${model}_${exp}_${variant}_gn_*.nc $outdir
    fi
    #EC-Earth3 is given on regular grid (gr).
    if [ $model = 'EC-Earth3' ]
    then
        ln -s ${moddir}/${flist[it2]}/${vlist[it2]}/gr/${version}/${vlist[it2]}_${flist[it2]}_${model}_${exp}_${variant}_gr_*.nc $outdir
    fi
done
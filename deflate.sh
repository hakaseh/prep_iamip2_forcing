#User input begins

model=EC-Earth3 #CMCC-ESM2 #MRI-ESM2-0
exp=ssp126 #585
variant=r1i1p1f1
vlist=(huss friver psl       tas uas vas rsds rlds prsn prra)
flist=(3hr  Omon   6hrPlevPt 3hr 3hr 3hr 3hr  3hr  3hr  3hr)

#User input ends

#Finally, compress the output to save some storage.
#Loop through variables
for v in "${!vlist[@]}"
do
    mkdir -p ${model}/${exp}/${vlist[v]}
    #Loop through years
    for i in {2015..2100}
    do
        outfile=${model}/${exp}/${vlist[v]}/${vlist[v]}_${flist[v]}_${model}_${exp}_${variant}_JRA_${i}.nc
        #deflate to save storage space.
        #increasing to 9 did not improve data saving (at least for huss). Set to 1 for saving time.
        outfile=${model}/${exp}/${vlist[v]}/${vlist[v]}_${flist[v]}_${model}_${exp}_${variant}_JRA_${i}.nc
        ncks -O -L 1 $outfile $outfile
	done
done
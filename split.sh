#User input begins


#model=CMCC-ESM2
model=MRI-ESM2-0
exp=ssp585
variant=r1i1p1f1
#pr needs to be listed after prsn, as prra calculation depends on the latter.
vlist=(huss friver psl       tas uas vas rsds rlds prsn pr)
flist=(3hr  Omon   6hrPlevPt 3hr 3hr 3hr 3hr  3hr  3hr  3hr)

#User input ends

#loop through variables
for v in "${!vlist[@]}"
do
	#parallel compute the following block
    {
    mkdir -p ${model}/${exp}/${vlist[v]}
    mkdir -p ${model}/${exp}/tmp/raw_cat
    mkdir -p ${model}/${exp}/tmp/raw_each_year
    infile=${model}/${exp}/tmp/raw_cat/${vlist[v]}.nc

    if [ ! -f $infile ]
    then
        #concatenate
        cdo -mergetime ${model}/${exp}/tmp/raw/${vlist[v]}_*.nc $infile
        #shift time by -90min for some of the CMCC2-ESM2 variables
        if [ ${model} = 'CMCC-ESM2' ]
        then
            if [ ${vlist[v]} = 'huss' ] || [ ${vlist[v]} = 'uas' ] || [ ${vlist[v]} = 'vas' ] || [ ${vlist[v]} = 'tas' ]
            then
                cdo -shifttime,-90min $infile $infile.tmp
                mv $infile.tmp $infile
            fi 
        fi      
    fi
    } &
done

wait

#loop through variables
for v in "${!vlist[@]}"
do
    {
    infile=${model}/${exp}/tmp/raw_cat/${vlist[v]}.nc

    #loop through years
    for i in {2015..2100}
    do
        outfile=${model}/${exp}/tmp/raw_each_year/${vlist[v]}_${i}.nc
        cdo -selyear,$i/$i $infile $outfile
        #extrapolate over land to avoid potential error when remapping
        if [ ${vlist[v]} = 'friver' ]
        then
            cdo -fillmiss2 $outfile $outfile.tmp
            mv $outfile.tmp $outfile
        fi
    done
    } &
done
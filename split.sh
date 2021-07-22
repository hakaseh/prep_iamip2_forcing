#User input begins

model=CMCC-ESM2 #MRI-ESM2-0
exp=ssp126 #585
vlist=(huss friver psl       tas uas vas rsds rlds prsn pr)
flist=(3hr  Omon   6hrPlevPt 3hr 3hr 3hr 3hr  3hr  3hr  3hr)

#User input ends

if [ ${model} = 'EC-Earth3' ]
then
    echo "no need to split because the raw data is already provided as one file per year... exiting."
else
    #loop through variables
    for v in "${!vlist[@]}"
    do
        #parallel compute the following block
        {
        mkdir -p ${model}/${exp}/tmp/raw_cat
        mkdir -p ${model}/${exp}/tmp/raw_each_year
        infile=${model}/${exp}/tmp/raw_cat/${vlist[v]}.nc

        #Do NOT re-concatenate if the file already exists
        if [ ! -f $infile ]
        then
            #concatenate
            cdo -mergetime ${model}/${exp}/tmp/raw/${vlist[v]}_*.nc $infile
            #shift time for some of the CMCC-ESM2 variables
            if [ ${model} = 'CMCC-ESM2' ]
            then
                #shift time by -90min
                if [ ${vlist[v]} = 'huss' ] || [ ${vlist[v]} = 'uas' ] || [ ${vlist[v]} = 'vas' ] || [ ${vlist[v]} = 'tas' ]
                then
                    cdo -shifttime,-90min $infile $infile.tmp
                    mv $infile.tmp $infile
                #shift by -180min
                elif [ ${vlist[v]} = 'psl' ]
                then
                    cdo -shifttime,-180min $infile $infile.tmp
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
        infile=${model}/${exp}/tmp/raw_cat/${vlist[v]}.nc

        #loop through years
        for i in {2015..2100}
        do
            #parallel compute
            {
            outfile=${model}/${exp}/tmp/raw_each_year/${vlist[v]}_${i}.nc
            cdo -selyear,$i/$i $infile $outfile
            } &
        done
    done
fi
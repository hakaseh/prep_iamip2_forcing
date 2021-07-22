#User input begins

model=EC-Earth3 #CMCC-ESM2 #MRI-ESM2-0
exp=ssp126 #585
variant=r1i1p1f1
#pr needs to be listed after prsn, as prra calculation depends on the latter.
vlist=(huss friver psl       tas uas vas rsds rlds prsn pr)
flist=(3hr  Omon   6hrPlevPt 3hr 3hr 3hr 3hr  3hr  3hr  3hr)
#Location of JRA55-do data for creating atmospheric and land grid files.
fjraatm=/g/data/qv56/replicas/input4MIPs/CMIP6/OMIP/MRI/MRI-JRA55-do-1-4-0/atmos/3hrPt/tas/gr/v20190429/tas_input4MIPs_atmosphericState_OMIP_MRI-JRA55-do-1-4-0_gr_200001010000-200012312100.nc
fjralan=/g/data/qv56/replicas/input4MIPs/CMIP6/OMIP/MRI/MRI-JRA55-do-1-4-0/landIce/day/licalvf/gr/v20190429/licalvf_input4MIPs_atmosphericState_OMIP_MRI-JRA55-do-1-4-0_gr_20000101-20001231.nc

#User input ends

#Create grid files for remapping.
cdo griddes ${fjraatm} > jra_grid_atom.txt
cdo griddes ${fjralan} > jra_grid_land.txt

#Loop through variables
for v in "${!vlist[@]}"
do
    #parallel compute
    {
    mkdir -p ${model}/${exp}/${vlist[v]}
    #Loop through years
    for i in {2015..2100}
    do
        #not parallel compute here (it would overload vdi)
        
        #EC-Earth3 provides one file for one year, so no need to split.
        if [ ${model} = 'EC-Earth3' ]
        then
            infile=${model}/${exp}/tmp/raw/${vlist[v]}_*_${i}*.nc
        else
            infile=${model}/${exp}/tmp/raw_each_year/${vlist[v]}_${i}.nc
        fi
        outfile=${model}/${exp}/${vlist[v]}/${vlist[v]}_${flist[v]}_${model}_${exp}_${variant}_JRA_${i}.nc
                
		if [ ${vlist[v]} = "friver" ]
		then
            #nearest-neighbour remapping for friver
			cdo -remapnn,jra_grid_land.txt $infile $outfile
            #extrapolate over land to avoid potential error when remapping
            cdo -fillmiss2 $outfile $outfile.tmp
            mv $outfile.tmp $outfile
		else
            #conservative remapping for all other variables
			cdo -remapcon,jra_grid_atom.txt $infile $outfile
		fi
        #modify calendar type to work with the model.
		cdo -setcalendar,gregorian $outfile $outfile.tmp
		mv $outfile.tmp $outfile
		#force set pr and prsn to non-negative.
        if [ ${vlist[v]} = "pr" ] || [ ${vlist[v]} = "prsn" ]
		then
			cdo setrtoc,-inf,0,0 $outfile $outfile.tmp
			mv $outfile.tmp $outfile
		fi
    done
    } &
done

#wait because prra calculation depends on pr and prsn
wait

#Derive prra from pr and prsn (do this separately because parallel computing does not work with ncap2 for some reason)
mv ${model}/${exp}/pr ${model}/${exp}/tmp/
mkdir -p ${model}/${exp}/prra
#Loop through years. DO NOT parallel compute b/c ncap2 and ncks do not work well (maybe NCI specific issue)
for i in {2015..2100}
do
    inpr=${model}/${exp}/tmp/pr/pr_${flist[v]}_${model}_${exp}_${variant}_JRA_${i}.nc
    inprsn=${model}/${exp}/prsn/prsn_${flist[v]}_${model}_${exp}_${variant}_JRA_${i}.nc
    outfile=${model}/${exp}/prra/prra_${flist[v]}_${model}_${exp}_${variant}_JRA_${i}.nc

    cdo -merge $inprsn $inpr $outfile
    ncap2 -O -s "prra=pr-prsn" $outfile $outfile
    ncks -O -v prra $outfile $outfile
done
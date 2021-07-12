#User input begins

model=CMCC-ESM2
exp=ssp585
variant=r1i1p1f1
#Replace pr by prra. prra needs to be listed after prsn, as prra calculation depends on the latter.
vlist=(huss friver psl       tas uas vas rsds rlds prsn prra)
flist=(3hr  Omon   6hrPlevPt 3hr 3hr 3hr 3hr  3hr  3hr  3hr)
#Location of JRA55-do data for creating atmospheric and land grid files.
fjraatm=/g/data/qv56/replicas/input4MIPs/CMIP6/OMIP/MRI/MRI-JRA55-do-1-4-0/atmos/3hrPt/tas/gr/v20190429/tas_input4MIPs_atmosphericState_OMIP_MRI-JRA55-do-1-4-0_gr_200001010000-200012312100.nc
fjralan=/g/data/qv56/replicas/input4MIPs/CMIP6/OMIP/MRI/MRI-JRA55-do-1-4-0/landIce/day/licalvf/gr/v20190429/licalvf_input4MIPs_atmosphericState_OMIP_MRI-JRA55-do-1-4-0_gr_20000101-20001231.nc

#User input ends

#Create grid files for remapping.
cdo griddes ${fjraatm} > jra_grid_atom.txt
cdo griddes ${fjralan} > jra_grid_land.txt

#Loop through variables
for v in 9 #"${!vlist[@]}"
do
    mkdir -p ${model}/${exp}/${vlist[v]}
    #Loop through years
    for i in {2015..2100}
    do
        infile=${model}/${exp}/tmp/raw_each_year/${vlist[v]}_${i}.nc
        outfile=${model}/${exp}/${vlist[v]}/${vlist[v]}_${flist[v]}_${model}_${exp}_${variant}_JRA_${i}.nc
                
		if [ ${vlist[v]} = "friver" ]
		then
            #nearest-neighbour remapping for friver
			cdo -remapnn,jra_grid_land.txt $infile $outfile
            #extrapolate over land to avoid potential error when remapping
            cdo -fillmiss2 $outfile $outfile.tmp
            mv $outfile.tmp $outfile
		else
            #deriving prra from pr and prsn
			if [ ${vlist[v]} = "prra" ]
			then
                inprsn=${model}/${exp}/tmp/raw_each_year/prsn_${i}.nc
                inpr=${model}/${exp}/tmp/raw_each_year/pr_${i}.nc
                cdo -O -merge $inprsn $inpr $infile
                ncap2 -O -s "prra=pr-prsn" $infile $infile
                ncks -O -v prra $infile $infile
            fi
            #conservative remapping for all other variables
			cdo -remapcon,jra_grid_atom.txt $infile $outfile
		fi
        #modify calendar type to work with the model.
		cdo -setcalendar,gregorian $outfile $outfile.tmp
		mv $outfile.tmp $outfile
		#force set prra and prsn to non-negative.
        if [ ${vlist[v]} = "prra" ] || [ ${vlist[v]} = "prsn" ]
		then
			cdo setrtoc,-inf,0,0 $outfile $outfile.tmp
			mv $outfile.tmp $outfile
		fi
        #deflate to save storage space.
        #increasing to 9 did not improve data saving (at least for huss). Set to 1 for saving time.
		ncks -O -L 1 $outfile $outfile
		echo ${vlist[v]},$i,done
	done
done
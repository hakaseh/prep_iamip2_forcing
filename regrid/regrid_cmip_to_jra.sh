#create grid files, one for atmospheric (0.5-deg) and land (0.25-deg).
cdo griddes ~/data/members/JRA55-do/atmos/3hrPt/tas/gr/v20190429/tas_input4MIPs_atmosphericState_OMIP_MRI-JRA55-do-1-4-0_gr_200001010000-200012312100.nc > jra_grid_atom.txt
cdo griddes ~/data/members/JRA55-do/landIce/day/licalvf/gr/v20190429/licalvf_input4MIPs_atmosphericState_OMIP_MRI-JRA55-do-1-4-0_gr_20000101-20001231.nc > jra_grid_land.txt

#tas and others

f=3hr
#vlist=( tas huss uas vas rsds rlds )
vlist=( prra_and_prsn )

#psl

#f=6hrPlevPt
#vlist=( psl )

#friver

#f=Omon
#vlist=( friver )


for i in {2015..2100}
do
	for v in "${vlist[@]}"
	do
		mkdir -p ${v}
		outfile=${v}/${v}_${f}_EC-Earth3_ssp585_r1i1p1f1_JRA_${i}.nc


		if [ $v = "friver" ]
		then
	 		infile=~/data/projects/icebgc/prep_iamip2_forcing/download/${v}/${v}_${f}_EC-Earth3_ssp585_r1i1p1f1_gn_${i}*.nc
			cdo -remapnn,jra_grid_land.txt $infile $outfile
			cdo -O -setmissval,0 $outfile $outfile.tmp
			mv $outfile.tmp $outfile
		else
			if [ $v = "psl" ] || [ $v = "prra_and_prsn" ]
			then
                        	infile=~/data/projects/icebgc/prep_iamip2_forcing/download/${v}/${v}_${f}_EC-Earth3_ssp585_r1i1p1f1_gr_${i}*.nc
			else
				infile=~/data/members/CMIP6/ScenarioMIP/EC-Earth-Consortium/EC-Earth3/ssp585/r1i1p1f1/${f}/${v}/gr/v20200310/${v}_${f}_EC-Earth3_ssp585_r1i1p1f1_gr_${i}*.nc
			fi
			cdo -remapcon,jra_grid_atom.txt $infile $outfile

		fi

		cdo -setcalendar,gregorian $outfile $outfile.tmp
		mv $outfile.tmp $outfile
		if [ $v = "prra_and_prsn" ]
		then
			cdo setrtoc,-inf,0,0 $outfile $outfile.tmp
			mv $outfile.tmp $outfile
		fi
		ncks -O -L 1 $outfile $outfile
		echo $v,$i,done
	done
	echo $i,done
done

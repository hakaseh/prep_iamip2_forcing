#licalvf does not have projected output, so we will just prescribe the historical JRA55-do, which is invariant in time (climatology).
#although annual licalvf is sufficient, the model did not like it as input. so i create monthly licalvf, same frequency as friver.
#we need to change the time to 2015-2100 using friver


for yr in {2015..2100}
do	
	cdo monmean ~/data/members/JRA55-do/landIce/day/licalvf/gr/v20190429/licalvf_input4MIPs_atmosphericState_OMIP_MRI-JRA55-do-1-4-0_gr_20000101-20001231.nc licalvf_input4MIPs_atmosphericState_OMIP_MRI-JRA55-do-1-4-0_gr_2000.nc
	ncks -A -v friver ../friver/friver_Omon_EC-Earth3_ssp585_r1i1p1f1_JRA_${yr}.nc licalvf_input4MIPs_atmosphericState_OMIP_MRI-JRA55-do-1-4-0_gr_2000.nc
	ncks -L 1 -v licalvf licalvf_input4MIPs_atmosphericState_OMIP_MRI-JRA55-do-1-4-0_gr_2000.nc licalvf_input4MIPs_atmosphericState_OMIP_MRI-JRA55-do-1-4-0_gr_${yr}.nc
done
rm licalvf_input4MIPs_atmosphericState_OMIP_MRI-JRA55-do-1-4-0_gr_2000.nc

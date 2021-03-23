#20200216
#downloaded EC-Earth3 data that are not available on NCI: psl, friver, prsn
#created download/
#bash wget*.sh -H
#https://esgf-node.llnl.gov/esgf-idp/openid/hakase

#derive prra from pr and prsn (prra not provided by EC-Earth3)
#created download/prra/
#bash derive_prra.sh
#caution about EC-Earth3 pr and prsn: they contain negative values, while JRA55-do prra and prsn >= 0, so i need to force set negatives to zeros.


~/data/members/CMIP6/ScenarioMIP/EC-Earth-Consortium/EC-Earth3/ssp585/r1i1p1f1/3hr/

#3hr data available on NCI.
tas
huss
uas
vas
rsds
rlds

6hr/
#psl
provided at 6hourly, so need to change the frequency setting for forcing namelist?

#friver
-use the monthly mean of EC-Earth3. change the frequency set for forcing namelist?
-for some reason, friver is provided on native grid (gn), while others in regular grid (gr).
-for 2015, i compared yearly-global friver between JRA55 and EC-Earth5, and they are 0.08 vs 0.1, so quite comparable.
-conservative remapping does not work for some reason (due to landsea mask?), so i used nearest neighboor (remapnn).

#licalvf
use the same as JRA55-do, but have to change time (2015-2100). 

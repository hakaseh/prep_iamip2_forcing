# Remap CMIP6 atmospheric output to the JRA55-do grid
## Author: Hakase Hayashida

# Steps

1. If you are an NCI user, request NCI to download the CMIP6 data you need if they are not available (see https://clef.readthedocs.io/en/latest/gettingstarted.html).
1. `bash link.sh` to create symbolic links in `raw` for data that are already available on your server (e.g. NCI for Australians).
1. If you are NOT an NCI user, `bash wget.sh` to download data to `raw` that are not available your server. If you are an NCI user, it is recommended to request NCI to download the necessary data centrally (see the very first step above).
1. `bash split.sh` to concatenate the raw files and then split into years (one file for one year of data).
1. `bash remap.sh` to remap.
1. `bash deflate.sh` to compress the output.
1. `licalvf.sh` to create data for `licalvf`.
1. `rm -r tmp` if you are happy with the output.

## A few notes

1. Almost all CMIP6 models do not provide `prra`, which is needed for JRA55-do. Derive it from `pr` and `prsn` by knowing that `prra = pr - prsn`. Also, `pr` and `prsn` in CMIP6 models often contain negative values, while the values are non-negative in JRA55-do, so force set negatives to zeros (see `remap.sh`).
1. For `CMCC-ESM2`, some 3-hourly variable starts from 03:00:00, which makes it one less data points than expected (2)
1. `friver` is typically given in non-regular grid, whereas atmospheric variables are typicaly given in regular grid. This makes conservative remapping (`remapcon`) impossible for `friver` in `cdo`. Use nearest-neightbour for `friver` (`remapnn`), and `remapcon` for all others.
1. `friver` has land-sea mask. To prevent potential regmapping issue (producing NaNs), extrapolate over land (see `split.sh` and also `remap.sh`). 
1. `licalvf` is not available in CMIP6. Use the same values as in JRA55-do, but change time appropriately (i.e. 2015-2100).
1. Whenever possible, parallel computing is used (submit a block of code as a background job). however, some commands (ncap2, ncks) could not be used (job gets killed, maybe NCI has limits).
# Interchange


These are the scripts that go into the cgi_bin directory of Annie.

/usr/local/web/ucjeps_cgi



# Definitions and History of Individual Files


## LN2C.pl
#### Script used to process   
##### 
#### Script recovered from archive.

## draw_jmap.pl
#### Script used to fill in the regions on small maps of California on the Interchange and the eFlora.  This is the 2003 and prior version of this file and gif.
##### This script maps the HCODES onto the map gif ```calmap2.GIF``` This is one of many versions of the small map found in the archive.
#### Script recovered from archive. Last updated by Dick Moe. Superceded by draw_tiny_jmap.pl.

## draw_tiny_jmap.pl
#### Script used to process names and hcodes from the hash file ```nomsyn_hcode_hash```.  This script consults the old taxon id file ```TNOAN.out``` to find the taxon id's for each text name in the hash.  It then reads from a file called ```newdist``` and prints the new records in the hash file.
##### ```nomsyn_hcode_hash``` is also no longer updated each time the eFlora or ICPN is refreshed.  I am not sure why ```TJM_treat_path``` was also not used in 2015.
#### Script recovered from archive. Last updated by Dick Moe. Superceded by draw_tiny2.pl.

## draw_tiny_jmap.pl
#### Script used to process names and hcodes from the hash file ```nomsyn_hcode_hash```.  This script consults the old taxon id file ```TNOAN.out``` to find the taxon id's for each text name in the hash.  It then reads from a file called ```newdist``` and prints the new records in the hash file.
##### ```nomsyn_hcode_hash``` is also no longer updated each time the eFlora or ICPN is refreshed.  I am not sure why ```TJM_treat_path``` was also not used in 2015.
#### Script recovered from archive. Last updated by Dick Moe. Superceded by draw_tiny2.pl.

## draw_tiny_jmap.pl
#### Script used to process names and hcodes from the hash file ```nomsyn_hcode_hash```.  This script consults the old taxon id file ```TNOAN.out``` to find the taxon id's for each text name in the hash.  It then reads from a file called ```newdist``` and prints the new records in the hash file.
##### ```nomsyn_hcode_hash``` is also no longer updated each time the eFlora or ICPN is refreshed.  I am not sure why ```TJM_treat_path``` was also not used in 2015.
#### Script recovered from archive. Last updated by Dick Moe. Superceded by draw_tiny2.pl.
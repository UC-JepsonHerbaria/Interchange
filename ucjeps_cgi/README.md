# Interchange


These are the scripts that go into the cgi_bin directory of Annie.

/usr/local/web/ucjeps_cgi



# Definitions and History of Individual Files


## LN2C.pl
#### Script used to process   
##### 
#### Script recovered from archive.

## draw_jmap.pl
#### Script used to fill in the regions on maps of California on the Interchange and the eFlora.  This is the 2003 and prior version of this file and gif.
##### This script maps the HCODES onto the map gif ```calmap2.GIF``` This is one of many versions of the map found in the archive. ```calmap2.GIF```is a 276 kb, slightly larger version of the map.
#### Script recovered from archive. Last updated by Dick Moe. Superceded by draw_jmap_mini.pl.

## draw_jmap_mini.pl
#### Script used to fill in the regions on maps of California on the Interchange and the eFlora.  This is the 2013 version of this file and gif.
##### This script maps the HCODES onto the map gif ```calmap_mini.gif``` This is one of many versions of the map found in the archive.
#####Although this says "mini", this is not the small 39KB version of the map now used on the interchange.  ```calmap_mini.gif``` is a 186 kb, slightly larger version of the map.
#### Script recovered from archive. Last updated by Dick Moe. Superceded by XXXXXXXXXXX.

## draw_tiny_jmap.pl
#### Script used to fill in the regions on maps of California on the Interchange and the eFlora.  This is the 2013 version of this file and gif.
##### This script maps the HCODES onto the map gif ```calmaptrim4.gif``` This is one of many versions of the map found in the archive. ```calmaptrim4.gif``` is a 181 kb, slightly larger version of the map with black borders.
##### This and all the other 2013 an older versions of these files use the HCODE pixel mapping definitions shown in HCODE README under "Old Form (2013 version)"
#### Script recovered from archive. Last updated by Dick Moe. Superceded by draw_tiny2.pl. 

## draw_tiny2.pl
#### Script used to process names and hcodes from the hash file ```nomsyn_hcode_hash```.  This script consults the old taxon id file ```TNOAN.out``` to find the taxon id's for each text name in the hash.  It then reads from a file called ```newdist``` and prints the new records in the hash file.
##### ```nomsyn_hcode_hash``` is also no longer updated each time the eFlora or ICPN is refreshed.  I am not sure why ```TJM_treat_path``` was also not used in 2015.
##### This uses the HCODE pixel mapping definitions shown in HCODE README under "Short Form, 2015 version"
#### Modified from previous versions by David Baxter to change the KR boundary. Last updated by J. Alexander.
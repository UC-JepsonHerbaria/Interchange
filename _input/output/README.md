# Interchange


### This is the output directory created by the Interchange script ```make_interchange.pl``` (see Step 5).

##### 5. Run ```make_interchange.pl```, which uses ```CPN_out.txt``` as an input. This creates a directory called ```_input```, which contains directories output, temp, log, and links. If you want to review any "warns" the script gave, they can be found in log.
######  	>Output: a whole bunch of interchange files in ```_input/output```

## ICPN file parsing

```print "     5 parsing the plant name index\n";```
```&parse_cpn();```

##### made by line in ```make_interchange.pl```:

```#from new_parse_cpn.pl```
```sub parse_cpn {```

## Script Status definitions:
```
'1' => 'accepted name for taxon native to CA',
'1a' => 'taxonomic or nomenclatural synonym for taxon native to CA',
'1b' => 'unpublished, invalidly published, illegitimate, or rejected name for taxon native to CA',
'2' => 'accepted name for taxon naturalized in CA',
'2a' => 'taxonomic or nomenclatural synonym for taxon naturalized in CA',
'2b' => 'unpublished, invalidly published, illegitimate, or rejected name for taxon naturalized in CA',
'3' => 'accepted name for taxon occurring in CA only as a waif and/or garden escape, not naturalized',
'3a' => 'taxonomic or nomenclatural synonym for taxon occurring in CA only as a waif and/or garden escape, not naturalized',
'3b'  => 'unpublished, invalidly published, illegitimate, or rejected name for for taxon occurring in CA only as a waif and/or garden escape, not naturalized',
'4' => 'accepted name for taxon occurring in CA only as agricultural or garden weed',
'4a' => 'taxonomic or nomenclatural synonym for taxon occurring in CA only as agricultural or garden weed',
'4b' => 'unpublished, invalidly published, illegitimate, or rejected name for taxon occurring in CA only as agricultural or garden weed',
'5' => 'accepted name for taxon occurring in CA only as greenhouse weed',
'5a' => 'taxonomic or nomenclatural synonym for taxon occurring in CA only as greenhouse weed',
'6' => 'accepted name for taxon extirpated in CA',
'6a' => 'taxonomic or nomenclatural synonym for taxon extirpated in CA',
'7' => 'accepted name for taxon extinct',
'7a' => 'taxonomic or nomenclatural synonym for taxon extinct',
'8' => 'accepted name for taxon not occurring in CA (erroneous reports, misapplication of names, misidentifications, other exclusions)',
'8a' => 'taxonomic or nomenclatural synonym for taxon not occurring in CA (erroneous reports, misapplication of names, misidentifications, other exclusions)',
'8b' => 'unpublished, invalidly published, illegitimate, or rejected name for taxon not occurring in CA (erroneous reports, misapplication of names, misidentifications, other exclusions)',
'9' => 'accepted name for plant occurring in CA only under cultivation (e.g., as crop, ornamental, or experimental plant)',
'9a' => 'taxonomic or nomenclatural synonym for plant occurring in CA only under cultivation (e.g., as crop, ornamental, or experimental plant)',
'10' => 'accepted name for taxonomically recognized and/or fertile hybrid; hybrid form of name',
'10a' => 'accepted name for taxonomically recognized and/or fertile hybrid; non-hybrid form of name',
'10b' => 'taxonomic or nomenclatural synonym for taxonomically recognized and/or fertile hybrid; hybrid form of name',
'10bb' => 'unpublished, invalidly published, illegitimate, or rejected name for taxonomically recognized and/or fertile hybrid; hybrid form of name',
'10c' => 'taxonomic or nomenclatural synonym for taxonomically recognized and/or fertile hybrid; non-hybrid form of name',
'11' => 'accepted name for taxonomically not recognized and/or sterile hybrid; hybrid form of name',
'11a' => 'accepted name for taxonomically not recognized and/or sterile hybrid; non-hybrid form of name',
'12' => 'quadrinomial treated as trinomial elsewhere in this list',
'13' => 'represents correction or possible correction only in spelling or rank and treated elsewhere in this list',
'14' => 'orthographic variant of name treated elsewhere in this list',
'15' => 'genus name',
'16' => 'family name',
'17' => 'unpublished, invalidly published, illegitimate, or rejected name for taxon of unknown or uncertain status with respect to the flora of CA',
'1_t' => 'accepted name for taxon native to CA (tentative)',
'1a_t' => 'taxonomic or nomenclatural synonym for taxon native to CA (tentative)',
'1b_t' => 'unpublished, invalidly published, illegitimate, or rejected name for taxon native to CA (tentative)',
'2_t' => 'accepted name for taxon naturalized in CA (tentative)',
'2a_t' => 'taxonomic or nomenclatural synonym for taxon naturalized in CA (tentative)',
'2b_t' => 'unpublished, invalidly published, illegitimate, or rejected name for taxon naturalized in CA (tentative)',
'3_t' => 'accepted name for taxon occurring in CA only as a waif and/or garden escape, not naturalized (tentative)',
'3a_t' => 'taxonomic or nomenclatural synonym for taxon occurring in CA only as a waif and/or garden escape, not naturalized (tentative)',
'4_t' => 'accepted name for taxon occurring in CA only as agricultural or garden weed (tentative)',
'4a_t' => 'taxonomic or nomenclatural synonym for taxon occurring in CA only as agricultural or garden weed (tentative)',
'4b_t' => 'unpublished, invalidly published, illegitimate, or rejected name for taxon occurring in CA only as agricultural or garden weed (tentative)',
'5_t' => 'accepted name for taxon occurring in CA only as greenhouse weed (tentative)',
'5a_t' => 'taxonomic or nomenclatural synonym for taxon occurring in CA only as greenhouse weed (tentative)',
'6_t' => 'accepted name for taxon extirpated in CA (tentative)',
'6a_t' => 'taxonomic or nomenclatural synonym for taxon extirpated in CA (tentative)',
'7_t' => 'accepted name for taxon extinct (tentative)',
'7a_t' => 'taxonomic or nomenclatural synonym for taxon extinct (tentative)',
'8_t' => 'accepted name for taxon not occurring in CA (erroneous reports, misapplication of names, misidentifications, other exclusions) (tentative)',
'8a_t' => 'taxonomic or nomenclatural synonym for taxon not occurring in CA (erroneous reports, misapplication of names, misidentifications, other exclusions) (tentative)',
'9_t' => 'accepted name for plant occurring in CA only under cultivation (e.g., as crop, ornamental, or experimental plant) (tentative)',
'9a_t' => 'taxonomic or nomenclatural synonym for plant occurring in CA only under cultivation (e.g., as crop, ornamental, or experimental plant) (tentative)',
'10_t' => 'accepted name for taxonomically recognized and/or fertile hybrid; hybrid form of name (tentative)',
'10a_t' => 'accepted name for taxonomically recognized and/or fertile hybrid; non-hybrid form of name (tentative)',
'10b_t' => 'taxonomic or nomenclatural synonym for taxonomically recognized and/or fertile hybrid; hybrid form of name (tentative)',
'10c_t' => 'taxonomic or nomenclatural synonym for taxonomically recognized and/or fertile hybrid; non-hybrid form of name (tentative)',
'11_t' => 'accepted name for taxonomically not recognized and/or sterile hybrid; hybrid form of name (tentative)',
'11a_t' => 'accepted name for taxonomically not recognized and/or sterile hybrid; non-hybrid form of name (tentative)',
'14_t' => 'orthographic variant of name treated elsewhere in this list (tentative)',
'unresolved' => 'Current Status not yet established'
```

## Long format status definitions:
### A. In CA
###### Current Status: 1, accepted name for taxon native to CA
###### Current Status: 1a, taxonomic or nomenclatural synonym for taxon native to CA
###### Current Status: 1b, unpublished, invalidly published, illegitimate, or rejected name for taxon native to CA
###### Current Status: 2, accepted name for taxon naturalized in CA
###### Current Status: 2a, taxonomic or nomenclatural synonym for taxon naturalized in CA
###### Current Status: 2b, unpublished, invalidly published, illegitimate, or rejected name for taxon naturalized in CA

### B. In CA but not in CA Flora (escaped from or persistent beyond cultivation but not naturalized in CA, or occurring in cultivation in CA but only as a weed, without deliberate human fostering)

###### Current Status: 3, accepted name for taxon occurring in CA only as a waif and/or garden escape, not naturalized
###### Current Status: 3a, taxonomic or nomenclatural synonym for taxon occurring in CA only as a waif and/or garden escape, not naturalized
###### Current Status: 3b, unpublished, invalidly published, illegitimate, or rejected name for for taxon occurring in CA only as a waif and/or garden escape, not naturalized
###### Current Status: 4, accepted name for taxon occurring in CA only as an agricultural, garden, or urban weed
###### Current Status: 4a, taxonomic or nomenclatural synonym for taxon occurring in CA only as an agricultural, garden, or urban weed - tr (no records)
###### Current Status: 4b, unpublished, invalidly published, illegitimate, or rejected name for taxon occurring in CA only as an agricultural, garden, or urban weed
###### Current Status: 5, accepted name for taxon occurring in CA only as greenhouse weed - tr (no records)
###### Current Status: 5a, taxonomic or nomenclatural synonym for taxon occurring in CA only as greenhouse weed - tr (no records)

### C. Not in CA or in CA only in cultivation, under deliberate human fostering (extirpation intentional or not, of native or alien taxa)

###### Current Status: 6, accepted name for taxon extirpated in CA
###### Current Status: 6a, taxonomic or nomenclatural synonym for taxon extirpated in CA
###### Current Status: 7, accepted name for taxon extinct
###### Current Status: 7a, taxonomic or nomenclatural synonym for taxon extinct
###### Current Status: 8, accepted name for taxon not occurring in CA (erroneous reports, misapplication of names, misidentifications, other exclusions)
###### Current Status: 8a, taxonomic or nomenclatural synonym for taxon not occurring in CA (erroneous reports, misapplication of names, misidentifications, other exclusions)
###### Current Status: 8b, unpublished, invalidly published, illegitimate, or rejected name for taxon not occurring in CA (erroneous reports, misapplication of names, misidentifications, other exclusions)
###### Current Status: 9, accepted name for plant occurring in CA only under cultivation (e.g., as crop, ornamental, or experimental plant)
###### Current Status: 9a, taxonomic or nomenclatural synonym for plant occurring in CA only under cultivation (e.g., as crop, ornamental, or experimental plant)

### D. Special Categories

###### Current Status: 10, accepted name for taxonomically recognized and/or fertile hybrid; hybrid form of name
###### Current Status: 10a, accepted name for taxonomically recognized and/or fertile hybrid; non-hybrid form of name
###### Current Status: 10b, taxononomic or nomenclatural synonym for taxonomically recognized and/or fertile hybrid; hybrid form of name
###### Current Status: 10bb, unpublished, invalidly published, illegitimate, or rejected name for taxonomically recognized and/or fertile hybrid; hybrid form of name
###### Current Status: 10c, taxonomic or nomenclatural synonym for taxonomically recognized and/or fertile hybrid; non-hybrid form of name
###### Current Status: 11, taxonomically not recognized and/or sterile hybrid; hybrid form of name
###### Current Status: 11a, taxonomically not recognized and/or sterile hybrid; non-hybrid form of name
###### Current Status: 12, quadrinomial treated as trinomial elsewhere in this checklist
###### Current Status: 13, represents correction or possible correction only in spelling or rank and treated elsewhere in this checklist
###### Current Status: 14, orthographic variant of name treated elsewhere in this checklist
###### Current Status: 15, genus name
###### Current Status: 16, family name
###### Current Status: 17, unpublished, invalidly published, illegitimate, or rejected name for taxon of unknown or uncertain status with respect to the flora of California

# Details on Individual files

## JM_parseq.txt
###### Paragraph sequence index to be appended to CGI script ```get_JM_treatment.pl```
###### Made by line in ```make_interchange.pl```
```	&open_output_file($file_JM_parseq);```
		```print OUT <<EOP;```
```#Append this to  IJM.pl and upload it to /cgi-bin on Annie. It is the index to treatment paragraph offsets```
```EOP```
	```print OUT "1\n";```

## LN2C.txt:	
###### List of taxon IDs associated with each name element; appended to CGI script ```LN2C.pl```
###### Made by line in ```make_interchange.pl```:
```&open_output_file($file_LN2C);```


## flat_dbm_1.txt 
###### Taxon SMASCH IDs to Interchange contents from ```$file_cpn_out```
###### Made by line in ```make_interchange.pl```:
###### makes ```capn_db.hash``` from ```flat_dbm_1.txt```
```sub flatten_dbm {```
```	%flat_dbm=(...```

```$hashfile_capn_db => "flat_dbm_1.txt", ...```

```$hashfile_capn_db = $tempdir."capn_db.hash";```


## flat_dbm_2.txt 
###### Taxon SMASCH IDs to Jepson Manual paragraph number
###### Made by line in ```make_interchange.pl```:
###### makes ```tid_par.hash``` from ```flat_dbm_2.txt```
```sub flatten_dbm {```
```	%flat_dbm=( ...```

```$hashfile_tid_par => "flat_dbm_2.txt", ...```

```$hashfile_tid_par = $tempdir."tid_par.hash";``` 


## flat_dbm_3.txt 
###### Jepson Manual 1992 name to new Jepson Manual name
###### Made by line in ```make_interchange.pl```:
###### makes ```jmname_newname.hash``` from ```flat_dbm_3.txt```
```sub flatten_dbm {```
```	%flat_dbm=( ...```

```$hashfile_jmname_newname => "flat_dbm_3.txt", ...```

```$hashfile_jmname_newname = $tempdir."jmname_newname.hash"; ```


## flat_dbm_4.txt 
###### Taxon name to Interchange taxon ID (some added that are not in SMASCH)
###### Made by line in ```make_interchange.pl```:
###### makes ```name_to_code.hash``` from ```flat_dbm_4.txt```
```sub flatten_dbm {```
```	%flat_dbm=( ...```
```$hashfile_name_to_code => "flat_dbm_4.txt", ...```
```$hashfile_name_to_code = $tempdir."name_to_code.hash";``` 


## flat_dbm_5.txt 
###### Jepson Manual names to .... [I guess David Baxter could not tell where this goes when he wrote this]
###### Made by line in ```make_interchange.pl```:
###### makes ```JM_namehash.hash``` from ```flat_dbm_5.txt``` and places the hash in the temp directory
```sub flatten_dbm {```
```	%flat_dbm=( ...```

```$hashfile_JM_namehash => "flat_dbm_5.txt", ...```

```$hashfile_JM_namehash = $tempdir."JM_namehash.hash"; ```


## flat_dbm_6.txt  
###### Paragraph number to marked up contents of paragraph
###### Made by line in make_interchange.pl:
###### makes ```JM_treatment_h.hash``` from ```flat_dbm_6.txt```
```sub flatten_dbm {```

```	%flat_dbm=( ...```

```$hashfile_JM_treatment => "flat_dbm_6.txt"); ...```

```$hashfile_JM_treatment = $tempdir."JM_treatment_h.hash";``` 


## I_common.txt
###### Common Name parsing
```print "     7 making common name file\n";```

###### made by line in make_interchange.pl:
```&make_common_index();```


## I_treat_index_XXX.html, I_treat_indexes.html
###### HTML index files for the search and index pages for the interchange, this is the old JM edition 1 format
###### files stopped being generated 2012 (not in outpus from 2012-2015), re-appeared in 2016 outputs, and now is gone in 2017 outputs, commented out or is this a bugged?
###### made by lines in make_interchange.pl:
```print "     4 making name hash\n";```
```&make_namehash();```
###### and
```sub make_treatment_indexes {```
```##########TREATMENT INDEXES###############```


## I_index_XXX.html, and others
###### HTML index files for the index pages for the interchange, these are the updated,
###### made by line in make_interchange.pl:
```#from new_parse_cpn.pl```
```sub parse_cpn {```
###### and
```sub make_index {```
###### which is within the ```sub parse_cpn```


## I_status_XXX.html, and others
###### HTML files for each of the codes for the nativity status of the plants listed as being present in CA based on eFLora/Jepson Manual 
###### made by line in ```make_interchange.pl```:
```#from new_parse_cpn.pl```
```sub parse_cpn {```
###### and
```&make_status_index```
###### which is within the ```sub parse_cpn```


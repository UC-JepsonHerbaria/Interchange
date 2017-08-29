# Interchange

######  These are the scripts noted in the instructions for parsing the interchange text file into various html pages, text files, and hash databases.

## Updating the Interchange (files are in ~/DATA/Interchange/)
### 2017 by David Baxter
#### 1. Pull down ICPN_current.rtf from Jepson eFlora computer.
#### 2. Convert to ICPN_current.txt by opening in TextEdit and saving as a txt
#### 3. Run check_sn.pl. Outputs:
###### 	>check_sn_error.txt -> syntactical errors which will need to be addressed with Tom. 
###### May result in new formatting of code, but hopefully not
###### 	>check_sn_no_code.txt -> names which don't have a taxon id in smasch_taxon_ids.txt. Add names where appropriate, but do not bother with oddball names, as they will be assigned an arbitrary (non-persistent) TID.
#### 4. Use output to make fixes in ICPN_current.txt (and/or enumerate for Rosatti so he can fix them in his authoritative file, then pull it down again). Iterate until legitimate names are taken care of. 
###### 		>Output: CPN_out.txt
#### 5. Run make_interchange.pl, which uses CPN_out.txt as an input. This creates a directory called _input, which contains directories output, temp, log, and links. If you want to review any "warns" the script gave, they can be found in log.
###### 		>Output: a whole bunch of interchange files in _input/output
#### 6. Run tar_interchange.sh  in  _input/output
###### 		>Output: interchange.tar
#### 7. interchange.tar gets sftp'd to annie. From the user directory (i.e. where you arrive after sftp connection), cd make_interchange/undump, then put interchange.tar
###### 		>(if feeling unsure, first ssh in and cp interchange.tar old_interchange.tar
#### 8. Exit then ssh back in to make_interchange/undump, then run undump_interchange.pl. This gives a warn that tells you what files need to be need to be moved where. this is mostly covered by install.sh (everything is covered in the next two steps).
#### 9. Run install.sh
#### 10. Manually copy LN2C.pl to the cgi directory (i.e. cp LN2C.pl /usr/local/web/ucjeps_cgi/LN2C.pl).

###### Document most recently changed: 01/01/2003 01/20/2003

## Making the Online Interchange 
###### The interchange web application is constructed from the following files (on Rosatti's PC, Dick Moe's PC, the library Mac): 
#### 	1.	The main plant names index file, caplantnames.doc: This is on Rosatti's PC, where it is edited in Microsoft Word. It is a large (9M before being saved as text) tagged markup file, and can be edited with any text editor on any platform (once it is saved as text). 
#### 	2.	The Jepson manual markup file, markup_plusFT, on the library G3: this is the Jepson treatment file, originally derived from the files that produced The Jepson Manual. It is marked up in a not-yet-compliant form of XML with no DTD. It is 7M+. It has been modified to include distribution and flowering-time information from the Desert Manual, and to include some of the changes agreed upon in the Interchange. Jeff is responsible for its modification. It can be edited in any editor on any platform. The bioregion file is generated separately from this. 
#### 	3.	The smasch taxon id DBM file tnoan_db. This file is made on emma using the SQL query "select taxon_id, noauth_name from taxon_noauth_name". It must be updated periodically. The file (20+M) is used for several applications. 
#### 	4.	A table of nomenclatural variants, jmname_newname, to allow the interchange to hook up to smasch 
#### 	5.	A table of CNPS taxon_ids (cnps_taxon_ids) 
#### 	6.	Static web pages on ucjeps, interchange.html and jepson_flora_project.html 
#### 	7.	Scripts that generate lookup databases and indexes from the CPN index and JM markup
##### 	1.	c:\interchange\check_sn.pl 
##### 	2.	c:\interchange\make_interchange.pl 
##### 	3.	c:\interchange\new_parse_cpn.pl [SUPERSEDED] 
##### 	4.	c:\jepson\make_JM_treat.pl [SUPERSEDED] 

#### 	8.	cgi scripts on ucjeps--/export/home/bnhm/rlmoe/ucjeps_cgi
##### 	1.	get_jm_treatment.pl 
##### 	2.	get_cpn.pl 
##### 	3.	ln2c.pl 

#### 	9.	cgi script on herbaria24, draw_jmap.pl [this should be moved to ucjeps if the GD module is available] 

### The sequence of updating the Interchange is the following: 
#### 	1.	Get the most recent version of the treatment markup file from Jeff. Save it as text if it is not saved as text already. 
#### 	2.	Run the file through make_JM_treat.pl [perl make_JM_treat.pl], creating the DBM files JM_treatments_h and JM_namehash [SUPERSEDED] 
#### 	3.	Get most recent caplantnames.doc from Rosatti, save it in Word as text 
#### 	4.	Run it through check_sn.pl (perl check_sn.pl caplantnames.txt), creating the output file cpn.out. This will report editing errors in the file that must be addressed before continuing. Notify Rosatti about changes that have been made so that he can make them in the master file. 
#### 	5.	Run new_parse_cpn.pl [perl new_parse_cpn.pl]. This converts the Rosatti file into the database file capn_db, and produces index lists like I_index_A.html and I_status_1.html and indexes (alphabetical and by family) to treatments. Output is in c:\interchange\updates [SUPERSEDED] 
#### 	6.	Run make_interchange.pl [perl make_interchange.pl]. This converts the Rosatti file into the database file capn_db, and produces index lists like I_index_A.html and I_status_1.html and indexes (alphabetical and by family) to treatments. Output is in c:\interchange\updates 
#### 	7.	Transfer files from \interchange\update to interchange directory on ucjeps
##### 	1.	DBM files capn_db => flat_dbm_1, tid_par => flat_dbm_2, jmname_newname => flat_dbm_3, name_to_code => flat_dbm_4, JM_namehash => flat_dbm_5, /jepson/JM_treatments_h => flat_dbm_6 Transfer requires an awkward translation step, because I don't have the database library BerkeleyDB on my PC, and that is the library used on ucjeps. Therefore, the dbm files are dumped by the script to flat (key, value) files, then reconstructed on ucjeps using undump.pl. I could eliminate this step by running everything on ucjeps (that would entail moving the tnoan DBM file and CNPS table there (dumping and undumping) and transfering the two master files and the generating scripts)--is there a downside? Need to do it in an isolated directory. I'd need to modify the generating scripts to use BerkeleyDB 
##### 	2.	Index files (I_status_*.html, I_index_[A-Z].html, I_treat_index_[A-Z].html I_index_supplant.html, I_index_added.html, I_indexes.html) 
##### 	3.	Lookup strings: LN2C.out [gets appended to ln2c.pl on ucjeps], par_sequence [gets appended to get_JM_treatment.pl] 

#### 	8.	Add LN2C.out and par_sequence to cgi_scripts ln2c.pl and get_JM_treatment.pl 
#### 	9.	Add date to herb home page and JFP home page 

## Revising Interchange

### Get latest list from Rosatti
#### (FTP from ucjeps using binary fetch)

### Open list in word and save it as text

### Check list using check_sn.pl
#### 	make required corrections in CPN.out
#### 	report corrections to Rosatti

### Move last updates files to archives (I_new_entries.html; I_changed_entries.html)

### Run new_parse_cpn.pl on cpn.out

### Check DB file with check_cpn.pl

### transfer files

## Script Output and Process Notes:

### A. check_sn.pl

### B. make_interchange.pl
#### The file startes printing a README file of sorts, which as of 2017, still has these notes:
#### There are some things that need to be addressed before you proceed:
#### MODIFY spelling in CS 13 entries that are spelled correctly.
#### FIX no ID NAMES: Aloe saponaria hybrid and Encelia hybrid; Trifolium phase names
#### FIX NAME PROB Fragaria X anassia ...
#### Add CPC icon to CGI
#### Make sure I_XW is working properly with cgi scripts
#### Fix make_interchange w/r/t FNA and I_XW (generalize I_XW?)
#### Read Current names to check for additions
#### Link to ILDIS names
#### see ILDIS.txt
#### Delphinium ajacis NAME CANT BE SUPPLANTED BECAUSE IT WAS NEVER USED EXCEPT IN SYNONYMY. We need Consolida ambigua as a name supplanted by Consolida ajacis. Fix closing quote in markup.
#### Ensure that misapplied names such as Hemizonia congesta subsp. congesta trigger a @supplanted update in make_interchange
#### JUNIPERUS links from juniperus.org

## The above README text has not been updated recently, so it is not known how many of the above items the script prints out, have actually been resolved.




# Details on Individual files

## check_sn.pl
##### Script that checks the Interchange text file for error and formatting problems
###### Written by Dick Moe

## make_interchange.pl
##### Script that processes the output file from ```check_sn.pl```, called ```CPN_out.txt```
###### The 2006 version is the earliest found and has some processes that are no longer used in the 2017 version.
###### The


## make_NOMSYN_HCODES.pl
##### Script that creates a hash file, ```output/nomsyn_hcode_hash```, from the text file ```nomsyn_HCODE_cch_out.txt```
###### nomsyn_hcode_hash is the synonym and accepted name to HCODE hash file that was used by old versions of the Interchange.
###### This file used to be created by an unknown process.  The file on Annie had not been updated since 2012.
###### This file is still recreated in case there is a need for a script to use this version of the hash.
###### This file is created during the HCODE processing by the yellow flag scripts
######  Superceeded in the Interchange in 2017 by ```output/tidsyn_hcode_hash```

## make_TID_HCODES.pl
##### Script that creates a hash file, ```output/tidsyn_hcode_hash```, from the text file ```tid_HCODE_cch_out.txt```
###### tidsyn_hcode_hash is the synonym and accepted name taxon ID to HCODE hash file that is used now by the Interchange.
###### This file is created during the HCODE processing by the yellow flag scripts.  It is essential for the bioregions to display as filled in on Interchange maps.


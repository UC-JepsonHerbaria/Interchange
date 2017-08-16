Document most recently changed: 01/01/2003 01/20/2003

Making the Online Interchange 
The interchange web application is constructed from the following files (on Rosatti's PC, Dick Moe's PC, the library Mac): 
	1.	The main plant names index file, caplantnames.doc: This is on Rosatti's PC, where it is edited in Microsoft Word. It is a large (9M before being saved as text) tagged markup file, and can be edited with any text editor on any platform (once it is saved as text). 
	2.	The Jepson manual markup file, markup_plusFT, on the library G3: this is the Jepson treatment file, originally derived from the files that produced The Jepson Manual. It is marked up in a not-yet-compliant form of XML with no DTD. It is 7M+. It has been modified to include distribution and flowering-time information from the Desert Manual, and to include some of the changes agreed upon in the Interchange. Jeff is responsible for its modification. It can be edited in any editor on any platform. The bioregion file is generated separately from this. 
	3.	The smasch taxon id DBM file tnoan_db. This file is made on emma using the SQL query "select taxon_id, noauth_name from taxon_noauth_name". It must be updated periodically. The file (20+M) is used for several applications. 
	4.	A table of nomenclatural variants, jmname_newname, to allow the interchange to hook up to smasch 
	5.	A table of CNPS taxon_ids (cnps_taxon_ids) 
	6.	Static web pages on ucjeps, interchange.html and jepson_flora_project.html 
	7.	Scripts that generate lookup databases and indexes from the CPN index and JM markup
	1.	c:\interchange\check_sn.pl 
	2.	c:\interchange\make_interchange.pl 
	3.	c:\interchange\new_parse_cpn.pl [SUPERSEDED] 
	4.	c:\jepson\make_JM_treat.pl [SUPERSEDED] 
	8.	cgi scripts on ucjeps--/export/home/bnhm/rlmoe/ucjeps_cgi
	1.	get_jm_treatment.pl 
	2.	get_cpn.pl 
	3.	ln2c.pl 
	9.	cgi script on herbaria24, draw_jmap.pl [this should be moved to ucjeps if the GD module is available] 

The sequence of updating the Interchange is the following: 
	1.	Get the most recent version of the treatment markup file from Jeff. Save it as text if it is not saved as text already. 
	2.	Run the file through make_JM_treat.pl [perl make_JM_treat.pl], creating the DBM files JM_treatments_h and JM_namehash [SUPERSEDED] 
	3.	Get most recent caplantnames.doc from Rosatti, save it in Word as text 
	4.	Run it through check_sn.pl (perl check_sn.pl caplantnames.txt), creating the output file cpn.out. This will report editing errors in the file that must be addressed before continuing. Notify Rosatti about changes that have been made so that he can make them in the master file. 
	5.	Run new_parse_cpn.pl [perl new_parse_cpn.pl]. This converts the Rosatti file into the database file capn_db, and produces index lists like I_index_A.html and I_status_1.html and indexes (alphabetical and by family) to treatments. Output is in c:\interchange\updates [SUPERSEDED] 
	6.	Run make_interchange.pl [perl make_interchange.pl]. This converts the Rosatti file into the database file capn_db, and produces index lists like I_index_A.html and I_status_1.html and indexes (alphabetical and by family) to treatments. Output is in c:\interchange\updates 
	7.	Transfer files from \interchange\update to interchange directory on ucjeps
	1.	DBM files capn_db => flat_dbm_1, tid_par => flat_dbm_2, jmname_newname => flat_dbm_3, name_to_code => flat_dbm_4, JM_namehash => flat_dbm_5, /jepson/JM_treatments_h => flat_dbm_6 Transfer requires an awkward translation step, because I don't have the database library BerkeleyDB on my PC, and that is the library used on ucjeps. Therefore, the dbm files are dumped by the script to flat (key, value) files, then reconstructed on ucjeps using undump.pl. I could eliminate this step by running everything on ucjeps (that would entail moving the tnoan DBM file and CNPS table there (dumping and undumping) and transfering the two master files and the generating scripts)--is there a downside? Need to do it in an isolated directory. I'd need to modify the generating scripts to use BerkeleyDB 
	2.	Index files (I_status_*.html, I_index_[A-Z].html, I_treat_index_[A-Z].html I_index_supplant.html, I_index_added.html, I_indexes.html) 
	3.	Lookup strings: LN2C.out [gets appended to ln2c.pl on ucjeps], par_sequence [gets appended to get_JM_treatment.pl] 
	8.	Add LN2C.out and par_sequence to cgi_scripts ln2c.pl and get_JM_treatment.pl 
	9.	Add date to herb home page and JFP home page 

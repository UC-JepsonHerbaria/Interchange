# HCODE Generating Scripts

## Introduction

#### HCODES or DIST codes are strings that describe the biogeographical regions that a taxon is reported from by the treatment author.  These are strings derived from the BIOREGIONAL DISTRIBUTION tag in the eflora_treatments.txt file.

#### Proper defining and coding of the hcodes are essential for the proper map distributions to be displayed online.

#### In the beginning, only county level distributions were displayed in the Interchange.  That function is still present.  Now that 1.5 million specimens are mapped on the CCH, that distributional information is processed and passed down to maps in the eFlora and ICPN

#### The bioregion boundaries are filled in on gif maps in the Interchange through the passage of hexadecimal versions of the hcode string and the unique numerical taxon id.

#### It is possible that older versions of the Interchange website passed along this information via standardized text version of the taxon name, instead of the numerical code.  

#### Older versions of the hcode has files have only the taxon name and the hexadecimal code, which the current Interchange web site cannot parse. As per David's notes below, the creation scripts for the taxon ID and hexadecimal code hash file was lost and a general script, alter_treat_path.pl, was recommended to be used to add new codes. However, this script does not recreae the entire hcode hash.  It only modifies or deleted a limited number of records.  A new process was needed to be developed to recrreate the has file for use by the eflora and interchange, each time either was refreshed. Thus deleteing and old data from the hash, and populating the hash with new taxon data each time the files are modfied.  Thus eliminating the need for a separate, peice by peice addition and subtraction of a set of taxa and codes from the hash file.

#### Older versions of the ICPN used the hash file bioregion.hcode6 to store the accepted names/synonym names and HCODE data.  This morphed into other hash file names until 2012 when the updating of the hash file appeared to be abandoned for the ICPN (probably unintentionally just "left-in-the-dust").

#### For the maps, and other features of the JOI website as a whole, this needs to be updated whenever the eFlora HCODEs are updated.

# GIF-DRAWING
## Introduction
#### Gif-drawing scripts are in the cgi-bin on Annie. 

#### smaller version:
```draw_jmap.pl```  

#### the eflora page uses ```new_jmap.pl```. ```new_jmap.pl``` can take a URL variable ```no_legend=1``` to hide the legend.
### Examples:
```http://ucjeps.berkeley.edu/cgi-bin/draw_jmap.pl?0b40db5c01```
```http://ucjeps.berkeley.edu/cgi-bin/new_jmap.pl?0b40db5c01```
```http://ucjeps.berkeley.edu/cgi-bin/new_jmap.pl?0b40db5c01&no_legend=1```

## Lists of HCODES and HTML Color codes and Pixel positions for each of the Bioregions

#### There seems to be two lists for the coloring of the GIF image maps. I am not sure why as of August 2017 why one is used instead of the other.  For future reference each is listed herein.

### Long Form, 2015 version
```
NCo	6,34	0,100,0	North Coast	California Floristic Province
KR	26,20	107,142,35	Klamath Ranges	California Floristic Province
NCoRH	30,46	32,178,170	High North Coast Ranges California Floristic Province
NCoRI	38,66	32,178,170	Inner North Coast Ranges	California Floristic Province
NCoRO	19,41	32,178,170	Outer North Coast Ranges	California Floristic Province
CaRF	46,41	32,178,170	Cascade Range Foothills California Floristic Province
CaRH	55,36	10,125,30	High Cascade Range	California Floristic Province
nSNF	62,72	70,130,180	n Sierra Nevada Foothills	California Floristic Province
cSNF	82,101	70,130,180	c Sierra Nevada Foothills	California Floristic Province
sSNF	102,135	70,130,180	s Sierra Nevada Foothills	California Floristic Province
nSNH	72,66	30,144,255	n High Sierra Nevada	California Floristic Province
cSNH	88,93	30,144,255	c High Sierra Nevada	California Floristic Province
sSNH	107,120	30,144,255	s High Sierra Nevada	California Floristic Province
Teh	107,149	72,61,139	Tehachapi Mountain Area California Floristic Province
ScV	50,66	127,255,25	Sacramento Valley	California Floristic Province
SnJV	81,120	154,205,50	San Joaquin Valley	California Floristic Province
CCo	51,118	102,205,170	Central Coast	California Floristic Province
SnFrB	51,103	176,196,222	San Francisco Bay Area	California Floristic Province
SCoRI	60,118	69,139,116	Inner South Coast Ranges	California Floristic Province
SCoRO	77,149	69,139,116	Outer South Coast Ranges	California Floristic Province
SCo	117,171	155,48,255	South Coast	California Floristic Province
nChI	81,173	221,160,221	n Channel Islands	California Floristic Province
sChI	109,193	221,160,221	s Channel Islands	California Floristic Province
WTR	102,158	255,105,180	Western Transverse Ranges	California Floristic Province
SnGb	119,164	255,105,180	San Gabriel Mountains	California Floristic Province
SnBr	138,165	255,105,180	San Bernardino Mountains	California Floristic Province
PR	140,186	255,000,100	Peninsular Ranges	California Floristic Province
SnJt	143,175	255,000,100	San Jacinto Mountains	California Floristic Province
Wrn	72,20	255,165,0	Warner Mountains	Great Basin Province
MP	67,28	255,232,170	Modoc Plateau	Great Basin Province
WaI	110,100	250,155,15	White and Inyo Mountains	Great Basin Province
SNE	98,88	255,255,15	East of Sierra Nevada	Great Basin Province
DMtns	130,122	255,100,0	Desert Mountains	Desert Province
DMoj	140,140	255,160,122	Mojave Desert	Desert Province
DSon	165,180	255,140,0	Sonoran Desert	Desert Province
CCo	51,118	69,138,112	Central Coast	California Floristic Province
CaRF	46,41	179,214,156	Cascade Range Foothills California Floristic Province
CaRH	55,36	77,115,0	High Cascade Range	California Floristic Province
DMoj	140,140	255,235,176	Mojave Desert	Desert Province
DMtns	130,122	230,153,0	Desert Mountains	Desert Province
DSon	165,180	237,204,83	Sonoran Desert	Desert Province
KR	26,20	115,138,69	Klamath Ranges	California Floristic Province
MP	67,28	237,212,142	Modoc Plateau	Great Basin Province
NCo	6,34	38,115,0	North Coast	California Floristic Province
NCoRH	30,46	109,194,131	High North Coast Ranges California Floristic Province
NCoRI	38,66	109,194,131	Inner North Coast Ranges	California Floristic Province
NCoRO	19,41	109,194,131	Outer North Coast Ranges	California Floristic Province
PR	140,186	204,102,153	Peninsular Ranges	California Floristic Province
SCo	117,171	165,102,204	South Coast	California Floristic Province
SCoRI	60,118	69,204,170	Inner South Coast Ranges	California Floristic Province
SCoRO	77,149	69,204,170	Outer South Coast Ranges	California Floristic Province
SNE	98,88	230,230,00	East of Sierra Nevada	Great Basin Province
ScV	50,66	170,255,0	Sacramento Valley	California Floristic Province
SnBr	138,165	233,191,255	San Bernardino Mountains	California Floristic Province
SnFrB	51,103	191,255,233	San Francisco Bay Area	California Floristic Province
SnGb	119,164	233,191,255	San Gabriel Mountains	California Floristic Province
SnJV	81,120	208,255,115	San Joaquin Valley	California Floristic Province
SnJt	143,175	252,126,189	San Jacinto Mountains	California Floristic Province
Teh	107,149	156,186,214	Tehachapi Mountain Area California Floristic Province
WTR	102,158	233,191,255	Western Transverse Ranges	California Floristic Province
WaI	110,100	191,171,54	White and Inyo Mountains	Great Basin Province
Wrn	72,20	255,170,0	Warner Mountains	Great Basin Province
cSNF	82,101	122,182,245	c Sierra Nevada Foothills	California Floristic Province
cSNH	88,93	0,180,230	c High Sierra Nevada	California Floristic Province
nChI	81,173	193,156,214	n Channel Islands	California Floristic Province
nSNF	62,72	122,182,245	n Sierra Nevada Foothills	California Floristic Province
nSNH	72,66	0,180,230	n High Sierra Nevada	California Floristic Province
sChI	109,193	193,156,214	s Channel Islands	California Floristic Province
sSNF	102,135	122,182,245	s Sierra Nevada Foothills	California Floristic Province
sSNH	107,120	0,180,230	s High Sierra Nevada	California Floristic Province
```

### Short Form, 2015 version
```
CCo	51,118	96,154,131	Central Coast	California Floristic Province
CaRF	46,41	194,222,172	Cascade Range Foothills California Floristic Province
CaRH	55,36	97,136,0	High Cascade Range	California Floristic Province
DMoj	140,140	251,240,192	Mojave Desert	Desert Province
DMtns	130,122	255,100,13	Desert Mountains	Desert Province
DSon	165,180	235,216,100	Sonoran Desert	Desert Province
KR	26,20	134,157,86	Klamath Ranges	California Floristic Province
MP	67,28	236,222,160	Modoc Plateau	Great Basin Province
NCo	6,34	0,100,0	North Coast	California Floristic Province
NCoRH	30,46	137,204,149	High North Coast Ranges California Floristic Province
NCoRI	38,66	137,204,149	Inner North Coast Ranges	California Floristic Province
NCoRO	19,41	137,204,149	Outer North Coast Ranges	California Floristic Province
PR	140,186	207,123,169	Peninsular Ranges	California Floristic Province
SCo	117,171	155,48,255	South Coast	California Floristic Province
SCoRI	60,118	109,212,185	Inner South Coast Ranges	California Floristic Province
SCoRO	77,149	109,212,185	Outer South Coast Ranges	California Floristic Province
SNE	98,88	231,238,6	East of Sierra Nevada	Great Basin Province
ScV	50,66	187,255,0	Sacramento Valley	California Floristic Province
SnBr	138,165	236,202,255	San Bernardino Mountains	California Floristic Province
SnFrB	51,103	209,254,237	San Francisco Bay Area	California Floristic Province
SnGb	119,164	236,202,255	San Gabriel Mountains	California Floristic Province
SnJV	81,120	215,255,134	San Joaquin Valley	California Floristic Province
SnJt	143,175	207,123,169	San Jacinto Mountains	California Floristic Province
Teh	107,149	177,197,222	Tehachapi Mountain Area California Floristic Province
WTR	102,158	236,202,255	Western Transverse Ranges	California Floristic Province
WaI	110,100	198,178,71	White and Inyo Mountains	Great Basin Province
Wrn	72,20	255,165,0	Warner Mountains	Great Basin Province
cSNF	82,101	152,192,247	c Sierra Nevada Foothills	California Floristic Province
cSNH	88,93	78,190,234	c High Sierra Nevada	California Floristic Province
nChI	81,173	221,160,221	n Channel Islands	California Floristic Province
nSNF	62,72	152,192,247	n Sierra Nevada Foothills	California Floristic Province
nSNH	72,66	78,190,234	n High Sierra Nevada	California Floristic Province
sChI	109,193	221,160,221	s Channel Islands	California Floristic Province
sSNF	102,135	152,192,247	s Sierra Nevada Foothills	California Floristic Province
sSNH	107,120	78,190,234	s High Sierra Nevada	California Floristic Province
```

### Old Form (JPM first ed., probably)
```
CCo	137,255	102,205,170	Central Coast
CaRF	121,83	32,178,170	Cascade Range Foothills
CaRH	140,80	10,125,30	High Cascade Range
nChI	266,399	221,160,221	n Channel Islands
sChI	266,399	221,160,221	s Channel Islands
DMoj	320,315	255,160,122	Mojave Desert
DMtns	308,266	255,100,0	Desert Mountains
DSon	400,400	255,140,0	Sonoran Desert
KR	73,33	107,142,35	Klamath Ranges
MP	165,38	255,232,170	Modoc Plateau
NCo	39,73	0,100,0	North Coast
NCoRH	91,98	32,178,170	High North Coast Ranges
NCoRI	105,90	32,178,170	Inner North Coast Ranges
NCoRO	72,102	32,178,170	Outer North Coast Ranges
PR	325,406	255,000,100	Peninsular Ranges
SCo	275,369	155,48,255	South Coast Ranges
SCoRI	165,261	69,139,116	Inner South Coast Ranges
SCoRO	191,329	69,139,116	Outer South Coast Ranges
ScV	137,177	127,255,25	Sacramento Valley
SnBr	322,358	255,105,180	San Bernardino Mountains
SnFrB	136,223	176,196,222	San Francisco Bay Area
SnGb	288,356	255,105,180	San Gabriel Mountains
SNE	240,196	255,255,15	East of Sierra Nevada
SnJt	332,380	255,000,100	San Jacinto Mountains
SnJV	184,244	154,205,50	San Joaquin Valley
Teh	255,324	72,61,139	Tehachapi Mountain Area
WaI	265,213	250,155,15	White and Inyo Mountains
Wrn	181,40	255,165,0	Warner Mountains
WTR	247,344	255,105,180	Western Transverse Ranges
nSNF	159,159	70,130,180	n Sierra Nevada Foothills
nSNH	179,137	30,144,255	n High Sierra Nevada
cSNF	195,218	70,130,180	c Sierra Nevada Foothills
cSNH	218,203	30,144,255	c High Sierra Nevada
sSNF	230,250	70,130,180	s Sierra Nevada Foothills
sSNH	255,255	30,144,255	s High Sierra Nevada 
```


# Archived Older ICPN Instructions
### notes from David Baxer (from 2015) for previous versions of the ICPN)

#### Updating the distribution map codes for the eFlora
##### Dick's 2012 version of the eFlora passes this hcode value along somehow that I haven't quite plotted out.
##### David's 2015 version translates the bioregion string into the hcode at the very beginning of the process. 
##### When the eFlora raw file is parsed out and loaded into the SQLite database, the bioregion information is recorded twice: one field holds the original bioregion string, to be displayed for humans to read; the other holds the hcode which is fed straight to the gif map scripts


#### Updating the distribution map codes for the ICPN
##### The Jepson Online Interchange (JOI) map codes (referred to as $overlay_code, $hcode, dist codes, etc in get_cpn.pl) are updated separately from the normal JOI refresh.
##### Dick couldn't find the script(s) that do the full update from the eFlora, however he did find alter_data/alter_treat_path.pl. 
##### This file is now in my home directory on annie, i.e. /home/dbaxter/alter_treat_path.pl
##### In this script, data can be added to the __END__ of the script, then rerunning the script will update the coloring maps on the JOI pages


#### Updating the maps
##### If distribution strings are updated, then the kml point files that power the eflora specimen pages must be refreshed.
##### There is a hash that holds the map-drawing codes for each name.
```/usr/local/web/ucjeps_data/TJM_treat_path```
##### This is used by the eFlora (to draw maps and color kml point maps) and the Interchange (also to draw maps) [David states this but he must be mistaken or it was later changed by him.  The Interchange files in 2017 used entirely different hashes for the hcodes.  I have found two versions as described above].

#### To modify the hash:
##### -To modify a few, use alter_data/alter_treat_path.pl in the /home/rlmoe directory.
##### -To redo all, run CDL_buffer/region_gif/get_all_dist.pl, which prints the codes for all eflora treatments, then add that output to the DATA section of alter_treat_path.pl
##### [however, this updates the eFlora only and breaks the Interchange, which seems to have been "left in the dust" persay by all the changes to the eFlora in 2014-2016]

#HCODE Definitions

#### Regarding bioregion encoding, "flatten", and "hcodes"
#### the perl module ```flatten.pm``` (probably currently exists in multiple places) has functions which take the bioregion distribution strings as written in the eFlora raw file, and translates it to an array of 1s and 0s representing presence and absence in 35 bioregions. The code positions correspond to the bioregions as follows (zero-indexed):
#### ```flatten.pm``` also has a subroutine called ```get_hcode```, which encodes the 35 binary character string into a shorter hexidecimal representation (hcode = hexidecimal code). 
#### The gif maps on the Interchange and the eFlora pages use the hcode to determine which sections should be coloured in.

```
'0'==>'CCo''
'1'==>'CaRF'
'2'==>'CaRH'
'3'==>'n ChI'
'4'==>'s ChI'
'5'==>'DMoj'
'6'==>'DMtns'
'7'==>'DSon'
'8'==>'KR'
'9'==>'MP'
'10'==>'NCo'
'11'==>'NCoRH'
'12'==>'NCoRI'
'13'==>'NCoRO'
'14'==>'PR'
'15'==>'SCo'
'16'==>'SCoRI'
'17'==>'SCoRO'
'18'==>'SNE'
'19'==>'n SNF'
'20'==>'c SNF'
'21'==>'s SNF'
'22'==>'n SNH'
'23'==>'c SNH'
'24'==>'s SNH'
'25'==>'ScV'
'26'==>'SnBr'
'27'==>'SnFrB'
'28'==>'SnGb'
'29'==>'SnJV'
'30'==>'SnJt'
'31'==>'Teh'
'32'==>'WTR'
'33'==>'W&I''
'34'==>'Wrn'
```

### Example: Calochortus albus
#### bioregion string: s CaRF, n&c SN, CW, n ChI, TR, PR
##### PR = PR exc SnJt, SnJt
##### TR = WTR, SnGb, SnBr
##### n&c SN = n SNF, c SNF, n SNH, c SNH,
##### CW = CCo, SnFrB, SCoRI, SCoRO
#### bioregions included: 0,1,3,14,16,17,19,20,22,23,26,27,28,30,32
#### binary representation: 11010000000000101101101100111010100
#### C. albus hex representation: 0b40db5c01


### HCODE definitions from flatten.pm:
##### flatten6 (version 6 of the flatten program has been in used since atleast 2012 without changes until now
##### one could say due to the minor change below for Teh, this is version 6.5

##### assumes hierarchicality of SNE, DMoj, and MP
##### adds n & s ChI
##### sorts differently, ignoring latitudinal descriptors
```
@NCoR = ('NCoRO','NCoRI','NCoRH');
@CaR = ('CaRF','CaRH');
@cSN = ('cSNF', 'cSNH');
@nSN = ('nSNF', 'nSNH');
@sSN = ('sSNF', 'sSNH','Teh'); #added 'Teh' to this line recommended by Tom, because sSN by definition includes Teh, and there are taxa that have yellow flags in Teh that should not be
@SNF=('nSNF','cSNF','sSNF');
@SNH=('nSNH','cSNH','sSNH');
@SN = (@SNF,@SNH,'Teh');
@GV = ('ScV','SnJV');
@TR = ('WTR','SnGb','SnBr');
@ChI = ('nChI','sChI');
@PR = ('PR', 'SnJt');
@SW = ('SCo',@ChI,@PR,@TR);
@SCoR =  ('SCoRO','SCoRI');
@CW = (@SCoR, 'CCo','SnFrB');
@NW = (@NCoR, 'KR', 'NCo');
@MP = ('Wrn','MP');
@SNE = ('WaI','SNE');
@GB = (@MP, @SNE);
@DMoj = ('DMoj', 'DMtns');
@D = (@DMoj,'DSon');
@CA_FP = (@NW, @CaR, @SN, @GV, @CW, @SW);
@CA = (@CA_FP, @D, @GB);
```

#### alternate forms from the eflora are modified as follows:
```
	s/n (DMoj)/$1 (exc DMtns)/ unless m/DMtns/;
	s/(n SNE)/$1 (exc WaI)/ unless m/W&I/;
	s/MP \(caves in Lava[^)]+\)/MP (exc Wrn)/ unless m/Wrn/;
	s/CA-FP/CA_FP/;
	s/W&I/WaI/;
```
#### PR revisions
```
sub PRkludge{
	if(m/PR \(/){
		if (m/PR (\([^)]+\))/){
			$parens=$1;
			unless($parens =~ /San J|SnJt|scattered|desert slope/){
s/PR (\([^)]+\))/$& (exc SnJt)/ unless m/SnJt/;
				}
			}
		}
				elsif(m/n&?e PR/){
s/PR/PR (incl SnJt)/;
		}
				else{
					s/([a-z] PR)/$1 (exc SnJt)/ unless m/SnJt/;
				}
```

#### edge regions revision
```
sub edgekludge {
local($_)=@_;
$prev=$_;
s/([swen]* edge D\b)/$1 (exc DMtns)/;
s/([swen]* edge DMoj)/$1 (exc DMtns)/;
s/(D \([swen]* edge\))/$1 (exc DMtns)/;
s/(DMoj \([swen]* edge\))/$1 (exc DMtns)/;
s/PR \(D edge\)/PR (exc SnJt)/;
s/(adjacent edges D\b)/$1 (exc DMtns)/;
s/(edge of D\b)/$1 (exc DMtns)/;
s/(w edge SNE)/$1 (exc WaI)/;
```

#### adjacent regions revision
```
sub adjkludge {
local($_)=@_;
$prev=$_;
s/(adjacent [snew ]*DMoj)/$1 (exc DMtns)/;
s/ D and adjacent CA.FP/ D, PR, TR, sSN/; #used to read /D, PR, TR, Teh, sSN/, but sSN includes Teh, so this was changed also to match above
s/nSNE, adjacent CA.FP/nSNE, sSNH/;
```

#### SN revisions
```
sub SNkludge {
local($_)=@_;
#$key=$_;
s/SNE/XXX/;
s/([scn])([scnwe]+) (SN[HF]?)/$1$3/;
s/[nwsec]-([snc])\b/$1/g;
s/([scn]) (SN[^E])/$1$2/g;
s/([scn]) (SN)$/$1$2/g;
s/([scn])&([scn])(SN[HF]?)/$1$3, $2$3/g;
s/XXX/SNE/;
#$SN{$key}=$_;
s/excSN/exc SN/;
```
#### Exceptions
##### When a bioregional distribution includes an exception string 'SN exc Teh' or 'D (except DMtns)', the following code deletes the exception string from the hcode:
```
		($exception_string = $_)=~ s/.*exc[. ]+//;
		$exception_string =~ s/.*except //;

		@all_exceptions = split(/, /,$exception_string);

		foreach $exception (@all_exceptions){
			if($exception eq "coast"){
				undef($rawlocs{"CCo"});
				undef($rawlocs{"SCo"});
				undef($rawlocs{"NCo"});
				next;
			}
			undef($rawlocs{$exception}) if defined($qualified{$exception});
			grep(undef($rawlocs{$_}),@$exception) if @$exception;
		}
```



# Definitions and History of Individual Files 

## expand_hcode.pl 
#### Taxon name to Interchange taxon ID (some added that are not in SMASCH)
###### Made by line in ```make_interchange.pl```:
###### makes ```name_to_code.hash``` from ```flat_dbm_4.txt```
```sub flatten_dbm {```
```	%flat_dbm=( ...```
```$hashfile_name_to_code => "flat_dbm_4.txt", ...```
```$hashfile_name_to_code = $tempdir."name_to_code.hash";``` 


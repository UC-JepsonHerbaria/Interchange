#Make_interchange.pl
#combining Make_JMreat.pl and new_parse_cpn.pl
#Jan 20, 2003. Apparently working
#see make_interchange_readme
#altered May 4
#altered Sep 2 2003
use flatten;
open(IN,"Smasch_tid")|| die;
while(<IN>){
next unless/\d/;
	chomp;
	$SMASCH_LINK{$_}++;
}
close(IN);

open(IN,"add_updates") || die;
print <<EOP;
There are some things that need to be addressed before you proceed
EOP
{
local($/)="";
while(<IN>){
next if /(DONE|done)/;
print;
}
close(IN);
print <<EOP;
type "G<return>" to proceed, anything else to quit
EOP
}
$/="\n";
%I_XW=();
$response=<>;
die unless $response=~/G/;

$cpn_file="/interchange/cpn.out";
%CPNNOAN=();
%CP=();
%eppc_link=();
%fna_link=();
$outdir="c:/interchange/update/";
$corrections="I_XW";
$treat_file="new_markup";
$treat_hash="/jepson/JM_treatment_h";
	unlink $treat_hash;
$JMtreat_index="get_JMtreat_index";
$tnoan_file="/interchange/TNOAN_DB";

$page_top= qq{<a href="/jepson_flora_project.html">Jepson&nbsp;Flora Project</a>: <a href="/interchange/index.html">Jepson Interchange</a>};
$page_top=<<EOPT;
<table bgcolor="#f0f0f0" align="left" width="100%">
<TR>
<TD>
<font size=3>
&nbsp;
&nbsp;
<strong>
$page_top
</strong>
&nbsp;
&nbsp;
</font>
</td>
</tr>
</table>
EOPT
use DB_File;

warn "0\n";
	tie(%TNOAN, 'DB_File',$tnoan_file) || die;
{
	open(IN, "current_names") || die;
	local($/)="";
	while(<IN>){
		next unless m/Current [Nn]ame: ...../;
		next if /^#/;
		($syn,$current)=m/^(.*)\nCurrent [Nn]ame: (....*)/;
		if ($syn=~/\[misapplied\]/){
			#warn "SKIPPING MISAPPLICATION: $syn\n";
			next;
		}
		$syn=&strip_name($syn);
		$current=&strip_name($current);
		$cn_of_syn{$TNOAN{$syn}}=$current;
$this_is_current{$current}=$current;
	}
}
&make_cpn_id();
warn "1 loading links\n";
&load_links();
warn "2 making treatment hash\n";
&make_treatment_hash();
#die "made treatment hash: dieing\n";
warn "3 linking taxon_id to treatments\n";
&link_tID_to_treatment();
warn "4 making name hash\n";
&make_namehash();
warn "5 parsing the plant name index\n";
&parse_cpn();
warn "6 making treatment indexes\n";
&make_treatment_indexes();
warn "7 making common name file\n";
&make_common_index();
warn "8 making maps\n";
&flatten_dbm();

	untie(%TNOAN);

#0
sub make_cpn_id {
#This is an arbitrary number that starts a sequence of taxon_ids given
#to names not in smasch. Note that the same name can receive different
#ids in different invocations of this script
	$cpn_count=88000;
	open(IN,$cpn_file) || die;
	local($/)="";
	while(<IN>){
		next if 1 .. /PTERIDOPH/;
if (&next_cpn_line($_)){
#warn "make_cpn_id: skipping $_\n";
	next;
}
		$cpnnoan=&get_nan($_);
		$CPNNOAN{$cpnnoan}=($TNOAN{$cpnnoan} || ++$cpn_count);
	}
	close(IN);

#names not in smasch and not in CPN
foreach $cpnnoan (
"Allium diabloense",
"Carex hystricina",
"Phlox cespitosa",
"Ulex europaea"
){
		$CPNNOAN{$cpnnoan}=++$cpn_count;
		warn join("\t",$cpnnoan, $CPNNOAN{$cpnnoan}, $cpn_count, "\n");
}
}

open(OUT, ">hcodes.tmp" || die);
foreach(sort {$a<=>$b} (keys(%overlay))){
print OUT "$_: $overlay{$_}\n";
}

#1
sub load_links{
	open(IN,$corrections) || die;
	local($/)="\n";
	while(<IN>){
		chomp;
		next if m/^#/;
		next unless ($I_name,$L_name,$name_links)= split(/ *=> */);
		@name_links=split(/; */,$name_links);
#I_XW{12345}{SMASCH}=smasch_name
		foreach(@name_links){
			if($CPNNOAN{$I_name}){
				$I_XW_backlink{$L_name}{$_}= $CPNNOAN{$I_name};
#warn <<EOP;
#$name_links
#$I_name
#$L_name
#CPNNOAN{I_name}: $CPNNOAN{$I_name}
#namelink: $_
#backlink: $I_XW_backlink{$L_name}{$_}
#EOP
			}
			else{
				warn "no code for $I_name\n";
			}
		}
	}

	close(IN);
local($/)="\n";
open(IN,"cpc_links") || die;
while(<IN>){
	next unless/\t/;
	chomp;
@cpc=split(/\t/);
$link='<a href="http://ridgwaydb.mobot.org/cpcweb/CPC_ViewProfile.asp?CPCNum=' . "$cpc[1]" . '">Center for Plant Conservation</a>';
$cpc_link{$cpc[0]}=$link;
}
open(IN,"weed_links") || die;
while(<IN>){
	next unless/\t/;
	chomp;
	($weed_name,$link)=split(/\t/);

	if ($CPNNOAN{$weed_name}){
		$weed_link{$CPNNOAN{$weed_name}}=qq{${link}State of California Weed Information</a>};
	}
	else{
push(@no_link, "WEED: $weed_name not found in interchange\n");
	}
}

open(IN,"eppc_links") || die;
while(<IN>){
	next unless/\t/;
	chomp;
	($eppc_name,$link)=split(/\t/);

	if ($CPNNOAN{$eppc_name}){
		$eppc_link{$CPNNOAN{$eppc_name}}=qq{<a href=\"$link\">California Exotic Pest Plant Council</a>};
	}
	else{
		#print "EPPC: $eppc_name not found in interchange\n";
push(@no_link, "EPPC: $eppc_name not found in interchange\n");
	}
}

close(IN);
#foreach(keys(%eppc_link)){
#print "EL: $_: $eppc_link{$_}\n";
#}


       use LWP::Simple;
 $doc = get 'http://elib.cs.berkeley.edu/photos/plant_taxon_list.txt';
die "problem with CalPhotos list\n" unless length($doc) > 10000;
$doc=~s/\|.*//g;
open(OUT, ">cal_photos_list.IN");
print OUT $doc;
#open(IN,"calphotos_plant_taxa.txt") || die;
open(IN,"cal_photos_list.IN") || die;
while(<IN>){
	#next unless/\|/;
	chomp;
	$cpname=$_;
	#($cpname,$variant)=split(/\|/);
	foreach($cpname){
		s/ssp\./subsp./;
		s/ sp\..*//;
	}
	if($CPNNOAN{$cpname}){
		$CP{$CPNNOAN{$cpname}}++;
	}
	#elsif($CPNNOAN{$variant}){
		#$CP{$CPNNOAN{$variant}}++;
##for this to work, the variant needs to be the Interchange name and the link needs to be connected to the cp name
	#}
else{	push(@no_link, "CP: $cpname not found in interchange\n");}
}
close(IN);

open(IN,"fna_calif_links") || die;
while(<IN>){
	chomp;
	if(m/^LINK TEXT/){
		($link_text)=m/LINK TEXT	(.*)/;
		next;
	}
	elsif(m/^LINK/){
		($link)=m/LINK	(.*)/;
		next;
	}
	($fna_taxon_id,$fna_name)=split(/\t/);
foreach($fna_name){
s/alpinaus/alpina/;
s/Ã— ?/ × /;
s/ x / × /;
s/  / /g;
}

	if ($CPNNOAN{$fna_name}){
		$fna_link{$CPNNOAN{$fna_name}}= qq{<a href="${link}$fna_taxon_id">$link_text</a>};
	}
				#$I_XW_backlink{$L_name}{$_}= $CPNNOAN{$I_name};
elsif ($I_XW_backlink{$fna_name}{'FNA'}){
#warn " backlink: $fna_name $I_XW_backlink{$fna_name}{'FNA'}\n";
		$fna_link{$I_XW_backlink{$fna_name}{'FNA'}}= qq{<a href="${link}$fna_taxon_id">$link_text</a>};
		#warn $fna_link{$I_XW_backlink{$fna_name}{'FNA'}};
}
	else{
push(@no_link, "FNA: $fna_name not found in interchange\n");
	}
}

open(IN,"ildis.txt") || die;
while(<IN>){
next unless m/'California'/;
chomp;
s/^'//;
s/'$//;
@fields=split(/','/);
$ildis_name=join(" ",@fields[0, 1]);
	if ($CPNNOAN{$ildis_name}){
		$ildis_link{$CPNNOAN{$ildis_name}}= qq{<a href="http://biodiversity.soton.ac.uk/cgi-bin/Araneus.pl?genus~$fields[0]&species~$fields[1]">ILDIS World Database of Legumes</a>};
}
else{
push(@no_link, "ILDIS: $ildis_name not found in interchange\n");
}
}
open(IN,"/jepson/make_plantlist/usda_variant") || die;
while(<IN>){
	next unless m/->/;
	chomp;
	($jm_name,$usda_name)=split(/-> /);
	$usda_name=&strip_name($usda_name);
	$JMNAME{$usda_name}=$jm_name;
}

open(IN,"/jepson/make_plantlist/plantlist.text") || die "couldnt open USDA plantlist.text\n";
while(<IN>){
s/ssp\./subsp./g;
	($code,$name)=m/^"([^"]+)","([^"]+)/;
	$name=~s/\?//g;
	$sname=&strip_name($name);
	if ($CPNNOAN{$sname}){
		$plants_link{$CPNNOAN{$sname}}= qq{PLANTS $code};
}
	elsif($JMNAME{$sname}){
		$plants_link{$JMNAME{$sname}}= qq{PLANTS $code};
	}
else{
#push(@no_link, "USDA Plants: $sname not found in interchange\n");
}
}


	close(IN);

local($/)="";
open(IN,"fedlist.txt") || die "couldn't open USFW page: fedlist.txt\n";
#<TR><TD VALIGN=TOP>T </TD><TD>Thornmint, San Diego (<A HREF=/SpeciesProfile?spcode=Q00E> <EM>Acanthomintha ilicifolia</EM></A>)</TD></TR>
while(<IN>){
next if 1 .. /H4>Plants/;
if(m!<A HREF=/SpeciesProfile\?spcode=([^>]+)>(.*)</A>!){
$f_code=$1; $name=$2;
foreach($name){
s/<\/?EM>//g;
s/\(.*\)//;
s/  */ /g;
s/^ *//;
s/ *$//;
s/ssp\./subsp./;
s/Arabis mcdonaldiana/Arabis macdonaldiana/;
s/Arctostaphylos hookeri var. ravenii/Arctostaphylos hookeri subsp. ravenii/;
s/Astragalus clarianus/Astragalus claranus/;
s/Ceanothus ferrisae/Ceanothus ferrisiae/;
s/Lotus dendroideus subsp. traskiae/Lotus dendroideus var. traskiae/;
s/Phacelia insularis subsp. insularis/Phacelia insularis var. insularis/;
s/Rorippa gambellii/Rorippa gambelii/;
}
	if ($CPNNOAN{$name}){
		$usfw_link{$CPNNOAN{$name}}= qq{<a href="http://ecos.fws.gov/species_profile/SpeciesProfile?spcode=$f_code">U.S. Fish and Wildlife Service</a>};
}
else{
push(@no_link, "USFW: $name not found in interchange\n");
}
}
}
close(IN);
open(IN,"protologue.log") || die "couldnt open protologue file\n";
local($/)="\n";
while(<IN>){
next unless /\t/;
chomp;
($name,$link)=split(/\t/);
push(@proto_link,"$name\t$link");
	if ($CPNNOAN{$name}){
		$proto_link{$CPNNOAN{$name}}= qq{<a href="/archives/muhlenbergia/${link}.tif">Protologue</a>};
}
else{
push(@no_link, "Protologue: $name not found in interchange\n");
}
}
close(IN);
}

#2
sub make_treatment_hash{
	open(OUT,">$JMtreat_index") || die;

	open(IN, "$treat_file") || die;
	use DB_File;
	tie(%TREAT, 'DB_File',$treat_hash, O_CREAT|O_RDWR, 0666, $DB_HASH) || die;
	local($/)="";
	$parno= 0;
	$TREAT{$parno}="";
	while(<IN>){
$context=$_;
 if (m/^<comment/){
#warn $_;
next;
}
die $_ unless m/<desc/;
#s/<hort_lf.*<\/hort_lf>//g;
s/<hort_old.*<\/hort_old>//g;

if(m|<NDS[^>]*>([^<]+)</NDS>|){
$nds=$1;
$hc=&get_hcode($nds);
die " return hcode problem\n" unless length($hc)==10;
s|<HCODE>[^<]*</HCODE>|<HCODE>$hc</HCODE>| ||
s|</NDS>|</NDS>\n<HCODE>$hc</HCODE>| ||
die "match hcode problem\nNDS=$nds\nHC=$hc\n$context";
}


#remove this
#s/<ECOLOGY>\s*(<ENDANGERED>.*<\/ENDANGERED>.) */$1<ECOLOGY>/;
s/<(ENDANGERED|R_STATUS)>.*<\/(ENDANGERED|R_STATUS)>\.*//;
#s/<(ENDANGERED|R_STATUS)>.*<\/(ENDANGERED|R_STATUS>)\.*//;



		if(m/<common_name[^>]+>([^<]+)</){
			$CN=$1;
		}
		else{$CN="";}
		s/\n/ /g;
		if(m/<family_par>/){
			($family_name)=m|<family_name>\s(.*) *\s</family_name>|;
			($TREAT{++$parno}=$_)=~s/\n/ /g;
			print OUT "\n$family_name\t$CN => $parno\n";
			$last_fam=$parno;
		}
		elsif(m/<genus_par>/){
$GCN=$CN;
			($TREAT{++$parno}=$_)=~s/\n/ /g;
 			($genus_name)=m|<genus_name>([^ ]+).*</genus_name>|;
			print OUT "$genus_name\t$CN => $last_fam,$parno\n";
			$last_gen=$parno;
			($genus)=m/<genus_name[^>]*>([^<]+)<\/genus_name>/;
$common_name{$GCN}=$parno if $CN;
		}
		elsif(m/sp_par>/){
			if(m!<(phase|infrasp)_name[^>]*>([^<]+)</(phase|infrasp)_name>!){
				$infra=$2;
				($TREAT{++$parno}=$_)=~s/\n/ /g;
				if ($CN){
					$common_name{$CN}=$parno;
				}
				elsif($GCN){
					$common_name{$GCN}.="$parno,";
				}
				if(m/"full_name"/){
					$infra=~s/[A-Z]\./$genus/;
					$last_sp=0;
					($species_only=$infra)=~s/([A-Z]+ [a-z-]+).*/\u\L$1/;
#Uncomment following line to allow links to species also
$species_only=~s/ *$//;
					$species_only=~s/&mathx;/× /;
					print OUT "$species_only => $last_fam,$last_gen,$last_sp,$parno\n";
				if(m/<HCODE>(.*)<\/HCODE>/){
					$hcode=$1;
		$overlay{$CPNNOAN{$species_only}}=$hcode;
		$overlay{$TNOAN{$species_only}}=$hcode;
		$overlay{$JM_to_CPN{$species_only}}=$hcode;
}
				}
				else{
					$infra= "$species $infra";
				}
				$infra=~s/^([^ ]+ [^ ]+).* (var\.|ssp\.|f\.|subsp\. .*)/$1 $2/;
				$infra=~s/([^ ]+)/\u\L$1/;
				($infra_sub=$infra)=~s/ssp\./subsp./;
				$infra_sub=~s/  +/ /g;
				$infra_sub=~s/ *$//g;
	$infra_sub=~s/&mathx;/× /;
				print OUT "$infra_sub\t$CN => $last_fam,$last_gen,$last_sp,$parno\n";
				if(m/<HCODE>(.*)<\/HCODE>/){
					$hcode=$1;
		$overlay{$CPNNOAN{$infra_sub}}=$hcode;
		$overlay{$TNOAN{$infra_sub}}=$hcode;
		$overlay{$JM_to_CPN{$infra_sub}}=$hcode;
}
			}
			else{
				($TREAT{++$parno}=$_)=~s/\n/ /g;
if ($CN){
$common_name{$CN}=$parno;
}
elsif($GCN){
$common_name{$GCN}.="$parno,";
}
	##print "$parno:  $last_gen $last_fam\n";
				($species)=m|<sp_name[^>]*>([^<]+)</sp_name>|;
				$species=~s/^[A-Z]\./$genus/;
				$species=~s/([^ ]+)/\u\L$1/;
				$species=~s/  +/ /g;
				$species=~s/ *$//g;
	$species=~s/&mathx;/× /;
foreach($species){
	s/Fragaria .*ananassa .*cuneifolia.*/Fragaria × ananassa var. cuneifolia/ ||
	#s/Trifolium variegatum .*phase (\d)/Trifolium variegatum phase $1/ ||
s/A.* saponaria .* striata .*/Aloe saponaria × Aloe striata/ ||
s/Encelia farinosa .*frutescens/Encelia farinosa × Encelia frutescens/ ;
}
				print OUT "$species\t$CN => $last_fam,$last_gen,$parno\n";
				if(m/<HCODE>(.*)<\/HCODE>/){
					$hcode=$1;
		$overlay{$CPNNOAN{$species}}=$hcode;
		$overlay{$TNOAN{$species}}=$hcode;
		$overlay{$JM_to_CPN{$species}}=$hcode;
}
				$last_sp=$parno;
			}
		}
	}
	close(OUT);

#while(($tid, $hc)=each(%overlay)){
#print "$tid: $hc\n";
#}
#die;
}
#3
sub link_tID_to_treatment {
	open(OUT, ">TID_to_JMrecno") || die;
	open(IN,$corrections) || die;
	local($/)="\n";
	while(<IN>){
		chomp;
		next if m/^#/;
		next unless ($I_name,$L_name,$name_links)= split(/ *=> */);
		@name_links=split(/; */,$name_links);
#I_XW{12345}{SMASCH}=smasch_name
		foreach(@name_links){
#warn "$I_name$_\n" if $I_name=~/ferrisiae/;
			if($CPNNOAN{$I_name}){
#warn "$I_name$CPNNOAN{$I_name}\n" if $I_name=~/ferrisiae/;
				$I_XW{$CPNNOAN{$I_name}}{$_}=&strip_name($L_name);
#warn "$I_XW{$CPNNOAN{$I_name}}{$_}\n" if $I_name=~/ferrisiae/;
				if(m/^JM$/){
					$JM_to_CPN{$L_name}= $CPNNOAN{$I_name};
				}
			}
			else{
				warn "no code for $I_name\n";
			}
		}
	}

	close(IN);

	open(IN,"$JMtreat_index") || die;
	while(<IN>){
		next if /^$/;
		chomp;
		($name,$pars)=split(/ => /,$_);
		$name=~s/ *$//;
		$name=~s/ *\t.*//;
		$name=~s/  / /g;
unless($name=~m/Aloe saponaria . Aloe striata/ ||
$name=~m/Encelia farinosa . Encelia frutescens/){
			$name=ucfirst(lc($name));
}
foreach($name){
	s/&mathx;/× /;
	s/&euml;/e/;
	if($CPNNOAN{$name}){
		print OUT "$CPNNOAN{$name}\t$pars\n";
	}
	elsif( $TNOAN{$name}){
		print OUT "$TNOAN{$name}\t$pars\n";
	}
	elsif( $JM_to_CPN{$name}){
		print OUT "$JM_to_CPN{$name}\t$pars\n";
	}
	else{
		warn "no ID for $name\n";
		print OUT "\t$pars\n";
}
}
		#eval ($name_subs);
	}
	close(IN);
	close(OUT);
}

#4
sub make_namehash {
	$file="JM_namehash";
	unlink($file);
	tie(%name_hash, 'DB_File',$file, O_CREAT|O_RDWR, 0666, $DB_HASH) || die;
	%name_hash=();
	local($/)="";
	open(IN,"$JMtreat_index") || die;
	open(OUT, ">${outdir}I_treat_indexes.html") || die;
	print OUT &make_family_header();

	while(<IN>){
		chomp;
		@lines=split(/\n/);
		$family=shift(@lines);
		$family=~s/ =.*//;
		($family_only=$family) =~s/\t.*//;
		$family=lc($family);
		$family=~s/^([^ \t]+)/\U$1/;
		$family=~s/([\t ])(.)/$1\u$2/g;
		$family=~s/\t/&nbsp;&middot;&nbsp;/;
		if ($family=~/CUPRESSACEAE/){
			print OUT<<EOP;
<P>&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; <strong>
Gymnosperms and Gnetophytes
</strong>
EOP
		}
		elsif ($family=~/ACANTHACEAE/){
		print OUT<<EOP;
<P>&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; <strong>
Dicots
</strong>
EOP
		}
		elsif ($family=~/ALISMATACEAE/){
		print OUT<<EOP;
<P>&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; <strong>
Monocots
</strong>
EOP
		}
		print OUT <<EOP;
<LI><a href="/cgi-bin/get_JM_treatment.pl?$family_only">$family</a>
EOP
		foreach(@lines){
			s/\t.*=>/ =>/; #remove common name
				if(m/(^[A-Z][A-Z][^ ]+)/){
					$genus=$1;
					$name_hash{$family_only} .= "$genus\t";
				}
				else{
					$name_hash{$genus} .= "$_\t";
				}
			}
		}
		print OUT <<EOP;
 </ul> </oL> <br>
EOP
	print OUT &make_trailer();

	close(IN);
	close(OUT);
	untie(%TREAT);
	untie(%name_hash);
	open(OUT,">${outdir}/JM_parseq") || die;
		print OUT <<EOP;
append this to /cgi-bin/get_JM_treatment.pl. It is the index to treatment paragraph offsets
EOP
	print OUT "1\n";
	open(IN, "TID_to_JMrecno") || die;
	local($/)="\n";
	while(<IN>){
		s/.*\t//;
####added back
		#chomp;
		#($taxon_id,$pars)=m/(.*)\t(.*)/;
		#next unless $taxon_id;
		#$TID{$taxon_id}=$pars;
		#print OUT "$_\n" unless $seen{$_}++;
######
		print OUT unless $seen{$_}++;
		}
}


#5 from new_parse_cpn.pl
sub parse_cpn {
	%already_seen=();
	%seen=();
	unlink("jmname_newname");

	#cnps_taxon_ids contains smasch taxon_ids of CNPS names
	$mfile="cnps_taxon_ids";
	$mdate= int(-M $mfile);
	print "$mfile modified $mdate days ago\n";

	open(IN,"cnps_taxon_ids") || die;
	while(<IN>){
		chomp;
		++$CNPS{$_};
	}
	close(IN);







	$today=localtime();
$today=~s/^... //;
$today=~s/\d+:\d+:\d+//;
	($archive=$today)=~s/\s/_/g;
	#open(ARCHIVE,">>I_archive") || die;
	#print ARCHIVE "$today\n";

	%seen=();
	$ucjeps_path="http://ucjeps.berkeley.edu";

	$header=<<EOP;
<table width=100% bgcolor="#0000cc">
<tr>
<TD align="center"><font size=6 color="#ffdd00">
<font size=3>Jepson Flora Project</font><P>
<font size=7>J</font>EPSON
<font size=7>O</font>NLINE
<font size=7>I</font>NTERCHANGE
</font>
</td>
<td><img src="${ucjeps_path}/jeps.gif" align=right alt="jeps logo"></td>
</td>
</tr>
</table>
EOP

#####################################################################
#formerly commented out
##/jepson/TID_to_JMrecno contains smasch taxon_id followed by paragraph
## number in Jepson Manual Markup.
	#$mfile="/jepson/TID_to_JMrecno";
	$mfile="TID_to_JMrecno";
	open(IN,$mfile) || die;
	#open(OUT, ">${outdir}par_sequence") || die;
	#print OUT "1\n";
	while(<IN>){
		chomp;
		($taxon_id,$pars)=m/(.*)\t(.*)/;
	##print "$taxon_id==>$pars\n";
		next unless $taxon_id;
		$TID{$taxon_id}=$pars;
		#print OUT $pars, "\n" unless $seen_par{$pars}++;
	}
	close(IN);
	#close(OUT);
#########################################################################
unlink("tid_par") || die;
	tie(%TID_TO_PAR, 'DB_File',"tid_par", O_CREAT|O_RDWR, 0666) || die;
	tie(%XREF, 'DB_File',"jmname_newname", O_CREAT|O_RDWR, 0666) || die;
	while(($taxon_id,$JM_paragraphs)=each(%TID)){
		$TID_TO_PAR{$taxon_id}=$JM_paragraphs;
	#print "$key: $value\n";
	}

	%Current_Status=(
'1' => 'accepted name for taxon native to CA',
'1a' => 'taxonomic or nomenclatural synonym for taxon native to CA',
'1b' => 'unpublished, invalidly published, illegitimate, or rejected name for taxon native to CA',
'2' => 'accepted name for taxon naturalized in CA',
'2a' => 'taxonomic or nomenclatural synonym for taxon naturalized in CA',
'2b' => 'unpublished, invalidly published, illegitimate, or rejected name for taxon naturalized in CA',
'3' => 'accepted name for taxon occurring in CA only as a waif and/or garden escape, not naturalized',
'3a' => 'taxonomic or nomenclatural synonym for taxon occurring in CA only as a waif and/or garden escape, not naturalized',
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
'9' => 'accepted name for plant occurring in CA only under cultivation (e.g., as crop, ornamental, or experimental plant)',
'9a' => 'taxonomic or nomenclatural synonym for plant occurring in CA only under cultivation (e.g., as crop, ornamental, or experimental plant)',
'10' => 'accepted name for taxonomically recognized and/or fertile hybrid; hybrid form of name',
'10a' => 'accepted name for taxonomically recognized and/or fertile hybrid; non-hybrid form of name',
'10b' => 'taxonomic or nomenclatural synonym for taxonomically recognized and/or fertile hybrid; hybrid form of name',
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
'unresolved' => 'Current Status not yet established',
	);

unlink("capn_db") || die;
	tie(%CAPN, "DB_File", "capn_db", O_RDWR|O_CREAT,0666) || die;
	tie(%NAME_CODE, "DB_File", "name_to_code", O_RDWR|O_CREAT,0666) || die;
	%NAME_CODE=();
	%CAPN=();

	print <<EOP;
This script reads from cpn.out, a file created from the caplantnames index
by "check_sn.pl"
EOP
	$mfile="cpn.out";
	$mdate= int(-M $mfile);
	print "$mfile modified $mdate days ago\n";
	open(IN, "cpn.out") || die;
	local($/)="";
ENTRY:
	while(<IN>){
#s/LINK:.*FNA.*\n//;
		s/--->//g;
		$SM=$CS="";
		($CS)=m/\nCurrent Status: *(.*)/;
if  (1 .. /PTERIDOPH/){
#warn "$.: skipping initial $_\n";
		next ENTRY;
}
if (&next_cpn_line($_)){
		next ENTRY;
#warn "$.: skipping next_cpn_line: $_\n";
}
if ($CS=~/^12/){
#warn "$.: skipping CS12: $_\n";
		next ENTRY;
}
		$open= s/<sn>/<sn>/g;
		$close= s|</sn>|</sn>|g;
		die "<SN> problem: open: $open close $close\n$_ " unless $open==$close;
		chomp;
		s/  +/ /g;
		($name)=m/^(.*)/;
		s/\n-?done.*//;
		@lines=split(/\n/, $_, 100);
		grep(s/ +$//,@lines);
#author notes now part of markup
		#if($lines[0]=~/\) *$/){
		#if($lines[0]=~s/(.*) (\([^)]+\) \([^)]+\)) *$/$1/){
			#splice(@lines,1,0,"AN: $2");
		#}
		#elsif($lines[0]=~s/(.*) \(([^)]+)\) *$/$1/){
			#splice(@lines,1,0,"AN: $2");
		#}
		#elsif($lines[0]=~s/ \([^)]+\)[^(]+\(([^(]+)\)$//){
			#splice(@lines,1,0,"AN: $1");
		#}
		#elsif($lines[0]=~s/ \(([^)]+)\)$//){
			#splice(@lines,1,0,"AN: $1");
		#}
		#elsif($lines[0]=~s/ \(([^(]+\).*)\)$//){
			#splice(@lines,1,0,"AN: $1");
		#}
#}
##		if($lines[0]=~s/ \([^)]+\)[^(]+\(([^)]+)\)$//){
##			splice(@lines,1,0,"AN: $1");
##		}
##		elsif($lines[0]=~s/ \([^)]+\)[^(]+\(([^(]+)\)$//){
##			splice(@lines,1,0,"AN: $1");
##		}
##		elsif($lines[0]=~s/ \(([^)]+)\)$//){
##			splice(@lines,1,0,"AN: $1");
##		}
##		elsif($lines[0]=~s/ \(([^(]+\).*)\)$//){
##			splice(@lines,1,0,"AN: $1");
##		}
		$NAN=&strip_name($lines[0]);
if ($already_seen{$NAN}++){
($Current_Status=$CS)=~s/,.*//;
		warn "Orthography order problem: Already saw $NAN status $Current_Status\n" if $Current_Status =~/13/;
}
		($initial=$NAN)=~s/^(.).*/$1/;
		$taxon_id = $CPNNOAN{$NAN};
		if($cn_of_syn{$taxon_id}){
			unless (m/Current [Nn]ame: ...../ || m/Current [Nn]ame \(T\): ....../){
				if(m/Current Status.*tentative/){
					push(@lines,"Current name (T): $cn_of_syn{$taxon_id}");
				}
				else{
					push(@lines,"Current name: $cn_of_syn{$taxon_id}");
				}
			}
	
		}

		foreach (@lines[1 .. $#lines]){
if(m/^-?done/){
#warn "$.: skipping done: $_\n";

			next;
}
		#local($_)=$lines[$i];
		#print "$_\n";
			s/^ +//;
			(s/^Effort: */EF: / ||
			s/^Author [Nn]otes: */AN: / ||
			s/^Family: */FA: / ||
			s/^Source: */SR: / ||
			s/^Source ([a-z]) *: */SR$1: / ||
			s/^Summary: */SM: / ||
			s/^Notes on Publication of Name: */POP: / ||
			s/^[DP]AO[PD]O?P: */POP: / ||
			s/^[PD]OPO[BC]: */POP: / ||
			s/^[DP]OP: */POP: / ||
			s/^KM citation: */KMC: / ||
			s/^Comments?: */CT: / ||
			s/^Editorial Comments? ([0-9-]+): */CTE$1: / ||
			s/^Assigned to: */AT: / ||
			s/^Assignment date: */AD: / ||
			s/^Current Status Authority: */CSA: / ||
			s/^Current Status: *(\d+[a-z]?).*/CS: $1/ ||
			s/^Current Status: *tentative (\d+[a-z]?).*/CS: $1_t/ ||
			#s/^Current Status: *tentative (\d+[a-z]?).*/CS: $1_[t]/ ||
			s/^Current Status: */CS: / ||
			s/^Current Status Date: */DD: / ||
			s/^Decision [Dd]ate: */DD: / ||
			s/Correspondence: */CR: / ||
			s/Correspondence ([0-9]+): */CR$1: / ||
			s!^TJM synonyms: *!TSN: ! ||
			s!^TJM2 synonyms: *!TSN2: ! ||
			s!^Current JFP synonyms: *!JFPS: ! ||
			s!^TJD?M misapplied names: *!TMN: ! ||
			s/^Literature: */RL: / ||
			s/^Literature ([a-z]): */RL$1: / ||
			s/^Recent Literature: */RL: / ||
			s/^Recent Literature ([a-z]): */RL$1: / ||
			s/^Geography: */GG: / ||
			s/^Variant [sS]pelling: */VS: / ||
			s/^AN: /AN: /  ||
			s/^Synonyms not explicitly cited in TJM: /SNTJM: /)  ||
			s/^LINK: /LINK: /  ||
			s/^Types Info: /TI: /  ||
			s/^Current [Nn]ame: /CN: /  ||
			s/^Current [Nn]ame \(T\): /CN_T: /  ||
do{
			warn "no substitution $NAN $_\n";
push(@nosub, "$NAN $_");
};
			if(m/^FA: +(.*)/){
$family=$1;
}
			if(m/^KMC: .*\.$/){
s/\.$//;
}
			if(m/^VS: +(.*)/){
		$NAME_CODE{$1}=$taxon_id;
}
			if(m/^CS: +(.*)/){
				#($CS=$1)=~s/ \[t\]//;
				$CS=$1;
if($this_is_current{$NAN}){
				$CS=~s/_t//;
}
				$add_index{$CS}.=<<EOP;
$NAN\t$taxon_id
EOP
#warn "NAN: $NAN: $taxon_id\n";
			}
			if(m/(SM[^\t]+)/){
				$SM=$1;
				if(((m/SM.*rejection.*replacement/ ||
				m/SM.*reject.*different genus,? .*since TJM/ ||
				m/SM.*rejection.*treated as syn since/) &!
				m/SM.*possible rejection/)){
					unless($CS=~ m/unresolved|tentative/){
@xs_ref=();
$xs_ref="";
						if((@xs_ref)=grep(/Current [Nn]ame: .+/,@lines)){
							($xs_ref=$xs_ref[0])=~s/Current [Nn]ame: //;
							$xs_ref=&strip_name($xs_ref);
						}
						elsif((@xs_ref)=grep(/Current [Nn]ame \(T\): .+/,@lines)){
							($xs_ref=$xs_ref[0])=~s/Current [Nn]ame \(T\): //;
							$xs_ref=&strip_name($xs_ref);
						}
else{
push(@NCN, "No current name for $NAN\n");
}
						if(grep(/SR: TJM/,@lines)){
							push(@supplanted, "$NAN: $taxon_id: $xs_ref");
#warn "$NAN: $taxon_id: $xs_ref\n";
						}
					}
				#else{warn "Rej. or Rep. but $CS\n$SM\n\n"};
				}
				elsif(m/SM:.*addition/){

					if($CS!~/unresolved/){
						if(m/(probable|possible) addition, for taxon .*previously known to occur/){
							push(@I_new_range, "$NAN: $taxon_id: $family ($1)");
						}
						elsif(m/addition, for taxon .*previously known to occur/){
							push(@I_new_range, "$NAN: $taxon_id: $family");
						}


						elsif(m/addition.*(reported|rediscovered).*since TJM/){
							push(@I_new_range, "$NAN: $taxon_id: $family");
						}
						elsif(m/(possible|probable) addition.*(reported|rediscovered).*since TJM/){
							push(@I_new_range, "$NAN: $taxon_id: $family ($1)");
						}
						elsif(m/addition.*naturalized/){
							push(@I_new_range, "$NAN: $taxon_id: $family");
						}
						elsif(m/(possible|probable) addition.*naturalized/){
							push(@I_new_range, "$NAN: $taxon_id: $family ($1)");
						}
						elsif(m/addition.*previously known to occur/){
							push(@I_new_range, "$NAN: $taxon_id: $family");
						}
						elsif(m/(possible|probable) addition.*previously known to occur/){
							push(@I_new_range, "$NAN: $taxon_id: $family ($1)");
						}
						elsif(m/addition.*not cited in TJM/){
							push(@I_new_range, "$NAN: $taxon_id: $family");
						}
						elsif(m/(possible|probable) addition.*not cited in TJM/){
							push(@I_new_range, "$NAN: $taxon_id: $family ($1)");
						}
						elsif(m/addition *$/){
							push(@I_new_range, "$NAN: $taxon_id: $family");
						}
						elsif(m/(possible|probable) addition *$/){
							push(@I_new_range, "$NAN: $taxon_id: $family ($1)");
						}



						elsif(m/addition, for taxon .*described since/){
							push(@I_new_taxa, "$NAN: $taxon_id: $family");
						}
						elsif(m/(probable|possible) addition, for taxon .*described since/){
							push(@I_new_taxa, "$NAN: $taxon_id: $family ($1)");
						}
				#	}


					push(@added_index, "$NAN: $taxon_id: $family");
				}
			}
		}
		print "Error\n$_\n" if $lines[0]=~/Current/;
	}
		##print OUT $lines[0], "\n";
		$TID{$taxon_id}="" unless $TID{$taxon_id};
if ($I_XW{$taxon_id}{CNPS}){
		push(@lines,"LINK: CNPS|$I_XW{$taxon_id}{CNPS}");
}
elsif ($CNPS{$taxon_id}){
		push(@lines,"LINK: CNPS");
}

if($CP{$taxon_id}){
		push(@lines,"LINK: CP");
}
elsif ($I_XW{$taxon_id}{CP}){
		push(@lines,"LINK: CP|$I_XW{$taxon_id}{CP}");
}
if($SMASCH_LINK{$taxon_id}){
		push(@lines,"LINK: SMASCH");
		push(@lines,"LINK: HCODE=$overlay{$taxon_id}");
}
if ($I_XW{$taxon_id}{SMASCH}){
		push(@lines,"LINK: SMASCH|$I_XW{$taxon_id}{SMASCH}");
}
		push(@lines,"LINK: $fna_link{$taxon_id}") if $fna_link{$taxon_id};
		push(@lines,"LINK: $ildis_link{$taxon_id}") if $ildis_link{$taxon_id};

		push(@lines,"LINK: $eppc_link{$taxon_id}") if $eppc_link{$taxon_id};
		push(@lines,"LINK: $weed_link{$taxon_id}") if $weed_link{$taxon_id};
		push(@lines,"LINK: $cpc_link{$taxon_id}") if $cpc_link{$taxon_id};
		push(@lines,"LINK: $usfw_link{$taxon_id}") if $usfw_link{$taxon_id};
		push(@lines,"LINK: $plants_link{$taxon_id}") if $plants_link{$taxon_id};
		push(@lines,"LINK: $proto_link{$taxon_id}") if $proto_link{$taxon_id};
if($TID{$taxon_id}){
		push(@lines,"JMP: $TID{$taxon_id}");
}
elsif ($I_XW{$taxon_id}{JM}){
		push(@lines,"LINK: JM|$I_XW{$taxon_id}{JM}");
}
		$CAPN{$taxon_id}=join("\t",@lines);

		#	if($old_list{$NAN}){
			#	if($old_list{$NAN} ne $CAPN{$taxon_id}){
				#	print ARCHIVE "OLD\n$old_list{$NAN}\nNEW\n$CAPN{$taxon_id}\n\n";
				#	push(@changed_entry,"$NAN: $taxon_id");
				#	warn "$NAN has changed\n";
			#	}
		#	}
		#	else{
			#	push(@apparent_new_name,"$NAN: $taxon_id");
		#	}

		$x_ref="";
		if(grep(/CS: [12]a_t/,@lines)){
			$par_number=$TID_TO_PAR{$taxon_id};
			$par_number=~s/.*,//;
		#print "$taxon_id\t$x_ref\n";
			if(($x_ref)=grep(/CT: (since TJM.*treated as <sn>[^<]+)|(treated as <sn>.* since TJM)/,@lines)){
				if($x_ref=~m/<sn>([^<]+)<\/sn>/){$x_ref=$1;}
				$x_ref=&strip_name($x_ref);
				$XREF{$par_number}="$x_ref\tt";
			}
		}
		elsif(grep(/CS: [12]a/,@lines)){
			$par_number=$TID_TO_PAR{$taxon_id};
			$par_number=~s/.*,//;
		#print "$taxon_id\t$x_ref\n";
			if(($x_ref)=grep(/CT: (since TJM.*treated as <sn>[^<]+)|(treated as <sn>.* since TJM)/,@lines)){
				if($x_ref=~m/<sn>([^<]+)<\/sn>/){$x_ref=$1;}
				$x_ref=&strip_name($x_ref);
				$XREF{$par_number}="$x_ref";
				#print "XREF: $par_number: $x_ref\n";
			}
		}
		elsif(grep(/CN: /,@lines)){
			$par_number=$TID_TO_PAR{$taxon_id};
			$par_number=~s/.*,//;
			if(($x_ref)=grep(/CN: (.+)/,@lines)){
				if($par_number){
					$x_ref=&strip_name($x_ref);
					$XREF{$par_number}="$x_ref";
					print "NEW XREF: $par_number: $x_ref\n";
				}
				else{
					print "No XREF par number: $x_ref\n";
				}
			}
		}
		elsif(grep(/CN_T: /,@lines)){
			$par_number=$TID_TO_PAR{$taxon_id};
			$par_number=~s/.*,//;
			if(($x_ref)=grep(/CN_T: (.+)/,@lines)){
				if($par_number){
					$x_ref=&strip_name($x_ref);
					$XREF{$par_number}="$x_ref\tt";
					print "NEW XREF: $par_number: $x_ref\n";
				}
				else{
					print "No XREF par number: $x_ref\n";
				}
			}
		}




		$NAME_CODE{&strip_name($lines[0])}=$taxon_id;
		$jfp= "JFP-" . $CS;
		if($CPNNOAN{$NAN}){
			$indexes{$initial}{$NAN}=<<EOP;
<br><a href="/cgi-bin/get_cpn.pl?$CPNNOAN{$NAN}">$NAN $jfp</a>
EOP
		}
		else{
			print "NAME PROBLEM>$NAN<\n";
		}
		foreach (@lines[1 .. $#lines]){
			foreach $tag ("TMN", "TSN", "SNTJM", JFPS){
				if(m/$tag: +(.*)/){
					@synos=split(/; +/, $1);
					foreach(@synos){
						$_=&strip_name($_);
						#print "$_\n";
						$NAME_CODE{$_}=$taxon_id unless $NAME_CODE{$_};
					}
				}
			}
		}
	}
	close(IN);

	foreach ( A .. Z){
		&make_index($_);
	}

	@keys=sort {$a <=> $b ||$a cmp $b} keys(%add_index);
	grep(s/(.*)/<a href="I_status_${1}.html">$1 <\/a>|/, @keys);
	grep(s/_t </ (tentative) </, @keys);
	foreach (keys(%add_index)){
		&make_status_index($_);
	}
	&print_main_index;


	open(OUT,">${outdir}I_index_supplant.html") || die;
	print OUT <<EOP;
<html>
<head>
<title>
UCJEPS: Interchange Index to Superseded Names
</title>
</head>
<body>
$page_top<br>&nbsp;
<H2 align="center">
Index to Names Superseded since The Jepson Manual
</h2>
$today
<hr>
<strong>Clicking on a name will take you to the report from the Jepson Online Interchange</strong>
<OL>
EOP
	foreach(sort(@supplanted)){
		($name,$tid,$synon)=split(/: /,$_);
next if $name=~/Delphinium ajacis/;

		print OUT <<EOP;
<LI><a href="/cgi-bin/get_cpn.pl?$tid">$name</a> --> $synon
EOP
	}
	print OUT "</OL>", &make_trailer();

	open(OUT,">${outdir}I_index_added.html") || die;
	print OUT <<EOP;
<html>
<head>
<title>
UCJEPS: Interchange Index to Added Taxa
</title>
</head>
<body>
$page_top<br>&nbsp;
<H2 align="center">
Index to Names Added Since The Jepson Manual
<br>
(list does not include <a href="${ucjeps_path}/interchange/I_status_unresolved.html">names of unresolved status</a>)
</h2>
$today
<hr>
<strong>Clicking on a name will take you to the report from the Jepson Online Interchange</strong>
<br>
<a href="/interchange/I_index_added_byfam.html">Display list sorted by family</a>
<OL>
EOP
%already_saw_infra=();
	foreach(sort(@added_index)){
		($name,$tid,$family)=split(/: /,$_);
next if $name=~/^[A-Z][a-z]+$/;
if($name=~/^(.*) (var\.|subsp.)/){
$already_saw_infra{$1}++;
}
else{
next if $already_saw_infra{$name};
}

$family=uc($family);
		print OUT <<EOP;
<LI><a href="/cgi-bin/get_cpn.pl?$tid">$name</a> $family
EOP
push(@fam_order, "<LI>$family <a href=\"/cgi-bin/get_cpn.pl?$tid\">$name</a>\n");
	}
	print OUT "</OL>", &make_trailer();

	open(OUT,">${outdir}I_index_added_byfam.html") || die;
	print OUT <<EOP;
<html>
<head>
<title>
UCJEPS: Interchange Index to Added Taxa; family order
</title>
</head>
<body>
$page_top<br>&nbsp;
<H2 align="center">
Index to Names Added Since The Jepson Manual (Ordered by Family)
<br>
(list does not include <a href="${ucjeps_path}/interchange/I_status_unresolved.html">names of unresolved status</a>)
</h2>
$today
<hr>
<strong>Clicking on a name will take you to the report from the Jepson Online Interchange</strong>
<OL>
EOP
print OUT sort(@fam_order);
	print OUT "</OL>", &make_trailer();


	open(OUT,">${outdir}I_index_newrange.html") || die;
	print OUT <<EOP;
<html>
<head>
<title>
UCJEPS: Interchange Index to Range Extensions
</title>
</head>
<body>
$page_top<br>&nbsp;
<H2 align="center">
Index to Taxa Recorded from California Since The Jepson Manual
<br>
(range extensions from outside California and new naturalizations)
</h2>
$today
<hr>
<strong>Clicking on a name will take you to the report from the Jepson Online Interchange</strong>
<OL>
EOP
%already_saw_infra=();
	foreach(sort(@I_new_range)){
		($name,$tid,$family)=split(/: /,$_);
next if $name=~/^[A-Z][a-z]+$/;
if($name=~/^(.*) (var\.|subsp.)/){
$already_saw_infra{$1}++;
}
else{
next if $already_saw_infra{$name};
}
#<LI><a href="/cgi-bin/get_cpn.pl?77228">Coronilla valentina subsp. glauca</a> FABACEAE
#<LI><a href="/cgi-bin/get_cpn.pl?20421">Coronilla valentina</a> FABACEAE

		print OUT <<EOP;
<LI><a href="/cgi-bin/get_cpn.pl?$tid">$name</a> $family
EOP
	}
	print OUT "</OL>", &make_trailer();


	open(OUT,">${outdir}I_index_newtax.html") || die;
	print OUT <<EOP;
<html>
<head>
<title>
UCJEPS: Interchange Index to Newly Described Taxa
</title>
</head>
<body>
$page_top<br>&nbsp;
<H2 align="center">
Index to Taxa described Since The Jepson Manual
<br>
</h2>
$today
<hr>
<strong>Clicking on a name will take you to the report from the Jepson Online Interchange</strong>
<OL>
EOP
%already_saw_infra=();
	foreach(sort(@I_new_taxa)){
		($name,$tid,$family)=split(/: /,$_);
if($name=~/^(.*) (var\.|subsp.)/){
$already_saw_infra{$1}++;
}
else{
next if $already_saw_infra{$name};
}

		print OUT <<EOP;
<LI><a href="/cgi-bin/get_cpn.pl?$tid">$name</a> $family
EOP
	}
	print OUT "</OL>", &make_trailer();






	untie(%XREF);
	untie(%TID_TO_PAR);
	untie(%CAPN);

	#	open (OUT,">I_new_entries.html") || die;
	#	print OUT <<EOP;
#	<html>
#	<head>
#	<title>
#	UCJEPS: Interchange Index to Names Recently Added To Main File
#	</title>
#	</head>
#	<body>
#	$page_top<br>&nbsp;
#	<H2 align="center">
#	Index to Names Recently Added To Main File
#	</h2>
#	$today
#	<hr>
#	<strong>Clicking on a name will take you to the report from the Jepson Online Interchange</strong>
#	<OL>
#	EOP
	#	foreach(@apparent_new_name){
		#	($name, $tid)=m/(.*): (.*)/;
		#	print OUT<<EOP;
#	<LI><a href="/cgi-bin/get_cpn.pl?$tid">$name</a>
#	EOP
	#	}
	#	print OUT "</OL>", &make_trailer();
	#	close(OUT);
	#	open (OUT,">${outdir}I_changed_entries.html") || die;
		#	print OUT<<EOP;
#	<html>
#	<head>
#	<title>
#	UCJEPS: Interchange Index to Recently Changed Entries
#	</title>
#	</head>
#	<body>
#	$page_top<br>&nbsp;
#	<H2 align="center">
#	Index to Recently Changed Entries
#	</h2>
#	$today
#	<hr>
#	<strong>Clicking on a name will take you to the report from the Jepson Online Interchange</strong>
#	<OL>
#	EOP
#	
	#	foreach(@changed_entry){
		#	($name, $tid)=m/(.*): (.*)/;
		#	print OUT <<EOP;
#	<LI><a href="/cgi-bin/get_cpn.pl?$tid">$name</a>
#	EOP
	#	}
	#	print OUT "</OL>", &make_trailer();
	#	close(OUT);

	open(OUT, ">${outdir}LN2C.out") || die;
		print OUT <<EOP;
append this to /cgi-bin/LN2C.pl. It is the index for searches
EOP
	while(($name,$code)=each(%NAME_CODE)){
		next if $name=~/[()"]/;
		next if $name=~/\d/;
		@name=split(/ /,$name);
		foreach (sort  (@name)){
			$element{$_}.="$code " if (length($code) > 0 &! $seen{$_ . $code}++);

		}
	}
	foreach (sort(keys(%element))){
		next if m/(var\.|subsp\.)/;
		next if m/^×$/;
		next if m/^A\.$/;
		print OUT "$_: ", join(" ",sort(split(/ /,$element{$_}))), "\n";
	}
	untie(%NAME_CODE);

	{
	local($/)="\n";
	open(OUT, ">${outdir}I_status_1+2.html") || die;
	print OUT <<EOP;
<html>
<head>
<title>
UCJEPS: Interchange list of Accepted Names
</title>
</head>
<body>
<H2 align="center">
Jepson Interchange List of Currently Accepted Names of Native and Naturalized Plants of California
</h2>
<h3>
Names representing native taxa (category JFP-1) are in boldface; names representing naturalized taxa (category JFP-2) are in italics; this is a list of taxa that would be included in an edition of The Jepson Manual printed today
</h3>
<a href="${ucjeps_path}/interchange/I_status_1+2_t.html">
Names tentatively included are in a separate list.
</a>
<hr>
EOP
	foreach $file (qw(
		I_status_1.html
		I_status_2.html
		)){
		open(IN, "${outdir}$file") || die;
		while(<IN>){
			next unless m/cgi-bin/;
			if(m/<br>.*>([^<]+)<\/a>/){
				s/>([^<]+)<\/a>/><b>$1<\/b><\/a>/ if $file=~/1/;
				s/>([^<]+)<\/a>/><i>$1<\/i><\/a>/ if $file=~/2/;
				$add{$_}=$1;
			}
		}
	}
	foreach(sort {$add{$a} cmp $add{$b}} (keys(%add))){
		print OUT $_;
	}
	print OUT  &make_trailer();

#tentative
	%add=();
	open(OUT, ">${outdir}I_status_1+2_t.html") || die;
	print OUT <<EOP;
<html>
<head>
<title>
Interchange List of California Plant Names (tentative)
</title>
</head>
<body>
<H2 align="center">
Tentative additions to Jepson Interchange List of Names of Native and Naturalized Plants of California
</h2>
<h3>
Names representing native taxa (category JFP-1 tentative) are in boldface; names representing naturalized taxa (category JFP-2 tentative) are in italics
</h3>
<a href="${ucjeps_path}/interchange/I_status_1+2.html">
Return to the list of certain names
</a>
<hr>
EOP
	foreach $file (qw(
		I_status_1_t.html
		I_status_2_t.html
		)){
		open(IN, "${outdir}$file") || die;
			while(<IN>){
				next unless m/cgi-bin/;
				if(m/<br>.*>([^<]+)<\/a>/){
					s/>([^<]+)<\/a>/><b>$1<\/b><\/a>/ if $file=~/1/;
					s/>([^<]+)<\/a>/><i>$1<\/i><\/a>/ if $file=~/2/;
					$add{$_}=$1;
				}
			}
		}
		foreach(sort {$add{$a} cmp $add{$b}} (keys(%add))){
			print OUT $_;
		}
		print OUT &make_trailer();

	}

}



#6
sub make_treatment_indexes {
##########TREATMENT INDEXES###############
	open(IN,"$JMtreat_index") || die;
		while(<IN>){
			next if /^$/;
			chomp;
			($name,$par)=split(/ => /,$_);
			$name=~s/ *$//;
			$name=~s/ *\t.*//;
			$name=~s/  / /g;
unless($name=~m/Aloe saponaria . Aloe striata/ ||
$name=~m/Encelia farinosa . Encelia frutescens/){
			$name=ucfirst(lc($name));
}


			$JM{"<LI><a href=\"/cgi-bin/get_JM_treatment.pl?$par\">$name</a>"}=$name;
			push(@JM,"<LI><a href=\"/cgi-bin/get_JM_treatment.pl?$par\">$name</a>" );
			}
	close(IN);

	$prev_initial="Z";

	$top_of_file=<<EOP;
<html>
<head>
<title>
UC/JEPS: Interchange Index Page for The Jepson Manual
</title>
</head>
<body>
$page_top<br>&nbsp;
<H2 align="center">
Index to Taxa in The Jepson Manual
</H2>
<UL>
EOP
	foreach(sort {$JM{$a} cmp $JM{$b}}(keys(%JM))){
		$initial =substr($JM{$_}, 0, 1);
		if($initial eq $prev_initial){
	s/&mathx;/× /;
			print OUT "$_\n";
		}
		else{
			print OUT &make_trailer();
			$file="I_treat_index_" . $initial . ".html";
			open(OUT, ">${outdir}$file") || die;
			print OUT <<EOP;
$top_of_file
EOP
			foreach(A .. Z){
				if($_ eq $initial){
					print OUT <<EOP;
<a href="I_treat_index_${_}.html" ><font size=+4>$initial</font>|</a>
EOP
				}
				else{
					print OUT <<EOP;
<a href="I_treat_index_${_}.html" >$_|</a>
EOP
				}
			}
			print OUT<<EOP;
<hr><strong>Clicking on a name will take you to the description in The Jepson Manual</strong>
<P>
$_
EOP
			#warn "initial: $initial\nprevious: $prev_initial\n";
		}
		$prev_initial=$initial;
	}

}


#7
#
sub make_common_index {
	open(OUT, ">${outdir}I_common.out");
		print OUT <<EOP;
append this to /cgi-bin/get_cn2.pl. It is the index for common name searches
EOP
	local($/)="";
	open(IN,"$JMtreat_index") || die;

	while(<IN>){
		chomp;
s/Astragalus clarianus/Astragalus claranus/;
s/Cichorium endiva/Cichorium endivia/;
s/Clarkia mosquinii subsp. xerophylla/Clarkia mosquinii subsp. xerophila/;
		@lines=split(/\n/);
	s/&mathx;/× /;
		foreach $i (1 .. $#lines){
			$_=$lines[$i];
			if(s/ => (.*)//){
				$pars=$1;
			}
			else{
				$pars="";
			}
			($name, $cname)=split(/\t/);
			if($name=~/^[A-Z][A-Z]/){
				@last_gcname=();
			}
			if($cname){
				if($cname=~/ or /){
					if($cname=~/(.*), (.*), (.*), (.*) or (.*) ([^ ]+)$/){
						$cname="$1 $6, $2 $6, $3 $6, $4 $6, $5 $6";
					}
					elsif($cname=~/(.*), (.*), (.*) or (.*) ([^ ]+)$/){
						$cname="$1 $5, $2 $5, $3 $5, $4 $5";
					}
					elsif($cname=~/(.*), (.*) or (.*) ([^ ]+)$/){
						$cname="$1 $4, $2 $4, $3 $4";
					}
					elsif($cname=~/(.*) or (.*) ([A-Z]+) *$/){
						$cname="$1 $3, $2 $3";
					}
					elsif($cname=~/([A-Z]+) (.*) or ([A-Z]+) *$/){
						$cname="$1 $2, $1 $3";
					}
					else {warn ">$_<\n"};
				}
				#$cname=~s/'//g;
				@cnames=split(/, /,$cname);
					foreach (@cnames){
						s/^\s+//;
						s/\s+$//;
					}
					if($name=~/^[A-Z][A-Z]/){
						@last_gcname=@cnames;
					}
					foreach (@cnames){
						$name=ucfirst(lc($name));
						$cname{$_}.="$CPNNOAN{$name}, ";
					}
			}
			else{
				unless ($name=~/^[A-Z][A-Z]/){
					foreach $c_atom (@last_gcname){
						$name=ucfirst(lc($name));
						$cname{$c_atom}.="$CPNNOAN{$name}, ";
					}
				}
			}
		}
	}
	foreach (sort(keys(%cname))){
		$cname{$_}=~s/\t+/\t/g;
		$cname{$_}=~s/\t$//g;
		%c_element=();
		$cname=$_;
 		foreach(split(/ /,$cname{$cname})){
			$c_element{$_}++;
		}
		print OUT "$cname: ", join("",sort(keys(%c_element))),"\n";
	}
}

#8
sub flatten_dbm {
	%flat_dbm=(
capn_db => flat_dbm_1,
tid_par => flat_dbm_2,
jmname_newname => flat_dbm_3,
name_to_code => flat_dbm_4,
"JM_namehash" => flat_dbm_5,
#"/jepson/JM_namehash" => flat_dbm_5,
"/jepson/JM_treatment_h" => flat_dbm_6);
	foreach $dbm_file (sort(keys(%flat_dbm))){
	$count=0;
	open(OUT, ">${outdir}$flat_dbm{$dbm_file}") || die;
	tie(%FF, "DB_File", $dbm_file, O_CREAT|O_RDWR,0666) || die;
	if($dbm_file=~/JM_treatment/){
	#make null bitvector
		$nullvec="";
		for $i (0 .. 34){
			vec($nullvec,$i,1) = 0;
		}
		$gvec=$nullvec;

$par_count=scalar(keys(%FF));
--$par_count;
		foreach $par (reverse(1 .. $par_count)){
++$count;
			print OUT "$par\n";
			$entry=$FF{$par};
			if($entry=~/(sp_par|infrasp_par)/){
				if($entry=~m/<HCODE>(.*)<\/HCODE>/){
					$hcode=$1;
					$hvec = pack("b*", unpack("b*",pack("H*",$hcode)));
	
					$hstr= unpack("H*", pack("b*",unpack ("b*", $hvec)));
					$gvec |= $hvec;
					$hstr= unpack("H*", pack("b*",unpack ("b*", $gvec)));
				}
			}
		
			elsif($entry=~m/genus_par/){
				$hstr= unpack("H*", pack("b*",unpack ("b*", $gvec)));
				$entry=~s|</desc>|<ghcode>$hstr</ghcode></desc>|;
				$gvec=$nullvec;
			}
			print OUT "$entry\n\n";
		}
	}
	else{
		while(($key,$value)=each(%FF)){
			$value=~s/\n/<^>/g;
			++$count;
			print OUT $key,  "\n$value\n\n";
		}
	}
	close(OUT);
	untie(%FF);
	open(IN, "${outdir}$flat_dbm{$dbm_file}") || die;
	$outcount=0;
	local($/)="";
	while(<IN>){
		++$outcount;
	}
	close(IN);
	print <<EOP;
$dbm_file
DBM file: $count
Dump:     $outcount
EOP

	}
	print <<EOP;
Upload 
dbm files as flat_dbm_1 to 6
indexes, including treatment indexes,
to ucjeps
and most important, add
"LN2C.out" to cgi-bin/ln2c.pl on ucjeps
and JM_parseq to get_JM_treatment.pl
and I_common.out to get_cn2.pl 
and run get_hcode_from_markup
 See bad links in no_link.tmp
 See bad current name in no_current.tmp

EOP
open(OUT,">no_current.tmp") || die;
print OUT @NCN;
close OUT;
open(OUT,">no_link.tmp") || die;
print OUT @no_link;
close OUT;


}
sub get_nan{
	local($_)=@_;
	s/^(.*)[^\000]+/$1/;
	s/  +/ /g;
	s/ *$//;
	s/ \(([^)]+)\)$//;
	s/ \(([^(]+\).*)\)$//;
	$_=&strip_name($_);
	$_;
}

sub next_cpn_line {
local($_)=@_;
	return 1 if /^[A-Z][A-Z]/;
	#return 1 if /Current Status: *13/;
	return 0;
}
sub strip_name{
	local($_) = @_;
#warn "SAPONARIA: $_" if m/saponaria/;
if(m/Encelia californica .*Encelia farinosa/){
return("Encelia californica × Encelia farinosa");
}
if(m/Encelia farinosa .*Encelia frutescens/){
return("Encelia farinosa × Encelia frutescens");
}
if(m/Aloe saponaria.*A.*striata.*/){
return("Aloe saponaria × Aloe striata");
}

	s/^ *//;
	s/ x / × /;
s/^x ([A-Z][a-z]+ [a-z]+).*/× $1/;
s/Fragaria × ananassa Duchesne var. cuneifolia.*/Fragaria × ananassa var. cuneifolia/ ||
s/Trifolium variegatum Nutt. phase (\d)/Trifolium variegatum phase $1/ ||
	s/^([A-Z][a-z]+) (X?[-a-z]+).*(subsp.) ([-a-z]+).*(var\.) ([-a-z]+).*/$1 $2 $3 $4 $5 $6/ ||
	s/^([A-Z][a-z]+ [a-z]+) (× [-A-Z][a-z]+ [a-z]+).*/$1 $2/ ||
	s/^([A-Z][a-z]+) (× [-a-z]+).*/$1 $2/ ||
	s/^([A-Z][a-z]+) (X?[-a-z]+).*(ssp\.|var\.|f\.|subsp\.) ([-a-z]+).*/$1 $2 $3 $4/ ||
	s/^([A-Z][a-z]+) (X?[-a-z]+).*/$1 $2/||
	s/^([A-Z][a-z]+) [A-Z(].*/$1/;
#warn "SAPONARIA: $_" if m/saponaria/;
	return ($_);
}

sub make_family_header {
$_= <<EOP;
<html>
<head> <title> UCJEPS: Jepson Manual Treatment Indexes </title> </head>
<body>
$page_top<br>&nbsp;
<H2 align="center"> Index to Treatments and Keys From <em>The Jepson Manual</em></h2>
<h3>(including updated information from <em>The Jepson Desert Manual</em>
and other sources)
</h3>
<OL>
<LI><b>Names from The Jepson Manual Treatments Arranged Alphabetically By Genus</b>
<br>
<a href="I_treat_index_A.html">A</a> | <a href="I_treat_index_B.html">B</a> | <a href="I_treat_index_C.html">C</a> | <a href="I_treat_index_D.html">D</a> | <a href="I_treat_index_E.html">E</a> | <a href="I_treat_index_F.html">F</a> | <a href="I_treat_index_G.html">G</a> | <a href="I_treat_index_H.html">H</a> | <a href="I_treat_index_I.html">I</a> | <a href="I_treat_index_J.html">J</a> | <a href="I_treat_index_K.html">K</a> | <a href="I_treat_index_L.html">L</a> | <a href="I_treat_index_M.html">M</a> | <a href="I_treat_index_N.html">N</a> | <a href="I_treat_index_O.html">O</a> | <a href="I_treat_index_P.html">P</a> | <a href="I_treat_index_Q.html">Q</a> | <a href="I_treat_index_R.html">R</a> | <a href="I_treat_index_S.html">S</a> | <a href="I_treat_index_T.html">T</a> | <a href="I_treat_index_U.html">U</a> | <a href="I_treat_index_V.html">V</a> | <a href="I_treat_index_W.html">W</a> | <a href="I_treat_index_X.html">X</a> | <a href="I_treat_index_Y.html">Y</a> | <a href="I_treat_index_Z.html">Z</a>
<P>
<LI>
                <STRONG>Scientific Name</STRONG>
                <FORM action="http://ucjeps.berkeley.edu/cgi-bin/LN2C.pl"
                method=post>
                <INPUT name=genus size=40>
                <br>
                <INPUT type=submit value="Submit Name">
                <INPUT type=reset value=Reset>

                <br>
                <font size=-1>
                Partial names are allowed (e.g.,
<a href="http://ucjeps.berkeley.edu/cgi-bin/LN2C.pl?genus=Seq+gig">Seq gig</a>).
                You can retrieve all species in a genus by entering a
                genus name only.<br>When entering infraspecific names, do not include
                the words "var.", "subsp.", or "f.".
                </font>
                </FORM>
<LI><b>Families from the Jepson Manual Arranged in Manual Order</b>
<br>
<b>&nbsp;&nbsp;&nbsp;Select a family to find keys and lists of included genera</b>. 
<ul>
&nbsp;
<br>
<strong>
Ferns and Fern Allies
</strong>
EOP
$_;
}




sub make_trailer {
	return <<EOP;
<P>
<a href="/interchange.html">Return to the Interchange main page</a>
<br>
<a href="/jepson_flora_project.html">Go to the Jepson Flora Project main page</a>
<br>
<p>
<hr>
<!-- Begin Navigation -->
<CENTER>
<Font size=1 Face="Verdana, Arial, Helvetica">
<a href="/index.html"> University & Jepson Herbaria Home Page </a> | 
<BR>
<a href="/gen_info.html">General Information </a> | 
<a href="/ucherb.html"> University Herbarium </a> | 
<a href="/active.html"> Jepson Herbarium </a> |
<BR>
<a href="/Visitor_Guidelines.html"> Visiting the Herbaria </a> | 
<a href="/online_resources.html"> On-line Resources </a> | 
<a href="/res_teach.html"> Research </a> | 
<BR>
<a href="/education.html"> Education </a> | 
<a href="/other_sites_hosted.html"> Related Sites </a>
<br><a href="/copyright.html">Copyright &copy; </a> by the Regents of the University of California
</Font>
</CENTER>
<!-- End Navigation -->
</body></html>
EOP
}




sub print_main_index{
	open(OUT, ">${outdir}I_indexes.html") || die;
	print OUT <<EOP;
<html>
<head>
<title>
UCJEPS: Interchange Status Categories
</title>
</head>
<body>
$page_top<br>&nbsp;
<H2 align="center">
Index to California Plant Names
<br>
Current Status Categories
</h2>
<H3>Names Arranged Alphabetically under Current Status Categories</h3>
(numbers in parentheses indicate number of names in each category)
<UL>
EOP

	foreach (sort{$a<=>$b || $a cmp $b}(keys(%Current_Status))){
		@total=split(/\n/, $add_index{$_});
		$total=@total;
		next if $total==0;
		print OUT<<EOP;
<LI><a href="I_status_${_}.html">JFP-${_}, $Current_Status{$_}</a> ($total)
EOP
	}
	#print OUT " </ul> <P> <LI><a href=\"/Jepson_hypertree.html\">Hyperbolic tree indexes to the treatments</a> </oL>", &make_trailer();
	print OUT " </ul> </oL>", &make_trailer();
}

sub make_index {
	local($initial)=@_;
		open(OUT, ">${outdir}I_index_${initial}.html") || die;
		print OUT <<EOP;
<html>
<head>
<title>
UCJEPS: Interchange index to taxa: $initial
</title>
</head>
<body>
$page_top<br>&nbsp;
<blockquote>
EOP
		foreach(A .. Z){
		if($_ eq $initial){
			print OUT <<EOP;
<a href="I_index_${_}.html" ><font size=+4>$initial</font></a>
EOP
		}
		else{
			print OUT <<EOP;
<a href="I_index_${_}.html" >$_</a>
EOP
		}
		print OUT "|\n" unless $_ =~ /Z/;
	}
	print OUT "</blockquote><hr> <strong>Clicking on a name will take you to the report from the Jepson Online Interchange</strong></P>";
	foreach $name (sort (keys(%{$indexes{$initial}}))){
		print OUT "$indexes{$initial}{$name}";
	}
	print OUT &make_trailer();

open(IN, "interchange_templ.html") || die;
open(OUT,">$outdir/interchange.html") || die;
while(<IN>){
s/Aug 23 2003/$today/;
print OUT;
}
}



sub make_status_index{
local($status)=@_;
		@list=sort(split(/\n/,$add_index{$status}));
		$total=scalar(@list);
		next if $total==0;
	#warn "$status: $add_index{$status}\n";
		open(OUT, ">${outdir}I_status_${status}.html") || die "$outdir $status $!";
		print OUT <<EOP;
<html>
<head>
<title>
UCJEPS: Interchange Index to Current Status
</title>
</head>
<body>
$page_top<br>&nbsp;
<H2 align="center">
Index to Current Status
</h2>
<h3>
JFP-${status}: $Current_Status{$status} (total=$total)
</h3>
@keys
<hr>
<strong>Clicking on a name will take you to the report from the Jepson Online Interchange</strong>
EOP
		foreach(@list){
			($name,$id)=split(/\t/);
			#die;
			print OUT <<EOP;
<br><a href="/cgi-bin/get_cpn.pl?$id">$name</a>
EOP
		}
		print OUT &make_trailer();
	}

sub make_protologue_page{
		open(OUT, ">${outdir}I_protologue.html") || die "$outdir protologue $!";
		print OUT <<EOP;
<html>
<head>
<title>
UCJEPS: Protologue Scans
</title>
</head>
<body>
$page_top<br>&nbsp;
<H2 align="center">
Index to Scans of Protologues
</h2>
<hr>
<strong>Clicking on a name will take you to a TIF file of a page on which the protologue occurs</strong>
EOP
while(($taxon,$link)=split(/\t/,sort(@proto_link))){
print <<EOP;
<a href="/archives/muhlenbergia/${link}.tif">$_</a><br>
EOP
}
		print OUT &make_trailer();
	}


open(OUT,">no_subs") || die;
foreach(@nosub){
print OUT "$_\n";
}
__END__
   if($lines[0]=~s/([^(]+\([^)]+\)[^(]+\(([^)]+)\)[^(]+\))\(([^)]+)\)$/$1/){
elsif($lines[0]=~s/([^(]+\([^)]+\)[^(]+)\(([^(]+)\)$/$1/){
elsif($lines[0]=~s/ \(([^)]+)\)$//){
elsif($lines[0]=~s/ \(([^(]+\).*)\)$//){

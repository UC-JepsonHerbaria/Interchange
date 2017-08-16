#Make_interchange.pl
#combining Make_JMreat.pl and new_parse_cpn.pl
#Jan 20, 2003. Apparently working
#see make_interchange_readme
use flatten;
open(IN,"add_updates") || die;
print <<EOP;
There are some things that need to be addressed before you proceed
EOP
while(<IN>){
next if 0 ../DONE/;
print;
}
close(IN);
print <<EOP;
type "G<return>" to proceed, anything else to quit
EOP
$response=<>;
die unless $response=~/G/;

$cpn_file="/interchange/cpn.out";
%CPNNOAN=();
%CP=();
%eppc_link=();
%fna_link=();
$outdir="c:/interchange/update/";
$corrections="/jepson/JM_name_corrections";
$treat_file="/jepson/markup_plusFT.feb28.2003";
$treat_hash="/jepson/JM_treatment_h";
	unlink $treat_hash;
$JMtreat_index="get_JMtreat_index";
$tnoan_file="/interchange/TNOAN_DB";

$page_top= "<a href=\"/jepson_flora_project.html\">Jepson&nbsp;Flora Project: Index to California Plant Names</a>";
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
&make_cpn_id();
warn "1 loading links\n";
&load_links();
warn "2 making treatment hash\n";
&make_treatment_hash();
warn "3 linking taxon_id to treatments\n";
&link_tID_to_treatment();
warn "4 making name hash\n";
&make_namehash();
warn "5 parsing the plant name index\n";
&parse_cpn();
warn "6 making treatment indexes\n";
&make_treatment_indexes();
warn "7 making maps\n";
&flatten_dbm();


sub link_tID_to_treatment {
	open(OUT, ">TID_to_JMrecno") || die;
	open(IN,$corrections) || die;
	local($/)="\n";
	while(<IN>){
		chomp;
		next if m/^#/;
		next unless /=>/;
		($was,$to_be)=m/(.*) => (.*)/;
		$subs .=<<EOP;
s/$was/$to_be/;
EOP
	}
	close(IN);
	$name_subs=<<EOP;
foreach(\$name){
s/&mathx;/× /;
s/&euml;/e/;
$subs
if(\$CPNNOAN{\$name}){
print OUT "\$CPNNOAN{\$name}\\t\$pars\\n";
}
else{
print OUT "\$TNOAN{\$name}\\t\$pars\\n";
}
}
EOP

	open(IN,"$JMtreat_index") || die;
	while(<IN>){
		next if /^$/;
		chomp;
		($name,$pars)=split(/ => /,$_);
		$name=~s/ *$//;
		$name=~s/ *\t.*//;
		$name=~s/  / /g;
		$name=ucfirst(lc($name));
		eval ($name_subs);
	}
	close(IN);
	close(OUT);
}



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
warn $_;
next;
}
die $_ unless m/<desc/;

if(($nds)=m|<NDS>([^<]+)</NDS>|){
$hc=&get_hcode($nds);
die " return hcode problem\n" unless $hc;
s|<HCODE>[^<]*</HCODE>|<HCODE>$hc</HCODE>| ||
s|</NDS>|</NDS>\n<HCODE>$hc</HCODE>| ||
die "match hcode problem\nNDS=$nds\nHC=$hc\n$context";
}


#remove this
#s/<ECOLOGY>\s*(<ENDANGERED>.*<\/ENDANGERED>.) */$1<ECOLOGY>/;



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
			($TREAT{++$parno}=$_)=~s/\n/ /g;
 			($genus_name)=m|<genus_name>([^ ]+).*</genus_name>|;
			print OUT "$genus_name\t$CN => $last_fam,$parno\n";
			$last_gen=$parno;
			($genus)=m/<genus_name[^>]*>([^<]+)<\/genus_name>/;
		}
		elsif(m/sp_par>/){
			if(m|<infrasp_name[^>]*>([^<]+)</infrasp_name>|){
				($TREAT{++$parno}=$_)=~s/\n/ /g;
				$infra=$1;
				if(m/"full_name"/){
					$infra=~s/[A-Z]\./$genus/;
					$last_sp=0;
					($species_only=$infra)=~s/([A-Z]+ [a-z-]+).*/\u\L$1/;
#Uncomment following line to allow links to species also
					print OUT "$species_only => $last_fam,$last_gen,$last_sp,$parno\n";
				}
				else{
					$infra= "$species $infra";
				}
				$infra=~s/^([^ ]+ [^ ]+).* (var\.|ssp\.|f\.|subsp\. .*)/$1 $2/;
				$infra=~s/([^ ]+)/\u\L$1/;
				($infra_sub=$infra)=~s/ssp\./subsp./;
				$infra_sub=~s/  +/ /g;
				print OUT "$infra_sub\t$CN => $last_fam,$last_gen,$last_sp,$parno\n";
			}
			else{
				($TREAT{++$parno}=$_)=~s/\n/ /g;
	##print "$parno:  $last_gen $last_fam\n";
				($species)=m|<sp_name[^>]*>([^<]+)</sp_name>|;
				$species=~s/^[A-Z]\./$genus/;
				$species=~s/([^ ]+)/\u\L$1/;
				$species=~s/  +/ /g;
				print OUT "$species\t$CN => $last_fam,$last_gen,$parno\n";
				$last_sp=$parno;
			}
		}
	}
	close(OUT);

}


sub make_cpn_id {
#This is an arbitrary number that starts a sequence of taxon_ids given
#to names not in smasch. Note that the same name can receive different
#ids in different invocations of this script
	$cpn_count=88000;
	tie(%TNOAN, 'DB_File',$tnoan_file) || die;
	open(IN,$cpn_file) || die;
	local($/)="";
	while(<IN>){
		next if 1 .. /PTERIDOPH/;
	next if &next_cpn_line($_);
		$cpnnoan=&get_nan($_);
		$CPNNOAN{$cpnnoan}=($TNOAN{$cpnnoan} || ++$cpn_count);
	}
	close(IN);
	untie(%TNOAN);

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
	return 1 if /Current Status: *13/;
	return 0;
}
sub strip_name{
	local($_) = @_;
	s/^ *//;
	s/ x / × /;
s/^x ([A-Z][a-z]+ [a-z]+).*/× $1/;
	s/Fragaria × ananassa Duchesne var. cuneifolia \(Nutt. ex Howell\) Staudt/Fragaria × ananassa var. cuneifolia/ ||
	s/Trifolium variegatum Nutt. phase (\d)/Trifolium variegatum phase $1/ ||
	s/^([A-Z][a-z]+) (X?[-a-z]+).*(subsp.) ([-a-z]+).*(var\.) ([-a-z]+).*/$1 $2 $3 $4 $5 $6/ ||
	s/^([A-Z][a-z]+ [a-z]+) (× [-A-Z][a-z]+ [a-z]+).*/$1 $2/ ||
	s/^([A-Z][a-z]+) (× [-a-z]+).*/$1 $2/ ||
	s/^([A-Z][a-z]+) (X?[-a-z]+).*(ssp\.|var\.|f\.|subsp.) ([-a-z]+).*/$1 $2 $3 $4/ ||
	s/^([A-Z][a-z]+) (X?[-a-z]+).*/$1 $2/||
	s/^([A-Z][a-z]+) [A-Z(].*/$1/;
	return ($_);
}

sub make_family_header {
$_= <<EOP;
<html>
<head> <title> UCJEPS: Jepson Manual Treatment Indexes </title> </head>
<body>
<table width=100% bgcolor="#0000cc"> <tr> <TD align="center"><font size=6 color="#ffdd00"> <font size=3>Jepson Flora Project</font><P> <font size=7>J</font>EPSON <font size=7>O</font>NLINE <font size=7>I</font>NTERCHANGE </font> </td> <td><img src="/jeps.jpg" align=right alt="jeps logo"></td> </td> </tr> </table>
<H2 align="center"> Index to Treatments From The Jepson Manual </h2>
<OL>
<LI>Names from The Jepson Manual Treatments Arranged Alphabetically By Genus
<br>
<a href="I_treat_index_A.html">A</a> | <a href="I_treat_index_B.html">B</a> | <a href="I_treat_index_C.html">C</a> | <a href="I_treat_index_D.html">D</a> | <a href="I_treat_index_E.html">E</a> | <a href="I_treat_index_F.html">F</a> | <a href="I_treat_index_G.html">G</a> | <a href="I_treat_index_H.html">H</a> | <a href="I_treat_index_I.html">I</a> | <a href="I_treat_index_J.html">J</a> | <a href="I_treat_index_K.html">K</a> | <a href="I_treat_index_L.html">L</a> | <a href="I_treat_index_M.html">M</a> | <a href="I_treat_index_N.html">N</a> | <a href="I_treat_index_O.html">O</a> | <a href="I_treat_index_P.html">P</a> | <a href="I_treat_index_Q.html">Q</a> | <a href="I_treat_index_R.html">R</a> | <a href="I_treat_index_S.html">S</a> | <a href="I_treat_index_T.html">T</a> | <a href="I_treat_index_U.html">U</a> | <a href="I_treat_index_V.html">V</a> | <a href="I_treat_index_W.html">W</a> | <a href="I_treat_index_X.html">X</a> | <a href="I_treat_index_Y.html">Y</a> | <a href="I_treat_index_Z.html">Z</a>
<P>
<LI><a href="/Jepson_hypertree.html">Hyperbolic tree indexes to the treatments</a>
<P>
<LI>Families from the Jepson Manual Arranged in Manual Order
<ul>
&nbsp;
&nbsp;
&nbsp;
&nbsp;
&nbsp;
<strong>
Ferns and Fern Allies
</strong>
EOP
$_;
}

sub make_namehash {
	$file="JM_namehash";
	unlink($file);
	tie(%name_hash, 'DB_File',$file, O_CREAT|O_RDWR, 0666, $DB_HASH) || die;
	%name_hash=();
	local($/)="";
	open(IN,"$JMtreat_index") || die;
	open(OUT,">JM_fam_index.html") || die;
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
	warn "Add the contents of JM_parseq to get_JM_treatment.pl\n";
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
<!--Begin Navigation-->
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
<!--End Navigation-->
</body></html>
EOP
}



# from new_parse_cpn.pl
sub parse_cpn {
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
	($archive=$today)=~s/s/_/g;
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
<td><img src="http://ucjeps.berkeley.edu/jeps.gif" align=right alt="jeps logo"></td>
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
	tie(%TID_TO_PAR, 'DB_File',"tid_par", O_CREAT|O_RDWR, 0666) || die;
	tie(%XREF, 'DB_File',"jmname_newname", O_CREAT|O_RDWR, 0666) || die;
	while(($key,$value)=each(%TID)){
		$TID_TO_PAR{$key}=$value;
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
		($CS)=m/Current Status: *(.*)/;
		next ENTRY if  1 .. /PTERIDOPH/;
		next ENTRY if &next_cpn_line($_);
		$open= s/<sn>/<sn>/g;
		$close= s|</sn>|</sn>|g;
		die "<SN> problem: open: $open close $close\n$_ " unless $open==$close;
		chomp;
		s/  +/ /g;
		($name)=m/^(.*)/;
		s/\n-?done.*//;
		@lines=split(/\n/, $_, 100);
		grep(s/ +$//,@lines);
		if($lines[0]=~s/ \([^)]+\)[^(]+\(([^)]+)\)$//){
			splice(@lines,1,0,"AN: $1");
		}
		elsif($lines[0]=~s/ \([^)]+\)[^(]+\(([^(]+)\)$//){
			splice(@lines,1,0,"AN: $1");
		}
		elsif($lines[0]=~s/ \(([^)]+)\)$//){
			splice(@lines,1,0,"AN: $1");
		}
		elsif($lines[0]=~s/ \(([^(]+\).*)\)$//){
			splice(@lines,1,0,"AN: $1");
		}
		$NAN=&strip_name($lines[0]);
		warn "Already saw $NAN\n$lines[0]\n$_" if $seen{$NAN}++;
		($initial=$NAN)=~s/^(.).*/$1/;
		$taxon_id = $CPNNOAN{$NAN};

		foreach (@lines[1 .. $#lines]){
			next if/^-?done/;
		#local($_)=$lines[$i];
		#print "$_\n";
			s/^ +//;
			(s/^Effort: */EF: / ||
			s/^Family: */FA: / ||
			s/^Source: */SR: / ||
			s/^Source ([a-z]) *: */SR$1: / ||
			s/^Summary: */SM: / ||
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
			s!^TJM misapplied names: *!TMN: ! ||
			s/^Literature: */RL: / ||
			s/^Literature ([a-z]): */RL$1: / ||
			s/^Recent Literature: */RL: / ||
			s/^Recent Literature ([a-z]): */RL$1: / ||
			s/^Geography: */GG: / ||
			s/^AN: /AN: /  ||
			s/^Synonyms not explicitly cited in TJM: /SNTJM: /)  ||
			s/^LINK: /LINK: /  ||
			warn "no substitution $NAN $_\n";
			if(m/^CS: +(.*)/){
				#($CS=$1)=~s/ \[t\]//;
				$CS=$1;
				$add_index{$CS}.=<<EOP;
$NAN\t$taxon_id
EOP
#warn "NAN: $NAN: $taxon_id\n";
			}
			if(m/(SM[^\t]+)/){
				$SM=$1;
				if((m/SM.*rejection.*replacement/ || m/SM.*reject.*different genus since TJM/)){
					unless($CS=~ m/unresolved|tentative/){
						push(@supplanted, "$NAN: $taxon_id");
					}
				#else{warn "Rej. or Rep. but $CS\n$SM\n\n"};
				}
				elsif(m/SM: *addition/){
					push(@added_index, "$NAN: $taxon_id");
				}
			}
			print "Error\n$_\n" if $lines[0]=~/Current/;
		}
		##print OUT $lines[0], "\n";
		$TID{$taxon_id}="" unless $TID{$taxon_id};
		push(@lines,"LINK: CNPS") if $CNPS{$taxon_id};
		push(@lines,"LINK: CP") if $CP{$taxon_id};
		push(@lines,"LINK: $fna_link{$taxon_id}") if $fna_link{$taxon_id};
		push(@lines,"LINK: $eppc_link{$taxon_id}") if $eppc_link{$taxon_id};
		push(@lines,"JMP: $TID{$taxon_id}");
		$CAPN{$taxon_id}=join("\t",@lines);

		if($old_list{$NAN}){
			if($old_list{$NAN} ne $CAPN{$taxon_id}){
				print ARCHIVE "OLD\n$old_list{$NAN}\nNEW\n$CAPN{$taxon_id}\n\n";
				push(@changed_entry,"$NAN: $taxon_id");
				warn "$NAN has changed\n";
			}
		}
		else{
			push(@apparent_new_name,"$NAN: $taxon_id");
		}

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
			foreach $tag ("TMN", "TSN", "SNTJM"){
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
<OL>
EOP
	foreach(sort(@supplanted)){
		($name,$tid)=split(/: /,$_);

		print OUT <<EOP;
<LI><a href="/cgi-bin/get_cpn.pl?$tid">$name</a>
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
</h2>
$today
<hr>
<OL>
EOP
	foreach(sort(@added_index)){
		($name,$tid)=split(/: /,$_);

		print OUT <<EOP;
<LI><a href="/cgi-bin/get_cpn.pl?$tid">$name</a>
EOP
	}
	print OUT "</OL>", &make_trailer();






	untie(%XREF);
	untie(%TID_TO_PAR);
	untie(%CAPN);

	open (OUT,">I_new_entries.html") || die;
	print OUT <<EOP;
<html>
<head>
<title>
UCJEPS: Interchange Index to Names Recently Added To Main File
</title>
</head>
<body>
$page_top<br>&nbsp;
<H2 align="center">
Index to Names Recently Added To Main File
</h2>
$today
<hr>
<OL>
EOP
	foreach(@apparent_new_name){
		($name, $tid)=m/(.*): (.*)/;
		print OUT<<EOP;
<LI><a href="/cgi-bin/get_cpn.pl?$tid">$name</a>
EOP
	}
	print OUT "</OL>", &make_trailer();
	close(OUT);
	open (OUT,">${outdir}I_changed_entries.html") || die;
		print OUT<<EOP;
<html>
<head>
<title>
UCJEPS: Interchange Index to Recently Changed Entries
</title>
</head>
<body>
$page_top<br>&nbsp;
<H2 align="center">
Index to Recently Changed Entries
</h2>
$today
<hr>
<OL>
EOP

	foreach(@changed_entry){
		($name, $tid)=m/(.*): (.*)/;
		print OUT <<EOP;
<LI><a href="/cgi-bin/get_cpn.pl?$tid">$name</a>
EOP
	}
	print OUT "</OL>", &make_trailer();
	close(OUT);

	open(OUT, ">${outdir}LN2C.out") || die;
	print OUT <<EOP;
#append this to /cgi-bin/LN2C.pl. It is the index for searches
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
<a href="http://ucjeps.berkeley.edu/interchange/I_status_1+2_t.html">
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
<a href="http://ucjeps.berkeley.edu/interchange/I_status_1+2.html">
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

sub print_main_index{
	open(OUT, ">${outdir}I_indexes.html") || die;
	print OUT <<EOP;
<html>
<head>
<title>
UCJEPS: Main Interchange Search Page
</title>
</head>
<body>
<table width=100% bgcolor="#0000cc">
<tr>
<TD align="center"><font size=6 color="#ffdd00">
<font size=3>Jepson Flora Project</font><P>
<font size=7>J</font>EPSON
<font size=7>O</font>NLINE
<font size=7>I</font>NTERCHANGE
</font>
</td>
<td><img src="http://ucjeps.berkeley.edu/jeps.jpg" align=right alt="jeps logo"></td>
</td>
</tr>
</table>

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
	print OUT "</blockquote>\n";

	foreach $name (sort (keys(%{$indexes{$initial}}))){
		print OUT "$indexes{$initial}{$name}";
	}
	print OUT &make_trailer();
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
			$name=ucfirst(lc($name));


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
Index to Interchange Taxa in The Jepson Manual
</H2>
<UL>
EOP
	foreach(sort {$JM{$a} cmp $JM{$b}}(keys(%JM))){
		$initial =substr($JM{$_}, 0, 1);
		if($initial eq $prev_initial){
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
<a href="I_treat_index_${_}.html" ><font size=+4>$initial</font></a>
EOP
				}
				else{
					print OUT <<EOP;
<a href="I_treat_index_${_}.html" >$_</a>
EOP
				}
			}
			print OUT "$_\n";
			warn "initial: $initial\nprevious: $prev_initial\n";
		}
		$prev_initial=$initial;
	}

}

sub flatten_dbm {
	%flat_dbm=(
capn_db => flat_dbm_1,
tid_par => flat_dbm_2,
jmname_newname => flat_dbm_3,
name_to_code => flat_dbm_4,
"/jepson/JM_namehash" => flat_dbm_5,
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

		foreach $par (reverse(1 .. 9407)){
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
 See bad links in no_link.tmp

EOP
open(OUT,">no_link.tmp") || die;
print OUT @no_link;
close OUT;


}

sub load_links{
open(IN,"eppc_links") || die;
while(<IN>){
	next unless/\t/;
	chomp;
	($eppc_name,$link)=split(/\t/);

	if ($CPNNOAN{$eppc_name}){
		$eppc_link{$CPNNOAN{$eppc_name}}=qq{<a href="<a href=\"$link\">California Exotic Pest Plant Council</a>};
	}
	else{
		print "EPPC: $eppc_name not found in interchange\n";
push(@no_link, "EPPC: $eppc_name not found in interchange\n");
	}
}
close(IN);
#foreach(keys(%eppc_link)){
#print "EL: $_: $eppc_link{$_}\n";
#}


open(IN,"calphotos_plant_taxa.txt") || die;
while(<IN>){
	next unless/\|/;
	chomp;
	($cpname,$variant)=split(/\|/);
	foreach($cpname){
		s/ssp\./subsp./;
		s/ sp\..*//;
	}
	if($CPNNOAN{$cpname}){
		$CP{$CPNNOAN{$cpname}}++;
	}
	elsif($CPNNOAN{$variant}){
		$CP{$CPNNOAN{$variant}}++;
#for this to work, the variant needs to be the Interchange name and the link needs to be connected to the cp name
	}
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

	if ($CPNNOAN{$fna_name}){
		$fna_link{$CPNNOAN{$fna_name}}= qq{<a href="${link}$fna_taxon_id">$link_text</a>};
	}
	else{
push(@no_link, "FNA: $fna_name not found in interchange\n");
	}
	close(IN);
}
}

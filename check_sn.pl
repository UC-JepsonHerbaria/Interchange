$smasch_ID_file="../smasch_taxon_ids.txt";
$ICPN_file="icpn_current.txt";
open(IN, "$smasch_ID_file") || die;
while(<IN>){
	chomp;
	($code,$name,@residue)=split(/\t/);
	$TNOAN{$name}=$code;
}
open(ERR, ">check_sn_error.txt") || die;
open(NOCODE, ">check_sn_no_code.txt") || die;

{
open(IN, "$ICPN_file") || die "Couldnt open ICPN_current.txt\n";
local($/)="";
open(OUT, ">CPN_out.txt") || die;
while(<IN>){
	#unless (1 .. /PTERIDO/){
		#print " Dying colon--$lastline$_\n" if m/^.{3,25}:/;
	#}
	s/^=====.*\n.//;

	s/^\.//; #Get rid of leading periods  -  29 Sep 2006 by CAM
	s/LINK.*FNA.*\n//;
	s/LINK.*Check the California Weed.*\n//;
	s/  +/ /g;
	s/ $//;
	s/ \n/\n/g;
s/(...)Effort: @/$1\nEffort: @/;
	if(m/^(Admin|Family:)/){
		next;
	}

	if(m/^[A-Z][A-Z][A-Z]/){
		print OUT;
		next;
	}
	if(m/Current Status: 13/){
		++$count;
		#print "$count\n";
		next;
	}
	($name)=m/^(.*)/;

	if($name=~/ subsp\. .*var\. /){
		print ERR "skipping quadrinomial $name\n";
		#warn "skipping quadrinomial $name\n";
		next;
	}
	unless($TNOAN{&strip_name($name)}){
		warn "no code for $name stripped as ", &strip_name($name), "\n";
		print NOCODE  "no code for ", &strip_name($name), "\t$name\n";
	}

#Delete Rosatti's "{/...} lines
s/\n{\/.*}.*//g;
s/{\/.*?}//g;
s/\nCurrent Status:([^ ])/\nCurrent Status: $1/;

s/(Editorial Comments 2) +/$1: /;
s/Editorial Commens 1/Editorial Comments 1/;
s/ Summary:/Summary:/;
s/\nCurrent Name: *\n/\n/i;
s/\nCurrent Name: *$//i;

s/\342\200\234/"/g;
s/\342\200\235/"/g;
s/\342\200\231/'/g;
s/\342\200\230/'/g;
s/\342\200\246/.../g;
s/\342\200\241/&aacute;/;
s/\357\273\277//;
s/\342\200\223/&ndash;/g;
s/\303\274/&uuml;/g;
s/\303\253/&euml;/g;
s/\303\247/&ccedil;/g;
s/\305\223/&aelig;/g;
s/\305\240/&Scaron;/g;
s/\303\255/&iacute;/g;
s/\305\275/&eacute/;

s/\302\260/&deg;/g;
s/\302\274/1\/4/g;
s/\303\201/&Aacute;/g;
s/\303\211/&Eacute;/g;
s/\303\214/&Iacute;/g;
s/\303\216/&Icirc;/g;
s/\303\226/&Ouml;/g;
s/\303\227/&agrave;/g;
s/\303\240/&aacute;/g;
s/\303\241/&acirc;/g;
s/\303\242/&auml;/g;
s/\303\244/&aelig;/g;
s/\303\246/&ccedil;/g;
s/\303\247/&egrave;/;


s/\303\201/&Aacute;/g;
s/\303\251/&eacute;/g;
s/\303\263/&oacute;/g;
s/\303\250/&egrave;/g;
s/\303\266/&ouml;/g;
s/<#e9>/&eacute;/g;
s/<#fc>/&uuml;/g;
s/\303\241/&aacute;/g;
s/\303\261/&ntilde;/g;
s/\303\262/&ograve;/g;
s/\303\242/&acirc;/g;
s/<#f6>/&ouml;/g;
#s/\x9f/&uuml;/g;
#s/\x8e/&ntilde;/g;
#s/\x87/&aacute;/g;
#s/\xC3\x89/&Eacute;/g;
##s/\xdb/"/g;
#s/\x9a/&ouml;/g;
#s/\x91/&euml;/g;
#s/\x8a/&auml;/g;
#s/\x8d/&ccedil;/g;
#s/\xcf/&uacute;/g;
#s/\x97/&oacute;/g;
#s/\xa1/--/g;
#s/\x83/&Eacute;/g;
#s/\x85/&Ouml;/g;
##s/\xc3\xb1/&ntilde;/g;
##s/\xc3\xc5/&Scaron;/g;
##s/\xc3\xc2/1\/4/g;


	@lines=split(/\n/);

############################
	foreach $j (0 .. $#lines){
		if($lines[$j] =~ /^(Family|Author Notes)/){
			print ERR "\nPossible collapsed entries (space or tab on like supposed to be blank?) after $name\n>>>>>>$_\n<<<<<<" unless ($j==1||$j==2||$j==3);
			warn "\nPossible collapsed entries (space or tab on like supposed to be blank?) after $name\n>>>>>>$_\n<<<<<<" unless ($j==1||$j==2||$j==3);
		}
	}

#print "$name\n";


	if($#lines <= 3){
		print ERR "\n\nPossible bad blank after $name\n$_\n";
		warn "\n\nPossible bad blank after $name\n$_\n";
		next;
	}

	if(m/\nCurrent Status:.*\nCurrent Status:.../ms){
		print ERR "Multiple statuses:\n$_\n";
		warn "Multiple statuses:\n$_\n";
	}
	($name)=m/^(.*)/;
	if($seen{$name}++){
		print ERR "Second instance: $name\n$_\n";
		warn "Second instance: $name\n$_\n";
	}
	if(m/TJM, as minor variant of/){
		s/TJM, as minor variant of ([A-Z][a-z][^ ]+ [a-z][^ ]+ (var\.|subsp\.) [a-z]+)/TJM, as minor variant of <sn>$1<\/sn>/ ||
		s/TJM, as minor variant of ([A-Z][a-z][^ ]+ [a-z][a-z-]+)/TJM, as minor variant of <sn>$1<\/sn>/;
	}

	$open= s/<sn>/<sn>/g;
	$close= s|</sn>|</sn>|g;
	push(@SN, "$name: [SN]  open: $open close $close") unless $open==$close;
	@words=split(/\s+/);
	foreach(@words){
		if (m/(.*?([\200-\377][\200-\377]?).*)/){
			unless ($seen{$2}++){
				print ERR "UNCONVERTED ACCENT: $1 $2\n";
				#print ERR "\ns/\\x",sprintf("%lx",unpack('U*',$1)),"//g;", " Unconverted accent: $name $_\n";
				warn "UNCONVERTED ACCENT: $1 $2\n";
				##print join(" ", @words),"\n";
			}
		}
	}
#Current Status: pending 8, accepted name for taxon not occurring in CA (erroneous reports, misapplication of names, misidentifications, other exclusions)
	foreach (@lines[1 .. $#lines]){
		next if/^-?done/;
		(s/^Effort: */EF: / ||
		s/^Family: */FA: / ||
		s/^Source: */SR: / ||
		s/^Source ([a-z]) *: */SR$1: / ||
		s/^Summary: */SM: / ||
		s/^Notes on Publication of Name: */POP: / ||
		s/^PAODO?P: */POP: / ||
		s/^DAOPO?P: */POP: / ||
		s/^[PD]OPO[PBC]: */POP: / ||
		s/^[DP]OP: */POP: / ||
		s/^KM citation: */KMC: / ||
		s/^Comments?: */CT: / ||
		s/^Editorial Comments? ([0-9-]+): */CTE$1: / ||
		s/^Assigned to: */AT: / ||
		s/^Assignment date: */AD: / ||
		s/^Current Status Authority: */CSA: / ||
		s/^Current Status: *(\d+[a-z]?).*/CS: $1/ ||
		s/^Current Status: *(pending) (\d+[a-z]?).*/CS: $1_$2/ ||
		s/^Current Status: *tentative (\d+[a-z]?).*/CS: $1_[t]/ ||
		s/^Current Status: */CS: / ||
		s/^Current Status Date: */DD: / ||
		s/^Decision [Dd]ate: */DD: / ||
		s/^Current [Nn]ame: */CN: / ||
			s/^Current [Nn]ame \(T\): /CN_T: /  ||
		s/Correspondence: */CR: / ||
		s/Correspondence ([0-9]+): */CR$1: / ||
		s!^TJM synonyms: *!TSN: ! ||
		s!^TJM2 synonyms: *!TSN2: ! ||
		s!^Current JFP [Ss]ynonyms?: *!JFPS: ! ||
		s!^TJM2 misapplied names?: *!TMN: ! || #this line added to account for new tag
		s!^TJD?M misapplied names?: *!TMN: ! || 
		s!^Current JFP [Mm]isapplied names?: *!JFPMN: ! ||
		s/^Literature: */RL: / ||
		s/^Literature ([a-z]): */RL$1: / ||
		s/^Recent Literature ([a-z]): */RL$1: / ||
		s/^Geography: */GG: / ||
		s/^AN: /AN: /  ||
		s/^Author notes: /AN: /  ||
		s/^Author Notes: /AN: /  ||
		s/^LINK: /LINK: /  ||
		s/^Variant [Ss]pelling: /VS: /  ||
		s/Types Info: */TI: / ||
		s/^Synonyms not explicitly cited in TJM: /SNTJM: /  ||
		s/Synchronization with TJM2:/SNCH:/||
		s/Pending:/PND:/) ||
		push(@badtag, "$name [tag]: |$_");

	}



		($name)=m/^([^\s]+)/;

		s/Current Status: *(pending) (\d+[a-z]?).*/Current Status: $1_$2/;

	print OUT;
	$lastline=$_;
	}

}
foreach(sort(@badtag, @SN)){
	print ERR "$_\n" unless m/Version Date:/;
	warn "$_\n" unless m/Version Date:/;
}
sub strip_name{
	local($_) = @_;
	return unless $_;
#print "SAPONARIA: $_" if m/saponaria/;
if(m/Encelia californica .*Encelia farinosa/){
return("Encelia californica X Encelia farinosa");
}
if(m/Encelia farinosa .*Encelia frutescens/){
return("Encelia farinosa X Encelia frutescens");
}
if(m/Aloe saponaria.*A.*striata.*/){
return("Aloe saponaria X Aloe striata");
}
if(m/Spartina alterniflora .* Spartina foliosa.*/){
return("Spartina alterniflora X Spartina foliosa");
}
s/Uva-Ursi pechoensis.*/Uva-Ursi pechoensis/;



	s/^ *//;
	s/ x / X /;
s/&times;/X /;
s/ ex [A-Z][a-z.]+$//;
s/^[xX] ([A-Z][a-z]+ [a-z]+).*/$1/;

s/Ait. f\./Ait. filius/g;
s/Bakh. f\./Bakh. filius/g;
s/Balf. f\./Balf. filius/g;
s/Burm. f\./Burm. filius/g;
s/Delar. f\./Delar. filius/g;
s/Forst. f\./Forst. filius/g;
s/Gaertn. f\./Gaertn. filius/g;
s/Haage f\./Haage filius/g;
s/Haller f\./Haller filius/g;
s/Hallier f\./Hallier filius/g;
s/Hedw. f\./Hedw. filius/g;
s/Hook. f\./Hook. filius/g;
s/Jacq. f\./Jacq. filius/g;
s/L\. f\. sulcat/f. sulcat/g;
s/L. f\./L. filius/g;
s/Lestib. f\./Lestib. filius/g;
s/Lindb. f\./Lindb. filius/g;
s/Lindm. f\./Lindm. filius/g;
s/Luer f\./Luer filius/g;
s/Michx. f\./Michx. filius/g;
s/Phil. f\./Phil. filius/g;
s/Rech. f\./Rech. filius/g;
s/Rehb. f\./Rehb. filius/g;
s/Reichenb. f\./Reichenb. filius/g;
s/Schult. f\./Schult. filius/g;
s/Wallr. f\./Wallr. filius/g;
s/Wendl. f\./Wendl. filius/g;
s/Fragaria × ananassa Duchesne var. cuneifolia.*/Fragaria × ananassa var. cuneifolia/ ||
s/Trifolium variegatum Nutt. phase (\d)/Trifolium variegatum phase $1/ ||
	s/^([A-Z][a-z]+) (X?[-a-z]+).*(subsp.) ([-a-z]+).*(var\.) ([-a-z]+).*/$1 $2 $3 $4 $5 $6/ ||
	s/^([A-Z][a-z]+ [a-z]+) (X [-A-Z][a-z]+ [a-z]+).*/$1 $2/ ||
	s/^([A-Z][a-z]+) (X [-a-z]+).*/$1 $2/ ||
	s/^([A-Z][a-z]+ [a-z]+) (× [-A-Z][a-z]+ [a-z]+).*/$1 $2/ ||
	s/^([A-Z][a-z]+) (× [-a-z]+).*/$1 $2/ ||
	s/^([A-Z][a-z]+) (X?[-a-z]+).*(subvar\.|ssp\.|var\.|f\.|subsp\.) ([-a-z]+).*/$1 $2 $3 $4/ ||
	s/^([A-Z][a-z]+) (X?[-a-z]+).*/$1 $2/||
	s/^([A-Z][a-z]+) [A-Z(].*/$1/;
#print "SAPONARIA: $_" if m/saponaria/;
	return ($_);
}


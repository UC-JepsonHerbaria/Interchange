#Use this to check caplantnames after it comes from Rosatti,
#and before submissions from Jeff and Margriet go to him.
#{
#open(IN,"variant_spelling.out") || die;
#local($/)="";
#while(<IN>){
#($name,$variant,$full_name)=m/^(.*)\n(.*)\n(.*)/;
#$variant{$full_name}=$variant;
#}
#}
#foreach(keys(%variant)){
##print "$_\n";
#}
#close(IN);
warn <<EOP;
Croton setiger -setigerus problem and Muller. Arg. accent problem
EOP



#$treat_hash="/!proj/interchange/update - 4 Nov 2005/flat_dbm_6";
$treat_hash="output/flat_dbm_6.txt";
die $! unless -e $treat_hash;
open(IN,"$treat_hash") || die;
$/="";
while(<IN>){
chomp;
($par,$entry)=split(/\n/);
	if($entry=~m/family_par/){
$_=$entry;
($last_family)=m|<family_name> *([^>]+) *</family_name>|;
}
	elsif($entry=~m/<genus_par>/){
$_=$entry;
($name)=m|<genus_name>([^>]+)</genus_name>|;
$name=ucfirst(lc($name));
$stored_genus{$name}=<<EOP;

$name
Family: $last_family
Source: added automatically from TJM
Current Status: 15, genus name
Current Status Authority: not applicable
Effort: @

EOP
#print "$name\n$stored_genus{$name}\n\n";
}
}

close(IN);

#open(IN,"ICPN_from_TJM2") || die;
#$/="";
#while(<IN>){
#chomp;
#$new_from_TJM2{
#}
{
#open(IN, "caplantnames.txt") || die;
local($/)="";
open(OUT, ">cpn_out.txt") || die;
while(<>){
unless (1 .. /PTERIDO/){
die " Dying colon--$lastline$_\n" if m/^.{3,25}:/;
}
s/^=====.*\n.//;

s/^\.//; #Get rid of leading periods  -  29 Sep 2006 by CAM
s/LINK.*FNA.*\n//;
s/LINK.*Check the California Weed.*\n//;
s/  +/ /g;
s/ $//;
s/ \n/\n/g;
	if  (1 .. /PTERIDOPH/){
print OUT;
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
#if($variant{$name}){
#s/$/$variant{$name}\n/;
#warn $_;
#}

s/(Editorial Comments 2) +/$1: /;
s/Editorial Commens 1/Editorial Comments 1/;
s/ Summary:/Summary:/;

s/‘/'/g;
s/—/--/g;
s/Á/&Aacute/g;
s/°/&deg;/g;
s/º/&deg;/g;
s/(\d\d)\?(\d)/$1&deg;$2/g;
s/é/&eacute;/g;
s/ö/&ouml;/g;
s/á/&aacute;/g;
s/\\'e1/&aacute;/g;
s/ü/&uuml;/g;
s/ä/&auml;/g;
s/É/&Eacute;/g;
s/ñ/&ntilde;/g;
s/ó/&oacute;/g;
s/ê/&ecirc;/g;
s/ç/&ccedil;/g;
s/í/'/g;
s/–/-/g;
s/±/&plus_minus;/g;
s/¼/1\/4/g;
s/½/1\/2/g;
s/qqww/<sn>/g;
s/zzxx/<\/sn>/g;
	@lines=split(/\n/);
foreach $j (0 .. $#lines){
if($lines[$j] =~ /^(Family|Author Notes)/){
die "Dying collapsed after $name\n$_\n" unless ($j==1||$j==2||$j==3);
}
}

#print "$name\n";


if($#lines <= 3){
#warn "Possible bad blank after $name\n$_\n";
print "\n\nPossible bad blank after $name\n$_\n";
next;
}

	($name)=m/^(.*)/;
if(m/TJM, as minor variant of/){
s/TJM, as minor variant of ([A-Z][a-z][^ ]+ [a-z][^ ]+ (var\.|subsp\.) [a-z]+)/TJM, as minor variant of <sn>$1<\/sn>/ ||
s/TJM, as minor variant of ([A-Z][a-z][^ ]+ [a-z][a-z-]+)/TJM, as minor variant of <sn>$1<\/sn>/;
}

	$open= s/<sn>/<sn>/g;
	$close= s|</sn>|</sn>|g;
	push(@SN, "$name: [SN]  open: $open close $close") unless $open==$close;
	@words=split(/\s+/);
	foreach(@words){
if (m/[\200-\377]/){
unless ($seen{$_}++){
		print "$name $_\n";
#print join(" ", @words),"\n";
}
}
	}
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
		s/^Synonyms not explicitly cited in TJM: /SNTJM: /)  ||
push(@badtag, "$name [tag]: |$_");

}



		($name)=m/^([^\s]+)/;
		if(m/15.*genus name/){
			$GN=$name;
$added_genus{$name}++;
		}
		elsif($name ne $GN){
			if ($stored_genus{$name}){
unless($added_genus{$name}++){
				print OUT $stored_genus{$name};

				$GN=$name;
}
			}
		}



print OUT;
$lastline=$_;
}

}
foreach(sort(@badtag, @SN)){
print "$_\n" unless m/Version Date:/;
}
foreach(sort(@added_genus, @SN)){
print "$_\n" unless m/Version Date:/;
}

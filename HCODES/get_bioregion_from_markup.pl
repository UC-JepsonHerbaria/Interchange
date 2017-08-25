
@NCoR = ('NCoRO','NCoRI','NCoRH');
@CaR = ('CaRF','CaRH');
@cSN = ('cSNF', 'cSNH');
@nSN = ('nSNF', 'nSNH');
@sSN = ('sSNF', 'sSNH');
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
foreach (@CA){
if(m/^([a-z])(.*)/){
$sortstring{$_} = "$2$1";
$sortstring{$_} =~ s/c$/o/;
}
else{
$sortstring{$_} = $_;
}
}
@CA = sort bycaps (@CA);
sub bycaps {
$sortstring{$a} cmp $sortstring{$b} ||
$a cmp $b
}
grep($qualified{$_}++,@CA);
foreach $i (0 .. $#CA){
$qualified{$CA[$i]} = $i;
}
#print join ("\n",sort bycaps keys %qualified);

for $i (0 .. 34){
vec($nullvec,$i,1) = 0;
}

$/="";
#open(IN, "/jepson/markup_plusFT") || die;
open(IN, "new_markup") || die;


$complete_name="";

while(<IN>){
#next unless m/\(exc .*\(exc/;
	if(m|<family_name>\s*(.*)\s*</family_name>|){
		$F_N=$1;
		if(m|<common_name level="family">\s*(.*)\s*</common_name>|){
			$F_N .= "   $1";
		}
		#print "\n$F_N\n";
	}
	if (m/<genus_name>([^<]+)/){
		$genus=ucfirst(lc($1));
	}

	if(m/sp_par/){
		$taxaut="";
	#<sp_name origin="native">A. septentrionale</sp_name>
#<taxaut>(L.) Hoffm.</taxaut>
		if(m/<sp_name origin="(native|intro)">([^<]+)/){
			($spname=$2)=~s/[A-Z]\. +//;
			($taxaut)=m|<taxaut>\s*(.*)\s*</taxaut>|;
			$complete_name="$genus $spname $taxaut";
			$spname .= " $taxaut";
		}
		elsif(m/<infrasp_name origin="(native|intro)">([^<]+)/){
			$i_n=$2;
			($taxaut)=m|<taxaut>\s*(.*)\s*</taxaut>|;
			$complete_name="$genus $spname $i_n $taxaut";
	#<infrasp_name origin="native">var. tenuissimus</infrasp_name>
#<taxaut>Mert. & Koch</taxaut>&quad;
		}

		elsif(m/<infrasp_name origin="(native|intro)" style="full_name">[A-Z]\. +([a-z-]+.*(var\.|ssp\.) [^<]+)/){
			$i_n=$2;
			($taxaut)=m|<taxaut>\s*(.*)\s*</taxaut>|;
			$complete_name="$genus $i_n $taxaut";
#<infrasp_name origin="native" style="full_name">A. trichomanes  L.  ssp. trichomanes</infrasp_name>
		}

		elsif(m/<phase_name>([^<]+)/){
			$complete_name="$genus $1";
		}
		else{
			($name)=m/^(.*\n.*)/;
			warn "$name sp_par without species element\n";
		}
	}
	if(m/<\/NDS>/){
		($bior)=m/<NDS[^>]*>\s*(.*)\s*<\/NDS>/;
$raw_bior=$bior;
		$complete_name=~s/ *$//;
		$complete_name=~s/ssp\./subsp./;
		($old_h_code)=m/<HCODE[^>]*>\s*(.+)\s*<\/HCODE>/;
		foreach($bior){
#warn "\nSTART: $_\n";
		#take care of n SN, n & c SNF etc
if(m/[scnwe] SN[^E]/ ||  m/[scnwe] SN$/){

		#this added June 27,1998
				$_ = &SNkludge($_) unless (m/exc SN/);
#warn "after SN: $_\n";
			}


#############
#edge kludges
			if(m/edge/){
				$_ = &edgekludge($_);
#warn "After edge: $_\n";
			}
#############

#adjacent kludges
			elsif(m/adjacent/){
				$_ = &adjkludge($_);
#warn "After adjacent: $_\n";
			}

			if(m/PR/){
				$_ = &PRkludge($_);
#warn "After PR: $_\n";
			}

#############
			s/s CA([^-])/sCA$1/;
			s/ ?\(?[Ff]ormerly[^)]+\)//;
			s/([ns]) ChI/$1ChI/g;
			s/n (DMoj)/$1 (exc DMtns)/;
			s/(n SNE)/$1 (exc WaI)/;
			s/e NW/NW (exc NCo)/;
		
			s/CA-FP/CA_FP/;
			s/W&I/WaI/;
			s/[?;]//g;

#warn "After subs: $_\n";
			@poslocs = split(/[ .;,]+/,$_);
	#s SN, Teh, SnGb, SnBr (and adjacent SCo), e PR, s SNE, D
###
			foreach $loc (@poslocs){
#warn "loc: $_\n";
###
				$temploc=quotemeta($loc);
				unless(m/\(exc[^)]+$temploc/){
					if($loc=~s/\)//){ push(@parenstr, "$name:$string") if defined($qualified{$loc});}
				}
				if (defined($qualified{$loc} )){
					$rawlocs{$loc}++;

				}
 				if (@$loc){
					grep($rawlocs{$_}++,@$loc);
 				}
			}
	
			if( m/exc\.? /){
				s/except/exc/;
				($exception_string = $_)=~ s/.*exc[. ]+//;
				$exception_string =~ s/.*except //;

#warn "ES: $exception_string\n";

				$exception_string =~ s/\).*//;

#NB the exception would be n NW following the split, 
# this is how partial regions are not excluded

				@all_exceptions = split(/, /,$exception_string);


					foreach $exception (@all_exceptions){
#warn "Exception: $exception\n";
						if($exception eq "coast"){
							undef($rawlocs{"CCo"});
							undef($rawlocs{"SCo"});
							undef($rawlocs{"NCo"});
							next;
						}
						undef($rawlocs{$exception}) if defined($qualified{$exception});
						grep(undef($rawlocs{$_}),@$exception) if @$exception;
					}
				}

				$distvec = $nullvec;
	 			foreach( keys(%rawlocs)){
 					if (defined($rawlocs{$_})){
						vec($distvec,$qualified{$_},1) = 1;
					}
				}
				$bitstr = unpack ("b*", $distvec);
				$hstr= unpack("H*", pack("b*",unpack ("b*", $distvec)));
				$bitstr2 =unpack("b*",pack("H*",$hstr));
#
#warn "$_\n$hstr\n$bitstr\n$bitstr2\n";
#

#warn "$line" if $hstr =~ /^0+$/;
				$name =~ s/<#cb>/E/g;
foreach($complete_name){
s/&mathx;/X-/g;
s/([A-Z]\.) ([A-Z]\.)/$1$2/g;
}
				$h_code=  unpack("H*", pack("b*",unpack ("b*", $distvec)));
				$bitstr2 =unpack("b*",pack("H*",$old_h_code));
				#print  $complete_name, "\t", unpack("H*", pack("b*",unpack ("b*", $distvec))),"\n";
				print  &strip_name($complete_name), "\t$raw_bior\t", unpack ("b*", $distvec),"\n", "$h_code\n" if $complete_name =~/tinctoria|eurycephal/;
				#print  $complete_name, "\nnew: $raw_bior\nnew:", unpack("H*", pack("b*",unpack ("b*", $distvec))),"old : $old_h_code\nnew$bitstr\nold$bitstr2\n\n" unless $h_code eq $old_h_code;
				undef(%rawlocs);	


			}
		}
	}



#print "$complete_name\t$bior\n";
close(IN);


sub PRkludge{
local($_)=@_;
$prev=$_;
	if(m/PR \(/){
		if (m/PR (\([^)]+\))/){
			$parens=$1;
			unless($parens =~ /San J|SnJt|scattered/){
s/PR (\([^)]+\))/$& (exc SnJt)/;
				}
			}
		}
				elsif(m/n&?e PR/){
s/PR/PR (incl SnJt)/;
		}
				else{
					s/([a-z] PR)/$1 (exc SnJt)/;
				}
#warn "$prev\n";
###warn "$_\n" unless $_ eq $prev;

$_;
}
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
###warn "$prev\n";
###warn "$_\n" unless $_ eq $prev;
$_;
}
	#s SN, Teh, SnGb, SnBr (and adjacent SCo), e PR, s SNE, D
sub adjkludge {
local($_)=@_;
$prev=$_;
s/(adjacent [snew ]*DMoj)/$1 (exc DMtns)/;
s/ D and adjacent CA.FP/ D, PR, TR, Teh, sSN/;
s/nSNE, adjacent CA.FP/nSNE, sSNH/;
###warn "$prev\n";
###warn "$_\n" unless $_ eq $prev;
$_;
}
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
$_;
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
	s/^([A-Z][a-z]+) (X?[-a-z]+).*(ssp\.|var\.|f\.|subsp.) ([-a-z]+).*/$1 $2 $3 $4/ ||
	s/^([A-Z][a-z]+) (X?[-a-z]+).*/$1 $2/||
	s/^([A-Z][a-z]+) [A-Z(].*/$1/;
warn "SAPONARIA: $_" if m/saponaria/;
	return ($_);
}


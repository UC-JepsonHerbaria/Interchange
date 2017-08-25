$/="";
open(IN, "update/flat_dbm_6") || die;
open(OUT, ">update/hcode_from_markup.out") || die;
@treat=(<IN>);
@treat=reverse(@treat);

$complete_name="";

foreach(@treat){
s/ghcode/HCODE/g;
$entry=$_;
	if(m|<family_name>\s*(.*)\s*</family_name>|){
		$F_N=$1;
		if(m|<common_name level="family">\s*(.*)\s*</common_name>|){
			$F_N .= "   $1";
		}
		print OUT "\n$F_N\n";
		#print "\n$F_N\n\n";
next;
	}
	if (m/<genus_name>([^<]+)/){
		$genus=$1;
next;
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

		elsif(m/<infrasp_name origin="(native|intro)" style="full_name">[A-Z]\. +([a-z-]+.*?(var\.|ssp\.) [^<]+)/){
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
	if(m/<HCODE>([^<]+)/){
$hcode=$1;
if(m/<NDS>(.*)<\/NDS>/){
$dist_str=$1;
}
elsif( m/<JDS>(.*)<\/JDS>/){
$dist_str=$1;
}
$complete_name=~s/  */ /g;
$complete_name=~s/  *$//g;
$complete_name=~s/&mathx;/X-/g;
$complete_name=~s/ssp\./subsp./g;
 $bitstr2 =unpack("b*",pack("H*",$hcode));
 $bitstr2 =~s/00000$//;
print OUT "$complete_name\t$hcode\n";
#print "$complete_name\n$dist_str\n$bitstr2\n\n";
		if(length($complete_name) <3){
		print OUT "$complete_name\t$hcode\n";
		die;
		}
		if(length($complete_name) >200){
		print OUT "$complete_name\t$hcode\n";
		die;
		}
}
else{
#print "$complete_name\t0000000000\n";
}
}

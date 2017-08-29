use lib "/Users/davidbaxter/DATA/";
use flatten;
use BerkeleyDB::Hash;

%HCODE_HASH=();
#%BE=();
$file="/JEPS-master/Interchange/output/tidsyn_hcode_hash";
	tie %HCODE_HASH, "BerkeleyDB::Hash", -Filename => $file, -Flags    => DB_CREATE or die "Cannot open file $filename: $! $BerkeleyDB::Error\n" ;



open(IN, "/Users/davidbaxter/DATA/eFlora/yellow_flag_processing/eflora_KML_Moe/outputs/tid_HCODE_cch_out.txt") || die;
while(<IN>){
($tid,$hcode)=m/^(.*)\t(.*)/;
++$total;
print "$total added\n" unless $total % 5000;
next if $taxon_id = m/^[A-Z]/; #skip records that are in ICPN or eFlora that have no tid yet, these have a taxon name in the $taxon_id field
#next if $taxon_id==115; #add values here if you desire some to be excluded
++$subtotal;

print $tid,"==>",$hcode,"\n";

$HCODE_HASH{$tid}=$hcode;

}
print "$subtotal out of $total retained\n";

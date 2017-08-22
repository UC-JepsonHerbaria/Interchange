use BerkeleyDB;
$file="/usr/local/web/ucjeps_data/interchange_KWID";
tie(%kwid_hash, "BerkeleyDB::Hash", -Filename=>$file)|| print "Couldnt open $file: $!";
$file="/usr/local/web/ucjeps_data/interchange_hold_KWID";
tie(%hold_kwid_hash, "BerkeleyDB::Hash", -Filename=>$file)|| print "Couldnt open $file: $!";
foreach(keys(%kwid_hash)){
print "$_\n$kwid_hash{$_}\n\n" unless $hold_kwid_hash{$_};
}

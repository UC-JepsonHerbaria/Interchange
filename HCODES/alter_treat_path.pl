use BerkeleyDB;

tie %store_treat_path,
"BerkeleyDB::Hash", -Filename => 
"TJM_treat_path"
or die "Cannot open file treat_path: $! $BerkeleyDB::Error\n" ;
#$store_treat_path{18573}="";
#$store_treat_path{18584}="";
#$store_treat_path{76816}="";
#$store_treat_path{19440}="";
#$store_treat_path{20070}="";
#$store_treat_path{80520}="";
#$store_treat_path{59422}="";
#$store_treat_path{26579}="";
#$store_treat_path{26586}="";
#$store_treat_path{26591}="";
#$store_treat_path{59442}="";
#$store_treat_path{59443}="";
#$store_treat_path{26599}="";
#$store_treat_path{26601}="";
#$store_treat_path{26608}="";
#$store_treat_path{26611}="";
#$store_treat_path{50700}="";
#$store_treat_path{26675}="";
#$store_treat_path{26681}="";
#$store_treat_path{45873}="";
#$store_treat_path{85883}="";
#$store_treat_path{66906}="";
#$store_treat_path{45887}="";
#$store_treat_path{78555}="";
#$store_treat_path{85882}="";
#$store_treat_path{45894}="";
#$store_treat_path{45896}="";
#$store_treat_path{45901}="";
#$store_treat_path{45897}="";
#$store_treat_path{73918}="";
#$store_treat_path{45899}="";
#$store_treat_path{45891}="";
#$store_treat_path{85881}="";
#$store_treat_path{81827}="";
#$store_treat_path{81828}="";
#$store_treat_path{81829}="";
#$store_treat_path{85880}="";
#$store_treat_path{81830}="";
#$store_treat_path{81831}="";
foreach(keys(%store_treat_path)){
print "$_: $store_treat_path{$_}\n";
}
untie %store_treat_path;

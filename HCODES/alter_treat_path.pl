#!perl

use DB_File;
$file="JM_treatments_h";
tie(%TREAT, 'DB_File',$file) || die;
#while(($key,$value)=each(%TREAT)){
#if ($value=~/L. minuta/){
#print $key, $value, "\n";
#$TREAT{$key}=~s/3--10 cm/3--10 mm/;
#}
#}
$TREAT{8329}=~s/ffffffff07/fffdffff03/;
print $TREAT{8329};

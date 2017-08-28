#!/usr/bin/perl
use GD;
open (GIF,"calmap300.gif") || die $!;
              $map = newFromGif GD::Image(GIF) || die "Cant open basemap\n";
              close GIF;

       use CGI;                             # load CGI routines
       $q = new CGI;                        # create new CGI object


$nullvec="";
for $i (0 .. 39){
vec($nullvec,$i,1) = 0;
}
while(<DATA>){
chomp;
($region,$mapcoord, $mapcolor,$longregion,$province) = split(/\t/, $_);
$prov{$region}=$sort_order++;
$parent{$region}=$province;
$expand{$region}=$longregion;
push(@regions,$region);
#hash with colors associated with region
$colors{$region} = $mapcolor;
#hash withcoordinates associated with region
$coord{$region} = $mapcoord;
}
#die;
#this sort is important, since it establishes the order of the bit vector,
#which should have been generated following a similar sort
#make sure here's not a blank line at data's end
foreach (@regions){
if(m/^([a-z])(.*)/){
$sortstring{$_} = "$2$1";
$sortstring{$_} =~ s/c$/o/;
}
else{
$sortstring{$_} = $_;
}
}
@regions=sort bycaps (@regions);
sub bycaps {
$sortstring{$a} cmp $sortstring{$b} ||
$a cmp $b
}
#Query string will replace this file read
undef(%prov_seen);
if($ENV{'QUERY_STRING'} =~/^..........$/){
$hc=$ENV{'QUERY_STRING'};
}
$distvec = $nullvec;
	#translate hex code to bit vector
#warn unpack("b*",pack("H*",$hcode)), "\n";
$distvec = pack("b*", unpack("b*",pack("H*",$hc)));
 $white = $map->colorClosest(255,255,255); # find white
$black = $map->colorClosest(0,0,0); # find black
$red = $map->colorAllocate(255,0,0); # find red
 $blue = $map->colorAllocate(0,0,255);
foreach $r (sort {$prov{$regions[$a]} <=> $prov{$regions[$b]}}(0 .. 34)){
if(vec($distvec,$r,1)){
##only allocate the colors if you need them
$regioncolor = $map->colorAllocate(split(/,/,$colors{$regions[$r]})) ;
warn "$r:$coord{$regions[$r]}\n";
if($regions[$r] =~ /DMtns/){
$map->fill(119,125,$regioncolor);
$map->fill(130,121,$regioncolor);
$map->fill(151,171,$regioncolor);
$map->fill(151,132,$regioncolor);
$map->fill(161,144,$regioncolor);
}
elsif($regions[$r] =~ /ChI/){
        if($regions[$r] =~ /nChI/){
$map->fill(81,173,$regioncolor);
$map->fill(86,172,$regioncolor);
}
elsif($regions[$r] =~ /sChI/){
$map->fill(110,184,$regioncolor);
$map->fill(110,194,$regioncolor);
}
}
elsif($regions[$r] =~ /SCoRI/){
$map->fill(64,121,$regioncolor);
$map->fill(79,137,$regioncolor);
$map->fill(87,145,$regioncolor);
}
elsif($regions[$r] =~ /SNE/){
$map->fill(99,90,$regioncolor);
$map->fill(115,98,$regioncolor);
}
else {
$map->fill(split(/,/,$coord{$regions[$r]}), $regioncolor);
}
}
}

$map->fill(310,119,$black);
$map->fill(43,345,$black);

       print $q->header(-type=>'image/gif',-expires=>'+3d');
binmode(STDOUT);
print STDOUT $map->gif;
close (STDOUT);

#region <tab> coordinates<tab>RGB color
__END__
CCo	51,118	96,154,131	Central Coast	California Floristic Province
CaRF	46,41	194,222,172	Cascade Range Foothills California Floristic Province
CaRH	55,36	97,136,0	High Cascade Range	California Floristic Province
DMoj	140,140	251,240,192	Mojave Desert	Desert Province
DMtns	130,122	255,100,13	Desert Mountains	Desert Province
DSon	165,180	235,216,100	Sonoran Desert	Desert Province
KR	26,20	134,157,86	Klamath Ranges	California Floristic Province
MP	67,28	236,222,160	Modoc Plateau	Great Basin Province
NCo	6,34	0,100,0	North Coast	California Floristic Province
NCoRH	30,46	137,204,149	High North Coast Ranges California Floristic Province
NCoRI	38,66	137,204,149	Inner North Coast Ranges	California Floristic Province
NCoRO	19,41	137,204,149	Outer North Coast Ranges	California Floristic Province
PR	140,186	207,123,169	Peninsular Ranges	California Floristic Province
SCo	117,171	155,48,255	South Coast	California Floristic Province
SCoRI	60,118	109,212,185	Inner South Coast Ranges	California Floristic Province
SCoRO	77,149	109,212,185	Outer South Coast Ranges	California Floristic Province
SNE	98,88	231,238,6	East of Sierra Nevada	Great Basin Province
ScV	50,66	187,255,0	Sacramento Valley	California Floristic Province
SnBr	138,165	236,202,255	San Bernardino Mountains	California Floristic Province
SnFrB	51,103	209,254,237	San Francisco Bay Area	California Floristic Province
SnGb	119,164	236,202,255	San Gabriel Mountains	California Floristic Province
SnJV	81,120	215,255,134	San Joaquin Valley	California Floristic Province
SnJt	143,175	207,123,169	San Jacinto Mountains	California Floristic Province
Teh	107,149	177,197,222	Tehachapi Mountain Area California Floristic Province
WTR	102,158	236,202,255	Western Transverse Ranges	California Floristic Province
WaI	110,100	198,178,71	White and Inyo Mountains	Great Basin Province
Wrn	72,20	255,165,0	Warner Mountains	Great Basin Province
cSNF	82,101	152,192,247	c Sierra Nevada Foothills	California Floristic Province
cSNH	88,93	78,190,234	c High Sierra Nevada	California Floristic Province
nChI	81,173	221,160,221	n Channel Islands	California Floristic Province
nSNF	62,72	152,192,247	n Sierra Nevada Foothills	California Floristic Province
nSNH	72,66	78,190,234	n High Sierra Nevada	California Floristic Province
sChI	109,193	221,160,221	s Channel Islands	California Floristic Province
sSNF	102,135	152,192,247	s Sierra Nevada Foothills	California Floristic Province
sSNH	107,120	78,190,234	s High Sierra Nevada	California Floristic Province

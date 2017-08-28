#!/usr/bin/perl
use GD;
open (GIF,"calmaptrim4.gif") || die $!;
#binmode(GIF);
              $map = newFromGif GD::Image(GIF) || die "Cant open basemap\n";
              close GIF;

       use CGI;                             # load CGI routines
       $q = new CGI;                        # create new CGI object


$nullvec="";
for $i (0 .. 39){
vec($nullvec,$i,1) = 0;
}
while(<DATA>){
#print;
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
#warn "$r:$coord{$regions[$r]}\n";
if($regions[$r] =~ /DMtns/){
$map->fill(283,271,$regioncolor);
$map->fill(305,265,$regioncolor);
$map->fill(350,287,$regioncolor);
$map->fill(372,311,$regioncolor);
$map->fill(353,372,$regioncolor);
}
elsif($regions[$r] =~ /ChI/){
	if($regions[$r] =~ /nChI/){
$map->fill(199,376,$regioncolor);
$map->fill(213,373,$regioncolor);
}
elsif($regions[$r] =~ /sChI/){
$map->fill(266,399,$regioncolor);
$map->fill(262,420,$regioncolor);
}
}
elsif($regions[$r] =~ /SCoRI/){
$map->fill(165,261,$regioncolor);
$map->fill(210,313,$regioncolor);
$map->fill(196,297,$regioncolor);
}
elsif($regions[$r] =~ /SNE/){
$map->fill(240,196,$regioncolor);
$map->fill(272,211,$regioncolor);
}
else {
$map->fill(split(/,/,$coord{$regions[$r]}), $regioncolor);
}
}
}

$map->fill(310,119,$black);
$map->fill(43,345,$black);

($width, $height) = $map->getBounds();
$newwidth = $width / 2;
$newheight = $height / 2;
$outim = new GD::Image($newwidth, $newheight);


$outim->copyResized($map, 0, 0, 0, 0, $newwidth, $newheight, $width, $height);

       print $q->header(-type=>'image/gif',-expires=>'+3d');
binmode(STDOUT);
print STDOUT $outim->gif;
close (STDOUT);

#region <tab> coordinates<tab>RGB color
__END__
NCo	39,73	0,100,0	North Coast	California Floristic Province
KR	73,33	107,142,35	Klamath Ranges	California Floristic Province
NCoRH	91,98	32,178,170	High North Coast Ranges	California Floristic Province
NCoRI	105,90	32,178,170	Inner North Coast Ranges	California Floristic Province
NCoRO	72,102	32,178,170	Outer North Coast Ranges	California Floristic Province
CaRF	121,83	32,178,170	Cascade Range Foothills	California Floristic Province
CaRH	140,80	10,125,30	High Cascade Range	California Floristic Province
nSNF	159,159	70,130,180	n Sierra Nevada Foothills	California Floristic Province
cSNF	195,218	70,130,180	c Sierra Nevada Foothills	California Floristic Province
sSNF	230,250	70,130,180	s Sierra Nevada Foothills	California Floristic Province
nSNH	179,137	30,144,255	n High Sierra Nevada	California Floristic Province
cSNH	218,203	30,144,255	c High Sierra Nevada	California Floristic Province
sSNH	255,255	30,144,255	s High Sierra Nevada	California Floristic Province
Teh	255,324	72,61,139	Tehachapi Mountain Area	California Floristic Province
ScV	137,177	127,255,25	Sacramento Valley	California Floristic Province
SnJV	184,244	154,205,50	San Joaquin Valley	California Floristic Province
CCo	137,255	102,205,170	Central Coast	California Floristic Province
SnFrB	136,223	176,196,222	San Francisco Bay Area	California Floristic Province
SCoRI	165,261	69,139,116	Inner South Coast Ranges	California Floristic Province
SCoRO	191,329	69,139,116	Outer South Coast Ranges	California Floristic Province
SCo	275,369	155,48,255	South Coast	California Floristic Province
nChI	266,399	221,160,221	n Channel Islands	California Floristic Province
sChI	266,399	221,160,221	s Channel Islands	California Floristic Province
WTR	247,344	255,105,180	Western Transverse Ranges	California Floristic Province
SnGb	288,356	255,105,180	San Gabriel Mountains	California Floristic Province
SnBr	322,358	255,105,180	San Bernardino Mountains	California Floristic Province
PR	325,406	255,000,100	Peninsular Ranges	California Floristic Province
SnJt	332,380	255,000,100	San Jacinto Mountains	California Floristic Province
Wrn	179,39	255,165,0	Warner Mountains	Great Basin Province
MP	165,38	255,232,170	Modoc Plateau	Great Basin Province
WaI	264,222	250,155,15	White and Inyo Mountains	Great Basin Province
SNE	240,196	255,255,15	East of Sierra Nevada	Great Basin Province
DMtns	308,266	255,100,0	Desert Mountains	Desert Province
DMoj	320,315	255,160,122	Mojave Desert	Desert Province
DSon	400,400	255,140,0	Sonoran Desert	Desert Province

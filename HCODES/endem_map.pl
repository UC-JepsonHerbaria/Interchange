
open(IN,"bioregion.hcode6") || die "couldnt open input\n";
while(<IN>){
chomp;
($name,$hcode)=split(/\t/);
next if /^#/;
next if /CEAE/;

#print "name1: $name\n";

$name=&strip_name($name);
push(@names,$name);
#print "name2: $name\n";
$distvec = pack("b*", unpack("b*",pack("H*",$hcode)));
$rank{$name}=$distvec;
}
close(IN);


#open(IN,"endem2.put");
#open(IN,"aliens.out");
open(IN,"rare.out");
while(<IN>){
chomp;
next unless /^[A-Z][A-Z]/;
$target{$_}++;
}
close(IN);

foreach(reverse(@names)){
($genus,$species,$rank,$infra)=split(/ /);
if($rank){
$genspec="$genus $species";
#print "$_ should NOT be removed\n";
foreach $i (0 ..34){
if(vec($rank{$_},$i,1) == 1){
$total_hits[$i]++;
$target_hits[$i]++ if $target{$_};
}
}
}
elsif($genspec eq "$genus $species"){
$remove{$_}++;
#print "$_ SHOULD be removed\n";
next;
}
else{
#print "$_ should NOT be removed\n";
foreach $i (0 ..34){
if(vec($rank{$_},$i,1) == 1){
$total_hits[$i]++;
$target_hits[$i]++ if $target{$_};
}
}
}
}

#die;

close(IN);
            
sub strip_name{
local($_) = @_;
s/^([A-Z]+) (X?[-a-z]+).*(ssp\.|var\.|f\.) ([-a-z]+).*/$1 $2 $3 $4/ ||
s/^([A-Z]+) (X?[-a-z]+).*/$1 $2/;
return ($_);
}

use GD;
"0"=>"255,250,255",
%ratios=(
".25"=>"245,245,245",
".5"=>"235,235,235",
".75"=>"225,225,225",
"1"=>"215,215,215",
"1.25"=>"205,205,205",
"1.5"=>"195,195,195",
"1.75"=>"180,180,180",
"2"=>"155,155,155",
"2.5"=>"135,135,135",
"3"=>"100,100,100",
"4"=>"50,50,50",
);
print "@target_hits\n";
print "@total_hits\n";

while(<DATA>){
#print;
chomp;
($region,$mapcoord, $mapcolor,$longregion) = split(/\t/, $_);
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

  open (GIF,"calmap2.GIF") || die $!;
binmode(GIF);
              $map = newFromGif GD::Image(GIF) || die "Cant open basemap\n";
              close GIF;
 $white = $map->colorClosest(255,255,255); # find white
$black = $map->colorClosest(0,0,0); # find black
foreach $r (0 .. 34){
$ratio = ($target_hits[$r] * 100)/$total_hits[$r];
print "ratio: $ratio\n";
if($ratio <= .25 ){
$ratio = 0;}
elsif($ratio <= .5 ){
#if($ratio <= 5 ){
$ratio = .25;}
elsif($ratio <= .75 ){
$ratio = .5;}
elsif($ratio <= 1 ){
$ratio = .75;}
elsif($ratio <= 1.25 ){
$ratio = 1;}
elsif($ratio <= 1.5 ){
$ratio = 1.25;}
elsif($ratio <= 1.75 ){
$ratio = 1.5;}
elsif($ratio <= 2 ){
$ratio = 1.75;}
elsif($ratio <= 2.5 ){
$ratio = 2;}
elsif($ratio <= 3 ){
$ratio = 2.5;}
elsif($ratio <= 3.5){
$ratio = 3;}
elsif($ratio <= 10){
$ratio = 4;}
else {warn "fell thru\n";}
$ratio_color = $ratios{$ratio};
print <<EOP;
r is $r
target_hits is $target_hits[$r]
total hits is $total_hits[$r]
ratio is $ratio
ratio_color is $ratio_color
EOP
#only allocate the colors if you need them
$regioncolor = $map->colorAllocate(split(/,/,$ratio_color)) ;

print "$regioncolor\n";
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
$keyx=200;
$keyy=5;
$keyw=20;
$keyh=10;
$keystr=$keyw+5;
$map->string(gdSmallFont,$keyx+$keystr,$keyy,"RARE PLANTS IN CALIFORNIA BIOREGIONS",$black);
#$map->string(gdSmallFont,$keyx+$keystr,$keyy,"ENDEMISM IN CALIFORNIA BIOREGIONS",$black);
$keyy+=15;
#$map->string(gdSmallFont,$keyx+$keystr,$keyy,"(endemism defined as native taxa for which no extra-California",$black);
#$map->string(gdSmallFont,$keyx+$keystr,$keyy,"(Alien as identified by The Jepson Manual)",$black);
$map->string(gdSmallFont,$keyx+$keystr,$keyy,"(RARE as identified by The Jepson Manual)",$black);
$keyy+=15;
#$map->string(gdSmallFont,$keyx+$keystr,$keyy,"records are given by The Jepson Manual)",$black);
#$keyy+=15;
$map->string(gdSmallFont,$keyx+$keystr,$keyy,"Percentage is number of RARE taxa in a region",$black);
#$map->string(gdSmallFont,$keyx+$keystr,$keyy,"Percentage is number of California endemics in a region",$black);
$keyy+=15;
$map->string(gdSmallFont,$keyx+$keystr,$keyy,"divided by total taxa in the region",$black);
$keyy+=15;
$keyx=320;
foreach $r (sort {$a<=>$b}(keys(%ratios))){
$regioncolor = $map->colorAllocate(split(/,/,$ratios{$r})) ;
$map->filledRectangle($keyx,$keyy,$keyx+$keyw,$keyy+$keyh,$regioncolor);
$map->string(gdSmallFont,$keyx+$keystr,$keyy,"$r\% RARE",$black);
$keyy+=15;
}



#open(OUT,">endemics.gif") || die;
open(OUT,">rare.gif") || die;
binmode(OUT);
print OUT $map->gif;
close (OUT);
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
SnJt	332,380	255,000,100	San Jacinto Mountains	California Floristic Province
SnBr	322,358	255,105,180	San Bernardino Mountains	California Floristic Province
PR	325,406	255,000,100	Peninsular Ranges	California Floristic Province
Wrn	179,39	255,165,0	Warner Mountains	Great Basin Province
MP	165,38	255,232,170	Modoc Plateau	Great Basin Province
WaI	264,222	250,155,15	White and Inyo Mountains	Great Basin Province
SNE	240,196	255,255,15	East of Sierra Nevada	Great Basin Province
DMtns	308,266	255,100,0	Desert Mountains	Desert Province
DMoj	320,315	255,160,122	Mojave Desert	Desert Province
DSon	400,400	255,140,0	Sonoran Desert	Desert Province

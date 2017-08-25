

while(<DATA>){
#print;
chomp;
($region,$mapcoord, $mapcolor,$longregion) = split(/\t/, $_);
push(@regions,$region);
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
print "Order of regions in vector\n";
for $i (0 .. $#regions){
print $regions[$i], "\n";
}
print "\n";
#die;
sub bycaps {
$sortstring{$a} cmp $sortstring{$b} ||
$a cmp $b
}


open(IN,"native") || die;
while(<IN>){
chomp;
$native{$_}++;
}
close(IN);
open(IN,"../bioregion.hcode6") || die "couldnt open input\n";
while(<IN>){
	last if m/UPDATES/;
	chomp;
	next if /^#/;
	next if /CEAE/;
	($name,$hcode)=split(/\t/);
	next unless $hcode;
	$name=&strip_name($name);
next unless $native{$name};
	#$distvec = pack("b*", unpack("b*",pack("H*",$hcode)));
$str= unpack("b*",pack("H*",$hcode));
$str=substr($str,0,35);
print "$name\t$str\n";
}

sub strip_name{
local($_) = @_;
s/^([A-Z]+) (X?[-a-z]+).*(subsp\.|ssp\.|var\.|f\.) ([-a-z]+).*/$1 $2 $3 $4/ ||
s/^([A-Z]+) (X?[-a-z]+).*/$1 $2/;
return ($_);
}

__END__
CCo	137,255	102,205,170	Central Coast
CaRF	121,83	32,178,170	Cascade Range Foothills
CaRH	140,80	10,125,30	High Cascade Range
nChI	266,399	221,160,221	n Channel Islands
sChI	266,399	221,160,221	s Channel Islands
DMoj	320,315	255,160,122	Mojave Desert
DMtns	308,266	255,100,0	Desert Mountains
DSon	400,400	255,140,0	Sonoran Desert
KR	73,33	107,142,35	Klamath Ranges
MP	165,38	255,232,170	Modoc Plateau
NCo	39,73	0,100,0	North Coast
NCoRH	91,98	32,178,170	High North Coast Ranges
NCoRI	105,90	32,178,170	Inner North Coast Ranges
NCoRO	72,102	32,178,170	Outer North Coast Ranges
PR	325,406	255,000,100	Peninsular Ranges
SCo	275,369	155,48,255	South Coast Ranges
SCoRI	165,261	69,139,116	Inner South Coast Ranges
SCoRO	191,329	69,139,116	Outer South Coast Ranges
ScV	137,177	127,255,25	Sacramento Valley
SnBr	322,358	255,105,180	San Bernardino Mountains
SnFrB	136,223	176,196,222	San Francisco Bay Area
SnGb	288,356	255,105,180	San Gabriel Mountains
SNE	240,196	255,255,15	East of Sierra Nevada
SnJt	332,380	255,000,100	San Jacinto Mountains
SnJV	184,244	154,205,50	San Joaquin Valley
Teh	255,324	72,61,139	Tehachapi Mountain Area
WaI	265,213	250,155,15	White and Inyo Mountains
Wrn	181,40	255,165,0	Warner Mountains
WTR	247,344	255,105,180	Western Transverse Ranges
nSNF	159,159	70,130,180	n Sierra Nevada Foothills
nSNH	179,137	30,144,255	n High Sierra Nevada
cSNF	195,218	70,130,180	c Sierra Nevada Foothills
cSNH	218,203	30,144,255	c High Sierra Nevada
sSNF	230,250	70,130,180	s Sierra Nevada Foothills
sSNH	255,255	30,144,255	s High Sierra Nevada

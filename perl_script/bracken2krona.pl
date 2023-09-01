#!

use Getopt::Std;
getopt("io");

unless (@ARGV && $opt_o && $opt_i) {
    print "-o output directory(abs_path)\n";
    print "-i iutput bracken_out(kraken2format)directory(abs_path)\n";
    print "-ARGV input file(abs_path)\n";
    die();
}
unless(-e $opt_i){print "input file does not exist!\n\n";die();}
mkdir $opt_o;
$kronatxtdir=$opt_o."kronatxt/";
$kronahtmldir=$opt_o."krona_html/";
mkdir $kronatxtdir;
mkdir $kronahtmldir;
for ($x=0; $x<@ARGV; $x++){
	if ($ARGV[$x] =~ /(\S+\/)(\S+)(.S.bracken.report)/){
	$filename=$2;
	}
	$brakenout=$opt_i.$filename.".S.bracken.report";
	$kronatxtout=$kronatxtdir.$filename."_krona";
	$kronahtmlout=$kronahtmldir.$filename."_krona_html";
	$krontxt_mergewildcard=$kronatxtdir.$filename."*_krona";
	$kronahtmlout=$kronahtmldir."combine_krona.html";
	#print "$kronatxtout\n";
	#print "$brakenout\n";
	#print "$kronahtmlout\n";
	#如果想要kraken2的output可以把它打開$krake2output=$foldername.$filename."_kraken2.output"
	system(" ~/KrakenTools-1.2/kreport2krona.py -r $brakenout -o $kronatxtout");
	#system("ktImportText $kronatxtout -o $kronahtmlout");
	}
system("ktImportText $krontxt_mergewildcard -o $kronahtmlout");

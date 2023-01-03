use Getopt::Std;
getopt("i");
$count1=0;
open FILE,$opt_i;
while(<FILE>){
    if (/>/) {
        if (/(>)(\S+)(_)(\d*)(\s.*)/) {
            $contig = $2;
	$array[$count1]=$contig;
	$count1++;
	#print "$contig\n";
        }
    }
else{next;}
}
close FILE;

my %count;
$count{$_}++ foreach @array;

#removing the lonely strings
#while (my ($key, $value) = each(%count)) {
    #if ($value == 1) {
        #delete($count{$key});
    #}
#}

#output the counts
while (my ($key, $value) = each(%count)) {
    print "$key\t$value\n";}

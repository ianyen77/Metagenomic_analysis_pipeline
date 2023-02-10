use Getopt::Std;
getopt("f");

open LEN,$opt_f;
my %len;
while(my $name = <LEN>){
	chomp($name);
	$name =~ s/^>//;
	my $seq = <LEN>; chomp($seq);
	my $idsarg = (split(/\s+/,$name))[0];
	my $le = length($seq);
	$len{$idsarg} = $le;
	chomp $idsarg;
	print"$idsarg\t$le\n";
}
close LEN;

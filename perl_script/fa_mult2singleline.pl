#!/usr/bin/perl
use strict;
use warnings;

my $filename = $ARGV[0];
open(my $fh, '<', $filename) or die "Could not open file '$filename' $!";

my $header = "";
my $sequence = "";

while (my $line = <$fh>) {
    chomp $line;
    if ($line =~ /^>(.*)/) {
        if ($header ne "") {
            print ">$header\n$sequence\n";
        }
        $header = $1;
        $sequence = "";
    } else {
        $sequence .= $line;
    }
}

print ">$header\n$sequence";

close $fh;

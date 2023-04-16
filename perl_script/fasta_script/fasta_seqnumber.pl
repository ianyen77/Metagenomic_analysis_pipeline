#!/usr/bin/perl
#This is script count fasta seq number
#usage perl -w ~/fasta_seqnumber.pl *.nucl

# Get a list of files that match the pattern *.nucl
@files = glob("@ARGV");
# Loop through each file and count the number of lines that contain ">"
foreach $filename (@ARGV) {
    $count = 0;
    open FILE, $filename or die "Cannot open file $filename: $!\n";
    while (<FILE>) {
        chomp;
        if (/>/) {
            $count++;
        }
    }
    close FILE;
    $filename2=$filename;
    $filename2=~ s/.*\///g;
    print "File $filename2 count: $count\n";
}


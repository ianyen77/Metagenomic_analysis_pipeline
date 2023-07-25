#!/usr/bin/perl

use Getopt::Std;
getopt("f");
chomp $opt_f;
open FILE,$opt_f;

my $current_seq_name;
my %sequence_lengths;

# 處理每一行fasta檔案
while (my $line = <FILE>) {
    chomp $line;
    if ($line =~ /^>/) {
        # 提取序列名稱
        $current_seq_name = substr($line, 1); # 去除">"符號
    } else {
        # 計算序列長度並累計
        $sequence_lengths{$current_seq_name} += length($line);
    }
}
close FILE;

# 輸出結果
foreach my $seq_name (keys %sequence_lengths) {
    print "$seq_name\t$sequence_lengths{$seq_name}\n";
}


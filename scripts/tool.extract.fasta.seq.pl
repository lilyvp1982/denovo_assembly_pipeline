#!/usr/bin/perl

use strict;
use warnings;

$ARGV[2] or die "perl extract.fasta.seq.pl LIST FASTA OUT\n";

my $list = shift @ARGV;
my $fasta = shift @ARGV;
my $out = shift @ARGV;
my %select;

open L, "$list" or die;
my $count=1;
while (<L>) {
    chomp;
    s/' '/,/g;
    my ($id) = split (",", $_);
    $select{$id} = 1; 
}
close L;

$/ = "\n>";
open O, ">$out" or die;
open F, "$fasta" or die;
while (<F>) {
    s/>//g;
    my ($id) = split (/ /, $_);
    print O ">$_" if (defined $select{$id});
}
close F;
close O;
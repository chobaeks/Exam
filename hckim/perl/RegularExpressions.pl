#!/usr/bin/perl
use strict;
use warnings;
use 5.010;

if( $#ARGV < 0 )
  { die "Supply a file name, please.\n"; }
if( $#ARGV > 0 )
  { die "Too many parameter.\n"; }

my $textfile = shift(@ARGV);
my $result = " ;";
my $now;
my $seq;

my @sizes = qw(4K 16K 64K 256K 1M 4M 16M);

my %result;

open(TEXT, $textfile) || die $!;
while(<TEXT>) 
{
my $line = $_;

    foreach (@sizes)
    {
        if ($line =~ /^$_\/1G/) 
        {
            $now = $_;
            $seq = 0;
        }
    }
 
    if (s/s,\s*(.*) MB\/s//)
    {
        $result{$now . $seq} .= $1;
        $seq += 1;
    }
}
close TEXT;

foreach (@sizes)
{
    $result .= $_ . ";";
}

$result .= "\n" . "wrtie;";
foreach (@sizes)
{
    $result .= $result{$_ . 0} . ";";
}

$result .= "\n" . "Overwrite;";
foreach (@sizes)
{
    $result .= $result{$_ . 1} . ";";
}

$result .= "\n" . "Read;";
foreach (@sizes)
{
    $result .= $result{$_ . 2} . ";";
}

$result .= "\n";

print $result;

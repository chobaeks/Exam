#!/usr/bin/perl
use strict;
use warnings;
use 5.010;

my @desc_extensions = split " ","mac shm lnk dld shr rel lib jpr"; 
push @desc_extensions, split " ","vprj vexe vdll vlib vrel vcom";

my @k = keys %ENV;

foreach (@k)
{
    print $_ . "=" . $ENV{$_} . "\n";
}

$ENV{'TOOL'} = 'C:\SAPDevelop\buildtools\dev' unless (defined $ENV{'TOOL'});

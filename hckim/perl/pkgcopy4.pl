#!/usr/bin/perl
use strict;
use Getopt::Long;

my $usage = "\nUsage:\n";
$usage .= "perl pkgcopy4.pl -newdb <newdbPATH> -pool <pool> -branch <branch> -type <dbg|opt> [-platform <platform>]\n";
$usage .= "-h, -help or -? to print this help message\n";

# parameter handling
my %options = ();
if ( !&GetOptions( \%options,
			'h|help|?',
			'newdb=s',
			'pool=s',
			'branch=s',
			'type=s',
			'platform=s',
			) ) {
	print "$usage";
	exit(1);
}

#my $pool=(defined $options{'pool'})?$options{'pool'}:die "Option pool is missing\n $usage";
#add newdb parameter : Hyunchang,Kim
my $newdb=(defined $options{'newdb'})?$options{'newdb'}:"newdb";
my $pool=(defined $options{'pool'})?$options{'pool'}:"POOL";
my $branch=(defined $options{'branch'})?$options{'branch'}:die "Option branch is missing\n $usage";
my $type=(defined $options{'type'})?$options{'type'}:die "Option type is missing\n $usage";
my $platform=(defined $options{'platform'})?$options{'platform'}:"linuxx86_64";

#my $lockdir="/var/lock";
#my $lockfile="pkgcopy_${branch}_${type}_${platform}.lock";
#$lockfile=$lockdir."/".$lockfile;

#if(-e $lockfile) {
#	die "\n$lockfile already exists, check running pkgcopy.pl\n\n";
#} else {
#    open(LOCKFILE, ">", $lockfile) || die "Can't open lock file $lockfile\n";
#}
#flock(LOCKFILE, 2) || die "Can't acquire lock\n";

#my $CLWDF=`ssh lroot\@ld9252 'readlink /sapmnt/production/makeresults/newdb/POOL_CONT/$branch/$type/$platform/LastBuild'`;
my $CLWDF=`ssh lroot\@ld9252 'readlink /sapmnt/production/makeresults/$newdb/$pool/$branch/$type/$platform/LastBuild'`;
chomp($CLWDF);
my $CL=readlink("/sapmnt/production/makeresults/$newdb/$pool/$branch/$type/$platform/LastBuild");
print "CL Seoul: ".$CL."\n";
print "CL Walldorf: ".$CLWDF."\n";
#if($CLWDF<=$CL)
if($CLWDF==$CL)
{
	print("Seoul is up-to-date\n");
	exit 0;
}

#sub INT_handler {
#	close(LOCKFILE);
#	unlink($lockfile);
#	exit 2;
#}
#$SIG{'INT'} = 'INT_handler';

#my $cpcmd="scp -prC lroot\@ld9252:/sapmnt/production/makeresults/$newdb/POOL_CONT/$branch/$type/$platform/$CLWDF /sapmnt/production/makeresults/$newdb/POOL_CONT/$branch/$type/$platform/";
my $cpcmd="scp -prC lroot\@ld9252:/sapmnt/production/makeresults/$newdb/$pool/$branch/$type/$platform/$CLWDF /sapmnt/production/makeresults/$newdb/$pool/$branch/$type/$platform/";
#my $cpcmd="rsync --checksum --recursive --partial --compress --links --progress /sapmnt/production/makeresults_wdf/$newdb/POOL_CONT/$branch/$type/$platform/$CLWDF /sapmnt/production/makeresults/$newdb/POOL_CONT/$branch/$type/$platform/";
#my $cplink="cp -farv /sapmnt/production/makeresults_wdf/$newdb/POOL_CONT/$branch/$type/$platform/LastBuild /sapmnt/production/makeresults/$newdb/POOL_CONT/$branch/$type/$platform/";
#my $cplink="cd /sapmnt/production/makeresults/$newdb/POOL_CONT/$branch/$type/$platform/; rm LastBuild; ln -sf $CLWDF LastBuild";
my $cplink="cd /sapmnt/production/makeresults/$newdb/$pool/$branch/$type/$platform/; rm LastBuild; ln -sf $CLWDF LastBuild";
my $cpfail=system($cpcmd);
if(!$cpfail) {
	print "Copy done! Update LastBuild link\n";
	system($cplink);
}

#close(LOCKFILE);
#unlink($lockfile);

#flock(LOCKFILE, 6) || die "Can't release lock\n";
#close LOCKFILE;
exit 0;


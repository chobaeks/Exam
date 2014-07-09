#!C:\PROGRA~1\Perl5.16\Perl64\bin\perl.exe
#    cgicall.pl - cgi script for remote makes
#
#    @(#)cgicall.pl     2003-12-09
#
#    GAR, SAP AG
#
#    ========== licence begin LGPL
#    Copyright (C) 2002 SAP AG
#
#    This library is free software; you can redistribute it and/or
#    modify it under the terms of the GNU Lesser General Public
#    License as published by the Free Software Foundation; either
#    version 2.1 of the License, or (at your option) any later version.
#
#    This library is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#    Lesser General Public License for more details.
#
#    You should have received a copy of the GNU Lesser General Public
#    License along with this library; if not, write to the Free Software
#    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#    ========== licence end
#

use CGI;
use File::Copy;
use File::Path;
use FileHandle;
use strict;

$| = 1;

# defaults
my %Glob =();
my $pid_file_name = "build.pid";
my $pathseparator = "/";
my @desc_extensions = split " ","mac shm lnk dld shr rel lib jpr";
push @desc_extensions, split " ","vprj vexe vdll vlib vrel vcom";

$ENV{'TOOL'} = 'C:\SAPDevelop\buildtools\dev' unless (defined $ENV{'TOOL'});

$ENV{'DOCUMENT_ROOT'}=(($^O=~/win32/i) ?
                      (( -d "D:\\w\\make" ) ?  "D:\\w\\make" : "D:\\SAPDevelop\\remuser\\wwwroot\\make") :
                       "/remuser/wwwroot/make")
                unless (defined $ENV{'DOCUMENT_ROOT'}) ;
$ENV{'PROCESSOR_ARCHITECTURE'}="AMD64";


@{$Glob{'localfiles'}} = (".ipreprof",".iuser");
$Glob{'iprofile'} = ".iprofile";
if($^O=~/win32/i)
{
    @{$Glob{'localfiles'}} = ("ipreprof.bat","iuser.bat");
    $Glob{'iprofile'} = "iprofile.bat";
    $pathseparator = "\\";
}
else
{
    $ENV{'PATH'} = "\$VMAKETOOL/local/bin:$ENV{'PATH'}";
}


my $query = CGI->new();
print $query->header(-type=>'text/html',-expires=>'now');

$Glob{'user'}         = $query->param('user');
$Glob{'release'}      = $query->param('release');
$Glob{'lc_state'}     = $query->param('lc_state');
$Glob{'src_dir'}      = $query->param('src_dir');
$Glob{'cmd'}          = $query->param('cmd');
@{$Glob{'cmdparams'}} = $query->param('cmdparam');
$Glob{'bit64'}        = $query->param('bit64');
$Glob{'ignoreown'}    = $query->param('ignoreown');
$Glob{'debug'}        = $query->param('debug');
$Glob{'action'}       = $query->param('action');
$Glob{'mode'}         = $query->param('mode');          # telnet
$Glob{'type'}         = $query->param('type');          # lc or lcapps
$Glob{'platform'}     = $query->param('platform');      # real platform
$Glob{'platformtag'}  = $query->param('platformtag');   # platformtag given by command line
$Glob{'oldprofile'}   = $query->param('oldprofile');    # old -> use old profile | new -> generate profile
$Glob{'timeout'}      = defined $query->param('timeout') ?  $query->param('timeout') : 1000;
$Glob{'version'}      = $query->param('version'); # fast|quick|slow
$Glob{'cmdtargets'}   = $query->param('cmdtargets');
$Glob{'cmdoptions'}   = $query->param('cmdoptions');
$Glob{'silent'}       = $query->param('silent');
$Glob{'profiledir'}   = $query->param('profiledir');
$Glob{'progress'}     = $query->param('progress');
$Glob{'forcemake'}    = defined $query->param('forcemake') ? 1 :0;
$Glob{'scroll'}       = $query->param('scroll');
$Glob{'use_ajax'}     = defined $query->param('ajax') ? 1 :0;
$Glob{'use_css'}      = defined $query->param('css') ? 1 :0;
$Glob{'outputtype'}   = defined $query->param('outputtype') ? $query->param('outputtype'):  "normal" ;
$Glob{'specialtype'}  = $query->param('specialtype');
$Glob{'setenv'}       = $query->param('setenv');
$Glob{'suffix'}       = $query->param('suffix');
$Glob{'lc_ver_str'}   = $query->param('lc_ver_str');
$Glob{'configfile'}   = defined $query->param('configfile') ? $query->param('configfile') : "./WebConfig.pl";

# lcapps variables
$Glob{'branch'}          = $query->param('branch');
$Glob{'apo_com_short'}   = $query->param('apo_com_short');
$Glob{'lcversion'}       = $query->param('lcversion');
$Glob{'lcpool_count'}    = $query->param('lcpool_count');
$Glob{'apo_patch_level'} = $query->param('apo_patch_level');
$Glob{'changelist'}      = $query->param('changelist');
$Glob{'relstat'}         = $query->param('relstat');
$Glob{'p4client'}        = $query->param('p4client');
$Glob{'variant'}         = $query->param('variant');
$Glob{'gartest'}         = $query->param('gartest');
$Glob{'forced_userdir'}  = $query->param('forced_userdir');
$Glob{'display'}         = $query->param('display');
$Glob{'bit32'}           = $query->param('bit32');

my $CancelButtonName = "CancelButton";
my $LogfileButtonName = "LogFilesButton";
my $logfilebutton_enabled = 0;

my @global_targets = ();
my $global_version = undef;

my $outputarea = undef;
my $ProtFrameOpen = 0;
my $DefaultBGColor = '#D4D9DB';
my $force_links = 1;
$Glob{'use_web2'} = 0;

my $text_opened = 0;
my $pre_text_opened = 0;
my $rc = undef;
my $protfile = undef;
my $script_name     = $ENV{'SCRIPT_NAME'};
my $remote_hostname = $query->server_name();
my %cmdparams = ();

$ENV{'SUPPRESS_PROFILE_OUTPUT'} = "yes";

chomp $remote_hostname;

# cut domain for request of server informations
my $short_hostname = ($remote_hostname =~ /^([^\.]*)\./) ? $1 : $remote_hostname;
my @dirs_to_cleanup = $query->param('deldirs');
my $current_titleline = "";

# substitute loop back
if (($Glob{'src_dir'} =~ /^127\.0\.0[^:]*:(.*)$/) && defined $ENV{REMOTE_ADDR})
{
    $Glob{'src_dir'} = "$ENV{REMOTE_ADDR}:$1";
}

my $http_address ="http://$remote_hostname:$ENV{'SERVER_PORT'}";
if (defined $ENV{'HTTP_HOST'})
{   $http_address ="http://$ENV{'HTTP_HOST'}"; }

unless (defined $Glob{'type'})
{
    $Glob{'type'} = "lc";
}

if ($Glob{'mode'} !~ /^(web1|telnet)$/)
{
    $Glob{'use_ajax'} = 1;
    $Glob{'use_css'} = 1;
    $Glob{'use_web2'} = 1;
};

if ( -r $Glob{'configfile'})
{
    local @ARGV = ();
    push @ARGV, \%Glob;
    do "$Glob{'configfile'}";
}

#$Glob{'lc_state'} = "DEV" unless (defined $Glob{'lc_state'});

my $typedir = "$Glob{'type'}";
defined $Glob{'specialtype'} and $typedir .= "/$Glob{'specialtype'}";

my $userdir = "$typedir/";



if ( ! @{$Glob{'cmdparams'}} && ($Glob{'cmdtargets'} || $Glob{'cmdoptions'}))
{
    @{$Glob{'cmdparams'}} = ();
    push @{$Glob{'cmdparams'}}, split " ", $Glob{'cmdoptions'} if ($Glob{'cmdoptions'});
    push @{$Glob{'cmdparams'}}, split " ", $Glob{'cmdtargets'} if ($Glob{'cmdtargets'});
}


if ($Glob{'type'} =~ /^lc$/)
{

    if (($Glob{'release'} =~ /^(\d)\.(\d).(\d\d)\.(.*)$/) || ($Glob{'release'} =~ /^(\d)\.(\d).([^.]+)$/))
    {
        $userdir .= "$1$2";
        my $corlevel = $3;
        $Glob{'lc_state'} = $4;
        if (defined $Glob{'lc_state'})
        {   $userdir .= "$corlevel";    }
        else  # make version without corlevel -> 3rd "parameter" = lc_state
        {   $Glob{'lc_state'} = $corlevel;      }
        unless ($Glob{'lc_state'} =~ /DEV/i)
        {   $userdir .= "$Glob{'lc_state'}"; }
        $userdir .= "_64" if (defined $Glob{'bit64'});
        $Glob{'lc_state'} = "RAMP" if ($Glob{'lc_state'} =~ /\d\d/);
        $Glob{'lc_state'}  =~ tr/a-z/A-Z/;
    }
    elsif ($Glob{'release'} =~ /^TOOL\.\d\d\.(.*)$/)
    {
        $userdir .= "TOOL_$2";
        $userdir .= "_$Glob{'user'}" unless (defined $Glob{'ignoreown'});
    }
    else
    {
        _print_startline ("cgicall ($Glob{'user'})- Error : wrong release $Glob{'release'}");
        _error_exit ("Unknown type \"$Glob{'type'}\" used");
    }
    $userdir .= "_$Glob{'user'}" unless (defined $Glob{'ignoreown'});
    $userdir .= "_$Glob{'suffix'}" if (defined $Glob{'suffix'});

    if (($Glob{'action'} =~ /start/) && ($Glob{'version'} =~ /(.).*/))
    {
        $Glob{'cmd'} = "im$1.pl";
    }
}
elsif ($Glob{'type'} =~ /^hdb$/)
{
    if (defined $Glob{'branch'} && not defined $Glob{'release'})
    {
        $Glob{'release'} = $Glob{'branch'};
    }
    $userdir .= "$Glob{'release'}";
    $userdir .= "_64" if (defined $Glob{'bit64'});
    $userdir .= "_32" if (defined $Glob{'bit32'});
    $userdir .= "_$Glob{'user'}";
    # $userdir .= "_$Glob{'p4client'}" if (defined $Glob{'p4client'});
    if (($Glob{'action'} =~ /start/) && ($Glob{'version'} =~ /(.).*/))
    {
        $Glob{'cmd'} = "hm$1.pl";
    }
}
elsif ($Glob{'type'} =~ /^lcapps$/)
{
    $userdir .= "$Glob{'branch'}";
    $userdir .= "_64" if (defined $Glob{'bit64'});
    $userdir .= "_$Glob{'user'}";
    $userdir .= "_$Glob{'p4client'}" if (defined $Glob{'p4client'});
    $Glob{'release'} = $Glob{'branch'};
    $Glob{'variant'} = "Release" unless (defined $Glob{'variant'});
    $Glob{'cmd'} = "lcmake.pl";
    #if ($Glob{'variant'} =~ /Debug/)
    #{ unshift @{$Glob{'cmdparams'}}, "--config=Debug"; }
}
else
{
    _print_startline ("cgicall ($Glob{'user'})- Error : wrong type $Glob{'type'}");
    _error_exit ("Unknown type \"$Glob{'type'}\" used");
}

if (defined $Glob{'forced_userdir'} )
{
    $userdir = $Glob{'forced_userdir'};
}

if ( defined $Glob{'p4client'} )
{
    $ENV{"REM_P4CLIENT"} = $Glob{'p4client'};
}

my $own  ="$ENV{'DOCUMENT_ROOT'}/$userdir";

$ENV{'USER_ECLIPSE_ROOT'}="$ENV{'DOCUMENT_ROOT'}/eclipse/$userdir";

if (defined $Glob{'display'})
{   $ENV{'DISPLAY'}= "$Glob{'display'}"; }
elsif (defined $ENV{REMOTE_ADDR})
{   $ENV{'DISPLAY'}= "$ENV{REMOTE_ADDR}:0.0"; }
elsif (($Glob{'src_dir'} =~ /^(.*):(.:|X)/) || ($Glob{'src_dir'} =~ /^(.*):/))
{   $ENV{'DISPLAY'}= "$1:0.0"; }

if($^O=~/win32/i)
{
    $own  =~ tr/\//\\/;
    $ENV{'TEMP'}="$own\\tmp";
}

# set HOME
if($^O !~ /win32/i)
{
    my $home = `echo ~`;
    if ($home =~ /^~/)
    {   $home = "/sapmnt/home2/remuser"; }
    chomp $home;

    $ENV{'HOME'} = $home;
}


$ENV{'USER'} = defined $Glob{'user'} ? "$Glob{'user'}(remuser)" : "remuser";

unless ($Glob{'action'} =~ /^start|show|stop|prot|clean|term|manage|cmd|dir|plist$/ )
{
    _print_startline ("$Glob{'release'}($Glob{'user'})- Error : wrong action $Glob{'action'}");
    _error_exit ("Unknown action \"$Glob{'action'}\" used");
}

if ($Glob{'action'} !~ /start/)
{ undef $Glob{'use_css'};}

$SIG{'KILL'}= \&_handle_stop_signal;
_print_dbg ("CMD: $Glob{'cmd'} @{$Glob{'cmdparams'}}", 3);

$rc = eval "$Glob{'action'}_make()";
_close_html();


######################

sub start_make
{
    _print_startline ("$Glob{'release'}($Glob{'user'}): $Glob{'cmd'} @{$Glob{'cmdparams'}}");
    _print_headarea("Make", "$Glob{'cmd'} @{$Glob{'cmdparams'}} "); #(<span id='MakeProgress'>Starting</span>)");
    _check_path($own);


    _set_Makestate(0);

    # check for running make
    if ((-f "$own/log/build.pid") && (-f "$own/sys/wrk/vmake.pid"))
    {
        my @make_infos = _get_make_info("$own/log/build.pid");
        _print_h3("An other make is running ($make_infos[0])");
        _print_h3("command: $make_infos[1]");
        if ($Glob{'forcemake'})
        {
            _stop_make($own);
            _print_hr();
        }
        else
        {
            $Glob{'action'}="skip";
            if ($Glob{'mode'} =~ /telnet/)
            {
                if ( $Glob{'type'} =~ /^hdb$/)
                {   print "To show log files use remhlo command !\n"; }
                else
                {   print "To show log files use remipf command !\n"; }
                print "To cancel current make use the remkill command !\n";
            }
            else
            {
                my $http_options = _get_http_options();
                my $href = "${script_name}"._get_http_options();
                _print_nl ();
                print "<A HREF=$href&action=show>Show current make</A>";
                _print_nl (2);
                print "<A HREF=$href&action=stop>Cancel current make</A>";
                _print_nl (2);
                $href .= "&action=start&forcemake&cmd=$Glob{'cmd'}";
                foreach (@{$Glob{'cmdparams'}})
                {
                    $href .= "&cmdparam=$_";
                }
                print "<A HREF=$href>Cancel current and restart '$Glob{'cmd'} @{$Glob{'cmdparams'}}'</A>";
                _print_nl (2);
                _print_link_to_own(1);
                _print_nl (1);
            }
            _set_title("Skipped - $current_titleline");
            return;
        }
    }
    unlink ("$own/log/build.canceled");

    _begin_text();
    _write_pid_file ("$Glob{'cmd'} @{$Glob{'cmdparams'}}");
    _end_text();

    _set_Makestate(1);

    if ( ( defined $Glob{'oldprofile'} ) && ( ! -e "$own/$Glob{'iprofile'}" ))
    {
        _print_h3 ("Can't find profile ($own/$Glob{'iprofile'}) - force generation");
        _print_nl();
        $Glob{'oldprofile'} = undef;
    }
    unless ( defined $Glob{'oldprofile'} )
    {
        _prepare_make();
        _print_hr();
    }

    # check for existing targets
    my ($tmp_version,$tmp_targets) = _analyze_cmdparams();
    if (@$tmp_targets && (! -e "$own/log/build.canceled"))
    {
        # ready for starting make
        _open_protfile("$own/log/build.prot");
        _print_h3 ("Start make ($Glob{'cmd'} @{$Glob{'cmdparams'}})");
        _print_to_protfile("\nStart make ($Glob{'cmd'} @{$Glob{'cmdparams'}})\n");
        _begin_text();

        # create make command
        my $make_cmd;
        if ($^O =~/win32/i)
        {
            if ( $Glob{'type'} =~ /^(lc|hdb)$/)
            { $make_cmd = "call \"$own\\iprofile.bat\" & cmd /c %TOOLSHELL% -S ";   }
            else
            { $make_cmd = "call \"$own\\..\\iprofile.bat\" $own & cmd /c %TOOLSHELL% -S";   }
        }
        else
        { $make_cmd = ". $own/.iprofile ; \$TOOLSHELL -S "; }

        # set environment variables for mail
        my $http_options = _get_http_options();
        $ENV{'HTTP_PROT_ADDRRESS'}="$http_address$script_name$http_options&cmd=$Glob{'cmd'}";
        foreach (@{$Glob{'cmdparams'}})
        {
            $ENV{'HTTP_PROT_ADDRRESS'} .= "&cmdparam=$_";
        }
        $ENV{'HTTP_SHOW_ADDRRESS'} = "$ENV{'HTTP_PROT_ADDRRESS'}&action=show";
        $ENV{'HTTP_PROT_ADDRRESS'} .= "&action=prot";
        $ENV{'HTTP_OWN_ADDRRESS'}="$http_address/$userdir/";

        _print_dbg ("HTTP_PROT_ADDRRESS: \n $ENV{'HTTP_PROT_ADDRRESS'}", 2 );
        _print_dbg ("HTTP_SHOW_ADDRRESS: \n $ENV{'HTTP_SHOW_ADDRRESS'}", 2 );
        _print_dbg ("HTTP_OWN_ADDRRESS: \n $ENV{'HTTP_OWN_ADDRRESS'}", 2 );

        _print_dbg ("call: $make_cmd $Glob{'cmd'} @{$Glob{'cmdparams'}}",2);

        if ( ($Glob{'mode'} !~ /telnet/i) || $Glob{'progress'} )
        {
            $ENV{VMAKE_REPORT_FORMAT}='Make state - <PROGRESS('.($Glob{'progress'}?"$Glob{'progress'}" : "1").
                                      ')>% / error count: <ERROR_COUNT(100)> ';
        }
        if ($Glob{'mode'} =~ /telnet/)
        {
            _print ("Remote Build Directory: $own\n");
        }

        open(MAKE,"$make_cmd $Glob{'cmd'} @{$Glob{'cmdparams'}} |");
        while(<MAKE>)
        {
            _print_dual ("$_");
        }
        close MAKE;
        $rc = $?;
        _print_dbg("return value: $rc", 2);

        _print_to_protfile("Remote make finished ".( $rc!=0 ? "with errors" : "successfully"));
        _end_text();
        if (-e "$own/log/build.canceled")
        {
            _set_title("Canceled - $current_titleline");
            _print_h3("Remote make canceled") ;
        }
        elsif ( $rc == 0 )
        {
            _set_title("OK - $current_titleline");
            _print_h3("Remote make finished successfully") ;
        }
        else
        {
            _set_title("Error - $current_titleline");
            _print_h3("Remote make finished with errors", "red" );
        }
        _print_to_protfile("\nRemcall was finished\n");
        _close_protfile();
    }
    else
    {
        if (-e "$own/log/build.canceled")
        {
            _set_title("Canceled - $current_titleline");
            _print_h3("Remote make canceled") ;
        }
    }
    _set_Makestate(0);

    unless ($Glob{'use_css'})
    { _print_link_to_own(1); }
    _print_links_to_protocols();
    unless ($Glob{'use_css'})
    { _print_maketarget(1);}

    #_remove_pid_file();
    #return 0;
}

#####

sub _get_protocollinks
{
    my $target = shift;
    my $version = shift;
    my $name = $target;
    my $protroot = "sys/wrk/$version/";
    $protroot .= (-d "$own/sys/wrk/$version/prot") ? "prot/" : "log/";
    my $prot = "";
    if ($target =~ /::?(.*)/)
    {   $prot =  "$protroot$1"; }
    else
    {   $prot = "$protroot$target" };
    # description without extension
    # -> look for <extension>.e0
    if ( (($name =~ /^::/) || ($name !~ /\//)) && ($name !~ /\./))
    {
        _print_dbg ("found description without extension", 1 );
        foreach (@desc_extensions)
        {
            _print_dbg ("check description for $_", 2 );
            if ( -f "$own/$prot.$_.p0" )
            {
                $target .= ".$_";
                $prot   .= ".$_";
                last;
            }
        }
    }
    elsif ((not -e "$own/$prot.e0") && ($target =~ /^:.*\/([^\/]*)$/))
    {
        if (-e "$own/$protroot$1.e0")
        {   $prot = "$protroot$1";
            _print_dbg ("$own/$protroot$1.e0 found ", 2 );
        }
        else
        {
            _print_dbg ("$own/$protroot$1.e0 not found ", 2 );
        }
    }

    return ((-e "$own/$prot.e0")? "/$userdir/$prot.e0" : undef,
            (-e "$own/$prot.p0")? "/$userdir/$prot.p0" : undef,
            (-e "$own/$prot.x0")? "/$userdir/$prot.x0" : undef);
}



######################

sub show_make
{
    my $running_command = (_get_make_info("$own/log/build.pid"))[1];
    if ( ! defined $running_command)
    {
        $running_command = "$Glob{'cmd'} @{$Glob{'cmdparams'}}";
    }
    _print_startline ("$Glob{'release'}($Glob{'user'}): show make - $running_command");
    _print_headline  ("Showing remote make",$running_command );
    _check_path($own);

    _set_cmdparams($running_command);

    my $protfile = new FileHandle "$own/log/build.prot", "r";
    my $timeout_counter = 0;
    my $line = "";
    if (defined $protfile)
    {
        _begin_pre_text();
        while ( $line !~ /Remcall was finished/)
        {
            $line = <$protfile>;
            last if ($line =~ /Remcall was finished/);
            if (defined $line)
            {
                $timeout_counter = 0;
                print ($line);
            }
            else
            {
                if ($timeout_counter > $Glob{'timeout'})
                {
                    _error_exit("Timeout ($Glob{'timeout'} s) for reading reached");
                }
                else
                {
                    sleep 5;
                    $timeout_counter += 5;
                }
            }
        }
        _end_pre_text();
    }
    else
    {
        _print_h3 ("No make infomation found.");
    }
    _print_link_to_own();
    _print_links_to_protocols(1);
}

######################

sub prot_make
{
    #my $running_command = (_get_make_info("$own/log/build.pid"))[1];
    my $targets;
    my $options;
    my $version;

    ($version, $targets, $options)=_analyze_cmdparams();

    my $target = shift @$targets;
    _print_startline ("$Glob{'release'}($Glob{'user'}): log files of remote make of $target" );
    if ($Glob{'use_ajax'})
    {
        my ($errprt,$nprt,$xprt);
        my $defaultlink = undef;
        my $oldprt = "${script_name}"._get_http_options()."&action=plist";

        _print_headline ("Make log file", (defined $target) ? $target : undef  );
        print "<form name=\"Headform\">\n";

        if (defined $target)
        {
            ($errprt,$nprt,$xprt)  = _get_protocollinks($target,$version);

            if (defined $nprt)
            {
                print '<input type="button" name="NormalProt" style="margin-left:3px; border-width:1px" value="Standard log" onclick="openProt('.
                      "'NormalProt','$http_address$nprt')\">\n";

            }
            if ( defined $errprt)
            {
                print '<input type="button" name="ErrorProt" style="margin-left:3px; border-width:1px" value="Error log" onclick="openProt('.
                      "'ErrorProt','$http_address$errprt')\">\n";

            }
            if (defined $xprt)
            {
                print '<input type="button" name="ExtProt" style="margin-left:3px; border-width:1px" value="Extended log" onclick="openProt('.
                      "'ExtProt','$http_address$xprt')\">\n";
            }

        }
        else
        {   $defaultlink = $oldprt;     }

        print '<input type="button" name="OldProts" style="margin-left:8px; border-width:1px" value="Old log files" onclick="openProt('.
                  "'OldProts','$http_address${script_name}"._get_http_options()."&action=plist')\">\n";
        print '<input type="button" name="Makedir" style="margin-left:15px; border-width:1px" value="Makedir" onclick="openProt('.
                  "'Makedir','$http_address/$userdir/')\">\n";
        if($^O !~ /win32/i)
        {
            print '<input type="button" style="margin-left:30px" name="ButtonXterm" value="Xterm" onclick="'.
                            "makeRequest('$http_address"._get_xterm_href()."')\">\n";
        }

        print _get_helplink_string();
        print "\n</form>\n";
        print '<script type="text/javascript">'."\n";
        print "markButton('Headform',";

        if (defined $defaultlink)
        {   print ("'OldProts'"); }
        else
        {
            if (defined $cmdparams{'-e'} ||  defined $cmdparams{'-E'})
            {
                $defaultlink = $errprt;
                print ("'ErrorProt'");
            }
            elsif (defined $cmdparams{'-x'} ||  defined $cmdparams{'-X'})
            {
                $defaultlink = $xprt;
                print ("'ExtProt'");
            }
            else
            {
                $defaultlink = $nprt;
                print ("'NormalProt'");
            }
        }



        print ");\n</script>\n";


        if ($defaultlink =~ /\S/)
        {
            print '<iframe src="'."$http_address$defaultlink".'" name="Makeframe"  width="100%" height="87%">'."\n";
        }
        else
        {
            print '<iframe name="Makeframe"  width="100%" height="87%">'."\n";
        }
        print "<p>No iframes supported by your browser</p>\n";
        print "</iframe>\n";
        print "</p>\n";
        # _set_BackgroundColor($DefaultBGColor);

        if ($defaultlink !~ /\S/)
        {
            _open_html_Makeframe();
            _print_to_Makeframe("Error: cannot find make log files for $target");
            _close_html_Makeframe();
        }

    }
    else
    {
        _print_headline  ("Log files");
        _print_links_to_protocols();
        _print_link_to_own(1);
    }

}

######################

sub stop_make
{
    my @make_infos = _get_make_info("$own/log/build.pid");
    _set_cmdparams($make_infos[1]);
    if (defined $make_infos[0])
    {
        _print_startline ("$Glob{'release'}($Glob{'user'}): stop make - $make_infos[1] - PID $make_infos[0]");
        _print_headline  ("Canceling remote make",  $make_infos[1]);
        _stop_make($own);
    }
    else
    {
        _print_startline ("$Glob{'release'}($Glob{'user'}): stop make - can't find current make information");
        _print_headline  ("Canceling remote make", $make_infos[1]);
        _print_h3 ("Can't find make infomation. No make is running.");
    }
    _print_link_to_own();
    _print_links_to_protocols(1);
}

######################

sub clean_make
{
    my ($version, $targets, $options)=_analyze_cmdparams();
    my $check = undef;
    my $all = undef;
    my $user_to_cleanup = $Glob{'user'};
    my $multiple_select = 0;
    if ( @dirs_to_cleanup )
    {
        _print_startline ("$Glob{'release'}($Glob{'user'}): clean selected directories");
        _print_headline ("Removing selected make directories");
    }
    else
    {
        foreach (@$options)
        {
            if (/-all/)
            {
                $all = 1 ;
                $multiple_select = 1;
            }
            $check = 1 if (/-check/);
            if (/-user=(.*)$/)
            {
                $multiple_select = 1;
                $user_to_cleanup = $1;
            }
        }

        if ( $multiple_select == 0 && defined $Glob{'ignoreown'})
        {
             _print_startline  ("Cleanup of main make area forbidden!");
             _print_headline  ("You are trying to cleanup main area, which is very destructiv...");
             _print_h3 ("remfree only supported for user area for this reason...");
        }
        else
        {

            if ($all)
            {
                _print_startline ("$Glob{'release'}($Glob{'user'}): clean all of $user_to_cleanup");
                _print_headline ("Removing make directories". ($check ? "($check)" : ""));

                opendir MAKEDIR, "$own/..";
                my @found_dirs = grep {/_$user_to_cleanup/} readdir MAKEDIR;
                close DEVDIR;

                if ( ( $Glob{'mode'} =~ /telnet/ ) || defined $check )
                {
                    @dirs_to_cleanup =  @found_dirs;
                }
                else
                {
                    print $query->startform (-method=>"get");
                    print $query->checkbox_group(-name=>'deldirs',
                                        -values=>[@found_dirs],
                                        -defaults=>[@found_dirs],
                                        -linebreak=>'yes');
                    _print_nl();
                    print $query->hidden(-name=>'action',-default=>'clean');
                    print $query->hidden(-name=>'user',-default=>$Glob{'user'});
                    print $query->hidden(-name=>'debug',-default=>$Glob{'debug'}) if (defined $Glob{'debug'});
                    print $query->hidden(-name=>'profiledir',-default=>$Glob{'profiledir'}) if (defined $Glob{'profiledir'});
                    print $query->hidden(-name=>'type',-default=>$Glob{'type'});
                    print $query->hidden(-name=>'release',-default=>$Glob{'release'});
                    print $query->hidden(-name=>'ajax',-default=>1) if ($Glob{'use_ajax'});
                    print $query->hidden(-name=>'css',-default=>1) if ($Glob{'use_css'});
                    print $query->hidden(-name=>'scroll',-default=>$Glob{'scroll'}) if (defined $Glob{'scroll'});
                    print $query->hidden(-name=>'specialtype',-default=>$Glob{'specialtype'}) if (defined $Glob{'specialtype'});
                    print $query->hidden(-name=>'display',-default=>$Glob{'display'}) if (defined $Glob{'display'});
                    print $query->hidden(-name=>'setenv',-default=>$Glob{'setenv'}) if (defined $Glob{'setenv'});

                    print $query->submit('Delete','Delete');
                    print $query->submit('Cancel','Cancel');
                    print $query->endform;
                    return;
                }
            }
            elsif ( -d "$ENV{'DOCUMENT_ROOT'}/$userdir" )
            {
                _print_startline ("$Glob{'release'}($Glob{'user'}): $userdir");
                _print_headline ("Removing make directory", $userdir );

                if ($userdir =~ /$typedir\/(.*)$/)
                {
                    @dirs_to_cleanup = ($1);
                }
            }
            else
            {
                _print_startline ("$Glob{'release'}($Glob{'user'}): clean $userdir");
                _print_headline ("Removing make directory", $userdir);
            }
        }

        if ( @dirs_to_cleanup  &&  ! $query->param('Cancel') )
        {
            my @errors = ();
            my $count = 0;
            foreach (@dirs_to_cleanup)
            {
                my $own_to_cleanup = "$ENV{'DOCUMENT_ROOT'}/$typedir/$_";
                if ( $check )
                {
                    _print_h3 ("To delete $own_to_cleanup");
                }
                else
                {
                    _print_h3 ("Delete $own_to_cleanup ...");
                    if (  -d $own_to_cleanup )
                    {
                        if (defined ((_get_make_info("$own_to_cleanup/log/build.pid"))[0]))
                        {
                            _stop_make($own_to_cleanup);
                            sleep (2);
                        }
                        _print_nl();
                        if ( rmtree($own_to_cleanup, defined $Glob{'debug'} ? 1 : 0  ) > 0)
                        {
                            _print_h3 ("... $own_to_cleanup removed");
                            $count++;
                        }
                        else
                        {
                            _print_h3 ("... error while removing $own_to_cleanup");
                            push @errors, $own_to_cleanup;
                        }
                    }
                    else
                    {
                        _print_h3 ("... $own_to_cleanup not found");
                    }
                    _print_hr();
                }
            }
            _print_nl();
            _print_h3 ("$count make ". ( $count>1 ? "directories" : "directory" ). " deleted successfully") if ($count);
            if (@errors)
            {
                _print_h3 ("Deleting of ". (join ",", @errors) . "failed !");
            }
        }
        else
        {
            _print_h3 ("Nothing to delete ...");
        }
    }
}

##########################

sub plist_make
{
    my @versions = @_;
    my $protHash = undef;
    _print_startline ("$Glob{'release'}($Glob{'user'}): List of log files");

    my $logDir = "log";
    $logDir = "prot" if -d "$own/sys/wrk/opt/prot";

    foreach my $version (('fast','quick','slow','opt','dbg'))
    {
        _print_dbg ("look in '$own/sys/wrk/$version/$logDir'...",2);
        my @protlist = find_files("$own/sys/wrk/$version/$logDir", "", 10, '.*\.e.' );
        foreach my $protfile (@protlist)
        {
            unless (($protfile =~ /^config\/Buildinfo/) || ($protfile =~ /^config\/profiles/))
            {
                my $filetime = (stat("$own/sys/wrk/$version/$logDir/$protfile"))[9];
                if (open (FILE, "<$own/sys/wrk/$version/$logDir/$protfile"))
                {
                    my $errorcount = 0;
                    $protHash->{$filetime}->{'status'} = "Not Finished";
                    while (<FILE>)
                    {
                        if (/TARGET: .* STATUS: ERROR/)
                        {
                            $errorcount++;
                        }
                        if (/END: MAKE .* RESULT: (ERROR|OK|NO ACTION)/)
                        {
                            $protHash->{$filetime}->{'status'} = ($1 eq "NO ACTION") ? "Skipped" : $1;
                            last;
                        }
                    }
                    $protHash->{$filetime}->{'errorcount'} = $errorcount;
                }
                close FILE;
                $protHash->{$filetime}->{'file'} = "$protfile";
                $protHash->{$filetime}->{'version'} = "$version";
                _print_dbg ("found '$protfile' ($filetime)",2);
            }
        }
    }

    if (defined $protHash)
    {
        _print_h3 ("Found following log files:");
        print $query->start_table({-border => '1', -cellpadding=>5} );
        foreach my $filetime (reverse sort {$a <=> $b} keys %$protHash)
        {
            my $protshortname = ($protHash->{$filetime}->{file} =~ /\/([^\/]+)$/) ? $1 : $protHash->{$filetime}->{file};
            my $protshortname = $protHash->{$filetime}->{file};
            if ($protHash->{$filetime}->{file} =~ /^(.*)\.e(.)/)
            {
                my $target = $1;
                my $histcount = $2;
                print "<tr><td".(
                    ($protshortname ne $protHash->{$filetime}->{file} ) ?
                    " title='$protHash->{$filetime}->{file}'>" :
                    ">");
                print $query->a({-href => "/$userdir/sys/wrk/$protHash->{$filetime}->{version}/$logDir/$target.p$histcount"},"$target");
                print "</td><td>$protHash->{$filetime}->{version}";
                print "</td><td>";
                print $query->a({-href => "/$userdir/sys/wrk/$protHash->{$filetime}->{version}/$logDir/$target.e$histcount"},
                       $protHash->{$filetime}->{'errorcount'} ?
                       "$protHash->{$filetime}->{'errorcount'} Errors" :
                       $protHash->{$filetime}->{'status'});
                print "</td><td>";
                print $query->a({-href => "/$userdir/sys/wrk/$protHash->{$filetime}->{version}/$logDir/$target.x$histcount"},"Extended");
                print "</td><td>".localtime($filetime)."</td>\n";
                print "</tr>";
            }
        }
        print $query->end_table();
    }

}



sub find_files
{
    my ($initialdir, $subdir, $deep, $name) = @_;
    my @returnvalue;
    my $newdir = $initialdir;
    ($subdir =~ /\S/) and $newdir.="/$subdir";
    -d "$newdir" or return undef;
    opendir(DH,"$newdir") || return undef;
    my @content = readdir(DH);
    closedir(DH);
    _print_dbg ("Check $subdir ...\n",1);

    my @files = grep { -f "$newdir/$_" } @content;
    my @dirs = grep { -d "$newdir/$_" && ! /^\.{1,2}$/} @content;


    if ( $deep > 0 )
    {
        foreach(@dirs)
        {
            -l "$newdir/$_" and next;
            my @result = find_files($initialdir, ($subdir =~ /\S/) ? "$subdir/$_" : "$_", $deep-1 , $name );
            defined @result && push @returnvalue,@result;
        }
    }

    foreach my $file (@files)
    {

        if (! defined $name || $file =~ /^$name$/ )
        {
            push @returnvalue,($subdir =~ /\S/) ? "$subdir/$file" : "$file";
        }
    }

    return @returnvalue;
}

##############################################

sub cmd_make
{
    my $rc = 0;
    my $complete_cmd = join " ", @{$Glob{'cmdparams'}} ;
    _print_startline ("$Glob{'release'}($Glob{'user'}): Execute command '$Glob{'cmd'} @{$Glob{'cmdparams'}}'");

    unless (($Glob{'mode'} =~ /telnet/) && $Glob{'silent'} )
    {
        _print_headline  ("Execute command");
        _print_nl();
        _print_h3("$complete_cmd");
    }
    _check_path($own);

    if ( ! -e "$own/$Glob{'iprofile'}" )
    {
        _prepare_make();
        _print_hr();
    }
    my $remcmd;

    if ($^O =~/win32/i)
    {
        if ( $Glob{'type'} =~ /^(lc|hdb)$/)
        { $remcmd = "call \"$own\\iprofile.bat\" & cmd /c ";    }
        else
        { $remcmd = "call \"$own\\..\\iprofile.bat\" $own & cmd /c ";   }
    }
    else
    { $remcmd = ". $own/.iprofile ; "; }

    _begin_pre_text();
    $ENV{'SUPPRESS_PROFILE_OUTPUT'} = 'yes';
    _print_dbg ("call: $remcmd $complete_cmd",2);
    if (open(REMCMD,"$remcmd $complete_cmd 2>&1|"))
    {
        while(<REMCMD>)
        {
            print("$_");
        }
        close REMCMD;
        $rc = $?;
        _print_dbg("return value: $rc", 2);
    }
    else
    {
        _print ("Error while exucuting: $!\n");
        $rc = 1;
    }

    _end_pre_text();
    unless ($Glob{'mode'} =~ /telnet/)
    {
        _print_nl();

        if ( $rc == 0 )
        { _print_h3("Remote command finished successfully") ;   }
        else
        { _print_h3("Remote command finished with errors", "red" );}
        _print_link_to_own(1);
    }
}

###############################################

sub dir_make
{

    print "<html><head><meta http-equiv=\"refresh\" content=\"0; URL=$http_address/$userdir/\">\n</head><body>";
    _print_h2  ("Automatic forward to OWN ... ");
    _print_nl();
    _print_link_to_own();
}


###############################################


sub manage_make
{
    my ($version, $targets, $options)=_analyze_cmdparams();
    my %userdirs;
    my @releasedir_list = ();
    my $starttime = time ;
    my $sort_by = "own";
    my $reverse_sort = 0;
    _print_startline ("RemManager - Managing make users directories");
    _print_h2("RemManager for $Glob{'platform'} ($remote_hostname)");
    _print_hr();
    _print_h3  ("User directories in ".$query->a({-href => "$http_address/$Glob{'type'}/"},"$ENV{'DOCUMENT_ROOT'}/$typedir"));
    if ( -d "$ENV{'DOCUMENT_ROOT'}")
    {
        _print_dbg  ("DOCUMENT_ROOT:$ENV{'DOCUMENT_ROOT'}", 2);
        foreach (@$options)
        {
            if (/-sort=(.*)$/)
            {
                $sort_by = $1;
                _print_dbg  ("sort by $1", 2);
            }
            if (/-rsort=(.*)$/)
            {
                $sort_by = $1;
                $reverse_sort = 1;
                _print_dbg  ("reverse sort by $1", 2);
            }
        }

        opendir MAKEDIR, "$ENV{'DOCUMENT_ROOT'}/$typedir";
        my @user_dirs = sort grep {/_[dDCIic]\d{6}/} readdir MAKEDIR;
        close DEVDIR;

        my $sizesum = 0;
        my $dircount = 0;

        foreach (@user_dirs)
        {
            $dircount++;
            _set_title("$current_titleline - ".$dircount."/".scalar(@user_dirs));

            my %userdata ;
            my $cached_size;
            if (($starttime > 0) && (time > $starttime + 5))
            {
                _begin_text();
                print ("Determining size of user directories ... \n\n");
                _end_text();
                $starttime = 0;
            }
            $userdata{'own'} = "$_";
            my $localown = "$ENV{'DOCUMENT_ROOT'}/$typedir/$userdata{'own'}";
            _print_dbg ("Get infos for $localown");

            if ($userdata{'own'} =~ /_([dDCcIi]\d{6})/)
            {   $userdata{'user'}= uc ($1); }
            else
            {   $userdata{'user'}= "unknown";   }

            if (-e "$localown/log/build.pid" || -e "$localown/sys/wrk/vmake.pid" )
            {   $userdata{'state'}  =  "running";   }
            else
            {   $userdata{'state'}  =  "finished";  }
            $userdata{'date'} = 0;
            if ( -f "$localown/$Glob{'iprofile'}" )
            {
                $userdata{'date'} = (stat("$localown/$Glob{'iprofile'}"))[9];
            }
            if ( (-d "$localown/sys/wrk") &&
                ((stat("$localown/sys/wrk"))[9] >  $userdata{'date'} ))
            {
                    $userdata{'date'} = (stat("$localown/sys/wrk"))[9];
            }
            if($^O !~ /win32/i)
            {
                if (-f "$localown/.ownsize.cached" &&
                    (stat("$localown/.ownsize.cached"))[9] == $userdata{'date'} &&
                    time < (stat("$localown"))[9] + 15000
                    )
                {
                    my $fh = new FileHandle "$localown/.ownsize.cached", "r";
                    if ( defined $fh )
                    {
                        _print_dbg ("Read cached size ...", 3);
                        my $line = <$fh>; # info line
                        _print_dbg ("$line", 4);
                        $line = <$fh>;
                        chomp $line;
                        _print_dbg ("$line", 4);
                        $userdata{'size'} = int $line;
                    }
                    $fh->close;
                    _print_dbg ("Found cached size info: $userdata{'size'}", 2 );
                }
                else
                {
                    unlink "$localown/.ownsize.cached" if (-f "$localown/.ownsize.cached");
                    $userdata{'size'} = int `du -sk $localown`;
                    chomp $userdata{'size'};
                    my $fh = new FileHandle ">$localown/.ownsize.cached";
                    if (defined $fh)
                    {
                        $fh->print("# cached size of own directory for remmng\n");
                        $fh->print("$userdata{'size'}\n");
                        $fh->close;
                        utime $userdata{'date'}, $userdata{'date'}, "$localown/.ownsize.cached";
                    }
                    _print_dbg ("Determined size: $userdata{'size'}");
                }
            }
            $sizesum += $userdata{'size'};
            push @{$userdirs{$userdata{$sort_by}}}, \%userdata;
        }

        _print  (scalar (@user_dirs)." user directories found - overall ".int($sizesum/1024)."MB ");
        _print_nl();
        _set_title("$current_titleline");

        my %duser  = ();
        if (-e "$ENV{'TOOL'}/bin/tel.pl")
        {
            _print_dbg("execute $ENV{TOOL}${pathseparator}bin${pathseparator}tel.pl ...\n");
            open (TELCALL, "perl $ENV{TOOL}${pathseparator}bin${pathseparator}tel.pl |");
            while (<TELCALL>)
            {
                if (/^\"(.*)\"\s*, ([^,]*)\s*, ([DCI]\d+)\s*, [^,]*, (\S+@\S+)\s*,/)
                {
                    my $dnumber = uc ($3);
                    $duser{$dnumber}->{'Name'} = $1;
                    $duser{$dnumber}->{'Tel'} = $2;
                    $duser{$dnumber}->{'Mail'} = $4;
                    _print_dbg ("$dnumber: $duser{$dnumber}->{'Name'}\n");
                }
                else
                {
                        _print_dbg ("Not matched: '$_'\n");
                }
            }
            close (TELCALL);
        }


        my $href = "${script_name}"._get_http_options()."\&action=manage";
        my @columns = ($^O =~ /win32/i) ? ("own","user","state","date") : ("own","user","state","size","xterm","date");
        print "<table border=\"1\" cellpadding=\"5\">\n";
        foreach (@columns)
        {
            print  "<td><a href=\"$href\&cmdparam=".
                   (( ($reverse_sort == 0) && ($sort_by =~ /^$_$/)) ? "-rsort" : "-sort").
                   "=$_\">".uc($_)."</a></td>";
        }

        my @valuelist = ();
        my $manuser = $duser{uc($Glob{'user'})}->{'Name'};
        ($manuser =~ /^(.*)\s(\S*)$/)  and $manuser = $1;

        if ($reverse_sort)
        {  @valuelist = reverse sort { $sort_by =~ /size|date/ ? int $a <=> int $b : lc("$a") cmp lc ("$b") } keys %userdirs;   }
        else
        {  @valuelist = sort { $sort_by =~ /size|date/ ? int $a <=> int $b : lc("$a") cmp lc ("$b") } keys %userdirs;   }

        foreach my $value ( @valuelist )
        {
            foreach my $userdata (@{$userdirs{$value}})
            {
                my $dnumber = uc($userdata->{'user'});
                print  "<tr><td><a href=\"/$typedir/$userdata->{'own'}/\">$userdata->{'own'}</a></td>";
                my $mailbody = "mailto:$duser{$dnumber}->{'Mail'}?body=Hello ";
                if (defined $duser{$dnumber}->{'Name'})
                {
                    $mailbody .= ($duser{$dnumber}->{'Name'} =~ /^(.*)\s(\S*)$/) ? $1 : "$duser{$dnumber}->{'Name'}";
                    $mailbody .= ',%0D%0A%0D%0A'. "... your make area $userdata->{'own'} on $Glob{'platform'} ".'%0D%0A';
                    $mailbody .= "   $http_address/$typedir/$userdata->{'own'} ".'%0D%0A%0D%0A';
                    $mailbody .= '%0D%0ABest regards,%0D%0A'.$manuser.'%0D%0A';
                    print "<td nowrap title='$duser{$dnumber}->{'Tel'}'><a href=\""._to_mailformat ("$mailbody")."\">$duser{$dnumber}->{'Name'}</a></td>";
                }
                else
                {   print ("<td><p>$userdata->{'user'}</p></td>")};


                if ( -e  "$ENV{'DOCUMENT_ROOT'}/$typedir/$userdata->{'own'}/log/build.prot" )
                {   print  "<td><a href=\"/$typedir/$userdata->{'own'}/log/build.prot\">$userdata->{'state'}</a>"; }
                else
                {   print  "<td><p>$userdata->{'state'}</p></td>";  }
                if ($^O !~ /win32/i)
                {
                    print  "<td><p>".int($userdata->{'size'}/1024)."</p></td>";
                    print '<td><p><input type="button" name="ButtonXterm" value="Xterm" onclick="'.
                            "makeRequest('$http_address"._get_xterm_href()."&forced_userdir=$typedir/$userdata->{'own'}')\"></p></td>\n";
                }
                print  "<td><p>".gmtime($userdata->{'date'})."</p></td>";
                print "</tr>";
            }
        }
        print "</table>";
    }
}

######################

sub term_make
{
    _print_startline ("$Glob{'release'}($Glob{'user'}): Open xterm");
    $Glob{'silent'} or _print_headline("Open xterm");

    _check_path($own);

    if ( ( defined $Glob{'oldprofile'} ) && ( ! -e "$own/$Glob{'iprofile'}" ))
    {
        _print_h3 ("Can't find profile ($own/$Glob{'iprofile'}) - force generation");
        _print_nl();
        $Glob{'oldprofile'} = undef;
    }
    unless ( defined $Glob{'oldprofile'} )
    {
        _prepare_make();
        _print_hr();
    }

    if ($^O=~/win32/i)
    {
        _print_h3 ("Xterm is not available for windows", "red" );
    }
    else
    {
        if (($Glob{'src_dir'} =~ /^(.*):(.:|X)/) || ($Glob{'src_dir'} =~ /^(.*):/))
        {
            my $xterm_cmd = "$ENV{TOOL}/bin/remterm.sh $own $ENV{'DISPLAY'}";
            $ENV{'SDB_PLATFORM_TAG'} = $Glob{'platform'};
            _print_h3 ("Start xterm");
            _print_dbg ("xterm command: $xterm_cmd\n", 2 );
            _begin_text();
            open(XTERM,"$xterm_cmd 2>&1 |");
            while(<XTERM>)
            {       _print ("$_"); }
            close XTERM;
            _end_text();
        }
        else
        {
            _error_exit ("Can't determine display from $Glob{'src_dir'}\n");
        }

    }
    _print_hr();
    _print_link_to_own();
}


######################

sub _prepare_make
{
    my $outline = undef;
    my @outlines = ();
    # create a new profile
    unless ( defined $Glob{'ignoreown'} )
    {
        if ($Glob{'silent'})
        { push @outlines, "Create a new profile"; }
        else
        { _print_h3("Create a new profile"); }
        _begin_pre_text();
        $ENV{'SUPPRESS_PROFILE_OUTPUT'} = "yes" if ((defined $Glob{'silent'}) && (! defined $Glob{'debug'}));
        my $tooldir = $ENV{'TOOL'};
        if ($Glob{'type'} =~ /^(lc|hdb)$/)
        {
            local @ARGV = ("-own", $own, "-tool", $tooldir, "-vmake_path", "$own,$Glob{'src_dir'}");
            if ($Glob{'type'} eq "hdb")
            {
                push @ARGV, "-release", $Glob{'release'},
            }
            else
            {
                push @ARGV, "-lc_state", $Glob{'lc_state'},
            }
            push @ARGV, "-bit64"  if ( defined $Glob{'bit64'} );
            push @ARGV, "-bit32"  if ( defined $Glob{'bit32'} );
            if (defined $Glob{'silent'})
            {
                _print_dbg ("executable: $^X\n");
                my $cmd = "$^X $tooldir/bin/create$Glob{'type'}profile.pl ";
                $cmd .= join " ", @ARGV;
                _print_dbg ("execute: $cmd\n");
                open(PROFILECALL,"$cmd 2>&1 |");
                while(defined($outline=<PROFILECALL>))
                {
                    chomp $outline;
                    push @outlines, $outline;
                    _print_to_protfile ("$outline");
                    _print_dbg ("$outline");
                }
                close PROFILECALL;
                unless ( $? == 0 )
                {
                    _error_exit("Profile generation failed:\n". join "\n", @outlines);
                }
            }
            else
            {
                _print_dbg ("call $tooldir/bin/create$Glob{'type'}profile.pl @ARGV");
                do "$tooldir/bin/create$Glob{'type'}profile.pl";
            }
        }
        else
        {
            do "$tooldir/bin/vmakeEnv.pl";
            my @myARGV=("-own", $own, "-lcversion", "$Glob{'lcversion'}", "-apo_src", "$Glob{'src_dir'}", "-apo_com_short", "$Glob{'apo_com_short'}", "-remcall");
            push @myARGV, "-release", "$Glob{'branch'}";
            push @myARGV, "-lc_state", "$Glob{'lc_state'}" if ($Glob{'lc_state'});
            push @myARGV, "-lcpool_count", "$Glob{'lcpool_count'}" if ($Glob{'lcpool_count'});
            push @myARGV, "-apo_patch_level", $Glob{'apo_patch_level'} if ($Glob{'apo_patch_level'});
            push @myARGV, "-bit","64" if ($Glob{'bit64'});
            push @myARGV, "-debugX" if (defined $Glob{'debug'});
            push @myARGV, "-type", "dbg" if ($Glob{'variant'} =~ /Debug/);
            _print_dbg ("call vmakeEnv::init with following arguments\n    ". (join "\n    ", @myARGV). "\n"  , 4);
            vmakeEnv::init(@myARGV);
            unless (defined $Glob{'platform'})
            {
                $Glob{'platform'} = vmakeEnv::getPlatform();
                _print_dbg ("vmakeEnv told me I work on '$Glob{'platform'}'", 3);
            }
            _print_dbg ("call vmakeEnv::createProfile");

            my @profile_args = ("-all");
            push @profile_args, "-append", "$ENV{TOOL}/profiles/APODev/iprofile.$Glob{'platform'}" unless ($^O=~/win32/i);
            eval { vmakeEnv::createProfile(@profile_args); };
            if ($@)
            {
              print ("Error:$@\n");
                die;
            }
        }
        my $localfiledir = "$ENV{'DOCUMENT_ROOT'}/$typedir";
        if (defined $Glob{'profiledir'})
        {
            $localfiledir .= "/$Glob{'profiledir'}";

        }
        elsif (( $Glob{'type'} =~ /^lcapps$/ ) && ($^O=~/win32/i) )
        {

            $localfiledir .= ( defined $Glob{'bit64'} ? "/bit64" : "/bit32" );
        }
        # copy iuser and ipreprof
        _print_dbg ("copy localfiledir=$localfiledir", 2);
        foreach my $localfile (@{$Glob{'localfiles'}})
        {
            if (-e "$localfiledir/$localfile")
            {
                unlink ("$own/$localfile");
                _print_dbg ("copy $localfiledir/$localfile $own/$localfile", 2);
                copy ( "$localfiledir/$localfile", "$own/$localfile");
            }
        }
    }
    else
    {
        _print_h3("Using existing profile for independend make");
        _begin_text();
    }

    if ($Glob{'debug'} > 3)
    {

        my $set_call = ($^O=~/win32/i) ? "call \"$own\\iprofile.bat\" & set" : ". $own/.iprofile; set";
        my $settings = `$set_call`;
        _print_dual ("Current Settings after run iprofile:\n$settings\n");
    }
    _end_pre_text();;
}

###############################
# stop all makes (lc, lcapps)
###############################
sub _stop_make
{
    my $own = shift;
    my @make_infos = _get_make_info("$own/log/build.pid");
    my $rc = 0;
    _print_h3 ("Stop current make ($make_infos[1])");
    _begin_pre_text();
    #_begin_text();

    my $cancelfilename = "$own/log/build.canceled";
    _print_dbg ("write canceled $cancelfilename", 2);
    my $fh = new FileHandle ">$cancelfilename";
    if (defined $fh)
    {
        $fh->print("$make_infos[0]\n");
        $fh->print("$make_infos[1]\n") if (defined $make_infos[1]);
        $fh->close;
    }
    else
    {
        _error_exit("Can't open $cancelfilename");
    }

    my $kill_cmd;
    if ($^O =~/win32/i)
    {
        if ( $Glob{'type'} =~ /^(lc|hdb)$/)
        { $kill_cmd = "call \"$own\\iprofile.bat\" & cmd /c %TOOLSHELL% -S StopBuild.pl -make_only";    }
        else
        { $kill_cmd = "call \"$own\\..\\iprofile.bat\" $own & cmd /c %TOOLSHELL% -S StopBuild.pl -make_only";   }
    }
    else
    { $kill_cmd = ". $own/.iprofile ; \$TOOLSHELL -S StopBuild.pl -make_only"; }

    open(KILLCMD,"$kill_cmd |");
    while(<KILLCMD>)
    {
        _print ("$_");
    }
    close KILLCMD;
    $rc = $?;

    unlink ("$own/log/build.pid");

    #if ($Glob{'outputtype'} !~ /blind/)
    #{
    #   if ( _kill_process($make_infos[0], $make_infos[1]) > 0 )
    #   {
    #       $rc ++;
    #   }
    #else
    #{
  # unlink ("$own/log/build.pid");
    #}
    #}
    _end_pre_text();
    #_end_text();
    if ( $rc > 0 )
    {
        _print_h3 ("Error while stopping running make");
    }
    else
    {
        _open_protfile(">$own/log/build.prot");
        _print_to_protfile("\n\nRemote make canceled by an other process");
        _print_to_protfile("\nRemcall was finished\n");
        _print_h3 ("Make stopped successfully");
        _close_protfile();
    }
    _print_dbg ("_stop_make returned with $rc", 3);
    return $rc;
}

######################

sub _analyze_cmdparams
{
    my @targets = ();
    my @options = ();
    my $version = ($Glob{'type'} =~ /^hdb$/) ? "opt" : "fast";
    my $ignore_default_variants = shift;
    if ($Glob{'type'} =~ /^(lc|hdb)$/)
    {
        _print_dbg ("analyze '$Glob{'cmd'} @{$Glob{'cmdparams'}}'",2);
        if ($Glob{'type'} =~ /^hdb$/)
        {
            if ($Glob{'cmd'} =~ /h[lm]d/)
            {   $version = "dbg"; }
            elsif ($Glob{'cmd'} =~ /h[lm]o/)
            {   $version = "opt"; }
        }
        else
        {
            if ($Glob{'cmd'} =~ /i[pm]q/)
            {   $version = "quick"; }
            elsif ($Glob{'cmd'} =~ /i[pm]s/)
            {   $version = "slow"; }
        }
        _print_dbg ("Version is set to '$Glob{'version'}'",2);

        foreach my $param (@{$Glob{'cmdparams'}})
        {
            _print_dbg ("Analyze param '$param'",2);
            if ( $param =~ /^-/ )
            {
                push @options, $param;
                if ($param =~ /^([^=]*)=(.+)$/)
                {   $cmdparams{$1} = $2; }
                else
                {   $cmdparams{$param} = "";}
            }
            else
            {
                if ( $param =~ /^(.*)\/[\/-]/ )
                {   push @targets, $1;  }
                else
                {   push @targets, $param;  }
            }
        }
    }
    else
    {
        foreach my $param (@{$Glob{'cmdparams'}})
        {
            _print_dbg ("Analyze param '$param'",2);
            if ( $param =~ /^-/ )
            {
                push @options, $param;
                if ($param =~ /^--config=(.*)$/)
                {
                    $Glob{'variant'} = $1;
                }
                if ($param =~ /^--noconfig$/)
                {
                    $Glob{'variant'} = undef;
                }
            }
            else
            {
                if ( $param =~ /^(.*)\/[\/-]/ )
                {   push @targets, $1;  }
                else
                {   push @targets, $param;  }
            }
        }
        if ((defined $Glob{'variant'}) && ! $ignore_default_variants)
        {
            _print_dbg ("Append variant '$Glob{'variant'}' to targetnames",2);
            for ( my $count=0; $count <= $#targets; $count++)
            {
                _print_dbg ("Append variant '$Glob{'variant'}' to $targets[$count]",3);
                if ($targets[$count] =~ /^(.*)\.([^\.]*)$/)
                {   $targets[$count] = "$1+$Glob{'variant'}.$2"; }
                else
                {   $targets[$count] .= "+$Glob{'variant'}";    }
                _print_dbg ("Target now $targets[$count]",3);
            }
        }
    }
    @global_targets = @targets;
    $global_version = $version;
    return ($version, \@targets, \@options);
}

######################

sub _kill_process
{
    my $pid = shift;
    my $text = shift;

    if ( defined $text)
    {
        print "Stopping \"$text\" (PID: $pid) ... ";
        if (($^O=~/win32/i))
        {
            _print_dbg ("kill vmake with killpstree ($pid)\n", 2);
            local @ARGV = ($pid);
            do "$ENV{'TOOL'}/bin/killpstree.pl";
        }
        else
        {
            my $count = kill 9, $pid;
            if ($count >= 1 )
            {
                print "OK\n";
                return 0;
            }
            else
            {
                print "ERROR\n";
                return 1;
            }
        }
    }
}

sub _print_javascript_functions ()
{
    return if ($Glob{'mode'} =~ /telnet/);
#==================================
    my $java_scipt_functions = "<script type=\"text/javascript\" language=\"javascript\">\n";

    $java_scipt_functions .= "var Makecall = '$Glob{'cmd'}';\n";
    $java_scipt_functions .= <<EOJS1;

    var Makestate = 0;
    var ScrollEnabled = 1;

    function makeRequest(url) {
        var http_request = false;

        if (window.XMLHttpRequest) { // Mozilla, Safari, ...
            http_request = new XMLHttpRequest();
            if (http_request.overrideMimeType) {
                http_request.overrideMimeType('text/xml');
                // See note below about this line
            }
        } else if (window.ActiveXObject) { // IE
            try {
                http_request = new ActiveXObject("Msxml2.XMLHTTP");
            } catch (e) {
                try {
                    http_request = new ActiveXObject("Microsoft.XMLHTTP");
                } catch (e) {}
            }
        }

        if (!http_request) {
            alert('Giving up :( Cannot create an XMLHTTP instance');
            return false;
        }
        http_request.onreadystatechange = function() { alertContents(http_request); };
        http_request.open('GET', url, true);
        http_request.send(null);
    }


    function CheckEnterInMakeCall(LastEvent)
    {
        var charCode;
        // needed for NN4
        if(LastEvent && LastEvent.which)
            charCode = LastEvent.which;
        else
            charCode = event.keyCode; // for IE
        if(charCode == 13)
        {
            Check = true;
            if (Makestate != 0)
            {
                Check = confirm ("Do you want cancel running make?");
                if (Check)
                    Makestate = -1; // to Cancel

            }
            if (Check)
            {
                CancelRestart();
            }
            return false
        }
        else
            return true;

    }


    /*  if (LastKey.which == 13)
        {
            alert ("Found Enter");
            window.location.reload();
            //LastKey.keyCode=9;
            //CancelRestart(window.location.href);
            return false;
        }
    }
    */

    function CancelRestart (url)
    {
        if (Makestate < 1)
        {
            var CurrentCallTokens =  window.location.href.split('&');
            var NewCall = '';
            var org_cmd = Makecall;
            for (var i = 0; i < CurrentCallTokens.length; ++i)
            {
                if ( CurrentCallTokens[i].match(/cmd=/))
                    org_cmd = CurrentCallTokens[i];
                else
                    if (! CurrentCallTokens[i].match(/cmd=|cmdparam=|cmdtargets=|cmdoptions=/))
                    {
                        if ( NewCall != "")
                            NewCall = NewCall + "&";
                        NewCall = NewCall + CurrentCallTokens[i];
                    }
            }
            NewCall = NewCall + "&action=start&oldprofile=1";
            var MakeTargetTokens = document.forms["Headform"].elements["MakeCallText"].value.split(' ');
            if (MakeTargetTokens[0].match(/^(imf|imq|ims|lcmake|hmo|hmd)/))
            {
                NewCall = NewCall + "&cmd="+MakeTargetTokens[0];
                MakeTargetTokens.shift();
            }
            else
                NewCall = NewCall + "&" + org_cmd;

            for (var i = 0; i < MakeTargetTokens.length; ++i)
            {
                if ((MakeTargetTokens[i] != "") && (MakeTargetTokens[i] != " "))
                {
                    var newparam = MakeTargetTokens[i].replace(/\\+/g, "%2B");
                    newparam = newparam.replace(/=/g, "%3D");
                    NewCall = NewCall + "&cmdparam=" + newparam;
                }
            }
            // force killing old make
            if (Makestate < 0)
            {
                NewCall = NewCall + "&forcemake=1";
            }
            window.location.href = NewCall;
        }
        else
        {
            makeRequest(url);
        }
    }




    function alertContents(http_request) {

        if (http_request.readyState == 4) {
            if (http_request.status == 200) {
EOJS1
#<==================================
    if ($Glob{'debug'})
    { $java_scipt_functions .= "\n               alert(http_request.responseText)\n";}
    else
    { $java_scipt_functions .= "\n               // nothing to show\n";}
#==================================>
    $java_scipt_functions .= <<EOJS2;
            } else {
                alert('There was a problem with the request.');
            }
        }

    }

    function setprogress(progress)
    {
        if (window.document.MakeProgress)
            window.document.getElementById('MakeProgress').value = progress;
    }

    // start of prot javascript

    ProtButtons = new Array("NormalProt","ErrorProt","ExtProt","OldProts","Makedir");

    function openProt(ProtType,url) {
        parent.Makeframe.location = url;
        if (ProtType == "ButtonXterm")
        {
            // nothing do do
        }
        else
        {
            for (var i = 0; i < ProtButtons.length; ++i)
            {
                if (document.forms["Headform"].elements[ProtButtons[i]])
                {
                    if (ProtType == ProtButtons[i])
                    {
                        document.forms["Headform"].elements[ProtButtons[i]].style.backgroundColor = "ActiveCaption";
                        document.forms["Headform"].elements[ProtButtons[i]].style.color = "CaptionText";
                    }
                    else
                    {
                        document.forms["Headform"].elements[ProtButtons[i]].style.backgroundColor = "ButtonFace";
                        document.forms["Headform"].elements[ProtButtons[i]].style.color = "ButtonText"; // "#ffa0a0";
                    }
                }
            }
        }

    }

    function markButton(Formname,Buttonname)
    {
        document.forms[Formname].elements[Buttonname].style.backgroundColor = "ActiveCaption";
        document.forms[Formname].elements[Buttonname].style.color = "CaptionText";
    }

EOJS2
#<==================================
    if (($Glob{'action'} =~ /start/) && ($Glob{'scroll'} ne "no"))
    {
#
    $java_scipt_functions .= <<EOJS3;

    function AutoScroll ()
    {
        if ((Makestate > 0) && (ScrollEnabled == 1))
        {
            window.scrollBy(0,2000);
            window.setTimeout("AutoScroll()", 2000);
        }
    }

    function setScrollButton ()
    {
        if (ScrollEnabled)
        {
            document.forms["Headform"].elements["ButtonScroll"].value = 'Scroll on';
            ScrollEnabled = 0;
        }
        else
        {
            document.forms["Headform"].elements["ButtonScroll"].value = 'Scroll off';
            ScrollEnabled = 1;
        }
    }


    //window.setTimeout("AutoScroll()", 20000);

EOJS3
}
#<==================================
$java_scipt_functions .= "</script>\n";

_end_text();
print $java_scipt_functions;
}

sub _print_css
{
    return if ($Glob{'mode'} =~ /telnet/);
    my $css_definitions = <<EOCSS;
<style type="text/css">
body {
height:100%;
margin:0;
}

#menu {
left:0;
top:0;
width:100%;
height:90px;
background:#D4D9DB; /* Menu;                */
z-index:4;
padding-left:7;
}

body>#rahmen { padding-top:90px;  padding-buttom:90px; padding-left:7; }

body>#menu { position:fixed; }

body>#inhalt { position:static; }

#makeoutput {color:black; font-family:'Courier'; font-size:smaller }
#erroroutput {color:red; font-weight: bold; font-family:'Courier'; font-size:smaller }

pre { color:black; font-family:'Courier'; font-size:smaller }

</style>
<!--[if gte IE 5.5000]>
<style type="text/css">
html, body { overflow:hidden; }
#menu, #rahmen { position:absolute; }
#rahmen {
top:100px;
left:0;
padding-left:7;
padding-top:10;
padding-bottom:10;
height:expression(document.body.clientHeight - 100 + "px");
width:100%;
overflow:auto;
z-index:3;
position:relative; /* damit es im IE mit Mausrad scrollt */
}
#menu {padding-top:10px; height:100px;}
</style>

<![endif]-->
EOCSS

    print $css_definitions;
}


#######################

sub _add_blind_link
{
    my $linkname = shift;
    my $linkaddress = shift;

    return if ($Glob{'mode'} =~ /telnet/);
    print "<span\n";
    print "style=\"cursor: pointer; text-decoration: underline\"\n";
    print "onclick=\"makeRequest('$linkaddress')\">\n";
    print "$linkname\n";
    print "</span>\n";
}

######################
#
sub _print_link_to_own
{
    my $seperator = shift;
    return if ($Glob{'mode'} =~ /telnet/);
    my $old_text_opened = $text_opened;
    my $xterm_href = "${script_name}"._get_http_options();
    $xterm_href .= "\&action=term\&oldprofile=on";

    _end_text();
    _print_hr() if ($seperator);
    if ($^O=~/win32/i)
    {
        _print_h3("Make directory:   ".$query->a({-href => "$http_address/$userdir/", -target=> "_blank"},"$userdir"));
    }
    elsif ($Glob{'use_ajax'})
    {
        _print_h3("Make directory:   ".$query->a({-href => "$http_address/$userdir/", -target=> "_blank"},"$userdir "));
        _print_nl();
        _add_blind_link ("xterm", "$http_address$xterm_href");
    }
    else
    {
        _print_h3("Make directory:   ".$query->a({-href => "$http_address/$userdir/", -target=> "_blank"},"$userdir ").
        "(".$query->a({-href => $xterm_href, -target=> "RemTermWindow" },"xterm").")");
    }
    _begin_text() if ($old_text_opened == 1);
}


######################
#
sub _print_links_to_protocols
{
    my $seperator = shift;
    return if ($Glob{'mode'} =~ /telnet/);
    my $old_text_opened = $text_opened;
    _end_text();
    if ($seperator)
    {
        _print_nl();
        _print_hr()
    }
    _print_h3("Log files:");
    my $targets;
    my $options;
    my $version;
    ($version, $targets, $options)=_analyze_cmdparams();

    print $query->start_table({-border => '1', -cellpadding=>5} );

    #print "<TABLE with=100% cellpadding=10>";
    foreach my $target (@$targets)
    {
        my $name = $target;
        my $protroot = "sys/wrk/$version/";
        $protroot .= (-d "$own/sys/wrk/$version/prot") ? "prot/" : "log/";
        my $prot = "";
        if ($target =~ /::?(.*)/)
        {   $prot =  "$protroot$1"; }
        else
        {   $prot = "$protroot$target" };
        # description without extension
        # -> look for <extension>.e0

        if (($Glob{'type'} =~ /^lcapps$/) && defined ($Glob{'variant'}) && ($prot !~ /\+$Glob{'variant'}/))
        {
            if ($prot =~ /^(.*)\.([^\/\.]*)$/)
            {
                $prot = "$1+$Glob{'variant'}".".$2";
            }
            else
            {
                $prot .= "$Glob{'variant'}";
            }
            _print_dbg ("prot is now $prot", 1 );
        }

        if ( (($name =~ /^::/) || ($name !~ /\//)) && ($name !~ /\./))
        {
            _print_dbg ("found description without extension", 1 );
            foreach (@desc_extensions)
            {
                _print_dbg ("check description for $_", 2 );
                if ( -f "$own/$prot.$_.p0" )
                {
                    $target .= ".$_";
                    $prot   .= ".$_";
                    last;
                }
            }
        }
        elsif ((not -e "$own/$prot.e0") && ($target =~ /^:.*\/([^\/]*)$/))
        {
            if (-e "$own/$protroot$1.e0")
            {   $prot = "$protroot$1";  }
        }

        _print_dbg ("protfile to search for is '$prot.e0'", 1 );

        if ($Glob{'use_web2'})
        {
            my $prot_request = "$http_address${script_name}".   _get_http_options()."&action=prot&cmd=";
            if ($Glob{'type'} =~ /^lcapps$/)
            { $prot_request .= "lcprot.pl"; }
            elsif ($Glob{'type'} =~ /^hdb$/)
            { $prot_request .= "hl".(substr $version, 0,1).".pl"; }
            else
            { $prot_request .= "ip".(substr $version, 0,1).".pl"; }

            if ($Glob{'type'} =~ /^lcapps$/)
            {
                if  (defined ($Glob{'variant'}))
                {
                    if ($target =~ /^(.*)\+$Glob{'variant'}(.*)$/)
                    {
                        $target =  "$1$2";
                        $prot_request .= "&cmdparam=--config=$Glob{'variant'}";
                    }
                }
                else
                {   $prot_request .= "&cmdparam=--noconfig";}
            }
            $prot_request .= "&cmdparam=$target";

            print $query->Tr($query->th({-align => 'right'},"$target:"),
            $query->td( -e "$own/$prot.e0" ? $query->a({-href => "$prot_request&cmdparam=-e", -target=> "_blank"},'Error log') : "Error log file not found"),
            $query->td( -e "$own/$prot.p0" ? $query->a({-href => "$prot_request", -target=> "_blank"},'Standard log') : "Standard log file not found"),
            $query->td( -e "$own/$prot.x0" ? $query->a({-href => "$prot_request&cmdparam=-x",, -target=> "_blank"},'Extended log') : "Extended log file not found"));
        }
        else
        {
            print $query->Tr($query->th({-align => 'right'},"$target:"),
            $query->td( -e "$own/$prot.e0" ? $query->a({-href => "/$userdir/$prot.e0", -target=> "_blank"},'Error log') : "Error log file not found"),
            $query->td( -e "$own/$prot.p0" ? $query->a({-href => "/$userdir/$prot.p0", -target=> "_blank"},'Standard log') : "Standard log file not found"),
            $query->td( -e "$own/$prot.x0" ? $query->a({-href => "/$userdir/$prot.x0", -target=> "_blank"},'Extended log') : "Extended log file not found"));
        }
    }
    print $query->end_table();
    # print "</TABLE>";
    _begin_text() if ($old_text_opened == 1);
}

sub _get_logfile_links
{
    my $target = shift;
    my $version = shift;
    my $name = $target;
    my $protroot = "sys/wrk/$version/";
    $protroot .= (-d "$own/sys/wrk/$version/prot") ? "prot/" : "log/";
    my $prot = "";
    if ($target =~ /::?(.*)/)
    {   $prot =  "$protroot$1"; }
    else
    {   $prot = "$protroot$target" };
    # description without extension
    # -> look for <extension>.e0

    if (($Glob{'type'} =~ /^lcapps$/) && defined ($Glob{'variant'}) && ($prot !~ /\+$Glob{'variant'}/))
    {
        if ($prot =~ /^(.*)\.([^\/\.]*)$/)
        {
            $prot = "$1+$Glob{'variant'}".".$2";
        }
        else
        {
            $prot .= "$Glob{'variant'}";
        }
        _print_dbg ("prot is now $prot", 1 );
    }

    if ( (($name =~ /^::/) || ($name !~ /\//)) && ($name !~ /\./))
    {
        _print_dbg ("found description without extension", 1 );
        foreach (@desc_extensions)
        {
            _print_dbg ("check description for $_", 2 );
            if ( -f "$own/$prot.$_.p0" )
            {
                $target .= ".$_";
                $prot   .= ".$_";
                last;
            }
        }
    }
    elsif ((not -e "$own/$prot.e0") && ($target =~ /^:.*\/([^\/]*)$/))
    {
        if (-e "$own/$protroot$1.e0")
        {   $prot = "$protroot$1";  }
    }

    _print_dbg ("protfile to search for is '$prot.e0'", 1 );

    if ($Glob{'use_web2'})
    {
        my $prot_request = "$http_address${script_name}".   _get_http_options()."&action=prot&cmd=".
                          (($Glob{'type'} =~ /^lcapps$/) ? "lcprot" : (($Glob{'type'} =~ /^hdb$/) ? "hl" : "ip" ).(substr $version, 0,1)).
                          ".pl";

        if ($Glob{'type'} =~ /^lcapps$/)
        {
            if  (defined ($Glob{'variant'}))
            {
                if ($target =~ /^(.*)\+$Glob{'variant'}(.*)$/)
                {
                    $target =  "$1$2";
                    $prot_request .= "&cmdparam=--config=$Glob{'variant'}";
                }
            }
            else
            {   $prot_request .= "&cmdparam=--noconfig";}
        }

        $prot_request .= "&cmdparam=$target";
        return ((-e "$own/$prot.e0")? "$prot_request&cmdparam=-e" : undef,
                (-e "$own/$prot.p0")? "$prot_request" : undef,
                (-e "$own/$prot.x0")? "$prot_request&cmdparam=-x" : undef);
        }
    else
    {
        return ((-e "$own/$prot.e0")? "/$userdir/$prot.e0" : undef,
                (-e "$own/$prot.p0")? "/$userdir/$prot.p0" : undef,
                  (-e "$own/$prot.x0")? "/$userdir/$prot.x0" : undef);
    }
}


######################
sub _print_maketarget
{
    my $seperator = shift;
    return if ($Glob{'mode'} =~ /telnet/);
    my ($version, $targets, $options)=_analyze_cmdparams(1);
    my $old_text_opened = $text_opened;
    _end_text();
    _print_hr() if ($seperator);
    _print_h3("Restart make");
    print $query->startform (-method=>"get");
    print "Config:  ";
    if ($Glob{'type'} =~ /lcapps/)
    {
        print $query->radio_group(-name=>'variant',
                                  -values=>['Release','Debug'],
                                  -default=>'Release');
    }
    elsif ($Glob{'type'} =~ /hdb/)
    {
        print $query->radio_group(-name=>'maketype',
                                  -values=>['opt', 'dbg'],
                                  -default=>$version);
  }
    else
    {
        print $query->radio_group(-name=>'version',
                                  -values=>['fast', 'quick', 'slow'],
                                  -default=>$version);
    }
    _print_nl(2);
    print "Options:  ";
    print $query->textfield(-name=>'cmdoptions',
                            -override=>1,
                            -size=>50,
                            -default=>join " ", @$options);
    _print_nl(2);
    print "Targets:  ";
    print $query->textfield(-name=>'cmdtargets',
                            -override=>1,
                            -size=>50,
                            -default=>join " ", @$targets);
    _print_nl(2);
    if ($Glob{'type'} =~ /^(lc|hdb)$/)
    {
        if (defined $Glob{'oldprofile'})
        {
            $query->param(-name=>'oldprofile',-value=>'ON');
            print $query->checkbox(-name=>'oldprofile',
                                   -checked=>'checked',
                                   -value=>'ON',
                                   -label=>"  Don't generate a new profile");
        }
        else
        {
            print $query->checkbox(-name=>'oldprofile',
                                   -label=>"  Don't generate a new profile");
        }
        _print_nl(2);
    }
    print $query->hidden(-name=>'action',-default=>'start');
    print $query->hidden(-name=>'user',-default=>$Glob{'user'});
    print $query->hidden(-name=>'debug',-default=>$Glob{'debug'}) if (defined $Glob{'debug'});
    print $query->hidden(-name=>'profiledir',-default=>$Glob{'profiledir'}) if (defined $Glob{'profiledir'});
    print $query->hidden(-name=>'type',-default=>$Glob{'type'});
    print $query->hidden(-name=>'cmd',-default=>"lcmake");
    print $query->hidden(-name=>'src_dir',-default=>$Glob{'src_dir'});
    print $query->hidden(-name=>'forced_userdir',-default=>$Glob{'forced_userdir'});
    print $query->hidden(-name=>'display',-default=>$Glob{'display'});
    print $query->hidden(-name=>'bit64',-default=>$Glob{'bit64'}) if (defined $Glob{'bit64'});
    print $query->hidden(-name=>'platform',-default=>$Glob{'platform'}) if (defined $Glob{'platform'});
    print $query->hidden(-name=>'specialtype',-default=>$Glob{'specialtype'}) if (defined $Glob{'specialtype'});
    print $query->hidden(-name=>'display',-default=>$Glob{'display'}) if (defined $Glob{'display'});
    print $query->hidden(-name=>'setenv',-default=>$Glob{'setenv'}) if (defined $Glob{'setenv'});
    print $query->hidden(-name=>'suffix',-default=>$Glob{'suffix'}) if (defined $Glob{'suffix'});

    if ($Glob{'type'} =~ /^(lc|hdb)$/)
    {
        print $query->hidden(-name=>'release',-default=>$Glob{'release'});
        print $query->hidden(-name=>'lc_state',-default=>$Glob{'lc_state'}) if (defined $Glob{'lc_state'});
        print $query->hidden(-name=>'ignoreown',-default=>$Glob{'ignoreown'}) if (defined $Glob{'ignoreown'});
    }
    else
    {
        print $query->hidden(-name=>'branch',-default=>$Glob{'branch'});
        print $query->hidden(-name=>'apo_com_short',-default=>$Glob{'apo_com_short'});
        print $query->hidden(-name=>'lcversion',-default=>$Glob{'lcversion'});
        print $query->hidden(-name=>'lc_state',-default=>$Glob{'lc_state'});
        print $query->hidden(-name=>'lcpool_count',-default=>$Glob{'lcpool_count'}) if (defined $Glob{'lcpool_count'});
        print $query->hidden(-name=>'apo_patch_level',-default=>$Glob{'apo_patch_level'}) if (defined $Glob{'apo_patch_level'});
        print $query->hidden(-name=>'changelist',-default=>$Glob{'changelist'}) if (defined $Glob{'changelist'});
        print $query->hidden(-name=>'relstat',-default=>$Glob{'relstat'}) if (defined $Glob{'relstat'});
        print $query->hidden(-name=>'p4client',-default=>$Glob{'p4client'}) if (defined $Glob{'p4client'});
    }

    print $query->submit('Start','Start');
    print $query->endform;
    _begin_text() if ($old_text_opened == 1);
    return;
}


######################
# write output to $protfile and stdout
sub _print_dual
{
    my $text = shift;
    if (($Glob{'mode'} !~ /telnet/) && ($text =~ /VMAKE\sREPORT:\s+Make state - (\d+)% \/ error count: (\d+) /))
    {
        unless ($logfilebutton_enabled)
        {
            _activate_LogfileButton();
        }
        if ($2 > 0)
        {
            _set_title ("ERR $1% ($2 Error".(($2>1) ? "s" : "").") - $current_titleline");
        }
        else
        {
            _set_title ("$1% - $current_titleline");
        }

        _update_progress ("$1");
    }
    else
    {
        $text_opened or _begin_text();
        _print_to_protfile ($text);
        _print ("$text");
    }

}


######################
# write output to iframe
sub _print_to_Makeframe
{
    my $text = shift;
    if ($Glob{'mode'} =~ /telnet/)
    { print "$text";}
    else
    {
        if ($ProtFrameOpen == 0 )
        {
            _open_html_Makeframe();
        }

        print "<script type=\"text/javascript\">\n";
        $text =~ s/'/\\'/gm;
        print "parent.Makeframe.document.writeln('$text')";
        print "</script>";
    }
}

######################
# write output to iframe
sub _open_html_Makeframe
{
    my $text = shift;
    if ($Glob{'mode'} !~ /telnet/)
    {
        print "<script type=\"text/javascript\">\n";
        print "parent.Makeframe.document.open()";
        print "</script>";
        $ProtFrameOpen = 1;
    }
}


sub _close_html_Makeframe
{
    my $text = shift;
    if ($Glob{'mode'} !~ /telnet/)
    {
        print "<script type=\"text/javascript\">\n";
        print "parent.Makeframe.document.close()\n";
        print "</script>";
    }
}



######################
# write output and stdout
sub _print
{
    my $text = shift;
    if ($Glob{'mode'} =~ /telnet/)
    { print "$text";}
    else
    {
        chomp $text;
        if ($text =~ /^BUILD ERROR: /)
        {
            print "<div id=\"erroroutput\">";
            print (_html_styled_text($text));
            print "</div>\n";
        }
        else
        {
            print (_html_styled_text($text));
            print "<BR />\n";
        }
        _scroll_down(200);
    }
}


######################
#
sub _html_styled_text
{
    my $text = shift;
    $text =~ s/\&/\&amp;/g;
    $text =~ s/</\&lt;/g;
    return ($text);
}

######################

sub _write_pid_file
{
    my $text     = shift;
    my $filename = "$own/log/$pid_file_name";
    _print_dbg ("write pidfile $filename", 2);
    my $fh = new FileHandle ">$filename";
    if (defined $fh)
    {
        $fh->print("$$\n");
        $fh->print("$text\n") if (defined $text);
        $fh->close;
    }
    else
    {
        _error_exit("Can't open $filename");
    }
}

######################

sub _open_protfile
{
    my $filename = shift;

    $protfile = new FileHandle (">$filename");
    $protfile->autoflush(1);
    unless (defined $protfile)
    {
        _error_exit("can't open $filename for writing");
    };
}

#####################

sub _update_progress
{
    my $progress = shift;
    if ($Glob{'mode'} =~ /telnet/)
    {
    #   print ("$text\n");
    }
    else
    {
        #my $tmp_text_opened = $text_opened;
        #( $text_opened ) and _end_text();
        print "<script type=\"text/javascript\">\n";
        print "setprogress('$progress');\n";
        print "</script>";
    }
}



######################

sub _close_protfile
{
    $protfile->close();
}

######################

sub _get_make_info
{
    my $file = shift;
    my $pid = undef;
    my $command = undef;
    if (-f $file)
    {
        my $fh = new FileHandle "$file", "r";
        if ( defined $fh )
        {
            $pid = <$fh>;
            chomp $pid;
            $command = <$fh>;
            chomp $command;
        }
        $fh->close;
    }
    return ($pid,$command);
}


sub _get_xterm_href
{

    return if ($Glob{'mode'} =~ /telnet/);
    my $old_text_opened = $text_opened;
    my $xterm_href = "${script_name}"._get_http_options();
    $xterm_href .= "\&action=term\&oldprofile=on";

    return $xterm_href;
}

######################

sub _kill_vmake
{
    my $own = shift;
    my $pidfile = "$own/sys/wrk/vmake.pid";
    my $pid = undef;
    my $fh = new FileHandle "$pidfile", "r";
    my $rc = 1;
    if ( defined $fh )
    {
        $pid = <$fh>;
        chomp $pid;
    }
    $fh->close;
    if (defined $pid)
    {
        #if($^O =~ /win32/i)
        #{
            #try it with a event at first
        #   require Win32::Event;
        #   import Win32::Event;
        #
        #   _print_dbg("Send Event VMAKE_STOP_$pid ...",1);
        #   my $event = Win32::Event->open("VMAKE_STOP_$pid");
        #   if ($event)
        #   {
        #       $event->set;
        #       $rc = 0;
        #   }
        #}

        unless ($rc == 0)
        { $rc = _kill_process ( $pid, "vmake" ); }

        if ( $rc == 0 )
        {
            _print_dbg ("unlink '$pidfile'", 2);
            sleep 1;
            unlink "$pidfile";
        }
    }
    else
    {
        print "Error: can't get process infomation of vmake\n";
    }
    return ($rc);
}



######################
#
sub _set_cmdparams
{
    my $make_infos = shift;
    if (defined $make_infos)
    {
        # init $Glob{'cmd'} and @{$Glob{'cmdparams'}} with running make
        @{$Glob{'cmdparams'}} = split ' ', $make_infos;
        $Glob{'cmd'} = shift @{$Glob{'cmdparams'}};
    }
    return;
}

######################

sub _get_http_options
{
    my $action=shift;
    my $http_options = "?user=$Glob{'user'}&type=$Glob{'type'}";
    $http_options .= "&bit64=1" if (defined $Glob{'bit64'});
    $http_options .= "&debug=$Glob{'debug'}" if (defined $Glob{'debug'});
    $http_options .= "&scroll=$Glob{'scroll'}" if (defined $Glob{'scroll'});
    $http_options .= "&platform=$Glob{'platform'}" if (defined $Glob{'platform'});
    $http_options .= "&specialtype=$Glob{'specialtype'}" if (defined $Glob{'specialtype'});
    $http_options .= "&suffix=$Glob{'suffix'}" if (defined $Glob{'suffix'});
    $http_options .= "&setenv=$Glob{'setenv'}" if (defined $Glob{'setenv'});
    $http_options .= "&setenv=$Glob{'setenv'}" if (defined $Glob{'setenv'});
    $http_options .= "&src_dir=$Glob{'src_dir'}" if (defined $Glob{'src_dir'});
    $http_options .= "&forced_userdir=$Glob{'forced_userdir'}" if (defined $Glob{'forced_userdir'});
    $http_options .= "&display=$Glob{'display'}" if (defined $Glob{'display'});

    $http_options .= "&ajax=1" if ($Glob{'use_ajax'});
    $http_options .= "&css=1" if ($Glob{'use_css'});
    if ($Glob{'type'} =~ /^(lc|hdb)$/)
    {   $http_options .= "&release=$Glob{'release'}&lc_state=$Glob{'lc_state'}"; }
    else
    {
        $http_options .= "&branch=$Glob{'branch'}";
        $http_options .= "&p4client=$Glob{'p4client'}" if (defined $Glob{'p4client'});
    }
    return ($http_options);
}


sub _set_Makestate
{
    my $state = shift;
    return if ($Glob{'mode'} =~ /telnet/);
    _set_StartCancel_Button($state);

    print '<script type="text/javascript">'."\n";
    print "Makestate = $state;\n";
    print "</script>\n";
}

sub _set_StartCancel_Button
{
    return if ($Glob{'mode'} =~ /telnet/);
    my $state = shift;
    my $text = ($state == 0) ? "Restart new make" : "Cancel running make";

    print '<script type="text/javascript">'."\n";
    print "document.Headform.$CancelButtonName.value = '$text';\n";
    print "document.forms['Headform'].elements['ButtonScroll'].disabled = ".
           (($state == 0) ? "true":"false").";\n";
    print "</script>\n";
}

sub _set_Button
{
    my $ButtonName = shift;
    my $on_off = shift;
    return if ($Glob{'mode'} =~ /telnet/);
    my $value = ($on_off == 0) ? "true" : "false";
    return unless ($Glob{'use_web2'});

    print '<script type="text/javascript">'."\n";

    print "</script>\n";
}

sub _activate_LogfileButton
{
    my ($err, $std, $ext) = _get_logfile_links($global_targets[0], $global_version);
    print '<script type="text/javascript">'."\n";
    print "document.forms['Headform'].elements['$LogfileButtonName'].disabled = false;\n";
    print "document.forms['Headform'].elements['$LogfileButtonName'].onclick = function(){window.open('$std', '_blank');}\n";
    print "</script>\n";
    $logfilebutton_enabled = 1;
}


sub _set_BackgroundColor
{
    my $Color = shift;

    print '<script type="text/javascript">'."\n";
    print "document.bgColor = '$Color';\n";
    print "</script>\n";
}


######################

sub _close_html
{
    if ($Glob{'mode'} =~ /telnet/)
    {
        _print_dual ("Remcall was finished");
    }
    elsif ($Glob{'action'} =~ /start/)
    {
        if ($Glob{'use_css'})
        {
            _scroll_down(2000);
            print "</div>\n";
            print "</div>\n";
        }
        else
        {
            _print_hr();
            my $responsible_text = '<p>Responsible for problems and questions: <a href="mailto:DL_NEWDB_VMAKE@sap.com';
            my $body = '?body=%0D%0A%0D%0ANecessary information: %0D%0Acurrent action: '."$Glob{'action'}";
            if ( $Glob{'action'} =~ /start/i)
            {
                $body .= '%0D%0Ashow make: '.$ENV{'HTTP_SHOW_ADDRRESS'}. '&action=show';
                $body .= '%0D%0Aown: '.$ENV{'HTTP_OWN_ADDRRESS'};
            }
            else
            {
                $body .= '%0D%0Aown: '."$http_address/$userdir/";
            }
            $body .= '%0D%0Acomplete call: '.$query->url(-query => 1);
            $responsible_text .= _to_mailformat ("$body");
            $responsible_text .= '%0D%0A">Team ESW </a></p>';
            print "$responsible_text\n";
            _scroll_down(2000);
        }
    }
    else
    {
        print $query->end_html;
    }
    if ($Glob{'action'} =~ /start/)
    {
        unlink "$own/log/$pid_file_name";
    }
}

sub _scroll_down
{
    my $lines = shift;
    if (($Glob{'mode'} !~ /telnet/) && ($Glob{'scroll'} !~ /no/))
    {
        my $old_text_opened = $text_opened;
        $text_opened and _end_text();
        print "<script type=\"text/javascript\">\n";
        print "if (ScrollEnabled) { window.scrollBy(0,$lines);}\n";
        print "</script>";
        $old_text_opened and _begin_text();
    }
}

sub _print_out
{
    my $text = shift;
    if (defined $outputarea)
    {
        #_print(
    }
    else
    {
        print $text;
    }
}


######################

sub _begin_text
{
    if ( $text_opened == 0 )
    {
        $text_opened = 1;
        print "<div id=\"makeoutput\">" unless ($Glob{'mode'} =~ /telnet/);
    }
}

######################

sub _end_text
{
    if ( $text_opened != 0 )
    {
        $text_opened = 0;
        print "</div>" unless ($Glob{'mode'} =~ /telnet/);
    }
}

######################
sub _begin_pre_text
{
    if ( $pre_text_opened == 0 )
    {
        $pre_text_opened = 1;
        print "<PRE>" unless ($Glob{'mode'} =~ /telnet/);
    }
}

######################

sub _end_pre_text
{
    if ( $pre_text_opened != 0 )
    {
        $pre_text_opened = 0;
        print "</PRE>" unless ($Glob{'mode'} =~ /telnet/);
    }
}



######################

sub _set_title
{
    my $text = shift;
    if ($Glob{'mode'} =~ /telnet/)
    {
    #   print ("$text\n");
    }
    else
    {
        #my $tmp_text_opened = $text_opened;
        #( $text_opened ) and _end_text();
        print "<script type=\"text/javascript\">\n";
        print "settitle('$text');\n";
        print "</script>";
    }
}

######################

sub _print_h2
{
    my $text = shift;
    my $color = shift;
    if ($Glob{'mode'} =~ /telnet/)
    {
        print ("$text\n");
        print ("=" x length ($text) );
        print "\n";
    }
    else
    {
        if (defined $color)
        {
            print $query->h2({-style=>"Color: $color;"},"$text");
        }
        else
        {
            print $query->h2("$text");
        }
    }
}

######################

sub _print_h3
{
    my $text = shift;
    my $color = shift;
    if ($Glob{'mode'} =~ /telnet/)
    {
        print ("$text\n");
    }
    else
    {
        if (defined $color)
        {
            print $query->h3({-style=>"Color: $color;"},"$text");
        }
        else
        {
            print $query->h3("$text");
        }
    }
}

######################

sub _print_nl
{
    my $count = shift;
    $count = 1 unless (defined $count);
    while ($count > 0)
    {
        if (($Glob{'mode'} =~ /telnet/) || $text_opened )
        {   print "\n"; }
        else
        {   print "<BR>\n"; }
        $count--;
    }
}

#######################

sub _print_hr
{
    _print_nl();
    if (($Glob{'mode'} =~ /telnet/) || $text_opened )
    {   print "_____________________________________________________________________\n";    }
    else
    {   print "<HR>\n"; }
    _print_nl();
}


######################

sub _print_startline
{
    my $text = shift;
    if ($Glob{'mode'} =~ /telnet/)
    {
        print "Remcall was started\n";
        unless ($Glob{'silent'})
        {
            my $len = length ($text) + 2;
            print ("\n+".("-" x $len)."+" );
            print ("\n| $text |\n");
            print ("+".("-" x $len)."+\n\n" );
        }
    }
    else
    {
        $current_titleline = "$Glob{'platform'}: $text ($remote_hostname)";
        print $query->start_html("$current_titleline");

        print '<html xmlns="http://www.w3.org/1999/xhtml" lang="en-US"><head>';
        if ($Glob{'use_css'})
        {
            _print_css();
        }
        else
        {
            print "<style type=\"text/css\">\n";
            print "<!--\n";
            print "pre { color:black; font-family:'Courier'; font-size:smaller }\n";
            print "#makeoutput {color:black; font-family:'Courier'; font-size:smaller }\n";
            print "#erroroutput {color:red; font-weight: bold; font-family:'Courier'; font-size:smaller }\n";
            print "-->\n";
            print "</style>\n";
        }

        print "<script type=\"text/javascript\">";
        print "<!-- Begin\n";
        print "function settitle(title) \n";
        print "{\n";
        print "document.title = title;\n";
        print "}\n";
        print "//  End -->\n";
        print "</script>\n";
        print "<meta name=\"pragma\" content=\"no-cache\">\n";
        print "</head>\n";
        print "<BODY>\n";
        #if ($Glob{'use_ajax'} && ($Glob{'action'} =~ /start/))
        #{ print "<body onunload=\"cancelMake()\">\n"; }
        #else
        #{ print "<BODY>\n"; }
        if ($Glob{'use_web2'})
        {
            _print_javascript_functions();
        }
    }
}

######################

sub _print_powered
{
    if ($Glob{'mode'} =~ /telnet/)
    {   print "\n powered by Apache\n";     }
    else
    {
        _print_nl();
        print "<IMG SRC=\"icons/apache_pb.gif\" alt=\"powered by Apache\">";
        _print_nl();
    }
}


#######################

sub _print_headline
{
    my $action = shift;
    my $additional_info = shift;
    my $headline = "$action of ";
    if ($Glob{'type'} =~ /^(lc|hdb)$/)
    {
        $headline .= "$Glob{'release'}";
        if ($Glob{'release'} !~ /(dev|cor)$/i)
        {   $headline .= " ($Glob{'lc_state'})"; }
    }
    else
    {   $headline .= "$Glob{'branch'}"; }
    if ($Glob{'mode'} !~ /telnet/)
    {
        $headline .= " on ". $query->a({-href => "http://pts:1081/TestMonitor/Server.jsp?host=$short_hostname&cmd=detail", -target=> "_blank"}, $short_hostname);
    }
    else
    {   $headline .= " on $short_hostname"; }
    $headline .= (defined $Glob{'platform'}) ? "($Glob{'platform'})" : ""  ;

    (defined $additional_info) and $headline .= ": $additional_info";

    _print_h3($headline);
}

########################################

sub _print_headarea
{
    my $action = shift;
    my $additional_info = shift;
    if ($Glob{'use_css'} && ($Glob{'mode'} !~ /telnet/))
    {   print "<div id=\"menu\">\n"; }
    _print_headline($action, $additional_info);
    if (($Glob{'use_css'}) && ($Glob{'mode'} !~ /telnet/))
    {
        _print_headarea_content();
        print "</div>\n";
        print "<div id=\"rahmen\">\n";
        print "<div id=\"inhalt\">\n";
    }
    else
    {
        _print_hr();
    }
}

######################

sub _print_headarea_content
{

    my $cancelcmd = "CancelRestart('$http_address${script_name}".   _get_http_options()."&action=stop&outputtype=blind')";
    my  $ha_content = '<form name="Headform" action="">'."\n";
    if ($Glob{'action'} =~ /start/)
    {
        $ha_content .= '<input type="button" style="width:140px; margin-left:3px; border-width:1px" name="'. $CancelButtonName.'" value="Cancel running make" onclick="'.
                          $cancelcmd.
                        "\">\n";
        my ($version, $targets, $options)=_analyze_cmdparams(1);
        $ha_content .= '<input type="text" size=75  style="padding-left:3px; margin-left:3px; border-width:1px" name="MakeCallText" onKeyPress="return CheckEnterInMakeCall(event)" value="'."$Glob{'cmd'} ". (join " ", @$options) . " ".(join " ", @$targets). "\">\n";
    }


    $ha_content .= '<input disabled type="button" style="margin-left:10px; border-width:1px" name="'. $LogfileButtonName.'" value="Log Files" onclick="'.
                        "window.open('$http_address/$userdir/', '_blank')\">\n";

    $ha_content .=      '<input type="button" style="margin-left:10px; border-width:1px" name="ButtonXterm" value="Makedir" onclick="'.
                        "window.open('$http_address/$userdir/', '_blank')\">\n";
    if($^O !~ /win32/i)
    {
        $ha_content .=  '<input type="button" style="margin-left:10px; border-width:1px" name="ButtonXterm" value="Xterm" onclick="'.
                        "makeRequest('$http_address"._get_xterm_href()."')\">\n";
    }

    if (($Glob{'mode'} !~ /telnet/) && ($Glob{'scroll'} !~ /no/))
    {
        $ha_content .=      '<input type="button" style="margin-left:10px; border-width:1px" name="ButtonScroll" value="Scroll off" onclick="setScrollButton()">'."\n";
    }
    $ha_content .=      _get_helplink_string(). "\n</form>\n";

    # test for automatic cancel if the site will be leaved
    #if ($Glob{'action'} =~ /start/)
    #{
    #   print '<script type="text/javascript" language="javascript">';
    #   print "\n function cancelMake() {if (Makestate > 0){ $cancelcmd; alert(\"Du willst schon weg?\");} }\n</script>\n";
    #}


    if ($Glob{'use_web2'})
    {
        print ( $ha_content);
    }
    else
    {
        print "<table cellspacing=\"15\">";
        print "<tr><td>";
        print $query->a({-href => "$http_address/$userdir/", -target=> "_blank"},'Make directory');
        print "</td><td>";
        if ($Glob{'use_ajax'})
        {   _add_blind_link ("xterm", "$http_address"._get_xterm_href()); }
        else
        {   print $query->a({-href => _get_xterm_href(), -target=> "RemTermWindow" },"xterm"); }
        print "</td><td>";
        if (($Glob{'action'} =~ /start/) && $Glob{'use_ajax'})
        {   _add_blind_link ("Cancel", "$http_address${script_name}"._get_http_options()."&action=stop&outputtype=blind"); }
        else
        { print "<A HREF=${script_name}"._get_http_options()."&action=stop>Cancel current make</A>"; }
        print "</td></tr>";
        print "</table>\n";
    }
}


sub _get_helplink_string
{

    my $responsible_text = 'mailto:DL_NEWDB_VMAKE@sap.com';
    my $body = '?body=%0D%0A%0D%0AHelpful information: %0D%0Acurrent action: '."$Glob{'action'}";
    if ( $Glob{'action'} =~ /start/i)
    {
        $body .= '%0D%0Ashow make: '."$http_address$script_name"._get_http_options(). '&action=show';
        $body .= '%0D%0Aown: '."$http_address/$userdir/";
    }
    else
    {
        $body .= '%0D%0Aown: '."$http_address/$userdir/";
    }
    my $url = $query->url(-query => 1);
    $url =~ s/127\.0\.0\.\d/$ENV{REMOTE_ADDR}/g;

    $body .= '%0D%0Acomplete call: '.$url;

    $responsible_text .= _to_mailformat ("$body");

    $responsible_text = '<a href="'.$responsible_text.'" style="margin-left:30px;">Help</a>';

    #input type="button" style="margin-left:30px; border-width:1px" name="HelpButton" value="Help"  onclick="makeRequest('."'".
    #                     $responsible_text. "'\">";

    return $responsible_text;
}

######################

sub _print_to_protfile
{
    my $text = shift;
    if (defined $protfile)
    {
        print $protfile "$text";
    }
    else
    {
    # recursion _error_exit ("can't write to log file ($own/log/build.prot)");
    }
}

######################

sub _error_exit
{
    my $text = shift;
    _print_dbg("error_exit: $text", 2 );
    _end_text();

    if ($Glob{'action'} =~ /start/)
    {
        unlink "$own/log/$pid_file_name";
    }
    _print_h3("Error: $text", "red");
    _close_html();
    exit 0;
}

######################

sub _check_path
{
    my $own = shift ;
    my $old_text_opened = $text_opened;
    _print_dbg("_check_path: $own", 2 );
    _begin_text();
    mkpath("$own", 0777) unless (-d "$own");
    _print_dbg("_check_path: $own/log", 2 );
    mkpath("$own/log", 0777) unless (-d "$own/log");
    _print_dbg("_check_path: $own/tmp", 2 );
    mkpath("$own/tmp", 0777) unless (-d "$own/tmp");
    _end_text() if ($old_text_opened == 0);
}

######################

sub _print_dbg
{
    my $text = shift;
    my $dbg_level = shift;
    my $old_text_opened = $text_opened;
    $dbg_level = 1  unless (defined $dbg_level);
    _begin_text();
    if ($Glob{'debug'} >= $dbg_level)
    {
        print ("DBG$dbg_level: $text\n");
    }
    _end_text();
    _scroll_down(20);
}

#####################

sub _handle_stop_signal
{
    print ("Get kill signal ...\n");
    _end_text();
    _print_nl();
    _print_h3 ("Make canceled");
    _print_nl();
    _close_html();
    exit 1;
}

#####################

sub _to_mailformat
{
    my $text = shift;
    $text =~ s/\&/%26/g;
    $text =~ s/ /%20/g;
    return ($text);
}

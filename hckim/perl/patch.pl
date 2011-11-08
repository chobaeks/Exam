#!/usr/bin/perl
use strict;
use warnings;
use Wx;
use Wx qw(:everything);
use Wx::Event qw(EVT_MENU EVT_BUTTON);
use File::Basename;
use File::Copy;
use Wx::Perl::Packager;
use PAR;
use 5.010;

my $sec;
my $min;
my $hour;
my $mday;
my $mon;
my $year;
	
my $openpath = "C:\\patch";
my @fullpathlist;

my $m = Wx::SimpleApp->new;
my $f = Wx::Frame->new (undef, -1, "Patch",[300,300], [760,350]);

#my $Background = Wx::ListCtrl->new ($f, -1, [5,5], [733,303]);
my $TextBox1 = Wx::TextCtrl->new ($f, -1, "BookMark List", [22,10], [90,17], wxTE_READONLY );
my $TextBox2 = Wx::TextCtrl->new ($f, -1, "Save Path", [22,100], [90,17], wxTE_READONLY );
my $TextBox3 = Wx::TextCtrl->new ($f, -1, "File List", [22,130], [90,17], wxTE_READONLY );
my $TextBox4 = Wx::TextCtrl->new ($f, -1, "Comment", [22,265], [90,17], wxTE_READONLY );

my $ListItem = Wx::ListItem->new;
my $ListBox1 = Wx::ListBox->new ($f, -1, [120,100], [500,20]);
my $ListBox2 = Wx::ListCtrl->new ($f, -1, [120,130], [500,130], wxLC_REPORT);
my $ListBox3 = Wx::ListBox->new ($f, -1, [120,10], [500,80]);
my $ListBox4 = Wx::TextCtrl->new ($f, -1, "", [120,265], [500,20]);

$ListBox2->InsertColumn(0, "File Path",wxLIST_FORMAT_LEFT,300);
$ListBox2->InsertColumn(1, "File Name",wxLIST_FORMAT_LEFT,200);

my $button1 = Wx::Button->new ($f, -1, "Open", [630,100], [100,20]);
my $button2 = Wx::Button->new ($f, -1, "List Add", [630,130], [100,20]);
my $button3 = Wx::Button->new ($f, -1, "List Delete", [630,160], [100,20]);
my $button4 = Wx::Button->new ($f, -1, "List Reset", [630,190], [100,20]);
my $button5 = Wx::Button->new ($f, -1, "Run", [630,265], [100,20]);
my $button6 = Wx::Button->new ($f, -1, "Select Use", [630,10], [100,20]);

EVT_BUTTON ($f, $button1, \&open_dirpath_event);
EVT_BUTTON ($f, $button2, \&open_savepath_event);
EVT_BUTTON ($f, $button3, \&open_listdelete_event);
EVT_BUTTON ($f, $button4, \&open_listreset_event);
EVT_BUTTON ($f, $button5, \&play_menu_event);
EVT_BUTTON ($f, $button6, \&play_bookmarkuse_event);

$ListBox1->Append ($openpath);
$ListBox3->Append ("c:\\windows");
$ListBox3->Append ("c:\\windows\\softcamp\\common");
$ListBox3->Append ("c:\\windows\\softcamp\\vsd");
$ListBox3->Append ("c:\\windows\\softcamp\\di");
$ListBox3->Append ("c:\\windows\\softcamp\\sdk");

sub play_bookmarkuse_event
{
	$ListBox1->SetString(0, $ListBox3->GetString ($ListBox3->GetSelection ()));
	$openpath = $ListBox3->GetString ($ListBox3->GetSelection ());
}

sub open_dirpath_event
{

	my $prevdir ="./";

	my( $this, $event ) = @_;
	my $dialog = Wx::DirDialog->new 
		( $f,          
		  "Open Directory",
		  $prevdir,
		  0,
		  wxDefaultPosition,
		);

	if( $dialog->ShowModal != wxID_CANCEL ) 
	{
		$ListBox1->SetString(0, $dialog->GetPath());
		$openpath = $dialog->GetPath();
	}
	
	$dialog->Refresh;     
}


sub open_savepath_event
{
	my $prevdir ="./";
	my $prevfile='';

	my( $this, $event ) = @_;
	my $dialog = Wx::FileDialog->new
		( $f,          
		  "Open", 
		  $prevdir, $prevfile,
		  "|*.*|All files (*.*)", #확장자의 설�
		  wxFD_OPEN | wxFD_MULTIPLE
#이부분의 스트알 빼고는 거의 같음
		);

	if( $dialog->ShowModal != wxID_CANCEL ) 
	{
		foreach ($dialog->GetFilenames)
		{
			$ListItem->SetText($dialog->GetDirectory . $_);
			$ListBox2->InsertStringItem(0, $dialog->GetDirectory);
			$ListBox2->SetItem(0, 1, $_);

			push (@fullpathlist, $dialog->GetDirectory . "\\" .$_);           
		} 
	}
	$dialog->Refresh;              
}


sub open_listdelete_event
{
	waring_window ("Sorry. It's not Ready") and return;
	
	my $item = -1;

	while (1)
	{ 
		$item = $ListBox2->GetNextItem ($item, wxLIST_NEXT_ALL, wxLIST_STATE_SELECTED) . "\n";

		if ($item == -1)
		{
			last;
		}
		else
		{ 
#$ListBox2->GetItemText ($item, 0) . "\n";  #ListBox2 \x{c5d0}\x{c11c} \x{d574}\x{b2f9}\x{d558}\x{b294} \x{ac12}\x{c744} \x{ac00}\x{c838}\x{c640} @fullpathlist \x{bc30}\x{c5f4}\x{c5d0}\x{c11c} \x{c0ad}\x{c81c}\x{d574}\x{c57c}\x{d568}.
			$ListBox2->DeleteItem ($item);
			$item = -1;
		}  
	}
}


sub open_listreset_event
{
	$ListBox2->DeleteAllItems ();
	@fullpathlist = qw();
}


sub waring_window
{    
	my $waring = Wx::MessageDialog->new (undef, $_[0] , 'Waring', wxOK|wxICON_INFORMATION);
	$waring->ShowModal();
}

sub play_menu_event
{   		
	mkdir "c:\\skoipatch", 0755 or warn "Cannot make fred directory: $!" unless (-d "c:\\skoipatch");

	waring_window ("$openpath\nIt's not directory or does not exist. Please insert real directory.") and return unless (-d $openpath);
	waring_window ("Not have file list. Please insert at least one of the file.") and return if (@fullpathlist == 0);
	
	
	($sec, $min, $hour, $mday, $mon, $year) = localtime;

	$year = 1900 + $year;
	++$mon;
	
	waring_window ("already c:\\skoipatch\\" . $year. "_" . $mon . "_" . $mday . "_" . $hour . $min . $sec . "_" . $ListBox4->GetLineText(1) . "is make. Please try again later.") and return if (-d ("c:\\skoipatch\\" . $year. "_" . $mon . "_" . $mday . "_" . $hour . $min . $sec . "_" . $ListBox4->GetLineText(1)));
	 
	mkdir "c:\\skoipatch\\" . $year. "_" . $mon . "_" . $mday . "_" . $hour . $min . $sec . "_" .  $ListBox4->GetLineText(1), 0755 or warn "Cannot make fred directory: $!";
	mkdir "c:\\skoipatch\\" . $year. "_" . $mon . "_" . $mday . "_" . $hour . $min . $sec . "_" .  $ListBox4->GetLineText(1) . "\\old", 0755 or warn "Cannot make fred directory: $!";
	mkdir "c:\\skoipatch\\" . $year. "_" . $mon . "_" . $mday . "_" . $hour . $min . $sec . "_" .  $ListBox4->GetLineText(1) . "\\new", 0755 or warn "Cannot make fred directory: $!";
	
	foreach (@fullpathlist)
	{
		copyandrename (dirname ($_), basename ($_), $openpath);
	}
}

sub copyandrename
{      
	my $dir;
	my $file;
	my $filedir;
	my $filename;
	
	$filedir = $_[0];
	$filename = $_[1];
	$dir = $_[2];
	$file = $filedir . "\\" . $filename;

	#print $filedir ."\n". $filename ."\n". $dir . "\n";
	#print $dir . "\\" . $filename . "\n";

	if (-e $dir . "\\" . $filename)
	{
		print "have\n";
		
		copy ($file, "c:\\skoipatch\\" . $year. "_" . $mon . "_" . $mday . "_" . $hour . $min . $sec . "_" .  $ListBox4->GetLineText(1) . "\\new");
		copy ($dir . "\\" . $filename, "c:\\skoipatch\\" . $year. "_" . $mon . "_" . $mday . "_" . $hour . $min . $sec . "_" .  $ListBox4->GetLineText(1) . "\\old");

		rename ($dir . "\\" . $filename, $dir . "\\" . $filename . "_" . $year . "_" . $mon . "_" . $mday . "_". $hour .$min . $sec) or die "file rename failed : $!";
		move ($dir . "\\" . $filename . "_" . $year . "_" . $mon . "_" . $mday . "_". $hour .$min . $sec, $dir) or die "file rename failed : $!";

		print $file . "\n" . $dir . "\n";
		copy ($file, $dir);
	}
	else
	{	
		print "Nothing\n";
		copy ($file, "c:\\skoipatch\\" . $year. "_" . $mon . "_" . $mday . "_" . $hour . $min . $sec . "_" .  $ListBox4->GetLineText(1) . "\\new") or die "file copy failed : $!";

		copy ($file, $dir) or die "file copy failed : $!";
	}
}

$f->Show();
$m->MainLoop();
#!/usr/bin/perl
use strict;
use warnings;
use Wx;
use Wx qw(:everything);
use Wx::Event qw(EVT_MENU EVT_BUTTON EVT_LISTBOX_DCLICK EVT_LIST_COL_BEGIN_DRAG EVT_DROP_FILES);
use File::Basename; 
use File::Copy;
use Wx::Perl::Packager;
use PAR;
use Encode::KR;
use 5.010;

my $sec;
my $min;
my $hour;
my $mday;
my $mon;
my $year;

my $openpath = "C:\\windows\\softcamp\\vsd";
my @fullpathlist;
my @fullpathlist_tmp;

my $m = Wx::SimpleApp->new;
my $f = Wx::Frame->new (undef, -1, "Patch", [300,300], [760,350]);

my $TextBox1 = Wx::TextCtrl->new ($f, -1, "BookMark List", [22,10], [90,17], wxTE_READONLY );
my $TextBox2 = Wx::TextCtrl->new ($f, -1, "Save Path", [22,100], [90,17], wxTE_READONLY );
my $TextBox3 = Wx::TextCtrl->new ($f, -1, "File List", [22,130], [90,17], wxTE_READONLY );
my $TextBox4 = Wx::TextCtrl->new ($f, -1, "Comment", [22,265], [90,17], wxTE_READONLY );

#my $ListItem = Wx::ListItem->new;

#SavePath
my $ListBox1 = Wx::ListBox->new ($f, -1, [120,100], [500,20]);
#BookMarkList
my $ListBox3 = Wx::ListBox->new ($f, -1, [120,10], [500,80]);
#FileList
my $ListBox2 = Wx::ListCtrl->new ($f, -1, [120,130], [500,130], wxLC_REPORT);
#comment
my $ListBox4 = Wx::TextCtrl->new ($f, -1, "", [120,265], [500,20]);

$ListBox2->InsertColumn(1, "File Path",wxLIST_FORMAT_LEFT,300);
$ListBox2->InsertColumn(0, "File Name",wxLIST_FORMAT_LEFT,200);

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

EVT_LISTBOX_DCLICK ($f, $ListBox3, \&on_BookMarkList_double_click );
EVT_LIST_COL_BEGIN_DRAG ($f, $ListBox2, \&on_fileslist_drag);

sub on_BookMarkList_double_click
{
	$ListBox1->SetString(0, $_[1]->GetString());
}

sub play_bookmarkuse_event
{
	$ListBox1->SetString(0, $ListBox3->GetString ($ListBox3->GetSelection()));
	$openpath = $ListBox3->GetString ($ListBox3->GetSelection());
}

sub open_dirpath_event
{
	my $prevdir ="./";
	my $dialog = Wx::DirDialog->new	($f, "Open Directory", $prevdir, 0, wxDefaultPosition,);

	if($dialog->ShowModal != wxID_CANCEL) 
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

	my $dialog = Wx::FileDialog->new( $f, "List Add", $prevdir, $prevfile, "|*.*|All files (*.*)", wxFD_OPEN | wxFD_MULTIPLE);

	if( $dialog->ShowModal != wxID_CANCEL ) 
	{
		foreach ($dialog->GetFilenames)
		{	
#파일 추가할때 기존에 파일이 있는지 확인
			next if array_exists ($dialog->GetDirectory . "\\" . $_);
			
#$ListItem->SetText($dialog->GetDirectory . $_);
			$ListBox2->InsertStringItem(0,$_);
			
			$ListBox2->SetItem(0, 1, $dialog->GetDirectory);
			push (@fullpathlist, $dialog->GetDirectory . "\\" .$_);           
		} 
	}
	
	$dialog->Refresh;              
}


sub open_listdelete_event
{
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
			array_list_delete ($ListBox2->GetItemText ($item));
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

#변수에 해당하는 메세지를 경고창으로 띄워준다.
sub waring_window
{    
	my $waring = Wx::MessageDialog->new (undef, $_[0] , 'Waring', wxOK|wxICON_INFORMATION);
	$waring->ShowModal();
}

#play 버튼 이벤트. 예외적인 처리를 해주고 @fullpathlist 를 foreach 로 copyandrename 을 돌린다.
sub play_menu_event
{   		
#c:\\patchhistory 폴더가 없을 경우 생성한다.
	mkdir "c:\\patchhistory", 0755 or warn "Cannot make fred directory: $!" unless (-d "c:\\patchhistory");
#$openpath 가 폴더가 아닐 경우 경고창이 나오며 종료된다.
	waring_window ("$openpath\nIt's not directory or does not exist. Please insert real directory.") and return unless (-d $openpath);
#@fullpathlist 에 목록이 하나도 없을 경우 경고창이 나오며 종료된다.
	waring_window ("Not have file list. Please insert at least one of the file.") and return if (@fullpathlist == 0);

	($sec, $min, $hour, $mday, $mon, $year) = localtime;

#시간 자릿수가 한자리일 경우 0 을 앞에 더 추가시킨다.
#나머지작업 아래 5라인을 한줄로 변경 
	$sec = change_time ($sec);
	$min = change_time ($min);
	$hour = change_time ($hour);
	$mday = change_time ($mday);
	$mon = change_time ($mon);

	$year = 1900 + $year;
	++$mon;

	waring_window ("already c:\\patchhistory\\" . $year. "_" . $mon . "_" . $mday . "_" . $hour . $min . $sec . "_" . $ListBox4->GetLineText(1) . "is make. Please try again later.") and return if (-d ("c:\\patchhistory\\" . $year. "_" . $mon . "_" . $mday . "_" . $hour . $min . $sec . "_" . $ListBox4->GetLineText(1)));

	mkdir "c:\\patchhistory\\" . $year. "_" . $mon . "_" . $mday . "_" . $hour . $min . $sec . "_" .  $ListBox4->GetLineText(1), 0755 or warn "Cannot make fred directory: $!";
	mkdir "c:\\patchhistory\\" . $year. "_" . $mon . "_" . $mday . "_" . $hour . $min . $sec . "_" .  $ListBox4->GetLineText(1) . "\\old", 0755 or warn "Cannot make fred directory: $!";
	mkdir "c:\\patchhistory\\" . $year. "_" . $mon . "_" . $mday . "_" . $hour . $min . $sec . "_" .  $ListBox4->GetLineText(1) . "\\new", 0755 or warn "Cannot make fred directory: $!";

	foreach (@fullpathlist)
	{
		copyandrename (dirname ($_), basename ($_), $openpath);
	}
	
	waring_window ("Patch Complete.");
}

#파일경로, 파일이름, 복사할경로를 변수로 받아 처리. 복사할경로에 이미 파일이 있다면 파일이름을 "_날짜" 로 변경하고 복사한다. 복사할경로의 기존파일을 patchhistory\날짜\old\에 복사하고 새롭게 복사한파일을 patchhistory\날짜\new\ 에 복사한다. 
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
	
	if (-e $dir . "\\" . $filename)
	{
		print "have\n";

		copy ($file, "c:\\patchhistory\\" . $year. "_" . $mon . "_" . $mday . "_" . $hour . $min . $sec . "_" .  $ListBox4->GetLineText(1) . "\\new");
		copy ($dir . "\\" . $filename, "c:\\patchhistory\\" . $year. "_" . $mon . "_" . $mday . "_" . $hour . $min . $sec . "_" .  $ListBox4->GetLineText(1) . "\\old");

		rename ($dir . "\\" . $filename, $dir . "\\" . $filename . "_" . $year . "_" . $mon . "_" . $mday . "_". $hour .$min . $sec) or die "file rename failed : $!";
		move ($dir . "\\" . $filename . "_" . $year . "_" . $mon . "_" . $mday . "_". $hour .$min . $sec, $dir) or die "file rename failed : $!";

		print $file . "\n" . $dir . "\n";
		copy ($file, $dir);
	}
	else
	{	
		print "Nothing\n";
		copy ($file, "c:\\patchhistory\\" . $year. "_" . $mon . "_" . $mday . "_" . $hour . $min . $sec . "_" .  $ListBox4->GetLineText(1) . "\\new") or die "file copy failed : $!";
		copy ($file, $dir) or die "file copy failed : $!";
	}
}

#@fullpathlist 에 똑같은 변수가 있으면 1 을 리턴 없으면 0 을 리턴. 
#나머지작업 @fullpathlist 도 받아서 내부배열로 처리할수 있도록 변경해야함
sub array_exists
{
	my $check = $_;
	
	foreach (@fullpathlist)
	{	
		if (basename ($_) eq $check)
		{
			return 1;
		}
	}

	return 0;
}

#@fullpathlist_tmp 에 @fullpathlist 을 넣은 후 @fullpathlist 을 초기화한다. @fullpathlist_tmp 을 foreach 로 돌려 동일한 변수가 있는 경우를 제외하고 @fullpathlist 에 다시 push 한다. 
#나머지작업 한개의 목록마다 배열을 재생성하므로 목록을 많이 선택하거나 배열이 많을 경우 속도가 많이 걸릴 수 있다. 다른 방법도 더 고려해보는게 좋을듯.
sub array_list_delete
{
	my $check = $_[0];
	
	@fullpathlist_tmp = @fullpathlist;
	@fullpathlist = qw();
	
	foreach (@fullpathlist_tmp)
	{
		push (@fullpathlist, $_) unless (basename ($_) eq $check);
	}
	
	@fullpathlist_tmp = qw();
}				

#시간 변수가 한자리일 경우 폴더 자릿수가 맞지 않으므로 0~9 일 경우에는 앞에 0 을 한자리 더 붙여준다. 
sub change_time
{
	my $check = $_[0];
	my @alltime = (0..9);
	
	foreach (@alltime)
	{
		if ($check == $_)
		{
			$check = 0 . $check;
		}
	}
	
	$check;
}

$f->Show();
$m->MainLoop();

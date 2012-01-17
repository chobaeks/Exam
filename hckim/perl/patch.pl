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
use Encode;
use 5.010;

my $sec;
my $min;
my $hour;
my $mday;
my $mon;
my $year;

my $openpath;
my @fullpathlist;
my @fullpathlist_tmp;
my @patchsavepath;
my @patchfilepath;

my $m = Wx::SimpleApp->new;
my $f = Wx::Frame->new (undef, -1, "Patch", [100,100], [760,520]);

my $TextBox1 = Wx::TextCtrl->new ($f, -1, "BookMark List", [22,10], [90,17], wxTE_READONLY );
my $TextBox2 = Wx::TextCtrl->new ($f, -1, "Save Path", [22,100], [90,17], wxTE_READONLY );
my $TextBox3 = Wx::TextCtrl->new ($f, -1, "File List", [22,130], [90,17], wxTE_READONLY );
my $TextBox5 = Wx::TextCtrl->new ($f, -1, "Patch List", [22,290], [90,17], wxTE_READONLY );
my $TextBox4 = Wx::TextCtrl->new ($f, -1, "Comment", [22,430], [90,17], wxTE_READONLY );

#my $ListItem = Wx::ListItem->new;

#SavePath
my $ListBox1 = Wx::ListBox->new ($f, -1, [120,100], [500,20]);
#BookMarkList
my $ListBox3 = Wx::ListBox->new ($f, -1, [120,10], [500,80]);
#FileList
my $ListBox2 = Wx::ListCtrl->new ($f, -1, [120,130], [500,130], wxLC_REPORT);
#comment
my $ListBox4 = Wx::TextCtrl->new ($f, -1, "", [120,430], [500,20]);
#PatchList
my $ListBox5 = Wx::ListCtrl->new ($f, -1, [120,290], [500,130], wxLC_REPORT);

$ListBox2->InsertColumn(1, "File Path",wxLIST_FORMAT_LEFT,300);
$ListBox2->InsertColumn(0, "File Name",wxLIST_FORMAT_LEFT,200);

$ListBox5->InsertColumn(1, "Save Path",wxLIST_FORMAT_LEFT,300);
$ListBox5->InsertColumn(0, "File Path",wxLIST_FORMAT_LEFT,200);

my $button1 = Wx::Button->new ($f, -1, "Open", [630,100], [100,20]);
my $button2 = Wx::Button->new ($f, -1, "List Add", [630,130], [100,20]);
my $button3 = Wx::Button->new ($f, -1, "List Delete", [630,160], [100,20]);
my $button4 = Wx::Button->new ($f, -1, "List Reset", [630,190], [100,20]);
my $button5 = Wx::Button->new ($f, -1, "Run", [630,430], [100,20]);
my $button6 = Wx::Button->new ($f, -1, "Select Use", [630,10], [100,20]);
my $button7 = Wx::Button->new ($f, -1, "Bookmark Open", [630,40], [100,20]);
my $button8 = Wx::Button->new ($f, -1, "Insert", [330,265], [100,20]);
my $button9 = Wx::Button->new ($f, -1, "List Reset", [630,290], [100,20]);

EVT_BUTTON ($f, $button1, \&open_dirpath_event);
EVT_BUTTON ($f, $button2, \&open_savepath_event);
EVT_BUTTON ($f, $button3, \&open_listdelete_event);
EVT_BUTTON ($f, $button4, \&open_listreset_event);
EVT_BUTTON ($f, $button5, \&play_menu_event);
EVT_BUTTON ($f, $button6, \&play_bookmarkuse_event);
EVT_BUTTON ($f, $button7, \&play_bookmarklistopen_event);
EVT_BUTTON ($f, $button8, \&play_Insert_event);
EVT_BUTTON ($f, $button9, \&play_patchlistreset_event);

#$ListBox1->Append ($openpath);

EVT_LISTBOX_DCLICK ($f, $ListBox3, \&on_BookMarkList_double_click );

my $open;
#파일메뉴를 생성
my $file_menu = Wx::Menu->new; #하나의 메뉴를 생성

my $open_pathhistory = $file_menu->Append (-1, 'Open Patch History');

$file_menu->AppendSeparator();#메뉴에서 가운데 ---으로 나누는것 표시

my $bookmark_list_open_menu = $file_menu->Append (-1, 'Bookmark List Open');

$file_menu->AppendSeparator();#메뉴에서 가운데 ---으로 나누는것 표시

my $savepath_open_menu = $file_menu->Append (-1, 'Savepath Open');

$file_menu->AppendSeparator();#메뉴에서 가운데 ---으로 나누는것 표시

my $list_add_menu = $file_menu->Append (-1, 'List Add');
my $list_delete_menu = $file_menu->Append (-1, 'List Delete');
my $list_reset_menu = $file_menu->Append (-1, 'List Reset');

$file_menu->AppendSeparator();#메뉴에서 가운데 ---으로 나누는것 표시

my $run_menu = $file_menu->Append (-1, 'Run');

$file_menu->AppendSeparator();#메뉴에서 가운데 ---으로 나누는것 표시

my $exit_menu = $file_menu->Append (-1, 'Exit');

EVT_MENU($f, $open_pathhistory, \&open_pathhistory_event);
EVT_MENU($f, $bookmark_list_open_menu, \&play_bookmarklistopen_event);
EVT_MENU($f, $savepath_open_menu, \&open_dirpath_event);
EVT_MENU($f, $list_add_menu, \&open_savepath_event);
EVT_MENU($f, $list_delete_menu, \&open_listdelete_event);
EVT_MENU($f, $list_reset_menu, \&Bookmarklist_reset);
EVT_MENU($f, $run_menu, \&play_menu_event);
EVT_MENU($f, $exit_menu, sub {$_[0]->Close(1)});

my $bar = Wx::MenuBar->new; #메뉴바 생성

#Append(위에서 만든메뉴, 메뉴바의 라벨)
$bar->Append($file_menu,'Menu'); #메뉴바에 메뉴생성
$f->SetMenuBar($bar);#프레임에 메뉴를 세팅한다.

mkdir "c:\\patchhistory", 0755 or warn "Cannot make fred directory: $!" unless (-d "c:\\patchhistory");

#bookmark.ini 파일이 없을 경우 생성한다.
#나머지작업 bookmark.ini 의 폴더를 직접 지정할 수 있도록 변경
unless (-e "c:\\patchhistory\\bookmark.ini")
{
	open my $tmp, '>', "c:\\patchhistory\\bookmark.ini" or die $!;
	print $tmp "##it's bookmark list." . "\n";
	print $tmp "##If a list of changes you need to restart Program." . "\n";
	print $tmp "##Base = c:\\windows" . "\n";
	print $tmp "c:\\windows\\softcamp\\vsd" . "\n";
	print $tmp "c:\\windows\\softcamp\\di" . "\n";
	print $tmp "c:\\windows\\softcamp\\common" . "\n";
	print $tmp "c:\\windows\\softcamp\\sds" . "\n";
	close $tmp;
}

Bookmarklist_reset ();

sub open_pathhistory_event
{
	waring_window ("Not find c:\\patchhistory folder.") unless (-d "c:\\patchhistory");
	
	system ("explorer c:\\patchhistory");
}


# bookmark.ini 파일을 불러와 BookMarkList 창에 출력해준다. ## 로 시작하는 부분은 제외하고 가져온다.
sub Bookmarklist_reset
{
open my $BOOKMARK, '<', "c:\\patchhistory\\bookmark.ini" or die $!;

	while (<$BOOKMARK>)
	{
		if (/(^##Base = )(.*)/)
		{
			$ListBox3->Append($2);
			$ListBox1->Append($2);
			$openpath = $2;			
		}
		
		unless (/^##/)
		{ 
			$ListBox3->Append($_);
		}
	}
}


# "List Open" 클릭시에 이벤트
#나머지작업 북마크 리스트 변경시에 자동으로 갱신되도록 변경 (ListBox 를 ListCtrl 로 변경하면 가능하지만 다른 부분에 대한 예외처리가 많이 필요함. ListBox 의 리스트를 삭제하거나 리셋하는것이 가능하다면 쉽게 가능함)
sub play_bookmarklistopen_event
{
	system 'notepad c:\\patchhistory\\bookmark.ini';
	#Bookmarklist_reset ();
}


#BookMarkList 중 하나의 목록을 더블클릭했을시 이벤트
sub on_BookMarkList_double_click
{
	$ListBox1->SetString(0, $_[1]->GetString());
	$openpath = $_[1]->GetString();
}


# "Select Use" 버튼을 눌렀을시에 이벤트
sub play_bookmarkuse_event
{
	$ListBox1->SetString(0, $ListBox3->GetString ($ListBox3->GetSelection()));
	$openpath = $ListBox3->GetString ($ListBox3->GetSelection());
}


# "Open" 버튼을 눌렀을시 이벤트
sub open_dirpath_event
{
	my $prevdir ="./";
	my $dialog = Wx::DirDialog->new	($f, "Open Directory", $prevdir, 0, wxDefaultPosition,);

	if($dialog->ShowModal != wxID_CANCEL) 
	{
		$ListBox1->SetString (0, $dialog->GetPath());
		$openpath = $dialog->GetPath();
	}

	$dialog->Refresh;
}


# "List Add" 버튼을 눌렀을시 이벤트
sub open_savepath_event
{	
	my $prevdir ="./";
	my $prevfile='';#

	my $dialog = Wx::FileDialog->new( $f, "List Add", $prevdir, $prevfile, "|*.*|All files (*.*)", wxFD_OPEN | wxFD_MULTIPLE);

	if( $dialog->ShowModal != wxID_CANCEL ) 
	{
		foreach ($dialog->GetFilenames)
		{	
#파일 추가할때 기존에 파일이 있는지 확인
			next if array_exists ($dialog->GetDirectory . "\\" . $_);
			
#$ListItem->SetText($dialog->GetDirectory . $_);
			$ListBox2->InsertStringItem (0, $_);
			
			$ListBox2->SetItem (0, 1, $dialog->GetDirectory);
			push (@fullpathlist, $dialog->GetDirectory . "\\" .$_);           
		} 
	}
	
	$dialog->Refresh;              
}


# "List Delete" 버튼을 눌렀을시 이벤트
#select 된 리스트를 확인하여 메뉴상에서 삭제하고 @fullpathlist 의 배열에서도 해당 목록을 삭제한다.
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


# "List Reset" 버튼을 눌렀을시 이벤트
sub open_listreset_event
{
	$ListBox2->DeleteAllItems ();
#배열을 초기화한다.
	@fullpathlist = qw();
}


#변수에 해당하는 메세지를 경고창으로 띄워준다.
sub waring_window
{    
	my $waring = Wx::MessageDialog->new (undef, $_[0], 'Waring', wxOK|wxICON_INFORMATION);
	$waring->ShowModal();
}


#play 버튼 이벤트. 예외적인 처리를 해주고 @fullpathlist 를 foreach 로 copyandrename 을 돌린다.
sub play_menu_event
{   		
	my @patchfilepath_tmp;
	my $tmp;
	
	@patchfilepath_tmp = @patchfilepath;
	
#c:\\patchhistory 폴더가 없을 경우 생성한다.
	mkdir "c:\\patchhistory", 0755 or warn "Cannot make fred directory: $!" unless (-d "c:\\patchhistory");
#$openpath 가 폴더가 아닐 경우 경고창이 나오며 종료된다.
	chomp ($openpath);
	
#@patchfilepath 에 목록이 하나도 없을 경우 경고창이 나오며 종료된다.
	waring_window ("Not have patch file list. Please insert at least one of the file.") and return if (@patchfilepath == 0);

	($sec, $min, $hour, $mday, $mon, $year) = localtime;

#시간 자릿수가 한자리일 경우 0 을 앞에 더 추가시킨다.
#나머지작업 아래 5라인을 한줄로 변경

	++$mon;
	$year = 1900 + $year;

	$sec = change_time ($sec);
	$min = change_time ($min);
	$hour = change_time ($hour);
	$mday = change_time ($mday);
	$mon = change_time ($mon);

	waring_window ("already c:\\patchhistory\\" . $year. "_" . $mon . "_" . $mday . "_" . $hour . $min . $sec . "_" . $ListBox4->GetLineText(1) . "is make. Please try again later.") and return if (-d ("c:\\patchhistory\\" . $year. "_" . $mon . "_" . $mday . "_" . $hour . $min . $sec . "_" . $ListBox4->GetLineText(1)));

#나머지작업 comment (폴더 생성) 한글 입력되도록 변경 encode ("euc-kr" , decode ("utf-8", "한글")) 
	mkdir "c:\\patchhistory\\" . $year. "_" . $mon . "_" . $mday . "_" . $hour . $min . $sec . "_" . $ListBox4->GetLineText(1), 0755 or warn "Cannot make fred directory: $!";
	mkdir "c:\\patchhistory\\" . $year. "_" . $mon . "_" . $mday . "_" . $hour . $min . $sec . "_" . $ListBox4->GetLineText(1) . "\\old", 0755 or warn "Cannot make fred directory: $!";
	mkdir "c:\\patchhistory\\" . $year. "_" . $mon . "_" . $mday . "_" . $hour . $min . $sec . "_" . $ListBox4->GetLineText(1) . "\\new", 0755 or warn "Cannot make fred directory: $!";

	foreach (@patchsavepath)
	{
		$tmp = shift @patchfilepath_tmp;
		copyandrename (dirname ($tmp), basename ($tmp), $_);
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

sub play_Insert_event
{
	my @patchfilepath_tmp;
	
	@patchfilepath_tmp = @patchfilepath;	
		
#$openpath 가 폴더가 아닐 경우 경고창이 나오며 종료된다.
	chomp ($openpath);
	
	waring_window ("$openpath\nIt's not directory or does not exist. Please insert real directory.") and return unless (-d $openpath);
	
#@fullpathlist 에 목록이 하나도 없을 경우 경고창이 나오며 종료된다.
	waring_window ("Not have file list. Please insert at least one of the file.") and return if (@fullpathlist == 0);
	
	foreach (@fullpathlist)
	{
		my $patchfile_tmp = $_;
		
		foreach (@patchsavepath)
		{
			if ($_ eq $openpath)
			{	
				waring_window ("same") if (shift @patchfilepath_tmp eq $patchfile_tmp);	
			}	
		}

		$ListBox5->InsertStringItem (0, $_);			
		$ListBox5->SetItem (0, 1, $openpath);
				
		push (@patchsavepath, $openpath);
		push (@patchfilepath, $_);
	}
}

sub play_patchlistreset_event
{
	@patchsavepath = qw();
	@patchfilepath = qw();
		
	$ListBox5->DeleteAllItems ();
}


$f->Show();
$m->MainLoop();
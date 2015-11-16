#!/usr/bin/perl
use LWP::Simple;
# CMD LIST STRINGS #
$sysCmds="[System Commands] >> | \$ver | \$lines | \$chars | \$size | \$uptime | \$created | ";
$genCmds="[General Commands] >> | \$time | \$cmds | \$help | \$about | \$echo | \$joined | \$stats | \$articles | \$quote | \$admins | ";
$admCmds="[Admin Commands] >> | \$ident | \$die | ";
# CMD LIST STRINGS #
# HAVE how long SINCE <user> JOINED HackThisSite 
# displayed in the following format >>>
# - - - [years/months/weeks/days/hours/minutes/seconds]
# AS WELL AS JUST THE DATE/TIME THAT THEY JOINED (?)
# ADD A ' $quote add <quote> ' command to add a quote to the text file

# proxie general commands #
sub cmd_size() {
	$nick=shift(@_);
	$sock=shift(@_);
	$size[0]=&fileSize('kb','engine.pl');
	$size[1]=&fileSize('kb','funct.pl');
	$size[2]=&fileSize('kb','cmds.pl');
	$size[3]=&fileSize('kb','config.pl');
	$size[4]=&fileSize('kb','admin.pl');
	$total=($size[0]+$size[1]+$size[2]+$size[3]+$size[4]);
	&notice($sock,$nick,"I am made from PERL and have 5 scripts: total[".$total."/KB]: engine.pl[".$size[0]."/KB], funct.pl[".$size[1]."/KB], cmds.pl[".$size[2]."/KB], config.pl[".$size[3]."/KB], admin.pl[".$size[4]."/KB]");
}
sub cmd_version() {
	$nick=shift(@_);
	$sock=shift(@_);
	&notice($sock,$nick,$proxVersion);
}
sub cmd_created() {
	$nick=shift(@_);
	$sock=shift(@_);
	&notice($sock,$nick,"[Project Proxie] was started on ".$proxCreated);
}
sub cmd_echo() {
	$chan=shift(@_);
	$say=shift(@_);
	$sock=shift(@_);
	&privMsg($sock,$chan,$say,$chan);
}
sub cmd_lines() { # gives the total lines in each
	$nick=shift(@_);
	$sock=shift(@_);
	@lines=&countLines();
	$total=($lines[0]+$lines[1]+$lines[2]+$lines[3]+$lines[4]);
	&notice($sock,$nick,"I am made from PERL and have 5 scripts: total[".$total."]: engine.pl[".$lines[0]."], funct.pl[".$lines[1]."], cmds.pl[".$lines[2]."], config.pl[".$lines[3]."], admin.pl[".$lines[4]."]");
}
sub cmd_upTime() { # gives proxie's uptime
	$nick=shift(@_);
	$sock=shift(@_);
	$upTime=&upTime;
	&notice($sock,$nick,"Uptime- ".$upTime."[seconds]");	
}
sub cmd_quote() { # command to add/edit/remove/print numbered/random quote
	$args=shift(@_);
	$nick=shift(@_);
	$sock=shift(@_);
	if($args eq "add") {  
		#&modQuote("add");
		&notice($sock,$nick,$quote);
	}
	elsif($args eq "modify") {  
		#&modQuote("modify");
		&notice($sock,$nick,$quote);
	}
	elsif($args eq "delete") {  
		#&modQuote("delete");
		&notice($sock,$nick,$quote);
	}
	else {
		$quote=&getQuote("random");
		&notice($sock,$nick,$quote);
	}
}
sub cmd_countChars() { # lists the number of characters in each script
	$nick=shift(@_);
	$sock=shift(@_);
	@chars=(0,0,0,0,0);
	$/ = "\n"; # sets \n as the newline break for reading the files
	open(A,"engine.pl");
	my(@lines1) = <A>; # read file into list
	foreach $l (@lines1) { $engChar=($engChar+length($l)); }
	close(A);
	open(B,"funct.pl");
	my(@lines2) = <B>; # read file into list
	foreach $l (@lines2) { $funChar=($funChar+length($l)); }
	close(B);
	open(C,"cmds.pl");
	my(@lines3) = <C>; # read file into list
	foreach $l (@lines3) { $cmdChar=($cmdChar+length($l)); }
	close(C);
	open(D,"config.pl");
	my(@lines4) = <D>; # read file into list
	foreach $l (@lines4) { $conChar=($conChar+length($l)); }
	close(D);
	open(E,"admin.pl");
	my(@lines5) = <E>; # read file into list
	foreach $l (@lines5) { $admChar=($admChar+length($l)); }
	close(E);
	$/ = "\r\n"; # sets the newline break as \r\n again so chomp() works
	$total=($engChar+$funChar[1]+$cmdChar[2]+$conChar[3]+$admChar[4]);
	&notice($sock,$nick,"I am made from PERL and have 5 scripts: total[".$total."]: engine.pl[".$engChar."], funct.pl[".$funChar."], cmds.pl[".$cmdChar."], config.pl[".$conChar."], admin.pl[".$admChar."]");	
	# MAKE A FILE LENGTH SUB - fileLen() - to cut this down drastically
}
sub cmd_time() { # command that returns the time in the place specified
	$place=shift(@_); # if no place is specified, it returns proxie's time
	$nick=shift(@_);
	$sock=shift(@_);
	$usrURL="http://www.timeanddate.com/worldclock/results.html?query=".$place;
	$usrPage=get($usrURL); # queries the WORLD CLOCK site for place- $place
	$listLimit=1; # limit counter. (limiting the returned places to 5)
	$total=0;
	&notice($sock,$nick,"[WORLD CLOCK] data DIRECT from www.timeanddate.com/worldclock/");
	if($usrPage =~ /Current Time<\/th><td><strong id=ct  class=big>(.+)<\/strong><strong class=big id=cta> <a title="(.+)" href="(.+)">(.+)<\/a><\/strong><br>/) {
		&notice($sock,$nick,"[".$4."] >>> ".$1);
	}
	else {
		while($usrPage =~ m/\<a\shref\="city.html\?n=(\d+)">(.*?)\<\/a\>(?:\s\*)?<\/td>\<td\sclass\=r>(.*?)\<\/td\>/gm) { 
			$total++; # counter of total places returned
			if($listLimit<=5) {
				&notice($sock,$nick,"[".$1."] : ".$2." >>> ".$3);
				$listLimit++;
			}
		}
		&notice($sock,$nick,"[".$place."] returned a total of ".$total." possibilities.");
	}
	if($usrPage =~ /<br><h2>Sorry, found no matching cities or countries<\/h2>/) { # if the time isn't there (the $place isn't on the WORLD CLOCK)
		&notice($sock,$nick,"[".$place."] was not found on the WORLD CLOCK");
	}
	if($listLimit>=5) {
		&notice($sock,$nick,"For more results, goto- http://www.timeanddate.com/worldclock/results.html?query=".$place);
	}
}
sub cmd_usrJoined() {
	$nick=shift(@_);
	$usr=shift(@_);
	$sock=shift(@_);
	$usrURL="http://www.hackthissite.org/user/view/".$usr;
	$usrPage=get($usrURL); # get $usr's HTS.org statistics page
	if ($usrPage =~ /<b>Joined:<\/b> (.*)<br \/>/) { # print date $usr joined
		&notice($sock,$nick,"[".$usr."] Joined HTS On- ".$1."");
	}
	else { # if the user's stat page isn't there (the user doesn't exist)
		&notice($sock,$nick,"[".$usr."] was not found on hackthissite.org");
	}
}
sub cmd_usrStat() {
	$nick=shift(@_);
	$usr=shift(@_);
	$sock=shift(@_);
	$usrURL="http://www.hackthissite.org/user/view/".$usr;
	$usrPage=get($usrURL); # get $usr's HTS.org statistics page
	if($usrPage =~ /<b>Joined:<\/b> (.*)<br \/>/) { # date $usr joined
		$usrJoin=$1;
		if($usrPage =~ /<b>UserID:<\/b> (.*)<br \/>/) { # $usr ID
			$usrID=$1;
			if($usrPage =~ /<b>Last Login:<\/b> (.*)<br \/>/) { # etc...
				$usrLogin=$1;
				if($usrPage =~ /<b>Location:<\/b> (.*)<br \/>/) {
					$usrLoc=$1;
					for($b=1; $b<11; $b++) {
						if($usrPage =~ /href="missions\/basic\/$b\/">/) {
							$usrBasic=$usrBasic.$b.",";
						}					
					}
					$usrBasic=substr($usrBasic,0,(length($usrBasic)-1));
					for($r=1; $r<17; $r++) {
						if($usrPage =~ /href="missions\/realistic\/$r\/">/) {
							$usrReal=$usrReal.$r.",";
						}					
					}
					$usrReal=substr($usrReal,0,(length($usrReal)-1));
					for($a=1; $a<17; $a++) {
						if($usrPage =~ /href="missions\/realistic\/$a\/">/) {
							$usrApp=$usrApp.$a.",";
						}					
					}
					$usrApp=substr($usrApp,0,(length($usrApp)-1));
					for($e=1; $e<17; $e++) {
						if($usrPage =~ /href="missions\/extbasic\/$e\/">/) {
							$usrExt=$usrExt.$r.",";
						}					
					}
					$usrExt=substr($usrExt,0,(length($usrExt)-1));
					for($j=1; $j<17; $j++) {
						if($usrPage =~ /href="missions\/javascript\/$j\/">/) {
							$usrJava=$usrJava.$j.",";
						}					
					}
					$usrJava=substr($usrJava,0,(length($usrJava)-1));
				}
			}
		}
		&notice($sock,$nick,"[".$usr."] ID- ".$usrID. " | Joined- ".$usrJoin." | Last Login- ".$usrLogin);
		if($usrPage =~ /Rank:(.+)(\n+)/) { # print the user's rank
			&notice($sock,$nick,"Rank: ".$1);
		}
		if($usrBasic eq "" and $usrReal eq "" and $usrApp eq "" and $usrExt eq "" and $usrJava eq "") {
			&notice($sock,$nick,"[".$usr."] Has Not Completed Any Missions");
		} # if user has done NO challenges, then alert that.
		# otherwise, do each section separately and dont print if 
		# the user has not done any in that particular section of challenges
		else {
			&notice($sock,$nick,"-Completed Missions-");
			if($usrBasic ne "") { &notice($sock,$nick,"Basic [".$usrBasic."]"); }
			if($usrReal ne "") { &notice($sock,$nick,"Realistic [".$usrReal."]"); }
			if($usrApp ne "") { &notice($sock,$nick,"Application [".$usrApp."]"); }
			if($usrExt ne "") { &notice($sock,$nick,"ExtBasic [".$usrExt."]"); }
			if($usrJava ne "") { &notice($sock,$nick,"Javascript [".$usrJava."]"); }
		}
		$usrBasic=""; $usrReal=""; $usrApp=""; $usrExt=""; $usrJava="";
		# ^^^ Then Reset The Vars For the Next Use ^^^ #
	}
	else { # if the user's stat page isn't there (the user doesn't exist)
		&notice($sock,$nick,"[".$usr."] was not found on hackthissite.org");
	}
}
sub cmd_usrArticles() { # lists up to 5 of the user's articles and links
	$nick=shift(@_);
	$usr=shift(@_);
	$sock=shift(@_);
	$usrURL="http://www.hackthissite.org/user/view/".$usr;
	$usrPage=get($usrURL); # get $usr's HTS.org statistics page
	if($usrPage =~ /No Articles Submitted/) { # if the user has not done any
		&notice($sock,$nick,"[".$usr."] has no articles posted on hackthissite.org");
	}
	else {
		$listLimit=1; # set limit for number of articles returned
		$total=0; # variable to count TOTAL articles by $usr
		&notice($sock,$nick,"- - - Articles by ".$usr." - - -");
		while($usrPage =~ m/\<span style="font-weight: bold;"><a href="\/articles\/read\/(\d+)\/">(.+)<\/a><br \/>/gm) { 
			$total++; # number of articles by $usr -TOTAL- (counter)
			if($listLimit<=3) {
				&notice($sock,$nick,"[ http://www.hackthissite.org/articles/read/".$1." ] >> ".$2);
				$listLimit++;
			}
		}
		&notice($sock,$nick,"[".$usr."] has posted a total of ".$total." articles.");
		if($listLimit>3) {
			&notice($sock,$nick,"To see more of ".$usr."'s articles, goto- http://www.hackthissite.org/user/view/".$usr);
		}
	}	
}
# proxie general commands #
# proxie help commands #
sub cmd_help() {
	$nick=shift(@_);
	$sock=shift(@_);
	&notice($sock,$nick,"[".$proxVersion."] - please use ' \$cmds ' (no quotes) for available commands.");
}
sub cmd_about() {
	$nick=shift(@_);
	$sock=shift(@_);
	$proxUpTime=&upTime;
	&notice($sock,$nick,"Proxie ".$proxVersion." | by ".$proxAuthor." | Last Updated- ".$proxLastUpdate." | Uptime- ".$proxUpTime."[seconds] | Started at- ".$proxStartTime);
}
sub cmd_cmds() { # lists available commands
	$arg=shift(@_);
	$nick=shift(@_);
	$sock=shift(@_);
	if($arg eq "*") {
		&notice($sock,$nick,$genCmds);
		&notice($sock,$nick,$sysCmds);
		&notice($sock,$nick,$admCmds);
	}
	elsif($arg eq "general") { &notice($sock,$nick,$genCmds); }
	elsif($arg eq "admin") { 
		if(&isAdmin($nick)==1) {
			&notice($sock,$nick,$admCmds); 
		}
		else { &notice($sock,$nick,"you do not have administration privilidges"); }
	}
	elsif($arg eq "system") { &notice($sock,$nick,$sysCmds); }
	elsif($arg eq "\$ver") { &notice($sock,$nick,"SYNTAX: \$ver"); 
		&notice($sock,$nick,"[\$ver] >> gives the version number of the currently active proxie"); 
	}
	elsif($arg eq "\$about") { &notice($sock,$nick,"SYNTAX: \$about"); 
		&notice($sock,$nick,"[\$about] >> gives info about proxie, author, version, etc...");	
	}
	elsif($arg eq "\$echo") { &notice($sock,$nick,"SYNTAX: \$echo <string>"); 
		&notice($sock,$nick,"[\$echo] >> proxie will echo everything in <string> into the channel");
	}
	elsif($arg eq "\$lines") { &notice($sock,$nick,"SYNTAX: \$lines"); 
		&notice($sock,$nick,"[\$lines] >> counts and prints the number of lines in each of proxie's PERL files");
	}
	elsif($arg eq "\$cmds") { &notice($sock,$nick,"SYNTAX: \$cmds <command/category>"); 
		&notice($sock,$nick,"[\$cmds] >> gives a list of commands in <category> OR more info & syntax for <command>. You can use * for a list of all commands.");
	}
	elsif($arg eq "\$uptime") { &notice($sock,$nick,"SYNTAX: \$uptime"); 
		&notice($sock,$nick,"[\$uptime] >> prints how long proxie has been running for.");
	}
	elsif($arg eq "\$quote") { &notice($sock,$nick,"SYNTAX: \$quote"); 
		&notice($sock,$nick,"[\$quote] >> gives a random quote from the list. (\$quote add/edit/remove COMING SOON!)");
	}
	elsif($arg eq "\$chars") { &notice($sock,$nick,"SYNTAX: \$chars"); 
		&notice($sock,$nick,"[\$chars] >> lists how many characters are in each of proxie's PERL files."); 
	}
	elsif($arg eq "\$die") { &notice($sock,$nick,"SYNTAX: \$die"); 
		&notice($sock,$nick,"[\$die] >> shuts proxie down. {ADMIN}");
	}
	elsif($arg eq "\$ident") { &notice($sock,$nick,"SYNTAX: \$ident"); 
		&notice($sock,$nick,"[\$ident] >> tells proxie to identify with NickServ. {ADMIN} (outdated)");
	}
	elsif($arg eq "\$joined") { &notice($sock,$nick,"SYNTAX: \$joined <user>"); 
		&notice($sock,$nick,"[\$joined] >> prints the date+time that <user> signed up to hackthissite.org");
	}
	elsif($arg eq "\$stats") { &notice($sock,$nick,"SYNTAX: \$stats <user>"); 
		&notice($sock,$nick,"[\$stats] >> prints <user>'s stats, pulled straight off their hackthissite.org profile.");
	}
	elsif($arg eq "\$toggle") { &notice($sock,$nick,"SYNTAX: \$toggle <option>"); 
		&notice($sock,$nick,"[\$toggle] >> toggles a setting. {ADMIN}");
		if(&isAdmin($nick)==1) { &notice($sock,$nick,"[SETTINGS] >> debug (toggles debug mode) | more soon"); }
	}
	elsif($arg eq "\$size") { &notice($sock,$nick,"SYNTAX: \$size <user>"); 
		&notice($sock,$nick,"[\$size] >> gives the size of proxie's PERL code files- TOTAL & SEPARATE SIZES.");
	}
	elsif($arg eq "\$created") { &notice($sock,$nick,"SYNTAX: \$created"); 
		&notice($sock,$nick,"[\$created] >> gives the date proxie was created and how much time has passed since then.");
	}
	elsif($arg eq "\$help") { &notice($sock,$nick,"SYNTAX: \$help"); 
		&notice($sock,$nick,"[\$help] >> prints proxie's help info(sent to you when you join the channel).");
	}
	elsif($arg eq "\$time") { &notice($sock,$nick,"SYNTAX: \$time <place>"); 
		&notice($sock,$nick,"[\$time] >> gives the time and timezone of the place you provide. (and reference location)");
	}
	elsif($arg eq "\$admins") { &notice($sock,$nick,"SYNTAX: \$admins"); 
		&notice($sock,$nick,"[\$admins] >> lists all admin in proxie's admin list file [admins]");
	}
	else { 
		&notice($sock,$nick,"for more info on a command & it's syntax, use \$cmds <command>");
		&notice($sock,$nick,"for all available commands, use ' \$cmds <category> ' {CATEGORIES: general | system}");
		&notice($sock,$nick,"you are in the admin list, so you can use the 'admin' category (no quotes) as well..."); 
	}
	return 1;
}
# proxie help commands #
return 1;

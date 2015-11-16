#!/usr/bin/perl
# PROXIE ADMIN CHECK FUNCTION #
sub isAdmin() { # checks if $nick is in proxie's admin list
	$nick=shift(@_);
	$/ = "\n"; # sets \n as the newline break for reading the files
	open(ADMIN,"<admins");
	@admins=<ADMIN>; # put each line into a block in an array
	foreach $admin (@admins) { # for each admin in the list
		@break=split(/:/,$admin);# split line into 3 bits (separator = ':')
		if($nick eq $break[2]) { return 1; } # return 1 if usr is in list
	}
	close(ADMIN); # and closes the file
	$/ = "\r\n"; # sets \n as the newline break for reading the files
}
# PROXIE ADMIN CHECK FUNCTION #
# COMMAND THAT LISTS ADMINS IN LIST #
sub cmd_admins() {
	$nick=shift(@_);
	$sock=shift(@_);
	&notice($sock,$nick,"- all users in proxie admin list file [admins] -");
	$/ = "\n"; # sets \n as the newline break for reading the files
	open(ADMIN,"<admins");
	@admins=<ADMIN>; # put each line into a block in an array
	foreach $admin (@admins) { # for each admin in the list
		@break=split(/:/,$admin);# split line into 3 bits (separator = ':')
		&notice($sock,$nick,"[ID]".$break[0]." | [nick]".$break[2]." | [relation]".$break[1]." | [email]".$break[3]);
	}
	close(ADMIN); # and closes the file
	$/ = "\r\n"; # sets \n as the newline break for reading the files	
}
# COMMAND THAT LISTS ADMINS IN LIST #
# PROXIE ADMINISTRATION COMMANDS #
sub cmd_killProx() { # kills proxie and prints on client window
	$sock=shift(@_);
	$nick=shift(@_);
	$reason=shift(@_);
	$chan=shift(@_);
	if(&isAdmin($nick)==1) { # if the caller is in the admin list
		if($reason eq "") { $reason="x_x"; } # if no reason set, use default
		$proxLastOnline=localtime(); # updates the lastOnline date+time stamp
		&notice($sock,$nick,"yes sir!");
		&privMsg($sock,$chan,"committing suicide...",$chan);
		&logLine(">>> program killed by ".$nick." (".$reason.") <<<"); # log the line in today's log
		print $sock "QUIT :$reason\r\n"; # send QUIT command to server
		die("Proxie was killed by ".$nick." [$reason]\r\n");
	}
	else { &notice($sock,$nick,"You don't have admin privilidges!"); }
}
sub cmd_debugMode() {
	$nick=shift(@_);
	$sock=shift(@_);
	if(&isAdmin($nick)==1) { # if the caller is in admin list
		if($debugMode==0) { # if debug mode is turned off
			$proxDebug=1; # turn debug mode on(changes output)
			&notice($sock,$nick,"[Debug Mode] = 1");
		}
		else { # otherwise turn debug mode off
			$debugMode=0; 
			&notice($sock,$nick,"[Debug Mode] = 0");
		} 
	}
	else { &notice($sock,$nick,"You don't have admin privilidges!"); }
}
sub cmd_addAdmin() {
	$aNick=shift(@_);
	$aRelation=shift(@_);
	$aEmail=shift(@_);
	$nick=shift(@_);
	$sock=shift(@_);
	if(&isAdmin($nick)==1) { # if the caller is an admin
		$lines=&fileLines("admins"); # count lines in admin (to generate ID)
		$adminID=($lines); # admin IDs start at 0 (like an array)
		$adminLine=$adminID.":".$aRelation.":".$aNick.":".$aEmail;
		open(ADMINS,'>>admins'); # open admins list
		print ADMINS $adminLine."\n";
		close(ADMINS);
		&notice($sock,$nick,"the following line was added to the admin list file [admins]");
		&notice($sock,$nick,$adminLine);
	} # otherwise reject them and alert that they dont have admin privs.
	else { &notice($sock,$nick,"You don't have admin privilidges!"); }
}
# PROXIE ADMINISTRATION COMMANDS #
return 1;

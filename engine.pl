#!/usr/bin/perl
require("./funct.pl"); # contains proxie's functions
require("./cmds.pl"); # contains proxie's commands
require("./admin.pl"); # contains proxie's admin functions & commands
require("./config.pl"); # contains proxie's configuration and stats

$/ = "\r\n"; # so that chomp() removes all the line endings

###   FIX $time COMMAND TO GIVE PROXIE's TIME(GMT IN MY CASE) WHEN USER DOESN'T SPECIFY A PLACE   ###

# REMOVE LINE ENDINGS (\r\n) FROM &NOTICE() COMMAND CALLS
#			- - - IT IS MESSING UP MESSAGE  I/O STREAM
# FINISH $quote command!! (needs add/modify(?)/delete functionality)
# FINISH $admins command (needs REMOVE/MODIFY(?) FUNCTIONS)
# FIX countLines() to use fileLines() sub to count lines in each file
# $die only accepts ONE arg as reason =/ (?)
# MAKE POSSIBLE ARGUMENTS FOR $lines & $chars. =>  (?)
# MAKE MORE COMMANDS TO CHECK A USER'S HTS INFO
# LIKE $articles (list number of articles by $usr and link to newest 3?)
# SET A VAR AT THE START OF RUNNING A COMMAND, 
# SO THAT ONLY ONE CAN BE REQUESTED AT ANY ONE TIME
# MAYBE MAKE A STARTCMD() AND ENDCMD() FUNCTION TO TAKE CARE OF THIS ???
# USE sys.var file to store vars like $logData (so values are kept)

$proxieSock=&openSock('irc.hackthissite.org','6667');
if($proxieSock) {  
	$proxStartTime = localtime(); # updates the start time date+time stamp
	if($sleepOnConnect==1) { # if config is set for client to sleep on connect
		sleep(3); # makes the program wait 3 seconds after opening socket
	}
	if($proxieCliPass==1) { # if config says to use a client password
		print "Please enter proxie client password: "; # ask for client password
		$enterPw=<>; # get user's input
		chomp($enterPw); # remove line ending
		if($enterPw eq $proxiePass) { # if the correct client password is entered
			&regServ($proxieSock); # register on the server
		} # kill the program immediately, and alert the user to the mistake
		else { # otherwise, register on the IRC server
			die("Failed proxie client login...\r\nIncorrect Password !!\r\n"); 
		}
	} # and if config says NOT to use a client password then just
	elsif($proxieCliPass==0) { 
		&regServ($proxieSock); # register on the server
	} # register on the server
	else { die("Failed to boot proxie...\r\nInvalid Config Variable[\$proxieCliPass]\r\n"); }
}
while($proxieSock) {
	$servOut=<$proxieSock>; # grab a line from the connection
	chomp($servOut); # remove line endings from it
	# IF DEBUG MODE IS ON > PRINT ALL OUTPUT FROM SERVER
	if($debugMode==1) { print $servOut."\n"; } 
	@rawStr=split(/:/,$servOut);
	@splitStr=split(/ /,$rawStr[1]); # split by spaces
	@sender=split(/!/,$splitStr[0]);
	$nick=$sender[0]; # nickname of the message sender
	$msgType=$splitStr[1]; # the type of message PRIVMSG/NOTICE/ETC...
	$msgChan=$splitStr[2]; # the channel the message was in (PRIVMSG)
	$message=$rawStr[2]; # the actual MESSAGE
	$failCount=0; # fail counter (3xFAILS = DIE() )
	@action=split(/ /,$message,2); # all of string after 1st word=$action[1]
	$args=$action[1]; # put all the words after the first into $args
	if($failCount==3) { # if server registration has failed 3 times
		die("Failed to register on the server 3x times, 
			Please wait a minute and try again...\r\n"); # kill the program
	}
	if($nick =~ /reverse.irc.hackthissite.org/) { # if servReg FAILED
		if($message eq "You have not registered") { # (3fails allowed MAX)
			$failCount++; # increase fail counter +1 and try to
			&regServ($proxieSock); # try to register on the server (again)
		}
	}
	elsif($nick eq "NickServ") { # if the message originated from NickServ
		&printServMsg($nick,$message); # print message in the client
		# if nickserv threatens to change nickname
		if($message eq "If you do not change within one minute, I will change your nick.") {
			# then login with $proxieNickPass as the NickServ password
			&nsIdent($proxieSock); # identify with nickServ
		}
		elsif($message =~ /^Your nickname is now being changed to/) {
			die("NickServ didn't accept identification, 
			Please wait a minute and try again...\r\n"); # kill the program
		}
		elsif($message =~ /^Password accepted - you are now recognized./) {
			$loggedIn=1; # set $loggedIn var to 1
			print "[Successfully identified with NickServ]\r\n";
		}
	}
	elsif($nick eq "ChanServ") { # if the message originated from ChanServ
		&printServMsg($nick,$message); # print message in the client
	}
	elsif($nick eq "MemoServ") { # if the message originated from NickServ
		&printServMsg($nick,$message); # print message in the client
	}
	if ($servOut=~/^PING(.*)$/i) { # upon a ping request
		$pong=substr($1,2,length($1)); # remove the ":" at the beginning
		&pingPong($pong,$proxieSock); # run pingpong() subroutine
	}
	if($msgType=~/JOIN/) { # if someone JOINs the channel
		&printAction($msgChan,$nick," joined the channel (".$msgChan.")"); 
		&cmd_help($nick,$proxieSock); # NOTICE them the $help info
	}
	elsif($msgType=~/MODE/) { # if someone sets a MODE
		$modeChan=$splitStr[2];
		$modeSet=$splitStr[3]; # the mode that was set (e.g. +qo/-b/+v)
		@modeStr=split(/ /,$rawStr[1],5); # split by spaces
		$modeNicks=$modeStr[4]; # the nickname(s) the mode(s) was set on
		&printCtcp($nick," set ".$modeSet." ".$modeNicks." (".$modeChan.")"); # print on client window & in today's LOG (if $logData = 1)
	}
	elsif($msgType=~/PRIVMSG/ or $msgType=~/NOTICE/) { # if it is a PRIVMSG or NOTICE
		if($message=~/^ACTION/) { # if the message is an ACTION
			$args=substr($args,0,(length($args)-1));
			&printAction($msgChan,$nick,$args); # print it in the client window
		} # otherwise, if not an ACTION, then
		else { &printMsg($msgChan,$nick,$message); } # print message in the client
		if($message =~ /^VERSION/) {
				&notice($proxieSock,$nick,"VERSION Proxie[".$proxVersion."] irc.hackthissite.org  :Created by darksider");
		}
		if($message=~ /^\$(\S+)/) {
		if($message =~ /\$cmds(\s*)/) {
			if($message =~ /\$cmds(\s+)general$/) { &cmd_cmds("general",$nick,$proxieSock); }
			elsif($message =~ /\$cmds(\s+)system$/) { &cmd_cmds("system",$nick,$proxieSock); }
			elsif($message =~ /\$cmds(\s+)admin$/) { &cmd_cmds("admin",$nick,$proxieSock); }
			elsif($message =~ /\$cmds(\s+)\*$/ or $message =~ /\$cmds(\s+)all$/) { &cmd_cmds("*",$nick,$proxieSock); }
			else { &cmd_cmds($args,$nick,$proxieSock); } # IF NOT GEN/ADM/SYS REQUEST
		}
		elsif($message =~ /\$die(\s*|\s+\S+)$/) { # if the command is $die
			&cmd_killProx($proxieSock,$nick,$args,$msgChan); # run killProx() sub
		}
		elsif($message =~ /\$ver(\s*|\s+\S+)$/) { # if the command is $ver
			&cmd_version($nick,$proxieSock);
		}
		elsif($message =~ /\$about(\s*|\s+\S+)$/) { # if the command is $about
			&cmd_about($nick,$proxieSock);
		}
		elsif($message =~ /\$created(\s*|\s+\S+)$/) { # if the command is $created
			&cmd_created($nick,$proxieSock);
		}
		elsif($message =~ /\$uptime(\s*|\s+\S+)$/) { # if the command is $uptime
			&cmd_upTime($nick,$proxieSock);
		}
		elsif($message =~ /\$lines(\s*|\s+\S+)$/) { # if the command is $lines
			&cmd_lines($nick,$proxieSock);
		}
		elsif($message =~ /\$chars(\s*|\s+\S+)$/) { # if the command is $chars
			&cmd_countChars($nick,$proxieSock);
		}
		elsif($message =~ /\$echo(\s*|\s+\S+)/) { # if the command is $echo
			if($args =~ /^\W/) {
				&notice($proxieSock,$nick,"I refuse to echo any string that begins with a NON-ALPHANUMERIC character...");
			}
			else { &cmd_echo($msgChan,$args,$proxieSock); }
		}
		elsif($message =~ /\$ident(\s*|\s+\S+)$/) { # if the command is $ident
			$ident=&nsIdent($nick,$proxieSock); # identify with nickserv
			if ($ident==0) {
				&notice($proxieSock,$nick,"failed to ident- NO NickServ password defined in config.pl");
			}
			elsif($ident==1) {
				&notice($proxieSock,$nick,"[proxie identified with Nickserv]");
			}
		}
		elsif($message =~ /\$joined(\s*|\s+.+)$/) { # if the command is $joined
			&cmd_usrJoined($nick,$args,$proxieSock); # find the join date of the req usr
		}
		elsif($message =~ /\$stats(\s*|\s+.+)$/) { # if the command is $stats
			&cmd_usrStat($nick,$args,$proxieSock); # find the join date of the req usr
		}
		elsif($message =~ /\$articles(\s*|\s+.+)$/) { # if the command is $articles
			&cmd_usrArticles($nick,$args,$proxieSock); # find articles by the user specified
		}
		elsif($message =~ /\$toggle(\s*|\s+\S+)$/) { # if the command is $toggle
			if($message=~/\$toggle(\s+)debug(\s*)$/) { &cmd_debugMode($nick,$proxieSock); } 
			else { notice($proxieSock,$nick,"toggle what?"); }
		}
		elsif($message =~ /\$quote(\s*|\s+)/) { # if the command is $quote
			if($message =~ /\$quote(\s+)add$/) { &cmd_quote("add",$nick,$proxieSock); }
			elsif($message =~ /\$quote(\s+)del$/) { &cmd_quote("delete",$nick,$proxieSock); }
			elsif($message =~ /\$quote(\s+)mod$/) { &cmd_quote("modify",$nick,$proxieSock); }
			elsif($message =~ /\$quote(\s+)(\w+)$/) { $quote=&getQuote($2); &notice($proxieSock,$nick,$quote); }
			else { &cmd_quote("",$nick,$proxieSock); } # otherwise get random quote
		}
		elsif($message =~ /\$size(\s*|\s+\S+)$/) { # if the command is $size
			&cmd_size($nick,$proxieSock);
		}
		elsif($message =~ /\$help(\s*|\s+\S+)$/) { # if the command is $help
			&cmd_help($nick,$proxieSock);
		}
		elsif($message =~ /\$lins(\s+)(\w+)$/) { # if the command is $help
			$lines=&fileLines($2);
			&notice($proxieSock,$nick,$lines);
		}
		elsif($message =~ /\$admins(\s*|\s+\S+)/) { # if the command is $admins
			if($message =~ /\$admins(\s+)add(\s+)(.+)(\s+)(.+)(\s+)(.+)$/) { &cmd_addAdmin($3,$5,$7,$nick,$proxieSock); }
			else { &cmd_admins($nick,$proxieSock); }
		}
		elsif($message =~ /\$time(\s*|\s+.+)$/) { # if the command is $time
			&cmd_time($args,$nick,$proxieSock);
		}
		} # END OF IF($msg=~/^\$(\S+)/){IF message STARTS with a $ (command initiator)}
	}
}

#!/usr/bin/perl
use IO::Socket;

# proxie functions #
sub openSock() { # opens a connection to defined server/port
	$serv=shift(@_);
	$port=shift(@_);
	my $socket = new IO::Socket::INET ( 
		 PeerAddr => $serv, 
		 PeerPort => $port, 
		 Proto => 'tcp', 
	) or die("failed to open socket connection. [ ".$serv."/".$port." ]\r\n\n");
	print "...:::[Proxie Socket Connection OPEN]:::...\r\n";
	&logLine("[Socket Connection Opened...]"); # log the line in today's log
	return $socket;
}
sub regServ() { # registers proxie on the defined server
	$server=shift(@_);
	print $server "NICK proxie\r\n";
	print $server "USER proxie host host :Perl bot by darksider\r\n";
	# OLD USER LINE : print $server "USER proxie PERL::BOT by :Darksider\r\n";
	print "[Sent Server Registration Data...]\r\n"; 
	&logLine("[Sent Server Registration Data]"); # log the line in today's log
	&joinChan("#bots",$server);
	&joinChan("#proxie",$server);
}
sub nsIdent() { # identifies with NickServ
	$server=shift(@_);
	if($proxieNickPass eq "") { # if no nickserv password is specified
		print "[NO Nickserv password defined in config.pl]\r\n"; # alert the client
		&logLine("[NO Nickserv password defined in config.pl]"); # log the line in today's log
	}
	else { # otherwise, identify on nickserv
		print $server "PRIVMSG NickServ :IDENTIFY ".$proxieNickPass."\r\n";
		print "[Sent NickServ Identification Data...]\r\n"; # alert the client
		&logLine("[Sent NickServ Identification Data...]"); # log the line in today's log
	}
}
sub joinChan() { # joins proxie to a defined channel
	$chan=shift(@_);
	$server=shift(@_);
	print $server "JOIN ".$chan."\r\n";
	print "[Joined ".$chan."]\r\n";
	&logLine("[Joined ".$chan."]"); # log the line in today's log
}
sub printMsg() { # prints a PRIVMSG on proxie's client window
	if($debugMode==0) {	
		$chan=shift(@_);
		$sndr=shift(@_);
		$msg=shift(@_);
		print "[".$sndr."] ".$msg."   (".$chan.")\r\n";
		&logLine("[".$sndr."] ".$msg); # log the line in today's log
	}
}
sub printNotice() { # prints a NOTICE on proxie's client window
	if($debugMode==0) {	
		$sndr=shift(@_);
		$msg=shift(@_);
		print "/".$sndr."/ ".$msg."\r\n";
		&logLine("/".$sndr."/ ".$msg); # log the line in today's log
	}
}
sub printAction() { # prints an ACTION on proxie's client window
	if($debugMode==0) {	
		$sndr=shift(@_);
		$msg=shift(@_);
		print "---".$sndr." ".$msg."---\r\n";
		&logLine("---".$sndr." ".$msg."---"); # log the line in today's log
	}
}
sub printServMsg() { # prints a server message on proxie's client window
	if($debugMode==0) {
		$sndr=shift(@_);
		$msg=shift(@_);
		print "<".$sndr."> ".$msg."\r\n";
		&logLine("<".$sndr."> ".$msg); # log the line in today's log
	}
}
sub printCtcp() { # prints a ctcp request/msg on proxie's client window
	if($debugMode==0) {
		$sndr=shift(@_);
		$msg=shift(@_);
		print "#".$sndr." ".$msg."#\r\n";
		&logLine("#".$sndr." ".$msg."#"); # log the line in today's log
	}
}
sub privMsg() { # sends a PRIVMSG to $rcpt (nick/chan)
	$sock=shift(@_);
	$rcpt=shift(@_);
	$msg=shift(@_);
	$chan=shift(@_);
	print $sock "PRIVMSG ".$rcpt." :".$msg."\r\n";
	&printMsg($chan,"proxie",$msg); # print message in the client
}
sub notice() { # sends a NOTICE to $rcpt (nick/chan)
	$sock=shift(@_);
	$rcpt=shift(@_);
	$msg=shift(@_);
	print $sock "NOTICE ".$rcpt." :".$msg."\r\n";
	&printNotice("proxie",$msg); # print message in the client
}
sub action() { # sends an ACTION to $rcpt (nick/chan)
	$sock=shift(@_);
	$rcpt=shift(@_);
	$msg=shift(@_);
	$chan=shift(@_);
	print $sock "PRIVMSG ".$rcpt." :ACTION ".$msg."\r\n";
	&printAction($chan,"proxie",$msg); # print message in the client
}
sub splitStr() { # splits a string by spaces and returns bits in an array
	$uncutMsg=shift(@_);
	@splitStr=split(/ /,$uncutMsg);
	return @splitStr;
}
sub getMsg() { # gets & returns the message from an IRC-Standard line
	$uncutMsg=shift(@_);
	@splitMsg=split(/:/,$uncutMsg);
	return @splitMsg[2];
}
sub stripMsg() { # strips an IRC-Standard line down to the user,message & type
	$msg=shift(@_);
	$sock=shift(@_);
	@splitSpaces=&splitStr($msg); # use splitStr() to split by spaces
	$servMsg[0]=&checkUsr($msg); # gets username
	$servMsg[1]=&getMsg($msg); # gets the actual message
	$servMsg[2]=$splitSpaces[1]; # gets msg type (PRIVMSG/NOTICE/ETC..)
	return @servMsg; # returns an array with x3 blocks, user, message & type
}
sub checkUsr() { # returns the username that the message originated from
	$string=shift(@_);
	@splitSpaces=&splitStr($string); # use splitStr to split by spaces
	@splitUsr=split(/!/,$splitSpaces[0]); # split with ' ! ' to get username
	$strUsr=substr(@splitUsr[0],1); # cut the first character off (":")
	return $strUsr; # and return the username
}
sub pingPong() { # PING response function
	$ping=shift(@_);
	$sock=shift(@_);
	print $sock "PONG :".$ping."\r\n"; # reply with a PONG to stay connected
	&printCtcp("PING",$ping); # print the PING in the client window
	&printCtcp("PONG",$ping); # print the PONG in the client window
}
sub upTime() { # returns how long proxie has been online
	$runTime=(time-$^T);
	return $runTime;
}
sub countLines() { # returns an array with the total lines in each script
	@lines=(0,0,0,0,0);
	$/ = "\n"; # sets \n as the newline break for reading the files
	open(A,"engine.pl");
	while(<A>) { $lines[0]++; }
	close(A);
	open(B,"funct.pl");
	while(<B>) { $lines[1]++; }
	close(B);
	open(C,"cmds.pl");
	while(<C>) { $lines[2]++; }
	close(C);
	open(D,"config.pl");
	while(<D>) { $lines[3]++; }
	close(D);
	open(E,"admin.pl");
	while(<E>) { $lines[4]++; }
	close(E);
	$/ = "\r\n"; # sets the newline break as \r\n again so chomp() works
	return @lines;
}
sub fileLines() { # counts and returns the amount of lines in the given file
	$file=shift(@_);
	$/ = "\n"; # sets \n as the newline break for reading the files
	$lines=0;
	open(LINES,$file);
	while(<LINES>) { $lines++; }
	close(LINES);
	$/ = "\r\n"; # sets the newline break as \r\n again so chomp() works
	return $lines;
}
sub checkCmd() { # returns each word of a message to check for a command
	$msg=shift(@_);
	$uncutMsg=&getMsg($msg); # gets the actual message
	@commands=&splitStr($uncutMsg); # puts each word in an array block
	return @commands; # returns the array
}
sub cmdArgs() { # gets all the words after the command initiator
	$msg=shift(@_);
	@args=split(/ /,$msg,2);
	return $args[1];
}
sub fileSize() {
	$stype=shift(@_);
	$file=shift(@_);
	$byte=-s $file;
	$kilo=sprintf("%.2f",($byte/1024));
	$mega=sprintf("%.2f",($kilo/1024));
	$giga=sprintf("%.2f",($mega/1024));
	$tera=sprintf("%.2f",($giga/1024));
	if($stype eq "b") { $size=$byte; }
	elsif($stype eq "kb") { $size=$kilo; }
	elsif($stype eq "mb") { $size=$mega; }
	elsif($stype eq "gb") { $size=$giga; }
	elsif($stype eq "tb") { $size=$tera; }
	return $size;
}
sub getQuote() {
	$QID=shift(@_);
	$/ = "\n"; # sets \n as the newline break for reading the files
	open(QUOTES,"<quotes"); # opens quote list for READING (<)
	if($QID =~ /(\w+)/) {
		$quoteLines=0; # count lines in list (count quotes in list)
		while(<QUOTES>) { 
			$quotes[$quoteLines]=$_;
			$quoteLines++; 
		}
		$quoteLines=($quoteLines-1); # reduce by 1 ( arrays start at [0] )
		if(!$quotes[$QID]) { $quote="No quote in list with ID {".$QID."}"; }
		else {
			@quoteBits=split(/>/,$quotes[$QID]); # split line with each ':'
			$quote="[".$quoteBits[1]."] - '".$quoteBits[2]."' {".$quoteBits[0]."}";
		}
	}
	else {
		$quoteLines=0; # count lines in list (count quotes in list)
		while(<QUOTES>) { 
			$quotes[$quoteLines]=$_;
			$quoteLines++; 
		}
		$quoteLines=($quoteLines-1); # reduce by 1 ( arrays start at [0] )
		$randQID=int(rand($quoteLines)); # gets one random quote from list
		@randQuote=split(/>/,$quotes[$randQID]); # split line with each ':'
		$quote="[".$randQuote[1]."] - '".$randQuote[2]."' {".$randQuote[0]."}";
	}
	close(QUOTES);
	$/ = "\r\n"; # sets the newline break as \r\n again so chomp() works
	return $quote;
}
sub logLine() { # function to log a line of data from the server
	$line=shift(@_);
	@date=localtime();
	my($sec,$min,$hour,$date,$month,$yearOffset,$wday,$yday,$isdst)=localtime();
	$year=($yearOffset+1900); # Y2K disaster averted
	$month++;
	$logDate=$date."-".$month."-".$year;
	if($logData==1) { # if $logData var == 1 (log mode is on)
		open(LOGFILE,'>>logs/'.$logDate.'.log'); # open <date>.log
		print LOGFILE "[".$hour.":".$min.".".$sec."] ".$line."\n";
		close(LOGFILE);
	}
}
return 1;
# proxie functions #

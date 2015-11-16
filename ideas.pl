# PROXIE IDEAS

# WRITE A CALENDAR FUNCTION TO ADD/REMOVE/EDIT/VIEW EVENTS
# AND ALERT THE DEFINED USER(s) WHEN THE TIME COMES/ALARM GOES OFF

# PROXIE IDEAS

print "[Registered On Server]\r\n";

elsif($command[0] eq "\$getline") { # if the command is $lines
			$reqLine=&getLine($command[1],$command[2]);
			&notice($proxieSock,$proxieChan,"Here is line #".$command[1]." From '".$command[2]."' - \r\n");
			&notice($proxieSock,$proxieChan,$reqLine."\r\n");
}
sub getLine() { # gets line # $getLine from $file and returns it in $line
	$line=shift(@_);
	$file=shift(@_);
	open(REQFILE,"<".$file);
	my(@fileLines) = <REQFILE>; # read file into list
	$line=($line-1); # deduct by 1 (array starts at 0)
	$reqLine=$fileLines[$line]; # get the requested line into a var
	close(REQFILE);
	return $reqLine; # return the requested line
}

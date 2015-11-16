#!/usr/bin/perl

# proxie vars #
$loggedIn=0; # default is 0; changes to 1 on successful login.
$proxieNickPass="password"; # default nickserv password is same as client pwd
$sleepOnConnect=0; # [0] = don't sleep 3secs after socket opening. [1] = sleep
$proxieCliPass=0; # [1]=use client password|[0]=don't require client password
$proxiePass="password"; # client pwd (required at startup IF $proxieCliPass=1)
$proxieChan="#bots"; # proxie's base channel
$proxieIdent=0; # sets to 1 when proxie has been identified with nickserv
$failCount=0; # used to count server registration failures (3 MAX);
$debugMode=0; # DEBUG MODE [on=1|off=0] DEBUG MODE PRINTS ALL SERVER OUTPUT
$logData=1; # log mode [0/1] off/on DEFAULT=1;
# proxie vars #

# proxie stats #
$proxAuthor="darksider"; # author IRC nickname
$proxVersion="V3x"; # current version
$proxCreated="15th March 2010"; # when project proxie was started
$proxLastUpdate="Fri 26th March 2010, 2:00AM"; # last update date+time
$proxLastOnline=""; # the last time proxie was connected to an IRC server
$proxUpTime=(time-$^T); # contains how long proxie has been online (in seconds)
$proxStartTime=""; # date+time stamp set when proxie starts up
# proxie stats #

return 1;

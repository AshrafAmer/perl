#!/usr/bin/perl

use Socket;
use strict;
use Config::IniFiles;
my %SET;
my $cfg = Config::IniFiles->new( -file => "server_config.ini" );
my $line;
my $state;
my $username;
my $pass;
my $res;
my $email;


$SET{"LISTENIP"}=$cfg->val("Server","LISTENIP");
$SET{"LISTENPORT"}=$cfg->val("Server","LISTENPORT");

socket(CLIENTD,PF_INET,SOCK_STREAM,getprotobyname("tcp")) or die "Can not create a socket $! \n";

connect(CLIENTD,sockaddr_in($SET{"LISTENPORT"},inet_aton($SET{"LISTENIP"}))) or die "Can not connect to server $! \n";


###############################
###==> Get valid data from user
################################

print "For login press 1, for register press 2: ";
$state = <STDIN>;
chomp $state;

if($state ne 1 and $state ne 2){
	print "your '$state' is invalid input, please select only 1 or 2 \n";
        print "Thank You, Bye >_< \n";
        exit(1);
}


#######################################
####==> Check username, pass validation
########################################

print "Username: ";
$username = <STDIN>;
chomp $username;
print "Password: ";
$pass = <STDIN>;
chomp $pass;

$res = "$username,$pass";

if ($state eq 2){
	print "email: ";
	$email = <STDIN>;
	$res = "$res,$email";
}

syswrite CLIENTD, "$res \n";

while( <CLIENTD> ) {
        chomp;
	print "Server said : $_ \n";
}

close(CLIENTD);

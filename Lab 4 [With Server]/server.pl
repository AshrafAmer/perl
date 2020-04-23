#!/usr/bin/perl

use Socket;
use strict;
use Config::IniFiles;
use DBI;
use validate;
use auth;

my %SET;
my %SETTINGS;
my $CIP;
my $CPORT;
my $CLIENTADDR;
my $cfg = Config::IniFiles->new( -file => "server_config.ini" );
my $line;
my $DSN;
my $db;
my $sql;
my $rec;

my $config = 'config.ini';
my @arr;


$SET{"LISTENIP"}=$cfg->val("Server","LISTENIP");
$SET{"LISTENPORT"}=$cfg->val("Server","LISTENPORT");

#############################
####==> SetUp Configuration..
##############################

open(my $filehandle, '<', $config) or die "Can't Open $config File";
while(my $line = <$filehandle>){
        chomp $line;
        my @data = split("=", $line);
        push(@arr, @data[1]);
}

$SETTINGS{"DBHOST"}=@arr[0];
$SETTINGS{"DBUSER"}=@arr[1];
$SETTINGS{"DBPASS"}=@arr[2];
$SETTINGS{"DBNAME"}=@arr[3];

$DSN="DBI:mysql:database=".$SETTINGS{"DBNAME"}.";host=".$SETTINGS{"DBHOST"}."";
$db=DBI->connect($DSN,$SETTINGS{"DBUSER"},$SETTINGS{"DBPASS"}) or die "$db->errstr()";

socket(SERVERD,PF_INET,SOCK_STREAM,getprotobyname("tcp")) or die "Can not create a socket $! \n";
bind(SERVERD,sockaddr_in($SET{"LISTENPORT"},inet_aton($SET{"LISTENIP"}))) or die "Can not bind $! \n";
listen(SERVERD,SOMAXCONN) or die "Can not listen $! \n";


while ( $CLIENTADDR=accept(CLIENTD,SERVERD) ) {
	($CPORT,$CIP)=sockaddr_in($CLIENTADDR);
	print "Incoming connection from $CIP:$CPORT\n";
	while( <CLIENTD> ) {
		chomp;
		print "Client said : $_ \n";
		my @res = split(',', $_);

		if( @res eq 2) #login
		{
			if(auth::login($res[0], $res[1], $db)){
                		syswrite CLIENTD, "You are In.. Welcome $res[0] \n";
        		}else{
                		syswrite CLIENTD, "username or password is not correct >_< \n";
        		}
		}
		
		elsif( @res eq 3){
			#syswrite CLIENTD, "$res[0], $res[1], $res[2] \n";
			if(!validate::valid_username($res[0])){
                		syswrite CLIENTD, "username is invalid, Retry again... \n";
        		}

        		elsif(!validate::valid_pass($res[1])){
                		syswrite CLIENTD, "password is invalid, Retry again... \n";
        		}

        		elsif(!validate::valid_email($res[2])){
                		syswrite CLIENTD, "email is invalid, Retry again... \n";
                       }

        		elsif(auth::register($res[0], $res[1], $res[2], $db)){
                		syswrite CLIENTD, "Done... your account registered successfully.! \n";
            	      	}
			else{
                		syswrite CLIENTD, "Be Patient .. something wrong occured, Please Retry again \n";
        		}
		}
	}
	close(CLIENTD);
}
close(SERVERD);

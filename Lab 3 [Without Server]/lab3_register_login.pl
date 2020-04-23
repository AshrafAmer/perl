#!/usr/bin/perl

use strict;
use DBI;
use validate;
use auth;
########################
#==> Variables def:
########################

my $username;
my $pass;
my $email;
my $state;
my %SETTINGS;
my $DSN;
my $db;
my $sql;
my $rec;

my $config = 'config.ini';
my @arr;

#############################
###==> SetUp Configuration..
#############################

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


###############################
##==> Get valid data from user
###############################

print "For login press 1, for register press 2: ";
$state = <STDIN>;
chomp $state;

if($state ne 1 and $state ne 2){
	print "your '$state' is invalid input, please select only 1 or 2 \n";
	print "Thank You, Bye >_< \n";
	exit(1);
}

#######################################
###==> Check username, pass validation
#######################################

print "Username: ";
$username = <STDIN>;
chomp $username;
print "Password: ";
$pass = <STDIN>;
chomp $pass;

if($state eq 1){
	if(auth::login($username, $pass, $db)){
		print "You are In.. Welcome \n";
		exit(0);
	}else{
		print "username or password is not correct >_< \n";
		exit(1);
	}
}
elsif( $state eq 2){
	if(!validate::valid_username($username)){
		print "username is invalid, Retry again... \n";
		exit(1);
	}

	if(!validate::valid_pass($pass)){
                print "password is invalid, Retry again... \n";
                exit(1);
        }
	

	print "email: ";
	$email = <STDIN>;
	chomp $email;

	if(!validate::valid_email($email)){
                print "email is invalid, Retry again... \n";
                exit(1);
        }
	
	if(auth::register($username, $pass, $email, $db)){
                print "Done... your account registered successfully.! \n";
                exit(0);
        }else{
		print "Be Patient .. something wrong occured, Please Retry again \n";
		exit(1);
	}

}


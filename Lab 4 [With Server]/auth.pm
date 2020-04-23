#!/usr/bin/perl

use strict;
package auth;

#########################
#==> Check exist user
#########################

sub username_check{
	my ($username, $db) = @_;
    	my $res;
    	$res = $db->prepare("SELECT username FROM users WHERE username=?");
    	$res->execute($username) or die "$db->errstr()";
    	if($res->rows > 0){
        	return 1; #exist
    	}

    	return 0
}

##########################
##==> Login user
##########################

sub login{
	my ($username, $password, $db) = @_;
    	my $login_res;
	my $salt;    	
	my $hash_password;
	my $record;
	
    	if(username_check($username, $db)) #return 1 ==> exist
    	{
        	$login_res=$db->prepare("SELECT * FROM users") or die "$db->errstr()";
        	$login_res->execute() or die "$db->errstr()";
        	while ( $record = $login_res->fetchrow_hashref() ) {
            		$salt = $record->{"salt"};
            		$hash_password = qx{mkpasswd -m sha-512 $password $salt};
            		chomp $hash_password;
            		if($record->{"pass"} eq $hash_password){
                		return 1;
            		}
        	}
        	
		$login_res->finish;
    	}
    
	return 0;
}

###########################
###==> Register New user
###########################

sub register{
	my ($username, $password, $email, $db) = @_;
    	if(!username_check($username, $db)) # !0 === 1
    	{
        	my $sql_str;
        	my $pass;
		my $salt;		
		my $HASH; 
		my $hash_password;       	
		my $fst;
        	
        	$HASH = qx{mkpasswd --method=sha-512 $password};
        	$_ = $HASH;
        	($fst, $fst, $salt, $hash_password) = split /\$/;
        	chomp $hash_password;
        	my $Query = "INSERT INTO users(username,email,pass,salt) VALUES(?, ?, ?, ?)";
        	$sql_str=$db->prepare($Query) or die "$db->errstr()";
        	$sql_str->execute($username, $email, $HASH, $salt) or die "$db->errstr()";
        	$sql_str->finish();
        	return 1;
    	}
	return 0;
}


1;

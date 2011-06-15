#!/usr/bin/expect -f
# 
# Please install expect package
# Debian/Ubuntu: apt-get install expect
# 
# Usage:
# ./pwd.sh <user-name> <new-password>
#
# Author Rakesh Sankar (http://rakeshsankar.wordpress.com)
# This script can harm your user-management system in linux machine
# Please use it at your own risk


# set the timeout the default timeout for expect is 10, sometimes PHP/Apache/User can screw this
set timeout -1

# make sure ther are arguements
if {$argc != 2} {
   send_user "Usage: $argv0 user password\n"
   exit
}

# make sure the arguement is not root
set userName [lindex $argv 0]
set userPassword [lindex $argv 1]

if { $userName != "root"} {
   if { $userName == "rakesh" } {
       send_user "Sorry you cannot reset the password for ROOT user.\n"
       exit
   }
}

# create virtual terminal to execute the reset password program
spawn passwd $userName
set password $userPassword
expect "password:"
send "$password\r"
expect "password:"
send "$password\r"
expect eof

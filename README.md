# Is This Evil?
A bash script that validates an IP or domain's standing against a list of known Realtime Blackhole List (RBL).
<br>
<br>
Formely known as DNS Standing.
<br>
(Please do note that only the first returned result for DNS input will be compared against known RBL)

Features
--------------------
* More than __100 Realtime Blackhole List__ included
* Able to differentiate between __domain or IP__
* Easy to manage and update Realtime Blackhole List
* Informative and easy to use

Requirements
--------------------
* Unix/Linux with POSIX shell
* Basic commands such as:
	* dig
	* git
	* host
	* source

Installation
--------------------
	git clone https://github.com/colorful-dream/isthisevil
	chmod +x isthisevil/isthisevil.sh
	mv isthisevil/isthisevil.sh /usr/bin/isthisevil

Be sure to edit __line 27__ in __isthisevil.sh__ and specify the new location of the file holding a list of RBL, __rbl_list.sh__.
`RBL_LIST="rbl_list.sh"`

Usage
--------------------
	# You can either use an IP address or a Fully Qualified Domain Name (FQDN):
	$ isthisevil 93.184.216.34
	$ isthisevil example.com

	# You can use other UNIX utilities to narrow down results to blacklisted standing:
	$ isthisevil example.com|grep "Blacklisted" 


Credits
--------------------
Script written by [Dreアm](https://github.com/colorful-dream).

#!/bin/bash
#
# Project       :   isthisevil - Is This Evil?
# Filename      :   isthisevil.sh
# Description   :   Validates a domain's standing against known 
#                   Realtime Blackhole List (RBL)
# Author        :   Dreアm @ https://github.com/colorful-dream
# Created       :   August 7th 2016
# Last revision :   August 26th 2017
# Licence       :   MIT licensed, see LICENSE.md 
#
#=============================================================================#

#=========================#
# Regular expression(s)
#=========================#
# Fully Qualified Domain Name (FQDN)
REGEX_FQDN="(?=^.{5,254}$)(^(?:(?!\d+\.)[a-za-z0-9_\-]{1,63}\.?)+(?:[a-za-z]{2,})$)"
# IP address
REGEX_IP="^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$"

#=========================#
# RBL configuration(s)
#=========================#
# Path to Realtime Blackhole List (RBL)
RBL_LIST="rbl_list.sh"

#=========================#
# Bash color(s)
#=========================#
# Green
GREEN_COLOR="\033[1;32m"
# Yellow
YELLOW_COLOR="\033[1;33m"
# Red
RED_COLOR="\033[1;31m"
# Orange
CYAN_COLOR="\033[1;36m"
# Default: white
DEFAULT_COLOR="\033[m"

#=========================#
# Function(s)
#=========================#
# Imports a list of Realtime Blackhole List (RBL)
importRBL() {
	# Realtime Blackhole List (RBL) that utilizes only IP addresses
	source $RBL_LIST
}

# Colors output in terminal
colorOutput() {
	# Chosen color - text to ouput - Default color
	chosenColor=\$${1:-DEFAULT_COLOR}
	
	# Prints colored text
	echo -ne "$(eval echo ${chosenColor})"
	cat
	
	# Reverts to default color
	echo -ne "${DEFAULT_COLOR}" 
}

# Prints basic information on screen such as IP address and domain name
printInformation(){
	# Prints information of the target
	echo -ne "\nDomain Name                             IP Address\n"
	echo "============================================================"
	echo -ne "${fqdn}"|awk '{printf "%-40s", $fqdn}'
	echo -ne "$ipAddress\n\n"
	
	# Prints categorie name of the table for output below
	echo -ne "Realtime Blackhole List (RBL)           Standing\n"
	echo "============================================================"
}

# Handles error when perform instructions
handleError(){
	echo "Preliminary test failed: $1" >&2
	exit 1
}

# Validates value passed in parameter $1
validateParameter(){
	# Parameter $1 is empty or more than 1 parameter has been found
	if [ $# -ne 1 ]; then
		handleError "Please specify a FQDN or IP."
	fi
	
	# Attempts to match parameter $1 with a FQDN regex
	fqdn=$(echo $1 | grep -P "${REGEX_FQDN}")
	
	# Parameter $1 is matched as a FQDN
	if [ $fqdn ]; then
		# Retrieves IP address of the FQDN
		ipAddress=`host $1 | grep "has address" | head -n1 | awk '{print $4}'`
		
		# FQDN is not valid
		if [ -z "$ipAddress" ]; then
			handleError "You have entered an invalid FQDN."
		fi
	fi
	
	# Parameter $1 is an IP address
	if [[ $1 =~ ${REGEX_IP} ]]; then
		# Retrieve FQDN using dig command
		# Please note that this may not be accurate if the host manages multiple DNS
		fqdn=$(dig +short -x $1|sed 's/.$//')
		
		# Affects placeholder value "-" when unable to obtain FQDN
		if [ -z "$fqdn" ]; then
			fqdn="-"
		fi
		
		# Creates IP address variable
		ipAddress=$1
	fi
	
	# Lastly, parameter is not valid at all
	if [ -z "$fqdn" ] && [ -z "$ipAddress" ]; then
		handleError "You have entered an invalid FQDN."
	fi
}

# Reverses IP address into inverse address
inverseAddress(){
	reversedAddress=`echo $ipAddress | awk -F. '{print $4"."$3"." $2"."$1}'`
}

# Validates the standing of the target
validateStanding(){
	# Loop through RBL_SOURCE
	for rbl in ${RBL_SOURCE}; do
		# Retrieves return code from Realtime Blackhole List (RBL)
		returnCode="$(dig +short -t a ${reversedAddress}.${rbl}.)"

		# Prints Realtime Blackhole List (RBL) on screen
		echo -ne "${rbl}"|awk '{printf "%-40s", $rbl}'| colorOutput CYAN_COLOR
		
		# Interprets the return code from the Realtime Blackhole List (RBL)
		interpretReturnCode
  done
}

# Interprets the return code from the Realtime Blackhole List (RBL)
interpretReturnCode(){
	# Prints interpretation from $returnCode
	case "$returnCode" in
		# Request timed out
		*"TIMED OUT"*)
			echo -ne "Timed out\n" | colorOutput YELLOW_COLOR
			;;
		# IP queries prohibited
		"127.0.1.255")
			# FQDN is empty and cannot allow validation for Realtime Blackhole List (RBL) functionning with FQDN
			if [ "$fqdn" == "-" ]; then
				echo -ne "FQDN is absent\n" | colorOutput YELLOW_COLOR
			# Attempts to validate standing using FQDN
			else
				# Retrieves return code from Realtime Blackhole List (RBL)
				returnCode="$(dig +short -t a ${fqdn}.${rbl}.)"
				
				# Interprets the return code from the Realtime Blackhole List (RBL)
				interpretReturnCode
			fi
			;;
		"127."*)
			echo -ne "BLACKLISTED\n" | colorOutput RED_COLOR
			;;
		*)
			echo -ne "OK\n" | colorOutput GREEN_COLOR
			;;
	esac
}

#=========================#
# Main
#=========================#
importRBL
validateParameter $1
inverseAddress $1
printInformation
validateStanding

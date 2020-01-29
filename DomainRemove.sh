#!/bin/bash
#----AUTHOR:----------Kiren James
#----CONTRIBUTORS:----Kiren James
function removeDomain() {
	currenthostname=`hostname`
	currentdomainname=`dnsdomainname`
	# Promt user for sudo password
	read -s -p "Enter sudo password: " password
	# Remove client from domain
	echo ${password} | sudo -S realm leave
	# Remove domainname entry from host file
	echo ${password} | sudo sed -i "/${currenthostname}.${currentdomainname}/d" /etc/hostname
	
	echo "Successfully removed from domain."
}

function addDomainRemoveToBashRC {
	# Add function to use in terminal in future
	bashrc=`cat ~/.bashrc | grep -o domainremove`
	if [ -z ${bashrc} ]; then
		# Promt user for sudo password
		# read -s -p "Enter sudo password: " password
		# Copy script to local directory
		echo ${password} | sudo -S cp DomainRemove.sh /opt/DomainRemove.sh
		# Make file executable
		sudo chmod +x /opt/DomainRemove.sh
		echo >> ~/.bashrc
		# Add command to cli
		echo "alias domainremove='/opt/DomainRemove.sh'" >> ~/.bashrc
		# Reset the shell to use this command immediately
		. ~/.bashrc
		
		echo "Successfully installed as command for future use. Run the command domainremove."
		
		bash -c 'exec bash'
		# trap  "kill -9 $main" EXIT < Testing
	fi
}

function continueScript {
	removeDomain
	addDomainRemoveToBashRC
}

function promptSudoerPassword {
	# Prompt for sudoer password
	read -s -p "sudo password: " password
	echo
}

function sudoerPasswordCheck {
	# Check input sudoer password & continue script on success or propmt sudoer password on fail
	echo ${password} | sudo -S true 2>/dev/null && continueScript || (echo Incorrect password, please try again && promptSudoerPassword)
}

function currentUserSudoerCheck {
	currentuser=`whoami`
	sudoer=`getent group sudo | grep -o ${currentuser}`
	if [ -z ${sudoer} ]; then
		echo "Current user does not have sudo priviledges. Exiting script."
		exit
	else
		sudoerCheck
	fi
}

function sudoerCheck {
	# Check if terminal has sudo privileges
	if sudo -n true 2>/dev/null; then
		# Continue script
		continueScript
	else
		# Prompt for sudoer password
		promptSudoerPassword
		sudoerPasswordCheck
	fi
}

# Script begins here
currenthostname=``
currentdomainname=``
currentUserSudoerCheck

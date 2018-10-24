#!/bin/sh

clear

REPLACEME

netIDprompt="Please enter the AD account for this user: "
listUsers="$(/usr/bin/dscl . list /Users | grep -v _ | grep -v root | grep -v uucp | grep -v amavisd | grep -v nobody | grep -v messagebus | grep -v daemon | grep -v www | grep -v Guest | grep -v xgrid | grep -v windowserver | grep -v unknown | grep -v unknown | grep -v tokend | grep -v sshd | grep -v securityagent | grep -v mailman | grep -v mysql | grep -v postfix | grep -v qtss | grep -v jabber | grep -v cyrusimap | grep -v clamav | grep -v appserver | grep -v appowner) FINISHED"
#listUsers="$(/usr/bin/dscl . list /Users | grep -v -e _ -e root -e uucp -e nobody -e messagebus -e daemon -e www -v Guest -e xgrid -e windowserver -e unknown -e tokend -e sshd -e securityagent -e mailman -e mysql -e postfix -e qtss -e jabber -e cyrusimap -e clamav -e appserver -e appowner) FINISHED"
FullScriptName=`basename "$0"`
ShowVersion="$FullScriptName $Version"
check4AD=`/usr/bin/dscl localhost -list . | grep "Active Directory"`
osvers=$(sw_vers -productVersion | awk -F. '{print $2}')
lookupAccount=usadmin
OS=`/usr/bin/sw_vers | grep ProductVersion | cut -c 17-20`

echo "********* Running $FullScriptName Version $Version *********"

# If the machine is not bound to AD, then there's no purpose going any further. 
if [ "${check4AD}" != "Active Directory" ]; then
	echo "This machine is not bound to Active Directory.\nPlease bind to AD first. "; exit 1
fi

RunAsRoot()
{
        ##  Pass in the full path to the executable as $1
        if [[ "${USER}" != "root" ]] ; then
                echo
                echo "***  This application must be run as root.  Please authenticate below.  ***"
                echo
                sudo "${1}" && exit 0
        fi
}

RunAsRoot "${0}"

rm -rfv /Users/$selectedUser
		
ditto -rsrc -V /Volumes/Old_Mac/Users/$selectedUser /Users/$selectedUser

launchctl load -w /Library/LaunchDaemons/com.sophos.common.servicemanager.plist
		
dseditgroup -o edit -n /Local/Default -u vassarjamf -P jamfjamfjamfjamf -a usadmin -t user admin
		
dseditgroup -o edit -n /Local/Default -u vassarjamf -P jamfjamfjamfjamf -a $selectedUser -t user admin
		
chflags -R nouchg /Users/$selectedUser
		
chown -Rv $selectedUser /Users/$selectedUser

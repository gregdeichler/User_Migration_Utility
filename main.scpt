set the icon_file to (path to resource "applet.icns")
do shell script "launchctl unload -w /Library/LaunchDaemons/com.sophos.common.servicemanager.plist" with administrator privileges and password
do shell script "diskutil rename /dev/disk2s1 Old_Mac > /dev/null 2>&1 &"
do shell script "diskutil rename /dev/disk3s1 Old_Mac > /dev/null 2>&1 &"
do shell script "diskutil rename /dev/disk4s1 Old_Mac > /dev/null 2>&1 &"
do shell script "diskutil rename /dev/disk2s2 Old_Mac > /dev/null 2>&1 &"
do shell script "diskutil rename /dev/disk3s2 Old_Mac > /dev/null 2>&1 &"
do shell script "diskutil rename /dev/disk4s2 Old_Mac > /dev/null 2>&1 &"
do shell script "diskutil rename /dev/disk3 Old_Mac > /dev/null 2>&1 &"
do shell script "diskutil rename /dev/disk2 Old_Mac > /dev/null 2>&1 &"
do shell script "diskutil rename /dev/disk4 Old_Mac > /dev/null 2>&1 &"
do shell script "diskutil rename /dev/disk2s3 Old_Mac > /dev/null 2>&1 &"
do shell script "diskutil rename /dev/disk3s3 Old_Mac > /dev/null 2>&1 &"
do shell script "diskutil rename /dev/disk4s3 Old_Mac > /dev/null 2>&1 &"
set sourcePath to "Old_Mac:Users:"
set sourcePathPosix to POSIX path of sourcePath
set sourcePathCmd to "/Volumes/Old_Mac/Users/"
set foundUsers to "/Users/Shared/FoundUsers.txt"
with timeout of (360 * 60) seconds
	display dialog "Would You like to Migrate an account?" buttons {"Yes", "No"} default button 1 with icon icon_file
end timeout
if button returned of result is "yes" then
	set progress description to "Starting Migration"
	set progress additional description to "Disabling Sophos..."
	do shell script "launchctl unload -w /Library/LaunchDaemons/com.sophos.common.servicemanager.plist" with administrator privileges and password
	set progress additional description to "Searching For User Folders..."
	do shell script "ls /Volumes/Old_Mac/Users/ >/tmp/AllUsers.txt"
	do shell script "sed '/cisadmin/d' /tmp/AllUsers.txt >/tmp/removedcisadmin.txt"
	do shell script "sed '/usadmin/d' /tmp/removedcisadmin.txt >/tmp/removedusadmin.txt"
	do shell script "sed '/Guest/d' /tmp/removedusadmin.txt >/tmp/removedguest.txt"
	do shell script "sed '/Shared/d' /tmp/removedguest.txt >/Users/Shared/FoundUsers.txt"
else
	do shell script "launchctl load -w /Library/LaunchDaemons/com.sophos.common.servicemanager.plist" with administrator privileges and password
	error number -128 (* user cancelled *)
end if
set progress description to "Migrating"
set progress additional description to "Copying User Folder..."
set listOfUsers to {}
set Users to paragraphs of (read foundUsers)
repeat with nextLine in Users
	if length of nextLine is greater than 0 then
		copy nextLine to the end of listOfUsers
	end if
end repeat
choose from list listOfUsers with title "User Account Folders" with prompt "Which account would you like to transfer?"

set selectedUser to result
set newHomePath to "Macintosh HD:Users:"
set source to sourcePath & selectedUser & ":"
set destination to newHomePath
try
	with timeout of (180 * 180) seconds
		tell application "Finder"
			duplicate alias source to folder destination
		end tell
	end timeout
	set progress additional description to "Re-enabling Sophos..."
	do shell script "launchctl load -w /Library/LaunchDaemons/com.sophos.common.servicemanager.plist" with administrator privileges
	set progress additional description to "Giving Account Admin Rights..."
	do shell script "dseditgroup -o edit -n /Local/Default -u vassarjamf -P jamfjamfjamfjamf -a usadmin -t user admin" with administrator privileges and password
	do shell script "dseditgroup -o edit -n /Local/Default -u vassarjamf -P jamfjamfjamfjamf -a " & selectedUser & " -t user admin" with administrator privileges and password
	set progress additional description to "Converting to Network Account..."
	do shell script "chflags -R nouchg /Users/" & selectedUser & "" with administrator privileges and password
	do shell script "chown -Rv " & selectedUser & " /Users/" & selectedUser & "" with administrator privileges and password
	set theCompletedText to "Migration of " & selectedUser & " user data completed at " & (current date) & "."
	set progress description to "Finished"
	set progress additional description to "User Migration Complete!"
	display dialog theCompletedText buttons {"Done"} default button "Done" with icon icon_file
	--> Result: {button returned:"OK"}
on error errmsg
	display dialog errmsg & " User Migration Failed! What now?" buttons {"Command Line Copy", "Cancel"} default button "Command Line Copy" with icon icon_file
	if button returned of result is "Cancel" then
		do shell script "launchctl load -w /Library/LaunchDaemons/com.sophos.common.servicemanager.plist" with administrator privileges
		error number -128 (* user cancelled *)
	else
		with timeout of (360 * 60) seconds
			display dialog "Would You like to Migrate an account?" buttons {"Yes", "No"} default button 1 with icon icon_file
		end timeout
		if button returned of result is "yes" then
			set progress description to "Starting Migration"
			set progress additional description to "Searching For User Folders..."
			do shell script "ls /Volumes/Old_Mac/Users/ >/tmp/AllUsers.txt"
			do shell script "sed '/cisadmin/d' /tmp/AllUsers.txt >/tmp/removedcisadmin.txt"
			do shell script "sed '/usadmin/d' /tmp/removedcisadmin.txt >/tmp/removedusadmin.txt"
			do shell script "sed '/Guest/d' /tmp/removedusadmin.txt >/tmp/removedguest.txt"
			do shell script "sed '/Shared/d' /tmp/removedguest.txt >/Users/Shared/FoundUsers.txt"
		else
			do shell script "launchctl load -w /Library/LaunchDaemons/com.sophos.common.servicemanager.plist" with administrator privileges
			error number -128 (* user cancelled *)
		end if
		set progress description to "Migrating"
		set progress additional description to "Copying User Folder..."
		set listOfUsers to {}
		set Users to paragraphs of (read foundUsers)
		repeat with nextLine in Users
			if length of nextLine is greater than 0 then
				copy nextLine to the end of listOfUsers
			end if
		end repeat
		choose from list listOfUsers with title "User Account Folders" with prompt "Which account would you like to transfer?"
		set selectedUser to result
		set newHomePath to "Macintosh HD:Users:"
		set source to sourcePath & selectedUser & ":"
		set destination to newHomePath
		set sourcePathCmd to "/Volumes/Old_Mac/Users/"
		set migrationCommand to (path to resource "CommandLine_Migration.command") as string
		set commandPath to "Macintosh HD:Users:Shared:"
		with timeout of (180 * 180) seconds
			tell application "Finder"
				duplicate alias migrationCommand to commandPath with replacing
			end tell
		end timeout
		do shell script "sed -i.bu 's/REPLACEME/selectedUser=" & selectedUser & "/' " & "/Users/Shared/CommandLine_Migration.command"
		do shell script "open /Users/Shared/CommandLine_Migration.command"
	end if
end try

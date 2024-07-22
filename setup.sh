#Downloads
curl -s -o login.sh -L "https://raw.githubusercontent.com/JohnnyNetsec/github-vm/main/mac/login.sh"
#disable spotlight indexing
sudo mdutil -i off -a
#Create new account
sudo dscl . -create /Users/runneradmin
sudo dscl . -create /Users/runneradmin UserShell /bin/bash
sudo dscl . -create /Users/runneradmin RealName Runner_Admin
sudo dscl . -create /Users/runneradmin UniqueID 1001
sudo dscl . -create /Users/runneradmin PrimaryGroupID 80
sudo dscl . -create /Users/runneradmin NFSHomeDirectory /Users/tcv
sudo dscl . -passwd /Users/runneradmin P@ssw0rd!
sudo dscl . -passwd /Users/runneradmin P@ssw0rd!
sudo createhomedir -c -u runneradmin > /dev/null
sudo dscl . -append /Groups/admin GroupMembership runneradmin

## Set whether the computer responds to events sent by other computers (such as AppleScripts and ARD reporting).
echo -e "\n## Set whether the computer responds to events sent by other computers (such as AppleScripts and ARD reporting)."
echo -e "systemsetup -setremoteappleevents on\n"
sudo systemsetup -setremoteappleevents on

## Enable remote login
echo -e "\n## Enable remote login"
echo -e "sudo dseditgroup -o create -q com.apple.access_ssh ## (this allows you to use the dseditgroup command)\n"
sudo dseditgroup -o create -q com.apple.access_ssh ## (this allows you to use the dseditgroup command)
echo -e "sudo dseditgroup -o edit -a ADMINUSERNAME -t user com.apple.access_ssh  ## (this allows you to add a specific user replace test with your user)\n"
sudo dseditgroup -o edit -a ADMINUSERNAME -t user com.apple.access_ssh  ## (this allows you to add a specific user replace test with your user)
echo -e "sudo systemsetup -setremotelogin on ## Sets remote login (SSH) on or off.\n"
sudo systemsetup -setremotelogin on ## Sets remote login (SSH) on or off.

## Enable remote desktop for specific users
echo -e "\n## Enable remote desktop for specific users"
echo -e "sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -activate -configure -allowAccessFor -specifiedUsers\n"
sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -activate -configure -allowAccessFor -specifiedUsers

## specify users
echo -e "\n## specify users"
echo -e "sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -configure -users ADMINUSERNAME -access -on -privs -all -setmenuextra -menuextra yes -restart -agent\n"
sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -configure -users ADMINUSERNAME -access -on -privs -all -setmenuextra -menuextra yes -restart -agent

## Set whether the server restarts automatically after a power failure.
echo -e "\n## Set whether the server restarts automatically after a power failure."
echo -e "sudo systemsetup -setrestartpowerfailure on\n"
sudo systemsetup -setrestartpowerfailure on

## Set whether the computer will wake from sleep when a network admin packet is sent to it.
echo -e "\n## Set whether the computer will wake from sleep when a network admin packet is sent to it."
echo -e "sudo systemsetup -setwakeonnetworkaccess on\n"
sudo systemsetup -setwakeonnetworkaccess on

## Restart the ARD Agent and helper:
echo -e "\n## Restart the ARD Agent and helper:"
echo -e "sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -restart -agent\n"
sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -restart -agent

sudo jamf policy -trigger recon

#Enable VNC
sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -configure -allowAccessFor -allUsers -privs -all
sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -configure -clientopts -setvnclegacy -vnclegacy yes 
echo runnerrdp | perl -we 'BEGIN { @k = unpack "C*", pack "H*", "1734516E8BA8C5E2FF1C39567390ADCA"}; $_ = <>; chomp; s/^(.{8}).*/$1/; @p = unpack "C*", $_; foreach (@k) { printf "%02X", $_ ^ (shift @p || 0) }; print "\n"' | sudo tee /Library/Preferences/com.apple.VNCSettings.txt
# Optimize VNC settings for better performance
sudo defaults write /Library/Preferences/com.apple.RemoteManagement TextEncoding -string Tight
sudo defaults write /Library/Preferences/com.apple.RemoteManagement CompressionLevel -int 5
sudo defaults write /Library/Preferences/com.apple.RemoteManagement ScreenResolution -string "1280x1024x24"
sudo defaults write /Library/Preferences/com.apple.RemoteManagement -bool YES
# Additional optimizations
# Disable transparency effects
defaults write com.apple.universalaccess reduceTransparency -bool true
# Set performance-friendly resolution (adjust as needed)
sudo defaults write /Library/Preferences/com.apple.RemoteManagement DisplayResolution -string "1280x1024"
#Start VNC/reset changes
sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -restart -agent -console
sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -activate
#install ngrok
brew install --cask ngrok
#configure ngrok and start it
ngrok authtoken $1
ngrok tcp 5900 --region=eu &

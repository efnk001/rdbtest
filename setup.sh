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

# Check if Screen Sharing is enabled
sudo systemsetup -getremotelogin
# Enable Remote Login (SSH access)
sudo systemsetup -setremotelogin on

# Check if Screen Sharing is enabled
sudo systemsetup -getremoteappleevents
# Enable Remote Apple Events
sudo systemsetup -setremoteappleevents on

#Enable VNC
sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -configure -allowAccessFor -allUsers -privs -all
sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -configure -clientopts -setvnclegacy -vnclegacy yes 

echo runnerrdp | perl -we 'BEGIN { @k = unpack "C*", pack "H*", "1734516E8BA8C5E2FF1C39567390ADCA"}; $_ = <>; chomp; s/^(.{8}).*/$1/; @p = unpack "C*", $_; foreach (@k) { printf "%02X", $_ ^ (shift @p || 0) }; print "\n"' | sudo tee /Library/Preferences/com.apple.VNCSettings.txt

# Optimize VNC settings for better performance
sudo defaults write /Library/Preferences/com.apple.RemoteManagement TextEncoding -string Tight
sudo defaults write /Library/Preferences/com.apple.RemoteManagement CompressionLevel -int 5
sudo defaults write /Library/Preferences/com.apple.RemoteManagement ScreenResolution -string "1280x1024x24"

#Start VNC/reset changes
sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -restart -agent -console
sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -activate

#install ngrok
brew install --cask ngrok

#configure ngrok and start it
ngrok authtoken $1
ngrok tcp 5900 --region=eu &

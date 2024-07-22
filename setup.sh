#!/bin/bash

# Download login script
curl -s -o login.sh -L "https://raw.githubusercontent.com/JohnnyNetsec/github-vm/main/mac/login.sh"

# Disable Spotlight indexing
sudo mdutil -i off -a

# Create new account
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

# Enable VNC
sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -configure -allowAccessFor -allUsers -privs -all
sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -configure -clientopts -setvnclegacy -vnclegacy yes 
echo runnerrdp | perl -we 'BEGIN { @k = unpack "C*", pack "H*", "1734516E8BA8C5E2FF1C39567390ADCA"}; $_ = <>; chomp; s/^(.{8}).*/$1/; @p = unpack "C*", $_; foreach (@k) { printf "%02X", $_ ^ (shift @p || 0) }; print "\n"' | sudo tee /Library/Preferences/com.apple.VNCSettings.txt

# Optimize VNC settings for better performance
sudo defaults write /Library/Preferences/com.apple.RemoteManagement TextEncoding -string Tight
sudo defaults write /Library/Preferences/com.apple.RemoteManagement CompressionLevel -int 5
sudo defaults write /Library/Preferences/com.apple.RemoteManagement ScreenResolution -string "1280x1024x24"
sudo defaults write /Library/Preferences/com.apple.RemoteManagement -bool YES

# Disable transparency effects
defaults write com.apple.universalaccess reduceTransparency -bool true

# Set performance-friendly resolution (adjust as needed)
sudo defaults write /Library/Preferences/com.apple.RemoteManagement DisplayResolution -string "1280x1024"

# Enable Screen Sharing
sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -activate -configure -access -on -restart -agent -privs -all
sudo defaults write /Library/Preferences/com.apple.RemoteManagement.plist ARD_AllLocalUsers -bool true
sudo launchctl unload /System/Library/LaunchDaemons/com.apple.screensharing.plist
sudo launchctl load /System/Library/LaunchDaemons/com.apple.screensharing.plist

# Enable Remote Management
sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -activate -configure -access -on -restart -agent -privs -all

# Screen Recording permissions reset
tccutil reset ScreenCapture
echo "Screen Recording permissions reset. Please manually allow the desired apps in System Preferences."

# Install ngrok
brew install --cask ngrok

# Configure ngrok and start it
ngrok authtoken $1
ngrok tcp 5900 --region=eu &

#!/bin/zsh

# ------------------    edit the variables below this line    ------------------

# Enable 24 hour clock format. 12 hour clock enabled by default
twenty_four_hour_format="false"

# current time
currentTimeEpoch=$(date +'%s')

# number of seconds since action last occurred
# 86400 = 1 day
check_in_time_old=86400      # 1 day
check_in_time_aging=28800    # 8 hours
inventory_time_old=604800    # 1 week
inventory_time_aging=259200  # 3 days

# ---------------------    do not edit below this line    ----------------------

# Support App preference plist
preference_file_location="/Library/Preferences/nl.root3.support.plist"

# Start spinning indicator
defaults write "${preference_file_location}" ExtensionLoadingA -bool true

# Show placeholder value while loading
defaults write "${preference_file_location}" ExtensionValueA -string "KeyPlaceholder"

# Keep loading effect active for 0.5 seconds
sleep 0.5

# Set output value
defaults write "${preference_file_location}" ExtensionValueA -string "Checking in..."

# Set & Run Check in command
check_in_command=$(/usr/local/bin/jamf policy)

check_in_command

# Keep loading effect active for 10 seconds
sleep 10

# Stop spinning indicator
defaults write "${preference_file_location}" ExtensionLoadingA -bool false

## GET INFO FOR EXTENSION A
# Get last Jamf Pro check-in time from jamf.log
last_check_in_time=$(grep "Checking for policies triggered by \"recurring check-in\"" "/private/var/log/jamf.log" | tail -n 1 | awk '{ print $2,$3,$4 }')

# Convert last Jamf Pro check-in time to epoch
last_check_in_time_epoch=$(date -j -f "%b %d %T" "${last_check_in_time}" +"%s")
time_since_check_in_epoch=$(($currentTimeEpoch-$last_check_in_time_epoch))


# Convert last Jamf Pro epoch to something easier to read
if [[ "${twenty_four_hour_format}" == "true" ]]; then
  # Outputs 24 hour clock format
  last_check_in_time_human_reable=$(date -r "${last_check_in_time_epoch}" "+%A %H:%M")
else
  # Outputs 12 hour clock format
  last_check_in_time_human_reable=$(date -r "${last_check_in_time_epoch}" "+%A %-l:%M %p")
fi

#set status indicator for last check-in
if [ ${time_since_check_in_epoch} -ge ${check_in_time_old} ]; then
  check_in_status_indicator="🔴"
elif [ ${time_since_check_in_epoch} -ge ${check_in_time_aging} ]; then
  check_in_status_indicator="🟠"
elif [ ${time_since_check_in_epoch} -lt ${check_in_time_aging} ]; then
  check_in_status_indicator="🟢"
fi

# Write output to Support App preference plist
defaults write "${preference_file_location}" ExtensionValueA -string "${check_in_status_indicator}${last_check_in_time_human_reable}"

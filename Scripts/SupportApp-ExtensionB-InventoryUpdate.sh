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
defaults write "${preference_file_location}" ExtensionLoadingB -bool true

# Show placeholder value while loading
defaults write "${preference_file_location}" ExtensionValueB -string "KeyPlaceholder"

# Keep loading effect active for 0.5 seconds
sleep 0.5

# Set Temp label value
defaults write "${preference_file_location}" ExtensionValueB -string "Submitting Inventory..."

# Set & Run Inventory report
run_inventory=$(/usr/local/bin/jamf recon)

run_inventory

# Keep Loading effect active for 20 seconds
sleep 20

# Stop spinning indicator
defaults write "${preference_file_location}" ExtensionLoadingB -bool false

# GET INFO FOR EXTENSION B
  # Get last Jamf Pro inventory time from jamf.log
  last_inventory_time=$(grep "Removing existing launchd task /Library/LaunchDaemons/com.jamfsoftware.task.bgrecon.plist..." "/private/var/log/jamf.log" | tail -n 1 | awk '{ print $2,$3,$4 }')

  # Convert last Jamf Pro inventory time to epoch
  last_inventory_time_epoch=$(date -j -f "%b %d %T" "${last_inventory_time}" +"%s")
  time_since_inventory_epoch=$(($currentTimeEpoch-$last_inventory_time_epoch))


  # Convert last Jamf Pro epoch to something easier to read
  if [[ "${twenty_four_hour_format}" == "true" ]]; then
    # Outputs 24 hour clock format
    last_inventory_time_human_reable=$(date -r "${last_inventory_time_epoch}" "+%A %H:%M")
  else
    # Outputs 12 hour clock format
    last_inventory_time_human_reable=$(date -r "${last_inventory_time_epoch}" "+%A %-l:%M %p")
  fi

  #set status indicator for last inventory
  if [ ${time_since_inventory_epoch} -ge ${inventory_time_old} ]; then
    inventory_status_indicator="🔴"
  elif [ ${time_since_inventory_epoch} -ge ${inventory_time_aging} ]; then
    inventory_status_indicator="🟠"
  elif [ ${time_since_inventory_epoch} -lt ${inventory_time_aging} ]; then
    inventory_status_indicator="🟢"
  fi

defaults write "${preference_file_location}" ExtensionValueB -string "${inventory_status_indicator}${last_inventory_time_human_reable}"

#!/bin/zsh

# Support App Extension - Jamf Pro Last Check-In Time
#     ADDED Jamf Pro Inventory Time
#     ADDED indicator dots based on age of last check-in and inventory time
#
# Copyright 2022 Root3 B.V. All rights reserved.
#
# Support App Extension to get the Jamf Pro Last Check-In Time and publish to
# Extension A.
#
# Support App Extension to get the Jamf Pro Last Inventory Time and publish to
# Extension B.
#
# REQUIREMENTS:
# - Jamf Pro Binary
#
# THE SOFTWARE IS PROVIDED BY ROOT3 B.V. "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO
# EVENT SHALL ROOT3 B.V. BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR
# IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

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
defaults write "${preference_file_location}" ExtensionLoadingB -bool true

# Replace value with placeholder while loading
defaults write "${preference_file_location}" ExtensionValueA -string "KeyPlaceholder"
defaults write "${preference_file_location}" ExtensionValueB -string "KeyPlaceholder"

# Keep loading effect active for 0.5 seconds
sleep 0.5

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

# Write output to Support App preference plist
defaults write "${preference_file_location}" ExtensionValueA -string "${check_in_status_indicator}${last_check_in_time_human_reable}"
defaults write "${preference_file_location}" ExtensionValueB -string "${inventory_status_indicator}${last_inventory_time_human_reable}"

# Stop spinning indicator
defaults write "${preference_file_location}" ExtensionLoadingA -bool false
defaults write "${preference_file_location}" ExtensionLoadingB -bool false

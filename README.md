# Support App Configuration
![GitHub release (latest by date)](https://img.shields.io/github/v/release/robjschroeder/SupportApp?display_name=tag)

A sample of the configuration and resources I use with the Support App. The Support App and Helper installers are located at: [https://github.com/root3nl/SupportApp/releases](https://github.com/root3nl/SupportApp/releases)

<img width="575" alt="generic_light_mode_cropped" src="https://user-images.githubusercontent.com/23343243/211844819-84f2f5cd-b012-4c22-9089-a66b4a6c3607.png">

## Why build this
I love the idea of having a menu bar app to provide the end-user with critical information regarding their computer. The configuration of the app was pretty straightforward but I wanted to make my resources available for anyone that needed them. 

## How to use
1. The scripts in the /scripts directory need to exist somewhere locally on the computer. I used Jamf's Composer app to create a package containing the scripts that are installed into a /Library/OrgName/Scripts folder. You will need to know the path to the scripts and reference them in your plist configuration. 
2. The Support App and Helper need to be installed locally on the computer. I am using a Jamf Pro policy to deliever the pkg mentioned in step 1 and the two pkgs mentioned here.
3. The plist configuration needs to be delievered to the computer. I am using Jamf Pro with an Application & Custom Settings payload configuration profile to deliever these settings. You will need to change paths to your resources. 

In the end you will have some good information to display to your end user along with the ability for the end-user to do their own Jamf Pro check-in and inventory update. 

### Validated on:
- Apple Intel Mac: macOS 13.1 Ventura, macOS 12.6.2 Monterey, macOS 12.1 Monterey

Always test in your own environment before pushing to production.

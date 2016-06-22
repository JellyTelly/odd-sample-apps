# Odd Networks Roku SDK and Sample Apps

[![slack.oddnetworks.com](http://slack.oddnetworks.com/badge.svg)](http://slack.oddnetworks.com)

Note: due to the nature of Roku's scripting language based SDK the Oddworks Roku SDK is included as a git-submodule. There are two ways to include the required Oddworks SDK files in the Roku sample apps

git-subrepo - Install the git-submodule tool, switch to the root of the sample app folder and use the command (git subrepo commands must be run from the root of the containing repo) ```git subrepo clone https://github.com/oddnetworks/odd-roku-sdk ./roku/brightscript/dev/source/odd-roku-sdk``` and/or ```git subrepo clone https://github.com/oddnetworks/odd-roku-sdk ./roku/scenegraph/dev/source/odd-roku-sdk``` depending on which sample app(s) you want to work with. Refer to the git-submodule documentaton for information on pushing updates or pulling new changes to the SDk
manually download the odd-roku-sdk and copy the files to the odd-roku-sdk folder of the sample project
The first method is preferred as you can always pull any updates to the odd-roku-sdk. The second method requires manual management of the SDK dependencies

### Scene Graph Sample
Sample app that built using Roku's new Scene Graph XML components. Scene Graph gives you the ability to customize the look and feel of the app to your hearts content.


### BRS Component Sample
Sample app built using BRS Components.

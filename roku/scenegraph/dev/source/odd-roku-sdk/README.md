# Odd Networks Roku SDK

[![slack.oddnetworks.com](http://slack.oddnetworks.com/badge.svg)](http://slack.oddnetworks.com)

This repo contains the necessary Brightscript source files to work with the Oddworks plaftform with your Roku app. The SDK supports both Brightscript Component and Scenegraph based Roku apps.

### Installation

There are several methods to installing the SDK into your Roku app project:

- Clone and Copy - Simple clone this repo and copy the files present into your project. This method will require manually updating any changes to the SDK and is not reccommended

- Git Submodule - Git provides the ability to nest one repo within another. This method tends to be problematic for many users so we won't go in to how to set it up here.

- Git Subtree - Git provides a second method to incorporate one project within another. The subtree method is generally easier to work with and less prone to troubles. For more information refer to the googles or see [this post](http://blogs.atlassian.com/2013/05/alternatives-to-git-submodule-git-subtree/)

- Git-subrepo - This method requires you to install a tool to extend git but it is easier to work with in the end. This is the reccommended method of installation. Install the [git-submodule](https://github.com/ingydotnet/git-subrepo) tool and use the command ```git subrepo clone https://github.com/oddnetworks/odd-roku-sdk [<subdir>] [-b <upstream-branch>] [-f]``` where ```<subdir>``` is the location you want to clone the odd-roku-sdk into. Refer to the [git-submodule project documentation](https://github.com/ingydotnet/git-subrepo) for more information
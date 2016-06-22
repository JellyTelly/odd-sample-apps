#########################################################################
# common include file for application Makefiles
#
# Makefile Common Usage:
# > make
# > make install ROKU_DEV_TARGET=192.168.2.2 APPNAME=odd_example
# > make remove
#
# By default, ZIP_EXCLUDE will exclude -x \*.pkg -x storeassets\* -x keys\* -x .\*
# If you define ZIP_EXCLUDE in your Makefile, it will override the default setting.
#
# To exclude different files from being added to the zipfile during packaging
# include a line like this:ZIP_EXCLUDE= -x keys\*
# that will exclude any file who's name begins with 'keys'
# to exclude using more than one pattern use additional '-x <pattern>' arguments
# ZIP_EXCLUDE= -x \*.pkg -x storeassets\*
#
# Important Notes:
# To use the "install" and "remove" targets to install your
# application directly from the shell, you must do the following:
#
# 1) Make sure that you have the curl command line executable in your path
# 2) Set the variable ROKU_DEV_TARGET in your environment to the IP
#    address of your Roku box. (e.g. export ROKU_DEV_TARGET=192.168.1.1.
#    Set in your this variable in your shell startup (e.g. .bashrc)
# 3) Set the variable APPNAME in your environment to the app target
#    name (same as listing in dev/targets directory)
#    (e.g. export APPNAME=odd_example
#    Set in your this variable in your shell startup (e.g. .bashrc)
##########################################################################

ZIP_EXCLUDE= -x store\* -x .DS_Store -x \*/.\*

DEVREL = dev
BUILDREL = build
DISTREL = dist
COMMONREL = common
# SOURCEREL = .

ZIPREL = $(DISTREL)

APPSOURCEDIR = source

ifdef DEVPASSWORD
    USERPASS = rokudev:$(DEVPASSWORD)
else
    USERPASS = rokudev
endif

HTTPSTATUS = $(shell curl --silent --write-out "\n%{http_code}\n" $(ROKU_DEV_TARGET))

.PHONY: all $(APPNAME)

clean:
	@echo "*** Cleaning $(BUILDREL) ***"

	@echo "  >> removing old application build"
	@if [ -e "$(BUILDREL)" ]; \
	then \
		rm -rf $(BUILDREL)/*; \
	fi

build: clean
	@echo "*** Building $(APPNAME) ***"

	@echo "  >> creating destination directory $(BUILDREL)"
	@if [ ! -d $((BUILDREL) ]; \
	then \
		mkdir -p $((BUILDREL); \
	fi

	@echo "  >> setting directory permissions for $(BUILDREL)"
	@if [ ! -w $((BUILDREL) ]; \
	then \
		chmod 755 $((BUILDREL); \
	fi

	@echo "  >> copying $(APPNAME) $(DEVREL) to $(BUILDREL)"
	mkdir -p $(BUILDREL)/source
	cp -R $(DEVREL)/source $(BUILDREL)
	cp -R $(DEVREL)/targets/$(APPNAME)/* $(BUILDREL)

$(APPNAME): build
	@echo "*** Creating $(APPNAME).zip ***"

	@echo "  >> removing old application zip $(ZIPREL)/$(APPNAME).zip"
	@if [ -e "$(ZIPREL)/$(APPNAME).zip" ]; \
	then \
		rm  $(ZIPREL)/$(APPNAME).zip; \
	fi

	@echo "  >> creating destination directory $(ZIPREL)"
	@if [ ! -d $(ZIPREL) ]; \
	then \
		mkdir -p $(ZIPREL); \
	fi

	@echo "  >> setting directory permissions for $(ZIPREL)"
	@if [ ! -w $(ZIPREL) ]; \
	then \
		chmod 755 $(ZIPREL); \
	fi

# zip .png files without compression
# do not zip up Makefiles, or any files ending with '~'
	@echo "  >> creating application zip $(ZIPREL)/$(APPNAME).zip"
	(cd $(BUILDREL) ; zip -0 -r "../$(ZIPREL)/$(APPNAME).zip" . -i \*.png $(ZIP_EXCLUDE)); \
	(cd $(BUILDREL) ; zip -9 -r "../$(ZIPREL)/$(APPNAME).zip" . -x \*~ -x \*.png -x Makefile $(ZIP_EXCLUDE)); \

	@echo "*** packaging $(APPNAME) complete ***"

#if DISTDIR is not empty then copy the zip package to the DISTDIR.
	@if [ $(DISTDIR) ];\
	then \
		rm -f $(DISTDIR)/$(DISTZIP).zip; \
		mkdir -p $(DISTDIR); \
		cp -f --preserve=ownership,timestamps --no-preserve=mode $(ZIPREL)/$(APPNAME).zip $(DISTDIR)/$(DISTZIP).zip; \
	fi \

install: $(APPNAME)
	@echo "Installing $(APPNAME) to host $(ROKU_DEV_TARGET)"
	@if [ "$(HTTPSTATUS)" = " 401" ]; \
	then \
		curl --user $(USERPASS) --digest -s -S -F "mysubmit=Install" -F "archive=@$(ZIPREL)/$(APPNAME).zip" -F "passwd=" http://$(ROKU_DEV_TARGET)/plugin_install | grep "<font color" | sed "s/<font color=\"red\">//" | sed "s[</font>[[" ; \
	else \
		curl -s -S -F "mysubmit=Install" -F "archive=@$(ZIPREL)/$(APPNAME).zip" -F "passwd=" http://$(ROKU_DEV_TARGET)/plugin_install | grep "<font color" | sed "s/<font color=\"red\">//" | sed "s[</font>[[" ; \
	fi

remove:
	@echo "Removing $(APPNAME) from host $(ROKU_DEV_TARGET)"
	@if [ "$(HTTPSTATUS)" = " 401" ]; \
	then \
		curl --user $(USERPASS) --digest -s -S -F "mysubmit=Delete" -F "archive=" -F "passwd=" http://$(ROKU_DEV_TARGET)/plugin_install | grep "<font color" | sed "s/<font color=\"red\">//" | sed "s[</font>[[" ; \
	else \
		curl -s -S -F "mysubmit=Delete" -F "archive=" -F "passwd=" http://$(ROKU_DEV_TARGET)/plugin_install | grep "<font color" | sed "s/<font color=\"red\">//" | sed "s[</font>[[" ; \
	fi

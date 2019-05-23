#
# An example GNUmakefile
#

# Include the common variables defined by the Makefile Package
include $(GNUSTEP_MAKEFILES)/common.make

# Build a simple Objective-C program
VERSION = 0.1
PACKAGE_NAME = Terminal
APP_NAME = Terminal
Terminal_APPLICATION_ICON =

# The Objective-C files to compile
Terminal_OBJC_FILES = terminal.m TerminalWindow.m AppDelegate.m
Terminal_H_FILES = TerminalWindow.h AppDelegate.h

Terminal_RESOURCE_FILES = 


-include GNUmakefile.preamble

# Include in the rules for making GNUstep command-line programs
include $(GNUSTEP_MAKEFILES)/aggregate.make
include $(GNUSTEP_MAKEFILES)/application.make
-include GNUmakefile.postamble

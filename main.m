/*
This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#define _GNU_SOURCE

#include <sys/types.h>
#include <unistd.h>
#include <pty.h>
#include <fcntl.h>
#include <stdlib.h>
#include <termios.h>

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

#import "TerminalWindow.h"
#import "AppDelegate.h"

int main(int argc, char **argv) {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	char *slaveName = NULL;
	int master = posix_openpt(O_RDWR);
	int slave = -1;
	
	if (master == -1) {
		NSLog(@"Failed to open master fd");
		return 1;
	}
	if (grantpt(master) == -1) {
		NSLog(@"granpt failed");
		return 2;
	}
	if (unlockpt(master) == -1) {
		NSLog(@"unlockpt failed");
		return 3;
	}
	slaveName = ptsname(master);
	if (!slaveName) {
		NSLog(@"pstname failed...");
		return 4;
	}
	slave = open(slaveName, O_RDWR);
	if (slave == -1) {
		NSLog(@"Failed to open slave :(");
		return 5;
	}
	
	
	
	int pid = -1;
	if ((pid = fork()) == -1) {
		NSLog(@"Failed to fork");
	}
	if (pid == 0) {
		NSLog(@"This is the child");
		dup2(slave, 0);
		dup2(slave, 1);
		dup2(slave, 2);
		setsid();
		if (ioctl(slave, TIOCSCTTY, NULL) < 0) {
			NSLog(@"ioctl failed");
		}
		setenv("LOGNAME", "meguca", 1);
		setenv("USER", "meguca", 1);
		setenv("SHELL", "/bin/bash", 1);
		setenv("HOME", "/home/meguca", 1);
		setenv("TERM", "mt", 1);
		execvp("/bin/bash", argv);
		exit(1);
	} else {
		close(slave);
		NSAutoreleasePool *pool = [NSAutoreleasePool new];
		NSApplication *app = [NSApplication sharedApplication];
		AppDelegate *delegate = [AppDelegate new];
		[delegate setPty: master];
		[app setDelegate: delegate];
		[app run];
		[pool release];
	}
	
		
	[pool release];
	return 0;
}

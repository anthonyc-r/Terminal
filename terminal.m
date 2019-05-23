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


static int master;
static void readtty();


int main(int argc, char **argv) {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	char *slaveName = NULL;
	master = posix_openpt(O_RDWR);
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
	} else {
		close(slave);
		NSAutoreleasePool *pool = [NSAutoreleasePool new];
		NSApplication *app = [NSApplication sharedApplication];
		AppDelegate *delegate = [AppDelegate new];
		[app setDelegate: delegate];
		[app run];
		[pool release];
	}
	
		
	[pool release];
	return 0;
}

static void readtty() {
	fd_set rdSet, wrSet;
	char line[255];
	while (true) {
		FD_ZERO(&rdSet);
		FD_ZERO(&wrSet);
		FD_SET(master, &rdSet);
		FD_SET(master, &wrSet);
		pselect(master + 1, &rdSet, &wrSet, NULL, NULL, NULL);
		if (FD_ISSET(master, &rdSet)) {
			ssize_t sz = read(master, &line, 255);
			line[sz] = '\0';
			write(master, line, sz);
			printf("%s", line);
		}
		if (FD_ISSET(master, &wrSet)) {
			char inp[100];
			scanf("%s", inp);
			write(master, inp, strlen(inp));
			write(master, "\n", 1);
		}
	}
}

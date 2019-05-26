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
#import "Terminal.h"

@implementation Terminal

- (id) initWithFileDescriptor: (int)fileDescriptor {
	self = [super init];
	if (self) {
		queueLock = [NSLock new];
		writeQueue = [NSMutableArray new];
		master = fileDescriptor;
		[NSThread detachNewThreadSelector: @selector(selectForeverFromPty) 
							 	 toTarget: self
						   	   withObject: NULL];
	}
	return self;
}

- (id) initWithFileDescriptor: (int)fileDescriptor delegate: (id)aDelegate {
	self = [self initWithFileDescriptor: fileDescriptor];
	if (self) {
		delegate = aDelegate;
	}
	return self;
}

- (void) dealloc {
	[queueLock dealloc];
	[writeQueue dealloc];
	[super dealloc];
}

- (void) writeString: (NSString*)aString {
	[self pushToWriteQueue: aString];
}

- (void) setDelegate: (id)aDelegate {
	delegate = aDelegate;
}

- (void) pushToWriteQueue: (NSString*)string {
	[queueLock lock];
	[writeQueue addObject: string];
	[queueLock unlock];
}

- (NSString*) pullFromWriteQueue {
	NSString *item = NULL;
	[queueLock lock];
	if ([writeQueue count] > 0) {
		item = [writeQueue objectAtIndex: 0];
		[item retain];
		[item autorelease];
		[writeQueue removeObjectAtIndex: 0];
		NSLog(@"Pulled string, %@, from write queueu", item);
	}
	[queueLock unlock];
	return item;
}

- (void) selectForeverFromPty {
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	NSLog(@"polling pty");
	fd_set rdSet, wrSet;
	char line[255];
	while (true) {
		NSAutoreleasePool *innerPool = [NSAutoreleasePool new];
		FD_ZERO(&rdSet);
		FD_ZERO(&wrSet);
		FD_SET(master, &rdSet);
		FD_SET(master, &wrSet);
		pselect(master + 1, &rdSet, &wrSet, NULL, NULL, NULL);
		if (FD_ISSET(master, &rdSet)) {
			ssize_t sz = read(master, &line, 255);
			line[sz] = '\0';
			if (sz > 0) {
				NSLog(@"int val of output: %d", line[0]);
			}
			NSString *string = [[NSString stringWithCString: line] copy];
			NSLog(@"Read flag set, read %@, on main? %d", string, [NSThread isMainThread]);
			if (delegate) {
				[delegate performSelector: @selector(terminalDidOutputString:)
								 onThread: [NSThread mainThread]
							   withObject: string
							waitUntilDone: NO];
			}
		}
		if (FD_ISSET(master, &wrSet)) {
			NSLog(@"Write flag set.");
			NSString *string = [self pullFromWriteQueue];
			if (string) {
				NSLog(@"Writing, '%@'", string);
				int ret = write(master, [string cString], [string cStringLength]);
				if (ret == -1) {
					NSLog(@"Failed to write to master file descriptor, exit.");
					exit(-1);
				}
			} else {
				NSLog(@"Nothing to write.");
			}	
		}
		[innerPool release];
		usleep(1000000L);
	}
	[pool release];
}

- (void) handlePortMessage: (NSPortMessage*)aMessage {
	NSLog(@"Terminal recieved port message!!");
}

@end

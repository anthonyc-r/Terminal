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

#include <sys/types.h>
#include <unistd.h>
#include <pty.h>
#include <fcntl.h>
#include <stdlib.h>
#include <termios.h>

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

#import "AppDelegate.h"
#import "TerminalWindow.h"


@implementation AppDelegate 

- (void) applicationDidFinishLaunching: (NSNotification*)aNotification {
	NSLog(@"NSApp did finish launching..");
	queueLock = [NSLock new];
	readQueue = [NSMutableArray new];
	writeQueue = [NSMutableArray new];
	inputBuffer = [NSMutableString new];
	window = [TerminalWindow new];
	[window setDelegate: self];
	[window makeKeyAndOrderFront: self];
	[window makeFirstResponder: self];
	[NSThread detachNewThreadSelector: @selector(pollPty) 
							 toTarget: self
						   withObject: NULL];
	[NSTimer scheduledTimerWithTimeInterval: 1 
								     target: self
								   selector: @selector(updateUi)
								   userInfo: NULL
								    repeats: YES];
}

- (void) windowWillClose: (NSNotification*)sender {
	[NSApp terminate: self];
}

- (BOOL) acceptsFirstResponder {
	return YES;
}
- (BOOL) becomeFirstResponder {
	return YES;
}
- (BOOL) resignFirstResponder {
	return NO;
}

- (void) keyDown: (NSEvent*)theEvent {
	NSString *characters = [theEvent characters];
	[inputBuffer appendString: characters];
	NSLog(@"Key downasdas, characters: %@", characters);
	NSLog(@"inputBuffer: %@", inputBuffer);
	[window keyDown: theEvent];
}

- (void) setMasterPty: (int)master {
	masterpty = master;
}

- (void) updateUi {
	NSString *readString = [self pullFromReadQueue];
	if (readString) {
		NSLog(@"Read queue contained content, adding to window");
		[window appendText: readString];
	}
	NSString *writeString = inputBuffer;
	if ([writeString length] > 0) {
		NSLog(@"Input buffer contained string, %@, writing to tty", writeString);
		inputBuffer = [NSMutableString new];
		[self pushToWriteQueue: writeString];
		[writeString release];
		NSLog(@"write string after added... %@, count: %d", writeString, [writeString retainCount]);
	}
}

- (void) pollPty {
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	NSLog(@"polling pty");
	fd_set rdSet, wrSet;
	char line[255];
	while (true) {
		NSAutoreleasePool *innerPool = [NSAutoreleasePool new];
		FD_ZERO(&rdSet);
		FD_ZERO(&wrSet);
		FD_SET(masterpty, &rdSet);
		FD_SET(masterpty, &wrSet);
		pselect(masterpty + 1, &rdSet, &wrSet, NULL, NULL, NULL);
		if (FD_ISSET(masterpty, &rdSet)) {
			ssize_t sz = read(masterpty, &line, 255);
			line[sz] = '\0';
			NSString *string = [[NSString stringWithCString: line] copy];
			NSLog(@"Read flag set, read %@", string);
			[self pushToReadQueue: string];
		}
		if (FD_ISSET(masterpty, &wrSet)) {
			NSLog(@"Write flag set.");
			NSString *string = [self pullFromWriteQueue];
			if (string) {
				NSLog(@"Writing, '%@'", string);
				int ret = write(masterpty, [string cString], [string cStringLength]);
				if (ret == -1) {
					NSLog(@"Failed to write to master file descriptor, exit.");
					exit(-1);
				}
				//ret = write(masterpty, "\n", 1);
				//if (ret == -1) {
				//	NSLog(@"Failed to write to master file desc 2, exit.");
				//	exit(-1);
				//}
			} else {
				NSLog(@"Nothing to write.");
			}	
		}
		[innerPool release];
		usleep(1000000L);
	}
	[pool release];
}

- (void) pushToReadQueue: (NSString*) string {
	[queueLock lock];
	[readQueue addObject: string];
	[queueLock unlock];
}

- (NSString*) pullFromReadQueue {
	NSString *item = NULL; 
	[queueLock lock];
	if ([readQueue count] > 0) {
		item = [readQueue objectAtIndex: 0];
		[item autorelease];
		[readQueue removeObjectAtIndex: 0];
	}
	[queueLock unlock];
	return item;
}

- (void) pushToWriteQueue: (NSString*) string {
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

@end

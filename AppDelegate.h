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

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@class TerminalWindow;

@interface AppDelegate: NSResponder<NSApplicationDelegate, NSWindowDelegate> {
	TerminalWindow *window;
	int masterpty;
	NSLock *queueLock;
	NSMutableString *inputBuffer;
	NSMutableArray *writeQueue;
	NSMutableArray *readQueue;
} 

- (void) setMasterPty: (int)master;
- (void) updateUi;
- (void) pollPty;
- (void) pushToReadQueue: (NSString*) string;
- (NSString*) pullFromReadQueue; 
- (void) pushToWriteQueue: (NSString*) string;
- (NSString*) pullFromWriteQueue; 

@end

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

@protocol TerminalDelegate
- (void) terminalDidOutputString: (NSString*)aString;
@end

@interface Terminal: NSObject {
@private
	int master;
	NSLock *queueLock;
	NSMutableArray *writeQueue;
	id delegate;
}
- (id) initWithFileDescriptor: (int)fileDescriptor;
- (id) initWithFileDescriptor: (int)fileDescriptor delegate: (id)aDelegate;
- (void) writeString: (NSString*)aString;
- (void) setDelegate: (id)aDelegate;
- (void) pushToWriteQueue: (NSString*) string;
- (NSString*) pullFromWriteQueue; 
- (void) selectForeverFromPty;

@end

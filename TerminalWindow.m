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

#import "TerminalWindow.h"


@implementation TerminalWindow 

- (id) init {
	NSRect frame = NSMakeRect(500, 500, 600, 400);
	self = [super initWithContentRect: frame
							styleMask: NSTitledWindowMask | 
									   NSClosableWindowMask | 
									   NSMiniaturizableWindowMask 
							  backing: NSBackingStoreRetained 
							    defer: NO];
	if (self) {
		[self setFrame: frame display: YES];
		NSView *contentView = [self contentView];
		textView = [[NSTextView alloc] initWithFrame: NSMakeRect(0, 0, 600, 373)];
		[contentView addSubview: textView];
	}
	return self;
}

- (void) appendText: (NSString*) text {
	NSMutableString *string = [NSMutableString new];
	[string autorelease];
	if ([textView string]) {
		string = [[textView string] mutableCopy];
	}
	[string appendString: text];
	[textView setString: text];
}


@end

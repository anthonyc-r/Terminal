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

#import "AppDelegate.h"
#import "TerminalWindow.h"


@implementation AppDelegate 

- (void) applicationDidFinishLaunching: (NSNotification*)aNotification {
	NSLog(@"NSApp did finish launching..");
	window = [TerminalWindow new];
	[window setDelegate: self];
	[window makeKeyAndOrderFront: self];
	[window makeFirstResponder: self];
	NSLog(@"Creating terminal with pty: %d", pty);
	terminal = [[Terminal alloc] initWithFileDescriptor: pty delegate: self];
}

- (void) setPty: (int)aPty {
	pty = aPty;
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
	NSLog(@"Keydown characters: '%@'", characters);
	NSLog(@"Character code: %d", [theEvent keyCode]);
	[terminal writeString: characters];
}

- (void) terminalDidOutputString: (NSString*)aString {
	NSLog(@"Termina did output string: %@, on main? %d", aString, [NSThread isMainThread]);
	[window appendText: aString];
}
@end

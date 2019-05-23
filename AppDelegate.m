#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

#import "AppDelegate.h"
#import "TerminalWindow.h"

@implementation AppDelegate 

- (void) applicationDidFinishLaunching: (NSNotification*)aNotification {
	NSLog(@"NSApp did finish launching..");
	window = [TerminalWindow new];
	[window makeKeyAndOrderFront: self];
}

@end

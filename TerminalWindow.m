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
							  backing: NSBackingStoreBuffered 
							    defer: NO];
	if (self) {
		[self setFrame: frame display: YES];
		NSView *contentView = [self contentView];
		textView = [[NSTextView alloc] initWithFrame: NSMakeRect(0, 0, 600, 400)];
		[contentView addSubview: textView];
	}
	return self;
}

@end

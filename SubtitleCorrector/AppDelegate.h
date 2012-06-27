//
//  AppDelegate.h
//  SubtitleCorrector
//
//  Created by Diogo Castro on 27/06/12.
//  Copyright (c) 2012 FEUP. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>
@property (weak) IBOutlet NSPathControl *filePathControl;

@property (assign) IBOutlet NSWindow *window;
- (IBAction)buttonPressed:(id)sender;

@end

//
//  AppDelegate.h
//  SubtitleCorrector
//
//  Created by Diogo Castro on 27/06/12.
//  Copyright (c) 2012 FEUP. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate, NSTextFieldDelegate>
@property (weak) IBOutlet NSPathControl *filePathControl;
@property (weak) IBOutlet NSMatrix *optionsRadio;
@property (weak) IBOutlet NSTextField *secondsTextField;
@property (weak) IBOutlet NSTextField *milisecondsTextField;
@property (assign) IBOutlet NSWindow *window;

- (IBAction)chooseFile:(id)sender;
- (IBAction)correct:(id)sender;

@end

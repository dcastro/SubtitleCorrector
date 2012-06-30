//
//  AppDelegate.h
//  SubtitleCorrector
//
//  Created by Diogo Castro on 27/06/12.
//  Copyright (c) 2012 FEUP. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DragDropImageView.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, NSTextFieldDelegate, DragDropDelegate>
@property (weak) IBOutlet NSPathControl *filePathControl;
@property (weak) IBOutlet NSMatrix *optionsRadio;
@property (weak) IBOutlet NSTextField *secondsTextField;
@property (weak) IBOutlet NSTextField *milisecondsTextField;
@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSButton *correctButton;
@property (weak) IBOutlet DragDropImageView *dragDropImg;

- (IBAction)chooseFile:(id)sender;
- (IBAction)correct:(id)sender;

- (void) didDrop:(NSURL *)url;

@end

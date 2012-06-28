//
//  AppDelegate.m
//  SubtitleCorrector
//
//  Created by Diogo Castro on 27/06/12.
//  Copyright (c) 2012 FEUP. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize filePathControl = _filePathControl;
@synthesize optionsRadio = _optionsRadio;
@synthesize secondsTextField = _secondsTextField;
@synthesize milisecondsTextField = _milisecondsTextField;
@synthesize window = _window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
}

- (IBAction)chooseFile:(id)sender {
    // Create the File Open Dialog class.
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    
    // Enable the selection of files in the dialog.
    [openDlg setCanChooseFiles:YES];
    [openDlg setAllowsMultipleSelection:NO];
    
    // Display the dialog.  If the OK button was pressed,
    // process the files.
    if ( [openDlg runModal] == NSOKButton )
    {
        // Get an array containing the full filenames of all
        // files and directories selected.
        /*NSArray* files = [openDlg URL];
        
        // Loop through all the files and process them.
        for( i = 0; i < [files count]; i++ )
        {
            NSString* fileName = [files objectAtIndex:i];
            
            // Do something with the filename.
        }*/
        
        NSURL* path = [openDlg URL];
        [self.filePathControl setURL:path];
        
        
        
    }
    
    
}

- (IBAction)correct:(id)sender {
}



@end

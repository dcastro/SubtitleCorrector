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
        
        NSURL* url = [openDlg URL];
        [self.filePathControl setURL:url];
        
        
        
    }
    
    
}

- (IBAction)correct:(id)sender {

    NSURL* url = [self.filePathControl URL];
    NSMutableArray* corrected = [[NSMutableArray alloc] init];
    
    int msecs = [self.secondsTextField intValue] * 1000 + [self.milisecondsTextField intValue];
    
    const char *filename;
    filename = [[url path] UTF8String];
    FILE *file = fopen ( filename, "r+" );
    if ( file != NULL )
    {
        char line [ 512 ]; /* or other suitable maximum line size */
        while ( fgets ( line, sizeof line, file ) != NULL ) /* read a line */
        {
            NSString* string = [NSString stringWithUTF8String:line];
            
            //remove endline
            NSCharacterSet* charSet = [NSCharacterSet newlineCharacterSet];
            string = [[string componentsSeparatedByCharactersInSet: charSet] componentsJoinedByString: @""];
            
            
            //match line
            NSString* expression = @"[0-9]{2}:[0-9]{2}:[0-9]{2},[0-9]{3} --> [0-9]{2}:[0-9]{2}:[0-9]{2},[0-9]{3}";
            NSError *error = NULL;
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:expression options:NSRegularExpressionCaseInsensitive error:&error];
            NSUInteger numberOfMatches = 0;
            if (string != nil)
                numberOfMatches = [regex numberOfMatchesInString:string
                                                                options:0
                                                                  range:NSMakeRange(0, [string length])];
            
            //correction
            if (numberOfMatches) {
                
                NSString* expression = @"[0-9]{2}:[0-9]{2}:[0-9]{2},[0-9]{3}";
                NSError *error = NULL;
                NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:expression options:NSRegularExpressionCaseInsensitive error:&error];
                
                NSArray* matches = [regex matchesInString:string options:0 range:NSMakeRange(0, [string length])];
                
                for (NSTextCheckingResult *match in matches) {
                    NSRange matchRange = [match range];
                    NSString* timestamp = [string substringWithRange:matchRange];
                    
                    [self correctTimestamp:timestamp byMiliseconds:msecs];
                }
            }
            
            
            //save line for later
            string = [NSString stringWithFormat:@"%@\n", string];
            [corrected insertObject:string atIndex: [corrected count] ];
            
        }
        fclose ( file );
    }
    
    
    file = fopen ( filename, "w+" );
    if ( file != NULL )
    {
        
        for (NSString* string in corrected) {
            fputs([string UTF8String], file);
        }
        
        fclose(file);
        
        
    }
    
    
}

- (void) correctTimestamp:(NSString*) timestamp byMiliseconds:(int) msecs {
    
}



@end

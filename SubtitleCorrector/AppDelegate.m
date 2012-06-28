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
@synthesize correctButton = _correctButton;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    [self.correctButton setEnabled:NO];
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
        NSURL* url = [openDlg URL];
        [self.filePathControl setURL:url];
        
        [self.correctButton setEnabled:YES];
    }
    
    
}

- (IBAction)correct:(id)sender {

    NSURL* url = [self.filePathControl URL];
    NSMutableArray* corrected = [[NSMutableArray alloc] init];
    
    //calc time diff
    int msecs = [self.secondsTextField intValue] * 1000 + [self.milisecondsTextField intValue];
    //NSLog(@"tag: %i", self.optionsRadio.selectedTag);
    msecs *= self.optionsRadio.selectedTag;
    
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
                
                //find timestamps within the line
                
                NSString* expression = @"[0-9]{2}:[0-9]{2}:[0-9]{2},[0-9]{3}";
                NSError *error = NULL;
                NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:expression options:NSRegularExpressionCaseInsensitive error:&error];
                
                NSArray* matches = [regex matchesInString:string options:0 range:NSMakeRange(0, [string length])];
                
                //NSLog(@"old %@", string );
                
                for (NSTextCheckingResult *match in matches) {
                    NSRange matchRange = [match range];
                    NSString* timestamp = [string substringWithRange:matchRange];
                    
                    //correct timestamp
                    timestamp = [self correctTimestamp:timestamp byMiliseconds:msecs];
                    
                    string = [string stringByReplacingCharactersInRange:matchRange withString:timestamp];
                }
                //NSLog(@"new %@", string );
            }
            
            
            //save line for later
            string = [NSString stringWithFormat:@"%@\n", string];
            [corrected insertObject:string atIndex: [corrected count] ];
            
        }
        fclose ( file );
    }
    
    //backup original file
    if ([sender tag] == 2) {
        if ( [[NSFileManager defaultManager] isReadableFileAtPath:[url path]] ) {
            NSString* path = [[url path] stringByAppendingString:@".backup"];
            NSLog(@"url %@", [url path]);
            NSLog(@"dest %@", path);
            NSURL* destination = [NSURL fileURLWithPath:path];
            
            NSLog(@"url %@", [url description]);
            NSLog(@"dest %@", [destination description]);
            
            [[NSFileManager defaultManager] copyItemAtURL:url toURL:destination error:nil];
        }
    }
    
    //write correct subtitles to file
    file = fopen ( filename, "w+" );
    if ( file != NULL )
    {
        
        for (NSString* string in corrected) {
            fputs([string UTF8String], file);
        }
        
        fclose(file);
        
        
    }
    
    
}

- (NSString*) correctTimestamp:(NSString*) timestamp byMiliseconds:(int) msecs {
    //formatter
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm:ss,SSS"];
    
    //convert to date
    NSDate* date = [dateFormatter dateFromString:timestamp];
    
    //add/sub time
    NSTimeInterval interval = msecs/1000.0;
    date = [date dateByAddingTimeInterval:interval];
    
    //convert back to string
    NSString *dateString = [dateFormatter stringFromDate:date];
    //NSLog(@"old %@ new %@", timestamp, dateString );
    
    return dateString;
}



@end

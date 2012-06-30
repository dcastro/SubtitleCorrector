//
//  DragDropImageView.m
//  SubtitleCorrector
//
//  Created by Diogo Castro on 30/06/12.
//  Copyright (c) 2012 FEUP. All rights reserved.
//

#import "DragDropImageView.h"

@implementation DragDropImageView

@synthesize delegate;

NSString *kPrivateDragUTI = @"com.yourcompany.cocoadraganddrop";

- (id)initWithCoder:(NSCoder *)coder
{
    /*------------------------------------------------------
     Init method called for Interface Builder objects
     --------------------------------------------------------*/
    self=[super initWithCoder:coder];
    if ( self ) {
        //register for all the image types we can display
        NSArray* a = [NSArray arrayWithObject:NSPasteboardTypeString];
        //[self registerForDraggedTypes: a ];// [NSPasteboard pa ] ];//[NSImage imagePasteboardTypes]];
        
    }
    return self;
}

#pragma mark - Destination Operations

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{
    /*------------------------------------------------------
     method called whenever a drag enters our drop zone
     --------------------------------------------------------*/
    
    if ( [sender draggingSourceOperationMask] & NSDragOperationCopy ) {
        //highlight our drop zone
        highlight=YES;
        
        [self setNeedsDisplay: YES];
        
        return NSDragOperationCopy;
    }
    
    // Check if the pasteboard contains image data and source/user wants it copied
    if ( [NSImage canInitWithPasteboard:[sender draggingPasteboard]] &&
        [sender draggingSourceOperationMask] &
        NSDragOperationCopy ) {
        
        //highlight our drop zone
        highlight=YES;
        
        [self setNeedsDisplay: YES];
        
        /* When an image from one window is dragged over another, we want to resize the dragging item to
         * preview the size of the image as it would appear if the user dropped it in. */
        [sender enumerateDraggingItemsWithOptions:NSDraggingItemEnumerationConcurrent 
                                          forView:self
                                          classes:[NSArray arrayWithObject:[NSPasteboardItem class]] 
                                    searchOptions:nil 
                                       usingBlock:^(NSDraggingItem *draggingItem, NSInteger idx, BOOL *stop) {
                                           
                                           /* Only resize a fragging item if it originated from one of our windows.  To do this,
                                            * we declare a custom UTI that will only be assigned to dragging items we created.  Here
                                            * we check if the dragging item can represent our custom UTI.  If it can't we stop. */
                                           if ( ![[[draggingItem item] types] containsObject:kPrivateDragUTI] ) {
                                               
                                               *stop = YES;
                                               
                                           } else {
                                               /* In order for the dragging item to actually resize, we have to reset its contents.
                                                * The frame is going to be the destination view's bounds.  (Coordinates are local 
                                                * to the destination view here).
                                                * For the contents, we'll grab the old contents and use those again.  If you wanted
                                                * to perform other modifications in addition to the resize you could do that here. */
                                               [draggingItem setDraggingFrame:self.bounds contents:[[[draggingItem imageComponents] objectAtIndex:0] contents]];
                                           }
                                       }];
        
        //accept data as a copy operation
        return NSDragOperationCopy;
    }
    
    return NSDragOperationNone;
}

- (void)draggingExited:(id <NSDraggingInfo>)sender
{
    /*------------------------------------------------------
     method called whenever a drag exits our drop zone
     --------------------------------------------------------*/
    //remove highlight of the drop zone
    highlight=NO;
    
    [self setNeedsDisplay: YES];
}

-(void)drawRect:(NSRect)rect
{
    /*------------------------------------------------------
     draw method is overridden to do drop highlighing
     --------------------------------------------------------*/
    //do the usual draw operation to display the image
    [super drawRect:rect];
    
    if ( highlight ) {
        //highlight by overlaying a gray border
        [[NSColor grayColor] set];
        [NSBezierPath setDefaultLineWidth: 5];
        [NSBezierPath strokeRect: rect];
    }
}

- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender
{
    /*------------------------------------------------------
     method to determine if we can accept the drop
     --------------------------------------------------------*/
    //finished with the drag so remove any highlighting
    highlight=NO;
    
    [self setNeedsDisplay: YES];
    
    //check to see if we can accept the data
    return YES;
    //return [NSImage canInitWithPasteboard: [sender draggingPasteboard]];
} 

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
    /*------------------------------------------------------
     method that should handle the drop data
     --------------------------------------------------------*/
    if ( [sender draggingSource] != self ) {
        NSURL* fileURL;
        fileURL=[NSURL URLFromPasteboard: [sender draggingPasteboard]];
        [self.delegate didDrop:fileURL];
        
        /*
        //set the image using the best representation we can get from the pasteboard
        if([NSImage canInitWithPasteboard: [sender draggingPasteboard]]) {
            NSImage *newImage = [[NSImage alloc] initWithPasteboard: [sender draggingPasteboard]];
            [self setImage:newImage];
        }
        */
        
        //if the drag comes from a file, set the window title to the filename
        //fileURL=[NSURL URLFromPasteboard: [sender draggingPasteboard]];
        //[[self window] setTitle: fileURL!=NULL ? [fileURL absoluteString] : @"(no name)"];
    }
    
    return YES;
}

- (NSRect)windowWillUseStandardFrame:(NSWindow *)window defaultFrame:(NSRect)newFrame;
{
    /*------------------------------------------------------
     delegate operation to set the standard window frame
     --------------------------------------------------------*/
    //get window frame size
    NSRect ContentRect=self.window.frame;
    
    //set it to the image frame size
    ContentRect.size=[[self image] size];
    
    return [NSWindow frameRectForContentRect:ContentRect styleMask: [window styleMask]];
};

#pragma mark - Source Operations

- (void)mouseDown:(NSEvent*)event
{
    /*------------------------------------------------------
     catch mouse down events in order to start drag
     --------------------------------------------------------*/
    
    /* Dragging operation occur within the context of a special pasteboard (NSDragPboard).
     * All items written or read from a pasteboard must conform to NSPasteboardWriting or 
     * NSPasteboardReading respectively.  NSPasteboardItem implements both these protocols
     * and is as a container for any object that can be serialized to NSData. */
    
    NSPasteboardItem *pbItem = [NSPasteboardItem new];
    /* Our pasteboard item will support public.tiff, public.pdf, and our custom UTI (see comment in -draggingEntered)
     * representations of our data (the image).  Rather than compute both of these representations now, promise that 
     * we will provide either of these representations when asked.  When a receiver wants our data in one of the above 
     * representations, we'll get a call to  the NSPasteboardItemDataProvider protocol method –pasteboard:item:provideDataForType:. */
    [pbItem setDataProvider:self forTypes:[NSArray arrayWithObjects:NSPasteboardTypeTIFF, NSPasteboardTypePDF, kPrivateDragUTI, nil]];
    
    //create a new NSDraggingItem with our pasteboard item.
    NSDraggingItem *dragItem = [[NSDraggingItem alloc] initWithPasteboardWriter:pbItem];
    
    /* The coordinates of the dragging frame are relative to our view.  Setting them to our view's bounds will cause the drag image
     * to be the same size as our view.  Alternatively, you can set the draggingFrame to an NSRect that is the size of the image in
     * the view but this can cause the dragged image to not line up with the mouse if the actual image is smaller than the size of the
     * our view. */
    NSRect draggingRect = self.bounds;
    
    /* While our dragging item is represented by an image, this image can be made up of multiple images which
     * are automatically composited together in painting order.  However, since we are only dragging a single
     * item composed of a single image, we can use the convince method below. For a more complex example
     * please see the MultiPhotoFrame sample. */
    [dragItem setDraggingFrame:draggingRect contents:[self image]];
    
    //create a dragging session with our drag item and ourself as the source.
    NSDraggingSession *draggingSession = [self beginDraggingSessionWithItems:[NSArray arrayWithObject:dragItem] event:event source:self];
    //causes the dragging item to slide back to the source if the drag fails.
    draggingSession.animatesToStartingPositionsOnCancelOrFail = YES;
    
    draggingSession.draggingFormation = NSDraggingFormationNone;
}

- (NSDragOperation)draggingSession:(NSDraggingSession *)session sourceOperationMaskForDraggingContext:(NSDraggingContext)context
{
    /*------------------------------------------------------
     NSDraggingSource protocol method.  Returns the types of operations allowed in a certain context.
     --------------------------------------------------------*/
    switch (context) {
        case NSDraggingContextOutsideApplication:
            return NSDragOperationCopy;
            
            //by using this fall through pattern, we will remain compatible if the contexts get more precise in the future.
        case NSDraggingContextWithinApplication:
        default:
            return NSDragOperationCopy;
            break;
    }
}

- (BOOL)acceptsFirstMouse:(NSEvent *)event 
{
    /*------------------------------------------------------
     accept activation click as click in window
     --------------------------------------------------------*/
    //so source doesn't have to be the active window
    return YES;
}

- (void)pasteboard:(NSPasteboard *)sender item:(NSPasteboardItem *)item provideDataForType:(NSString *)type
{
    /*------------------------------------------------------
     method called by pasteboard to support promised 
     drag types.
     --------------------------------------------------------*/
    //sender has accepted the drag and now we need to send the data for the type we promised
    if ( [type compare: NSPasteboardTypeTIFF] == NSOrderedSame ) {
        
        //set data for TIFF type on the pasteboard as requested
        [sender setData:[[self image] TIFFRepresentation] forType:NSPasteboardTypeTIFF];
        
    } else if ( [type compare: NSPasteboardTypePDF] == NSOrderedSame ) {
        
        //set data for PDF type on the pasteboard as requested
        [sender setData:[self dataWithPDFInsideRect:[self bounds]] forType:NSPasteboardTypePDF];
    }
    
}
@end

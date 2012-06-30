//
//  DragDropImageView.h
//  SubtitleCorrector
//
//  Created by Diogo Castro on 30/06/12.
//  Copyright (c) 2012 FEUP. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@protocol DragDropDelegate <NSObject>

- (void) didDrop:(NSURL*) url;

@end

@interface DragDropImageView : NSImageView <NSDraggingSource, NSDraggingDestination, NSPasteboardItemDataProvider>
{
    //highlight the drop zone
    BOOL highlight;
}

@property (strong, nonatomic) id<DragDropDelegate> delegate;

- (id)initWithCoder:(NSCoder *)coder;

@end

//
//  AppDelegate.h
//  SDownload
//
//  Created by Christian Nilsen on 3/16/13.
//  Copyright (c) 2013 Brennan Kastner. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>
{
    NSMutableString* downloadLocation;
}

@property (assign) IBOutlet NSWindow *window;
@property (nonatomic, retain) IBOutlet NSTextField* downloadFolder;
@property (nonatomic, retain) IBOutlet NSButton* authorFolder;
@property (nonatomic, retain) IBOutlet NSButton* itunesEnabled;
@property (nonatomic, retain) IBOutlet NSButton* keepCopy;

-(IBAction)saveSettings:(id)sender;
-(IBAction)pickDirectory:(id)sender;
-(IBAction)itunesChanged:(id)sender;

@end

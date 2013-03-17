//
//  AppDelegate.m
//  SDownload
//
//  Created by Christian Nilsen on 3/16/13.
//  Copyright (c) 2013 Brennan Kastner. All rights reserved.
//

#import "AppDelegate.h"
#import "Sound.h"

@implementation AppDelegate

@synthesize downloadFolder;
@synthesize authorFolder;
@synthesize itunesEnabled;
@synthesize keepCopy;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
    
    [downloadFolder setStringValue:(NSString*)[settings objectForKey:@"downloadFolder"]];
    [authorFolder setState:([settings boolForKey:@"authorFolder"] ? NSOnState : NSOffState)];
    iTunesTransfer itunes = (iTunesTransfer)[settings integerForKey:@"iTunesFlag"];
    if (itunes != Nothing)
    {
        [itunesEnabled setState:NSOnState];
        [keepCopy setEnabled:YES];
        [keepCopy setState:(itunes == Copy) ? YES : NO];
    }
    else
    {
        [itunesEnabled setState:NSOffState];
        [keepCopy setEnabled:NO];
    }
}

-(IBAction)saveSettings:(id)sender
{
    NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
    
    // Save Download Folder
    [settings setObject:downloadFolder.stringValue forKey:@"downloadFolder"];
    
    // Save Author Settings
    [settings setBool:[authorFolder state] == NSOnState forKey:@"authorFolder"];
    
    // iTunes Setting
    iTunesTransfer value = Nothing;
    if ([itunesEnabled state] == NSOnState)
    {
        value = Move;
        if ([keepCopy state] == NSOnState)
            value = Copy;
    }
    [settings setInteger:(NSInteger)value forKey:@"iTunesFlag"];
    
    [settings synchronize];
    exit(0);
}

-(IBAction)pickDirectory:(id)sender
{
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setAllowsMultipleSelection:NO];
    [panel setCanChooseDirectories:YES];
    [panel setCanChooseFiles:NO];
    if ([panel runModal] == NSFileHandlingPanelOKButton)
    {
        [downloadFolder setStringValue:[[panel URLs] lastObject]];
    }
}

-(IBAction)itunesChanged:(id)sender
{
    [keepCopy setEnabled:([sender state] == NSOnState)];
}

@end

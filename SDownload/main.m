//
//  main.m
//  SDownload
//
//  Created by Christian Nilsen on 3/16/13.
//  Copyright (c) 2013 Brennan Kastner. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Sound.h>

int main(int argc, char *argv[])
{
    NSArray* arguments = [[NSProcessInfo processInfo] arguments];
    if ([arguments count])
    {
        for (int i = 0U; i < [arguments count]; i++)
        {
            if ([(NSString*)[arguments objectAtIndex:i] rangeOfString:@"soundcloud"].location != NSNotFound)
            {
                NSString* link = [(NSString*)[arguments objectAtIndex:i] stringByReplacingOccurrencesOfString:@"sdownload://" withString:@""];
                Sound* song = [[Sound alloc] init];
                [song loadURL:link];
                return 0;
            }
        }
    }
    return NSApplicationMain(argc, (const char **)argv);
}

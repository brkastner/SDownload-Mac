//
//  Sound.m
//  SDownload
//
//  Created by Brennan Kastner on 3/16/13.
//  Copyright (c) 2013 Brennan Kastner. All rights reserved.
//

#import "Sound.h"

@implementation Sound
-(id)init
{
    loading = YES;
    return self;
}

-(id)updateAttr:(NSString *)title :(NSString *)author :(NSString *)genre
{
    Title = title;
    Author = author;
    Genre = genre;
    return self;
}

-(void)addToiTunes
{
    NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
    NSString* authorFolder = @"";
    if ([settings boolForKey:@"authorFolder"])
        authorFolder = Author;
    NSString* fileName = [Sound getFileName:Title];
    NSString* oldDirectory = [NSString stringWithFormat:@"%@%@\\", [settings stringForKey:@"downloadFolder"], authorFolder];
    NSString* oldFile = [oldDirectory stringByAppendingFormat:@"%@.mp3", fileName];
    NSString* newFile = [NSString stringWithFormat:@"%@\\iTunes\\iTunes Media\\Automatically Add to iTunes\\%@.mp3", [NSSearchPathForDirectoriesInDomains(NSMusicDirectory, NSUserDomainMask, YES) objectAtIndex:0], fileName];
    
    iTunesTransfer transferFlag = (iTunesTransfer)[settings integerForKey:@"iTunesFlag"];
    switch (transferFlag)
    {
        case Move:
        {
            NSError* error;
            [[NSFileManager defaultManager] moveItemAtPath:oldFile toPath:newFile error:&error];
            if (error)
            {
                NSLog(@"There was an error moving the file to the iTunes directory!");
            }
            else
            {
                if (![[[NSFileManager defaultManager] contentsOfDirectoryAtPath:oldDirectory error:&error] count])
                {
                    [[NSFileManager defaultManager] removeItemAtPath:oldDirectory error:&error];
                    if (error)
                    {
                        NSLog(@"There was an error attempting to remove the empty artist directory!");
                    }
                }
            }
            break;
        }
        case Copy:
        {
            NSError* error;
            [[NSFileManager defaultManager] copyItemAtPath:oldFile toPath:newFile error:&error];
            if (error)
            {
                NSLog(@"There was an error copying the file to the iTunes directory!");
            }
            break;
        }
        case Nothing:
        {
            // Do nothing obviously
            break;
        }
    }
}

-(void)loadURL:(id)obj
{
    NSString* clientId = @"4515286ec9d4ace678140c3f84357b35";
    NSString* url = (NSString*)obj;
    [SCSoundCloud setClientID:clientId secret:@"a4ffc0b31713389821e2eef2340d0439" redirectURL:(NSURL*)@""];
    NSMutableDictionary* resolveDictionary = [[NSMutableDictionary alloc] init];
    [resolveDictionary setValue:url forKey:@"url"];
    [resolveDictionary setValue:clientId forKey:@"client_id"];
    SCRequestResponseHandler handler = ^(NSURLResponse* response, NSData* responseData, NSError* error)
    {
        [self download:response :responseData :error];
    };
    [SCRequest performMethod:SCRequestMethodGET
                  onResource:[NSURL URLWithString:@"https://api.soundcloud.com/resolve.json"]
             usingParameters:resolveDictionary
                 withAccount:nil
      sendingProgressHandler:nil
             responseHandler:handler];
}

-(void)download:(NSURLResponse*)response :(NSData*)responseData :(NSError*)error
{
    NSString* clientId = @"4515286ec9d4ace678140c3f84357b35";
    // Track info downloaded successfully
    NSError *jsonError = nil;
    if (error) {
        NSLog(@"There was an error contacting the API: %@", [error localizedDescription]);
    } else {
        NSJSONSerialization *jsonResponse = [NSJSONSerialization JSONObjectWithData:responseData
                                                                            options:0
                                                                              error:&jsonError];
        if (!jsonError && [jsonResponse isKindOfClass:[NSDictionary class]])
        {
            NSDictionary* trackInfo = (NSDictionary*)jsonResponse;
            NSString* title = [trackInfo objectForKey:@"title"];
            NSString* author = [[trackInfo objectForKey:@"user"] objectForKey:@"username"];
            NSString* genre = [trackInfo objectForKey:@"genre"];
            if (genre == nil) {
                genre = @"";
            }
            
            NSArray* tokens = [title componentsSeparatedByString:@"-"];
            if ([tokens count] > 1) {
                author = [tokens objectAtIndex:0];
                title = [tokens objectAtIndex:1];
            }
            
            [self updateAttr:title :author :genre];
            downloadQueue = [[NSMutableDictionary alloc] init];
            
            NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
            NSString* directory = [settings stringForKey:@"downloadFolder"];
            if ([settings boolForKey:@"authorFolder"])
                directory = [directory stringByAppendingString:author];
            
            NSFileManager* fileManager = [[NSFileManager alloc] init];
            BOOL isDirectory;
            if (![fileManager fileExistsAtPath:directory isDirectory:&isDirectory])
            {
                NSError* error;
                [fileManager createDirectoryAtPath:directory
                       withIntermediateDirectories:TRUE attributes:nil error:&error];
                if (error != nil)
                {
                    // There was an error creating the directory
                    NSLog(@"There was an error creating the music directory! Make sure the application is being run with proper permissions!");
                }
            }
            
            NSString* streamUrl = [NSString stringWithFormat:@"%@?client_id=%@", [trackInfo objectForKey:@"stream_url"], clientId];
            NSString* artworkUrl = [trackInfo objectForKey:@"artwork_url"];
            if (artworkUrl == nil)
                artworkUrl = [[trackInfo objectForKey:@"user"] objectForKey:@"avatar_url"];
            [downloadQueue setObject:[NSString stringWithFormat:@"%@\%@.mp3", directory, [Sound getFileName:title]] forKey:streamUrl];
            [downloadQueue setObject:[NSString stringWithFormat:@"%@\%@.jpg", NSTemporaryDirectory(), [Sound getFileName:title]] forKey:artworkUrl];
            
            while([downloadQueue count])
            {
                NSEnumerator* itr = [downloadQueue keyEnumerator];
                NSString* key = (NSString*)[itr nextObject];
                NSURL* url = [NSURL URLWithString:key];
                NSString* directory = [downloadQueue objectForKey:key];
                NSData* data = [NSData dataWithContentsOfURL:url];
                if (data)
                {
                    [data writeToFile:directory atomically:YES];
                }
                [downloadQueue removeObjectForKey:key];
            }
            [self packageAndDeploy];
        } else {
            NSLog(@"There was an error parsing the returned information from SoundCloud");
        }

    }
}

-(void)packageAndDeploy
{
    [self update];
    [self addToiTunes];
    loading = NO;
}

+(NSString*)generateRandomString:(int)size
{
    NSString* alphabet = @"qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM0123456789";
    NSUInteger alphabetLength = [alphabet length];
    NSMutableString* s = [NSMutableString stringWithCapacity:size];
    for (NSUInteger i = 0U; i < size; i++)
    {
        u_int32_t r = arc4random() % alphabetLength;
        unichar c = [alphabet characterAtIndex:r];
        [s appendFormat:@"%C", c];
    }
    return (NSString*)s;
}

+(NSString *)getFileName:(NSString *)title
{
    NSCharacterSet* invalidCharacters = [NSCharacterSet characterSetWithCharactersInString:@"/\\?%*|\"<>"];
    return [title stringByTrimmingCharactersInSet:invalidCharacters];
}

-(void)update
{
    NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
    NSString* authorFolder = @"";
    if ([settings boolForKey:@"authorFolder"])
        authorFolder = Author;
    NSString* fileName = [Sound getFileName:Title];
    NSString* oldDirectory = [NSString stringWithFormat:@"%@%@\\", [settings stringForKey:@"downloadFolder"], authorFolder];
    NSString* file = [oldDirectory stringByAppendingFormat:@"%@.mp3", fileName];
    TagLib::MPEG::File audioFile([file UTF8String]);
    
    TagLib::ID3v2::Tag *tag = audioFile.ID3v2Tag(true);
    tag->setArtist([Author UTF8String]);
    tag->setTitle([Title UTF8String]);
    TagLib::ID3v2::AttachedPictureFrame *frame = new TagLib::ID3v2::AttachedPictureFrame;
    frame->setMimeType("image/jpeg");
    ImageFile imageFile([[NSString stringWithFormat:@"%@\%@.jpg", NSTemporaryDirectory(), [Sound getFileName:Title]] UTF8String]);
    frame->setPicture(imageFile.data());
    
    tag->addFrame(frame);
    audioFile.save();
}
@end
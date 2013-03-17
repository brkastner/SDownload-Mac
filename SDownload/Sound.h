//
//  Sound.h
//  SDownload
//
//  Created by Christian Nilsen on 3/16/13.
//  Copyright (c) 2013 Brennan Kastner. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SoundCloudAPI/SCAPI.h>
#import "TagLibAmalgam.h"

typedef enum
{
    Nothing = 0,
    Copy = 1,
    Move = 2
} iTunesTransfer;

@interface Sound : NSObject
{
    @public
    NSString* Title;
    NSString* Author;
    NSString* Genre;
    bool loading;
    
    @private
    NSMutableDictionary* downloadQueue;
}

-(id)init;
-(id)updateAttr:(NSString*)title :(NSString*)author :(NSString*)genre;
-(void)addToiTunes;
-(void)update;
-(void)loadURL:(id)obj;
-(void)download;
-(void)packageAndDeploy;


+(NSString*)generateRandomString:(int)size;
+(NSString*)getFileName:(NSString*)title;
@end

class ImageFile : public TagLib::File
{
public:
    ImageFile(const char *file) : TagLib::File(file)
    {
        
    }
    
    TagLib::ByteVector data()
    {
        return readBlock(length());
    }
    
    
private:
    virtual TagLib::Tag *tag() const { return 0; }
    virtual TagLib::AudioProperties *audioProperties() const { return 0; }
    virtual bool save() { return false; }
};

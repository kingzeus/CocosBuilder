//
//  ResourceManagerSearch.m
//  CocosBuilder
//
//  Created by Higgx on 12/13/13.
//
//

#import "ResourceManagerSearch.h"
#import "CocosBuilderAppDelegate.h"
#import "ResourceManager.h"

@implementation ResourceManagerSearch

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];
	
    // Drawing code here.
}

-(void)textDidChange:(NSNotification *)notification{
//    NSLog(@"%@",[self stringValue]);
    NSString* str = [self stringValue];
    if ([str isEqualToString:@""]) {
        [[CocosBuilderAppDelegate appDelegate] setResType:kCCBResTypeNone];
    }else{
        int type = kCCBResTypeNone;
        
        NSArray* arr = [str componentsSeparatedByString:@" "];
        if (arr.count>1) {
            if ([[arr objectAtIndex:0] isEqualToString:@"ccb"]) {
                type = kCCBResTypeCCBFile;
            }
            if ([[arr objectAtIndex:0] isEqualToString:@"img"]) {
                type = kCCBResTypeImage;
            }
            arr = [arr subarrayWithRange:NSMakeRange(1, arr.count-1)];
            str = [arr componentsJoinedByString:@" "];
        }
        
        ResourceManager* ma = [CocosBuilderAppDelegate appDelegate].resManager;
        RMDirectory* rmd = [[ma activeDirectories] objectAtIndex:0];
        [rmd.searches removeAllObjects];
        [self search:rmd key:str type:type array:rmd.searches];
        [[CocosBuilderAppDelegate appDelegate] setResType:kCCBResTypeSearch];
    }
}

-(void)search:(RMDirectory*)dir key:(NSString*)key type:(int)type array:(NSMutableArray*)array{
    NSArray *arr = [dir resourcesForType:type];
    for (RMResource* res in arr) {
        if (res.type == kCCBResTypeDirectory) {
            RMDirectory* data = res.data;
            [self search:data key:key type:type array:array];
        }else{
            NSString* str1 = [[[res.filePath lastPathComponent] lowercaseString] substringToIndex:MIN([res.filePath lastPathComponent].length, [key length])];
            if ([str1 isEqualToString:key]) {
                RMResource* sres = [[[RMResource alloc]init] autorelease];
                sres.filePath = res.filePath;
                sres.modifiedTime = res.modifiedTime;
                sres.touched = res.touched;
                sres.type = res.type;
                if (res.data!=nil) {
                    if ([res.data isKindOfClass:[RMSpriteFrame class]]) {
                        RMSpriteFrame* sp = res.data;
                        RMSpriteFrame* ssp = [[[RMSpriteFrame alloc]init] autorelease];
                        ssp.spriteSheetFile = sp.spriteSheetFile;
                        ssp.spriteFrameName = sp.spriteFrameName;
                        sres.data = ssp;
                    }
                    if ([res.data isKindOfClass:[RMAnimation class]]) {
                        RMAnimation* sp = res.data;
                        RMAnimation* ssp = [[[RMAnimation alloc]init] autorelease];
                        ssp.animationFile = sp.animationFile;
                        ssp.animationName = sp.animationName;
                        sres.data = ssp;
                    }
                }
                [array addObject:sres];
            }

        }
    }
}

@end

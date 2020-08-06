//
//  NSData+Extensional.m
//  IMSDK
//
//  Created by 周进 on 2020/8/6.
//

#import "NSData+Extensional.h"

@implementation NSData (Extensional)

- (NSString*)byteSize;
{
    return [NSByteCountFormatter stringFromByteCount:self.length countStyle:NSByteCountFormatterCountStyleFile];
}

- (NSData*)getSubDataWithRange:(NSRange)range
{
    if (range.location >= [self length])
    {
        //开始的位置已越界，返回空
        return nil;
    }
    if ((range.location+range.length)>[self length]) {
        return [self subdataWithRange:NSMakeRange(range.location, [self length]-range.location)];
    }
    else
    {
        return [self subdataWithRange:range];
    }
    return nil;
}

@end

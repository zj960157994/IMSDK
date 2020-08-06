//
//  NSData+Extensional.h
//  IMSDK
//
//  Created by 周进 on 2020/8/6.
//

#import <Foundation/Foundation.h>


@interface NSData (Extensional)

- (NSString*)byteSize;

- (NSData*)getSubDataWithRange:(NSRange)range;

@end


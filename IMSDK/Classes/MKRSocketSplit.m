//
//  MKRSocketSplit.m
//  MaoKRadioPlayer
//
//  Created by 周进 on 2019/7/13.
//  Copyright © 2019 Muzen. All rights reserved.
//

#import "MKRSocketSplit.h"

@implementation MKRSocketSplit


+(MKRSocketSplit *)dataSplit:(CHead)head pack:(CCommunicationPack)pack body:(GPBMessage *)body{
    MKRSocketSplit *split = [[MKRSocketSplit alloc] init];
    split.header = head;
    split.communPack = pack;
    split.body = body;
    return split;
}

-(id)copyWithZone:(NSZone *)zone{
    
    MKRSocketSplit *split = [MKRSocketSplit new];
    split.header = self.header;
    split.body = self.body;
    split.communPack = self.communPack;
    
    return split;
    
}

+(MKRSocketSplit *)convertFrom:(MKRMessageData *)message{
    
    MKRSocketSplit *split = [MKRSocketSplit new];
    split.header = [message ntoh_term_head:message.header];
    split.body = message.body;
    split.communPack = message.communPack;
    return split;
}

@end

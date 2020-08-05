//
//  MKRSocketSplit.h
//  MaoKRadioPlayer
//
//  Created by 周进 on 2019/7/13.
//  Copyright © 2019 Muzen. All rights reserved.
//

#import <Foundation/Foundation.h>

//MARK: 数据拆分
@interface MKRSocketSplit : NSObject<NSCopying>
//请求通讯头
@property (nonatomic,assign) CCommunicationPack communPack;
//请求包头
@property (nonatomic,assign) CHead header;

@property (nonatomic,strong) GPBMessage *body;

+(MKRSocketSplit *)dataSplit:(CHead)head pack:(CCommunicationPack)pack body:(GPBMessage *)body;

+(MKRSocketSplit *)convertFrom:(MKRMessageData *)message;
@end

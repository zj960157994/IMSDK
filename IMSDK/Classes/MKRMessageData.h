//
//  MKRMessageData.h
//  MaoKingRadioPlayer
//
//  Created by 周进 on 2020/7/13.
//  Copyright © 2020 MaoKing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MKRMessageData : NSObject

//请求通讯头
@property (nonatomic,assign) CCommunicationPack communPack;
//请求包头
@property (nonatomic,assign) CHead header;
//认证才需要
@property (nonatomic,assign) CBind bindCmd;

@property (nonatomic,strong) GPBMessage *body;

@property (nonatomic,strong) NSMutableData *requestData;



+(CCommunicationPack)ntoh_term_pack:(CCommunicationPack)pack;
+(CHead)ntoh_term_head:(CHead)head;
-(CHead)ntoh_term_head:(CHead)head;

+(MKRMessageData *)createMsgDataWith:(CCommunicationPack)pack header:(CHead)header body:(id)body;
//MARK: 创建方法
+(MKRMessageData *)qucickCreate:(CMsgType)msgtype gpb:(GPBMessage *)gpb toUser:(NSInteger)toUserId deviceId:(NSString *)device;
+(MKRMessageData *)qucickCreate:(CMsgType)msgtype gpb:(GPBMessage *)gpb toUser:(NSInteger)toUserId fromid:(NSInteger)fromId deviceId:(NSString *)device;
//MARK: 网络主机转换成主机字节的数据包体
+(MKRMessageData *)messageNetToHost:(CCommunicationPack)pack chead:(CHead)header body:(GPBMessage *)body;
@end



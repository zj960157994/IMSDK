//
//  MKRMessageData.m
//  MaoKingRadioPlayer
//
//  Created by 周进 on 2020/7/13.
//  Copyright © 2020 MaoKing. All rights reserved.
//

#import "MKRMessageData.h"
@interface MKRMessageData ()<NSMutableCopying>

@end




@implementation MKRMessageData

- (instancetype)init
{
    self = [super init];
    if (self) {
        _requestData = [NSMutableData data];
    }
    return self;
}
-(id)mutableCopyWithZone:(NSZone *)zone{
    MKRMessageData* newObj = [[[self class] allocWithZone:zone] init];
    newObj.communPack = self.communPack;
    newObj.header = self.header;
    newObj.body = self.body;
    newObj.requestData = self.requestData;
    return newObj;
}


- (void)setCommunPack:(CCommunicationPack)communPack{
    _communPack = communPack;
    communPack = [self hton_term_pack:communPack];
    NSData *packData = [NSData dataWithBytes:&communPack length:sizeof(CCommunicationPack)];
    [self.requestData appendData:packData];
}
- (void)setHeader:(CHead)header{
    _header = header;
    header = [self hton_term_head:header];
    NSData *headerData = [NSData dataWithBytes:&header length:sizeof(CHead)];
    [self.requestData appendData:headerData];
}

- (void)setBindCmd:(CBind)bindCmd{
    _bindCmd = bindCmd;
     NSData *bindData = [NSData dataWithBytes:&bindCmd length:sizeof(CBind)];
    [self.requestData appendData:bindData];
}

- (void)setBody:(GPBMessage *)body{
    _body = body;
    [self.requestData appendData:[body data]];
}

-(CCommunicationPack)hton_term_pack:(CCommunicationPack)pack{
    pack.msgLen = htons(pack.msgLen);
    return pack;
}
-(CCommunicationPack)ntoh_term_pack:(CCommunicationPack)pack{
    pack.msgLen = ntohs(pack.msgLen);
    return pack;
}
+(CCommunicationPack)ntoh_term_pack:(CCommunicationPack)pack{
    pack.msgLen = ntohs(pack.msgLen);
    return pack;
}
-(CHead)hton_term_head:(CHead)head{
    CHead tempHead;
    tempHead.len = htons(head.len);
    tempHead.fromUid = htonl(head.fromUid);
    tempHead.toUid = htonl(head.toUid);
    tempHead.timeStamp = htonl64(head.timeStamp);
    tempHead.mqChanId = htons(head.mqChanId);
    tempHead.mqTag = htonl64(head.mqTag);
    tempHead.ecodeType = head.ecodeType;
    tempHead.msgType = head.msgType;
    memcpy(tempHead.deviceId, head.deviceId, 32);
    return tempHead;
}

-(CHead)ntoh_term_head:(CHead)head
{
    head.len = ntohs(head.len);
    head.fromUid = ntohl(head.fromUid);
    head.toUid = ntohl(head.toUid);
    head.timeStamp = ntohl64(head.timeStamp);
    head.mqChanId = ntohs(head.mqChanId);
    head.mqTag = ntohl64(head.mqTag);
    return head;
}
+(CHead)ntoh_term_head:(CHead)head{
    CHead tempHead;
    tempHead.len = htons(head.len);
    tempHead.fromUid = htonl(head.fromUid);
    tempHead.toUid = htonl(head.toUid);
    tempHead.timeStamp = htonl64(head.timeStamp);
    tempHead.mqChanId = htons(head.mqChanId);
    tempHead.mqTag = htonl64(head.mqTag);
    tempHead.ecodeType = head.ecodeType;
    tempHead.msgType = head.msgType;
    memcpy(tempHead.deviceId, head.deviceId, 32);
    return tempHead;
}


//MARK: 创建消息体的方法
+ (MKRMessageData *)createMsgDataWith:(CCommunicationPack)pack header:(CHead)header body:(id)body{
    MKRMessageData *msg = [[MKRMessageData alloc] init];
    msg.communPack = pack;
    msg.header = header;
    msg.body = body;
    return msg;
}

//MARK: 创建消息体
+(MKRMessageData *)qucickCreate:(CMsgType)msgtype gpb:(GPBMessage *)gpb toUser:(NSInteger)toUserId deviceId:(NSString *)device{
    MKRMessageData *msg = [[MKRMessageData alloc] init];
    unsigned short nlens = sizeof(CCommunicationPack)+sizeof(CHead)+[gpb data].length;
        CCommunicationPack pack = {
            nlens,
            msgtype,
            0,
            0
        };
        msg.communPack = pack;
        unsigned short hlen = sizeof(CHead)+[gpb data].length;
        CHead header = {
            1,//0 struct 1 protobuf
            msgtype,
            hlen,
            myUserId,
            (unsigned int)toUserId,
            [[NSDate date] timeIntervalSince1970]*1000,
            "0",
            0,
            0
        };
        memcpy(header.deviceId, [device UTF8String], DEVICEID_MAXLEN);
        msg.header = header;
        NSLog(@"发送%d消息时间:%llu",msgtype,header.timeStamp);
        msg.body = gpb;
        return msg;
}
+(MKRMessageData *)qucickCreate:(CMsgType)msgtype gpb:(GPBMessage *)gpb toUser:(NSInteger)toUserId fromid:(NSInteger)fromId deviceId:(NSString *)device{
    MKRMessageData *msg = [[MKRMessageData alloc] init];
    unsigned short nlens = sizeof(CCommunicationPack)+sizeof(CHead)+[gpb data].length;
        CCommunicationPack pack = {
            nlens,
            msgtype,
            0,
            0
        };
        msg.communPack = pack;
        unsigned short hlen = sizeof(CHead)+[gpb data].length;
        CHead header = {
            1,//0 struct 1 protobuf
            msgtype,
            hlen,
            (unsigned int)fromId,
            (unsigned int)toUserId,
            [[NSDate date] timeIntervalSince1970]*1000,
            "0",
            0,
            0
        };
        memcpy(header.deviceId, [device UTF8String], DEVICEID_MAXLEN);
        msg.header = header;
        NSLog(@"发送%d消息时间:%llu",msgtype,header.timeStamp);
        msg.body = gpb;
        return msg;
}
//MARK: 网络主机转换成主机字节的数据包体
+(MKRMessageData *)messageNetToHost:(CCommunicationPack)pack chead:(CHead)header body:(GPBMessage *)body{
    MKRMessageData *data = [[MKRMessageData alloc] init];
    data.communPack = pack;
    data.header = header;
    data.body = body;
    return data;
}



@end

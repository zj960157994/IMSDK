//
//  MKRChatRoomMsgModel.m
//  Leigod
//
//  Created by 周进 on 2020/8/3.
//  Copyright © 2020 leigod. All rights reserved.
//

#import "MKRChatMessageModel.h"
#import "ChatMessageCell.h"
@interface MKRChatMessageModel()<MKRDBProtocol>


@end

@implementation MKRChatMessageModel

- (void)setContent:(NSString *)content{
    _content = content;
    _cellHeight = [ChatMessageCell cellHeightWithContent:content];
}

- (void)setTId:(uint64_t)tId{
    _tId = tId;
    _uniqueCode = PTString(@"%d%lld%d",_fromUid,(int)_tId,_toUid);
}

+(NSString *)customPrimaryKey{
    return @"uniqueCode";
}


+(MKRChatMessageModel *)convertWithMessageData:(MKRMessageData *)data type:(CMsgType)type{
    MKRMessageData *newData = [data mutableCopy];
    
    MKRChatMessageModel *chat = [[MKRChatMessageModel alloc] init];
    chat.ecodeType = newData.header.ecodeType;
    chat.msgType = newData.header.msgType;
    chat.len = newData.header.len;
    chat.fromUid = newData.header.fromUid;
    chat.toUid = newData.header.toUid;
    chat.timeStamp =  newData.header.timeStamp;
    chat.deviceId = [NSString stringWithCString:newData.header.deviceId encoding:NSUTF8StringEncoding];
    chat.mqChanId = newData.header.mqChanId;
    chat.mqTag = newData.header.mqTag;
    
    if (type == E_CMD_P2PMSG) {
        CP2PMsg *message = (CP2PMsg *)(newData.body);
        chat.direction = message.direction;
        chat.status = message.status;
        chat.msgContType = message.msgContType;
        chat.tId = message.tId;
        chat.sequence = message.sequence;
        chat.prevMsgId = message.prevMsgId;
        chat.nextMsgId = message.nextMsgId;
        chat.createTime = message.createTime;
        chat.msgId = message.msgId;
        chat.content = message.content;
        chat.clientFileId = message.clientFileId;
        chat.sliceId = message.sliceId;
        chat.sliceEnd = message.sliceEnd;
        chat.ackSequence = message.ackSequence;
    }
    
    if (type == E_CMD_CHATROOMMSG) {
        CChatRoomMsg *RoomMsg = (CChatRoomMsg *)(newData.body);
        chat.chatroomId = RoomMsg.chatroomId;
        chat.status = RoomMsg.status;
        chat.msgContType = RoomMsg.msgContType;
        chat.tId = RoomMsg.tId;
        chat.prevMsgId = RoomMsg.prevMsgId;
        chat.nextMsgId = RoomMsg.nextMsgId;
        chat.createTime = RoomMsg.createTime;
        chat.msgId = RoomMsg.msgId;
        chat.content = RoomMsg.content;
        chat.clientFileId = RoomMsg.clientFileId;
        chat.sliceId = RoomMsg.sliceId;
        chat.sliceEnd = RoomMsg.sliceEnd;
        chat.ackSequence = RoomMsg.ackSequence;
        chat.communityId = RoomMsg.communityId;
    }
    
    return chat;
    
}

+(MKRChatMessageModel *)convertWithSplit:(MKRSocketSplit *)data type:(CMsgType)type{
    
    MKRChatMessageModel *chat = [[MKRChatMessageModel alloc] init];
    chat.ecodeType = data.header.ecodeType;
    chat.msgType = data.header.msgType;
    chat.len = data.header.len;
    chat.fromUid = data.header.fromUid;
    chat.toUid = data.header.toUid;
    chat.timeStamp =  data.header.timeStamp;
    chat.deviceId = [NSString stringWithCString:data.header.deviceId encoding:NSUTF8StringEncoding];
    chat.mqChanId = data.header.mqChanId;
    chat.mqTag = data.header.mqTag;
    
    if (type == E_CMD_P2PMSG) {
        CP2PMsg *message = (CP2PMsg *)(data.body);
        chat.direction = message.direction;
        chat.status = message.status;
        chat.msgContType = message.msgContType;
        chat.tId = message.tId;
        chat.sequence = message.sequence;
        chat.prevMsgId = message.prevMsgId;
        chat.nextMsgId = message.nextMsgId;
        chat.createTime = message.createTime;
        chat.msgId = message.msgId;
        chat.content = message.content;
        chat.clientFileId = message.clientFileId;
        chat.sliceId = message.sliceId;
        chat.sliceEnd = message.sliceEnd;
        chat.ackSequence = message.ackSequence;
    }
    
    if (type == E_CMD_CHATROOMMSG) {
        CChatRoomMsg *RoomMsg = (CChatRoomMsg *)(data.body);
        chat.chatroomId = RoomMsg.chatroomId;
        chat.status = RoomMsg.status;
        chat.msgContType = RoomMsg.msgContType;
        chat.tId = RoomMsg.tId;
        chat.prevMsgId = RoomMsg.prevMsgId;
        chat.nextMsgId = RoomMsg.nextMsgId;
        chat.createTime = RoomMsg.createTime;
        chat.msgId = RoomMsg.msgId;
        chat.content = RoomMsg.content;
        chat.clientFileId = RoomMsg.clientFileId;
        chat.sliceId = RoomMsg.sliceId;
        chat.sliceEnd = RoomMsg.sliceEnd;
        chat.ackSequence = RoomMsg.ackSequence;
        chat.communityId = RoomMsg.communityId;
    }
    
    return chat;

}
//MARK: 通过实践戳查询记录
+ (MKRChatMessageModel *)findWithTimeStamp:(NSInteger)timeStamp{
       
    NSString *sql = [NSString stringWithFormat: @"where timestamp = '%ld'",timeStamp];
    NSArray *firstData = [self findObjectsByCondition:sql];
    if (firstData.count>0) {
        return [firstData firstObject];
    }
    return nil;
}

//MARK: 更新某条记录的状态
+(BOOL)UpdateMessageStatus:(MKRChatMessageModel *)message status:(MessageSentStatus)status{
    [message setStatus:(uint32_t)status];
    return [message update];
}

//MARK: 更新msgid的发送值
+(BOOL)UpdateMessageStatus:(MKRChatMessageModel *)message msgId:(NSString *)msgId{
    [message setMsgId:msgId];
    return [message update];
}

//MARK: 查询大于某一条时间戳的消息记录
+(NSArray *)getMessageWithTid:(NSInteger)tid{
    NSString *sql = [NSString stringWithFormat: @"where tid > '%ld'",tid];
    NSArray *newMesssage = [self findObjectsByCondition:sql];
    if (newMesssage.count>0) {
        return newMesssage;
    }
    return @[];
}

//MARK: 获取最新的20条数据
+(NSArray *)getlastTwentyData{
    NSString *sql = [NSString stringWithFormat: @"LIMIT 0,%d",MessageDataListLength];
    NSArray *newMesssage = [self findObjectsByCondition:sql];
    if (newMesssage.count>0) {
        return newMesssage;
    }
    return @[];
}
//MARK: 

@end

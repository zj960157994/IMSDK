//
//  MKRChatRoomMsgModel.h
//  Leigod
//
//  Created by 周进 on 2020/8/3.
//  Copyright © 2020 leigod. All rights reserved.
//

#import "MKRChatMessageModel.h"
#import "MKRDBModel.h"

/*
 消息发送状态
 */

typedef NS_OPTIONS(NSUInteger, MessageSentStatus) {
    MessageSentStatusSending=0,//正在发送
    MessageSentStatusUnRead, //未读
    MessageSentStatusReaded, //已读
    MessageSentStatusReject, //拒收
    MessageSentStatusUnknow, //未知
};

@interface MKRChatMessageModel : MKRDBModel
//MARK: *******************************数据消息头字段
// 0结构体，1 protobuf, 2 json, 3 绑定的结构体
@property (nonatomic,assign) unsigned char ecodeType;
 // CMsgType
@property (nonatomic,assign) unsigned char msgType;
//消息长度
@property (nonatomic,assign) unsigned short len;
//发送者 发送者id
@property (nonatomic,assign) unsigned int fromUid;
// 接受者id 根据type判断是userId还是groupId
@property (nonatomic,assign) unsigned int toUid;
// 时间戳
@property (nonatomic,assign) unsigned long long timeStamp;
//设备ID
@property (nonatomic,copy) NSString *deviceId;
//tag
@property (nonatomic,assign) unsigned long long mqTag;
//chaid
@property (nonatomic,assign) unsigned short mqChanId;


//MARK: ********************************数据消息体的字段

@property (nonatomic,assign) uint32_t direction;
//聊天室ID
@property (nonatomic,assign) uint32_t chatroomId;
// 状态  0发送中 1未读 2已读 3拒收消息
@property (nonatomic,assign) uint32_t status;
// 消息内容类型  文字/图片/语音等
@property (nonatomic,assign) int msgContType;
// 客户端时间戳
@property (nonatomic,assign) uint64_t tId;
// 客户端序列
@property (nonatomic,assign) uint32_t sequence;
// 上一条消息id
@property (nonatomic,copy) NSString *prevMsgId;
// 下一条消息id
@property (nonatomic,copy) NSString *nextMsgId;
// 客户端发送时间
@property (nonatomic,assign) uint64_t createTime;
// 消息id     发送的时候为空
@property (nonatomic,copy) NSString *msgId;
// 消息内容
@property (nonatomic,copy) NSString *content;
// 上传文件的标识，文件分包用
@property (nonatomic,assign) uint32_t clientFileId;
// 包序列
@property (nonatomic,assign) uint32_t sliceId;
// 包结束标识
@property (nonatomic,assign) uint32_t sliceEnd;
// 确认序列号
@property (nonatomic,assign) uint64_t ackSequence;
//社区ID
@property (nonatomic,assign) uint32_t communityId;
//唯一值
@property (nonatomic,copy) NSString *uniqueCode;
//cell 显示的高度
@property (nonatomic,assign,readonly) CGFloat cellHeight;

//MARK: 数据转换
+(MKRChatMessageModel *)convertWithMessageData:(MKRMessageData *)data type:(CMsgType)type;
+(MKRChatMessageModel *)convertWithSplit:(MKRSocketSplit *)data type:(CMsgType)type;

//MARK: 通过timestap 查询消息记录
+(MKRChatMessageModel *)findWithTimeStamp:(NSInteger)timeStamp;
//MARK: 更新某条记录的状态
+(BOOL)UpdateMessageStatus:(MKRChatMessageModel *)message status:(MessageSentStatus)status;
//MARK: 更新msgid的发送值
+(BOOL)UpdateMessageStatus:(MKRChatMessageModel *)message msgId:(NSString *)msgId;

//MARK: 查询大于某一条时间戳的消息记录
+(NSArray *)getMessageWithTid:(NSInteger)tid;
//MARK: 获取最新的20条数据
+(NSArray *)getlastTwentyData;
@end


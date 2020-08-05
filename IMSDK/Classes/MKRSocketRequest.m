//
//  MKRSocketRequest.m
//  MaoKRadioPlayer正式环境
//
//  Created by 周进 on 2019/4/25.
//  Copyright © 2019 Muzen. All rights reserved.
//

#import "MKRSocketRequest.h"
#import "MKRChatMessageModel.h"
#import <objc/runtime.h>

@interface MKRSocketRequest()

@end

@implementation MKRSocketRequest

- (instancetype)init
{
    self = [super init];
    if (self) {
        _messageData = [[MKRMessageData alloc] init];
        _subject = [[RACSubject alloc] init];
        
    }
    return self;
}

//MARK: 发送请求
- (void)startRequest{

     [[MKRDealData shareInstance] sendRequest:self];
    
}



//MARK: 监听服务器端消息并发送ack
-(void)responseToserver:(CMsgType)msgtype gpbmsg:(GPBMessage *)msg toUserId:(NSInteger)userId{
    //响应某个ack给服务端
    //1.快速创建请求体
    MKRSocketRequest *request = [[MKRSocketRequest alloc] init];
    //2.创建消息体
    MKRMessageData *data = [MKRMessageData qucickCreate:msgtype gpb:msg toUser:0 deviceId:0];
    //3.设置消息体
    request.messageData = data;
    [request startRequest];

}
//MARK: 发送p2p消息
+(void)sendP2pRequest:(NSString *)content toUserId:(NSInteger)toUserId{
       CP2PMsg *p2pmsg = [CP2PMsg message];
        
        p2pmsg.direction = (uint32_t)0;
        p2pmsg.status = (uint32_t)0;
        p2pmsg.msgContType = MsgContentType_ETextMsgcontentType;
        p2pmsg.tId = (uint64_t)([[NSDate date] timeIntervalSince1970]*1000);
        p2pmsg.sequence = (uint32_t)0;
        p2pmsg.prevMsgId = @"0";
        p2pmsg.nextMsgId = @"0";
        p2pmsg.createTime = (uint64_t)([[NSDate date] timeIntervalSince1970]*1000);
        p2pmsg.msgId = @"";
        p2pmsg.content = content;
        p2pmsg.clientFileId = (uint32_t)0;
        p2pmsg.sliceId = (uint32_t)0;
        p2pmsg.sliceEnd = (uint32_t)0;
        p2pmsg.ackSequence = 0;

        MKRMessageData *data =  [MKRMessageData qucickCreate:E_CMD_P2PMSG gpb:p2pmsg toUser:toUserId deviceId:deviceIds];
        MKRSocketRequest *req = [[MKRSocketRequest alloc] init];
        req.messageData= data;
        [req startRequest];
}

//MARK: 发送聊天室消息
+ (MKRChatMessageModel *)sendChatRoomMessage:(NSString *)content toChatRoomId:(NSInteger)chatRoomId{
    
    CChatRoomMsg *roomMsg = [CChatRoomMsg message];
    roomMsg.chatroomId = (uint32_t)chatRoomId;
    roomMsg.status = 0;
    roomMsg.msgContType = MsgContentType_ETextMsgcontentType;
    roomMsg.tId = (uint64_t)([[NSDate date] timeIntervalSince1970]*1000);
    roomMsg.prevMsgId = @"0";
    roomMsg.nextMsgId = @"0";
    roomMsg.createTime = (uint64_t)([[NSDate date] timeIntervalSince1970]*1000);
    roomMsg.msgId = @"";
    roomMsg.content = content;
    roomMsg.clientFileId = (uint32_t)0;
    roomMsg.sliceId = (uint32_t)0;
    roomMsg.sliceEnd = (uint32_t)0;
    roomMsg.ackSequence = 0;
    roomMsg.communityId = 0;
    MKRMessageData *data =  [MKRMessageData qucickCreate:E_CMD_CHATROOMMSG gpb:roomMsg toUser:chatRoomId deviceId:deviceIds];
    MKRSocketRequest *req = [[MKRSocketRequest alloc] init];
    req.messageData = data;
    MKRChatMessageModel *chatMsg = [MKRChatMessageModel convertWithMessageData:data type:E_CMD_CHATROOMMSG];
    if([chatMsg save]){
        [req startRequest];
    }
    return chatMsg;
}
//MARK: 发送用户聊天室操作
+(void)sendUserActionMessage:(NSString *)content{
    CChatRoomUserAction *action = [[CChatRoomUserAction alloc] init];
    action.userActionType = CChatRoomUserActionType_ChatRoomUserActionEnter;
    action.extend = 10;
    action.chatroomId = ChatRoomId;
    action.msgId = @"";
    action.nickName = @"ligin";
    action.createTime = (uint64_t)([[NSDate date] timeIntervalSince1970]*1000);
    action.tId = (uint64_t)([[NSDate date] timeIntervalSince1970]*1000);
    action.ackSequence = (uint32_t)0;
    action.ackSequence = 0;
    action.communityId = 0;
    MKRMessageData *data =  [MKRMessageData qucickCreate:E_CMD_CHATROOM_USERACTION gpb:action toUser:ChatRoomId deviceId:deviceIds];
    MKRSocketRequest *req = [[MKRSocketRequest alloc] init];
    req.messageData = data;
    [req startRequest];
}

//MARK: 发送聊天室心跳
+(void)sendChatRoomHearBeat{
    CChatRoomHeart *heart = [CChatRoomHeart message];
    heart.communityId = 0;
    MKRMessageData *data =  [MKRMessageData qucickCreate:E_CMD_CHATROOM_USERHEART gpb:heart toUser:ChatRoomId deviceId:deviceIds];
    MKRSocketRequest *req = [[MKRSocketRequest alloc] init];
    req.messageData = data;
    [req startRequest];
}


//MARK: 聊天室设置
-(void)sendChatRoomSet{
    CChatRoomSettings *setting = [CChatRoomSettings message];
    setting.settingContent = @"";
    setting.chatroomId = ChatRoomId;
    setting.msgId = @"";
    setting.ackSequence = 0;
    MKRMessageData *data =  [MKRMessageData qucickCreate:E_CMD_CHATROOM_SETTINGS gpb:setting toUser:ChatRoomId deviceId:deviceIds];
    MKRSocketRequest *req = [[MKRSocketRequest alloc] init];
    req.messageData = data;
    [req startRequest];
}

//MARK: 聊天室用户列表
-(void)sendChatUserList{
    
    CChatRoomUserList *userList = [CChatRoomUserList message];
    userList.sliceId = 0;
    MKRMessageData *data =  [MKRMessageData qucickCreate:E_CMD_CHATROOM_USERLIST gpb:userList toUser:ChatRoomId deviceId:deviceIds];
    MKRSocketRequest *req = [[MKRSocketRequest alloc] init];
    req.messageData = data;
    [req startRequest];
    
}

//MARK: 社区操作
-(void)sendCommunityAction{
    CCommunityUserAction *userAction = [[CCommunityUserAction alloc] init];
    userAction.userActionType = CChatRoomUserActionType_ChatRoomUserActionEnter;
    userAction.chatroomId = ChatRoomId;
    userAction.msgId = @"";
    userAction.createTime = (uint64_t)([[NSDate date] timeIntervalSince1970]*1000);
    userAction.createTime = (uint64_t)([[NSDate date] timeIntervalSince1970]*1000);
    userAction.tId = (uint64_t)([[NSDate date] timeIntervalSince1970]*1000);
    userAction.ackSequence = (uint32_t)0;
    userAction.actionedId = 0;
    userAction.communityId = 0;
    userAction.communityName = @"";
    MKRMessageData *data =  [MKRMessageData qucickCreate:E_CMD_COMMUNITY_USERACTION gpb:userAction toUser:ChatRoomId deviceId:deviceIds];
    MKRSocketRequest *req = [[MKRSocketRequest alloc] init];
    req.messageData = data;
    [req startRequest];
    
}
//MARK:发送pgc消息
-(void)sendPgcDynamic{
    
    CPGCDynamicMsg *message = [[CPGCDynamicMsg alloc] init];
    message.userId = 10;
    message.publishUid = 0;
    message.eventSrcId = 0;
    message.eventSrcType = 1;
    message.msgId = @"";
    message.actionType = 0;
    message.tId = (uint64_t)([[NSDate date] timeIntervalSince1970]*1000);
    message.ackSequence = 0;
    message.createTime = (uint64_t)([[NSDate date] timeIntervalSince1970]*1000);
    MKRMessageData *data =  [MKRMessageData qucickCreate:E_CMD_PGC_DYNAMIC_MSG gpb:message toUser:ChatRoomId deviceId:deviceIds];
    MKRSocketRequest *req = [[MKRSocketRequest alloc] init];
    req.messageData = data;
    [req startRequest];
    
}

//MARK: 消息已经读取
-(void)sendMessageReaded:(MsgSessionType)sessionType{
    CMsgReaded *readed = [CMsgReaded message];
    readed.sessionType = sessionType;
    readed.tId = (uint64_t)([[NSDate date] timeIntervalSince1970]*1000);
    readed.msgId = @"";
    readed.ackSequence = 0;
    MKRMessageData *data =  [MKRMessageData qucickCreate:E_CMD_MSG_READED gpb:readed toUser:ChatRoomId deviceId:deviceIds];
    MKRSocketRequest *req = [[MKRSocketRequest alloc] init];
    req.messageData = data;
    [req startRequest];
}


//MARK: 机器人消息
-(void)sendRobotMessage:(MsgRobotType)robotType{
    
    CRobotMsgNotify *robot = [CRobotMsgNotify message];
    robot.subType = robotType;
    robot.msgId = @"";
    robot.notifyContent = @"";
    robot.ackSequence = 0;
    robot.tId = (uint64_t)([[NSDate date] timeIntervalSince1970]*1000);
    MKRMessageData *data =  [MKRMessageData qucickCreate:E_CMD_ROBOT_MSG_NOTIFY gpb:robot toUser:ChatRoomId deviceId:deviceIds];
    MKRSocketRequest *req = [[MKRSocketRequest alloc] init];
    req.messageData = data;
    [req startRequest];
}


//MARK: 请求消息映射protobuf
+(NSString *)convertFrom:(CMsgType)type{
    NSString *protobufStr = @"GPBMessage";
    switch (type) {
        case E_CMD_P2PMSG:
        {
            protobufStr = @"CP2PMsg";
        }
            break;
        case E_CMD_P2PMSGACK:
        {
            protobufStr = @"CMsgAck";
        }
            break;
        case E_CMD_CHATROOMMSG:
        {
            protobufStr = @"CChatRoomMsg";
        }
            break;
        case E_CMD_CHATROOMMSGACK:
        {
            protobufStr = @"CMsgAck";
        }
            break;
        case E_CMD_GROUPMSGACK:
        {
            protobufStr = @"CMsgAck";
        }
            break;
        case E_CMD_CHATROOM_SETTINGSACK:
        {
            protobufStr =@"CChatRoomSettingsAck";
        }
            break;
        case E_CMD_CHATROOM_USERLISTACK:
        {
            protobufStr = @"CChatRoomUserListAck";
        }
            break;
        case E_CMD_CHATROOM_USERACTION:
        {
            protobufStr = @"CChatRoomUserAction";
        }
        case E_CMD_CHATROOM_USERACTIONACK:
        {
            protobufStr = @"CChatRoomUserAction";
        }
            break;
        case E_CMD_COMMUNITY_USERACTIONACK:
        {
            protobufStr = @"CCommunityUserActionAck";
        }
            break;
        case E_CMD_PGC_DYNAMIC_MSGACK:
        {
            protobufStr = @"CPGCDynamicMsgAck";
        }
            break;
        case E_CMD_CHATROOM_USERHEARTACK:
        {
            protobufStr = @"CChatRoomHeartAck";
        }
            break;
        case E_CMD_MSG_READEDACK:
        {
            protobufStr = @"CMsgReadedAck";
        }
            break;
        case E_CMD_MSG_UNREAD_COUNTACK:
        {
            protobufStr = @"CMsgUnReadCountAck";
        }
            break;
        case E_CMD_ROBOT_MSG_NOTIFYACK:
        {
            protobufStr = @"CRobotMsgNotifyAck";
        }
            break;
        default:
            break;
    }
    return protobufStr;

}



- (void)dealloc{
    
}

@end

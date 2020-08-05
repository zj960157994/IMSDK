//
//  MKRReceiveResponse.m
//  Leigod
//
//  Created by 周进 on 2020/7/17.
//  Copyright © 2020 leigod. All rights reserved.
//

#import "MKRReceiveResponse.h"

@implementation MKRReceiveResponse

//MARK: 消息9类型接收返回10的response
+(void)p2pMsgResponseWithP2p:(MKRSocketSplit *)responseData{
       CP2PMsg *p2pmsg = (CP2PMsg *)(responseData.body);
       CMsgAck *ark = [CMsgAck message];

       ark.tId = p2pmsg.tId;
       ark.msgId = p2pmsg.msgId;
       ark.readedFlag = (uint32_t)0;
       ark.ackMsgType = (uint32_t)0;
       ark.chatroomId = (uint32_t)0;
       ark.communityId = (uint32_t)0;
       ark.ackSequence = p2pmsg.ackSequence;

    
       MKRMessageData *msgData =  [MKRMessageData qucickCreate:E_CMD_P2PMSGACK gpb:ark toUser:responseData.header.toUid fromid:responseData.header.fromUid deviceId:deviceIds];
       MKRSocketRequest *req = [[MKRSocketRequest alloc] init];
       req.messageData= msgData;
       [req startRequest];
}

//MARK: 收到聊天室是消息返回ack
+(void)chatRoomResponseWithRoomMsg:(MKRSocketSplit *)response{
    CChatRoomMsg *RoomMsg = (CChatRoomMsg *)(response.body);
    CMsgAck *ack = [CMsgAck message];

    ack.tId = RoomMsg.tId;
    ack.msgId = RoomMsg.msgId;
    ack.readedFlag = (uint32_t)0;
    ack.ackMsgType = (uint32_t)0;
    ack.chatroomId = (uint32_t)0;
    ack.communityId = (uint32_t)0;
    ack.ackSequence = RoomMsg.ackSequence;

    MKRMessageData *msgData =  [MKRMessageData qucickCreate:E_CMD_CHATROOMMSGACK gpb:ack toUser:RoomMsg.chatroomId fromid:myUserId deviceId:deviceIds];
    MKRSocketRequest *req = [[MKRSocketRequest alloc] init];
    req.messageData= msgData;
    [req startRequest];
}
//MARK: 响应用户操作ack
+(void)chatroomUserActionAckResponse:(MKRSocketSplit *)response{
    CChatRoomUserAction *action = (CChatRoomUserAction *)(response.body);
    CChatRoomUserActionAck *ack = [CChatRoomUserActionAck message];
    ack.tId = action.tId;
    ack.chatroomId = action.chatroomId;
    ack.communityId = action.communityId;
    ack.msgId = action.msgId;
    ack.ackSequence = action.ackSequence;
    ack.erroNo = 0;
    ack.actionedId = action.actionedId;
    
    MKRMessageData *msgData = [MKRMessageData qucickCreate:E_CMD_CHATROOM_USERACTION gpb:ack toUser:ChatRoomId fromid:myUserId deviceId:deviceIds];
    MKRSocketRequest *req = [[MKRSocketRequest alloc] init];
    req.messageData= msgData;
    [req startRequest];
}

//MARK: 收到聊天室用户列表ack
+(void)chatRoomUserListResponseWith:(MKRSocketSplit *)response{
    CChatRoomUserListAck *userlistAck = (CChatRoomUserListAck *)(response.body);
    NSInteger newUserslice = userlistAck.sliceId +1;
    if (userlistAck.sliceSums > newUserslice) {
        CChatRoomUserList *userList = [CChatRoomUserList message];
        userList.sliceId = (u_int32_t)newUserslice;
        MKRMessageData *data =  [MKRMessageData qucickCreate:E_CMD_CHATROOM_USERLIST gpb:userList toUser:ChatRoomId deviceId:deviceIds];
        MKRSocketRequest *req = [[MKRSocketRequest alloc] init];
        req.messageData = data;
        [req startRequest];
    }
}


//MARK: 收到pgc的消息
+(void)pgcResponseWith:(MKRSocketSplit *)response{
    CPGCDynamicMsg *userListack = (CPGCDynamicMsg *)(response.body);
    
    CPGCDynamicMsgAck *pgcMsg = [CPGCDynamicMsgAck message];
    pgcMsg.userId = myUserId;
    pgcMsg.publishUid = userListack.publishUid;
    pgcMsg.msgId = userListack.msgId;
    pgcMsg.readedFlag = 0;
    pgcMsg.tId = userListack.tId;
    pgcMsg.ackSequence = userListack.ackSequence;
    
    MKRMessageData *msgData =  [MKRMessageData qucickCreate:E_CMD_PGC_DYNAMIC_MSGACK gpb:pgcMsg toUser:0 fromid:response.header.fromUid deviceId:deviceIds];
    MKRSocketRequest *req = [[MKRSocketRequest alloc] init];
    req.messageData= msgData;
    [req startRequest];
}

//MARK: 消息已经读取
+(void)msgReadedResponseWith:(MKRSocketSplit *)response{
    
    CMsgReaded *readed = (CMsgReaded *)(response.body);
    
    CMsgReadedAck *ack = [CMsgReadedAck message];
    
    ack.sessionType = readed.sessionType;
    ack.tId = readed.tId;
    ack.ackSequence = readed.ackSequence;
    MKRMessageData *msgData =  [MKRMessageData qucickCreate:E_CMD_MSG_READEDACK gpb:ack toUser:0 fromid:response.header.fromUid deviceId:deviceIds];
    MKRSocketRequest *req = [[MKRSocketRequest alloc] init];
    req.messageData= msgData;
    [req startRequest];
}

//MARK: 消息未读数
+(void)unreadResponseWith:(MKRSocketSplit *)response{
    CMsgUnReadCount *unread = (CMsgUnReadCount *)(response.body);
       
    CMsgUnReadCountAck *ack = [CMsgUnReadCountAck message];
    
    ack.tId = unread.tId;
    ack.ackSequence = unread.ackSequence;
    MKRMessageData *msgData =  [MKRMessageData qucickCreate:E_CMD_MSG_UNREAD_COUNTACK gpb:ack toUser:0 fromid:response.header.fromUid deviceId:deviceIds];
    MKRSocketRequest *req = [[MKRSocketRequest alloc] init];
    req.messageData= msgData;
    [req startRequest];
}

//MARK: 机器人消息
+(void)robotMessageResponse:(MKRSocketSplit *)response{
    CRobotMsgNotify *robot = (CRobotMsgNotify *)(response.body);
       
    CRobotMsgNotifyAck *ack = [CRobotMsgNotifyAck message];
    ack.subType = robot.subType;
    ack.msgId = robot.msgId;
    ack.ackSequence = robot.ackSequence;
    ack.tId = robot.tId;
    MKRMessageData *msgData =  [MKRMessageData qucickCreate:E_CMD_ROBOT_MSG_NOTIFYACK gpb:ack toUser:0 fromid:response.header.fromUid deviceId:deviceIds];
    MKRSocketRequest *req = [[MKRSocketRequest alloc] init];
    req.messageData= msgData;
    [req startRequest];
}

@end

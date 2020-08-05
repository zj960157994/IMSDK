//
//  MKRMessageManager.m
//  Leigod
//
//  Created by 周进 on 2020/7/17.
//  Copyright © 2020 leigod. All rights reserved.
//

#import "MKRMessageManager.h"

static MKRMessageManager *instance = nil;
@interface MKRMessageManager()
@property (nonatomic,strong) RACSubject *subject;
@end

@implementation MKRMessageManager
- (instancetype)init
{
    self = [super init];
    if (self) {
        _subject = [[RACSubject alloc] init];
    }
    return self;
}

//MARK: 当返回ack更新数据的消息状态
-(void)updateMessageStatue:(MKRSocketSplit *)responseData{
    //获取消息的头部信息
    NSInteger timeInterval = (NSInteger)(responseData.header.timeStamp);
    //查询得到数据
    MKRChatMessageModel *dbData = [MKRChatMessageModel findWithTimeStamp:timeInterval];
    //更新数据
    if (dbData) {
        [MKRChatMessageModel UpdateMessageStatus:dbData status:(MessageSentStatusUnRead)];
    }
}


//MARK: 处理接收到的数据处理并做分发处理
-(void)dealDataParseData:(MKRSocketSplit *)responseData{
        //判断对象
        NSLog(@"---%p",responseData);
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_ALLMESSAGE object:responseData];
        [self.subject sendNext:@(responseData.header.msgType)];
         switch (responseData.header.msgType) {
             case E_CMD_PACKET_UNKNOWN:
             {
                 //未知消息类型
             }
                 break;
             case E_CMD_PACKET_BINDACK: //绑定成功
             {
                 [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_USERVERIFY object:nil];
             }
                 break;
             case E_CMD_PACKET_OFFLINE:
             {
                 //下线
                 
                 
             }
                 break;
             case E_CMD_PACKET_OFFLINEACK:
            {

                //回一个数据

            }
                 break;
           case E_CMD_PACKET_KICKOFF:
             {

                 //踢出

             }
                break;
           case E_CMD_PACKET_KICKOFFACK:
                  {

                      //回一个数据

                  }
                 break;
          case E_CMD_P2PMSG: //私聊消息类型
                 {
                     //回一个数据
                     [MKRReceiveResponse p2pMsgResponseWithP2p:responseData];
                     //存入数据库
                    BOOL saveStatus = [[MKRChatMessageModel convertWithSplit:responseData type:E_CMD_P2PMSG] save];
                 }
                break;
         case E_CMD_P2PMSGACK: //P2PMSGACK消息类型
                     {
                         //更新数据库的消息状态
                         

                     }
                    break;
          case E_CMD_GROUPMSG: //群聊消息类型
                 {
                     //回一个数据
                     [MKRReceiveResponse chatRoomResponseWithRoomMsg:responseData];
                     //存入数据库
                     
                 }
                break;
         case E_CMD_GROUPMSGACK : //群聊消息类型
                {

                    //回一个数据

                }
               break;
          case E_CMD_CHATROOMMSG: //聊天是消息
                 {
                     //回一个数据
                     [MKRReceiveResponse chatRoomResponseWithRoomMsg:responseData];
                     //存数据库
                     BOOL saveStatus = [[MKRChatMessageModel convertWithSplit:responseData type:E_CMD_CHATROOMMSG] save];
                     if (saveStatus) {
                          [self.subject sendNext:NOTIFICATION_NEWMessage];
                     }
                 }
                break;
         case E_CMD_CHATROOMMSGACK : //聊天室的ack
                  {
                      //消息得到服务器响应
                      [self updateMessageStatue:responseData];
                  }
                 break;
          case E_CMD_CHATROOM_USERACTION: //聊天室用户操作
                 {
                     //回一个数据
                     [MKRReceiveResponse chatroomUserActionAckResponse:responseData];

                 }
                break;
          case E_CMD_CHATROOM_USERACTIONACK: //聊天室用户操作ACK
                 {

                     //回一个数据

                 }
                break;
          case E_CMD_CHATROOM_SETTINGS: //聊天室设置
                 {

                     //回一个数据

                 }
                break;
         case E_CMD_CHATROOM_SETTINGSACK: //聊天室设置ACK
                 {

                     //回一个数据

                 }
                break;
         case E_CMD_CHATROOM_USERLIST: //聊天室用户列表
                 {

                     //回一个数据

                 }
                break;
         case E_CMD_CHATROOM_USERLISTACK: //聊天室用户列表ACK
                 {

                     //回一个数据

                 }
                break;
         case E_CMD_CHATROOM_USERHEART: //聊天室心跳
                 {

                     //回一个数据

                 }
                break;
         case E_CMD_CHATROOM_USERHEARTACK: //聊天室心跳ACK
                 {

                     //回一个数据

                 }
                break;
         case E_CMD_ROBOT_MSG_NOTIFY: //机器人消息通知
                 {

                     //回一个数据

                 }
                break;
         case E_CMD_ROBOT_MSG_NOTIFYACK: //机器人消息通知
                 {

                     //回一个数据

                 }
                break;
         case E_CMD_MSG_READED: //消息已读
                 {

                     //回一个数据

                 }
                break;
         case E_CMD_MSG_READEDACK: //消息已读ACK
                 {

                     //回一个数据

                 }
                break;
         case E_CMD_MSG_UNREAD_COUNT: //消息未读数
                 {

                     //回一个数据

                 }
                break;
         case E_CMD_MSG_UNREAD_COUNTACK: //消息未读数ACK
                 {

                     //回一个数据

                 }
                break;
         case E_CMD_COMMUNITY_USERACTION: //消息未读数ACK
                 {

                     //回一个数据

                 }
                break;
         case E_CMD_COMMUNITY_USERACTIONACK: //消息未读数ACK
             {

                 //回一个数据

             }
                        break;
         case E_CMD_PGC_DYNAMIC_MSG: //消息未读数ACK
             {

                 //回一个数据

             }
                        break;
         case E_CMD_PGC_DYNAMIC_MSGACK: //消息未读数ACK
             {

                 //回一个数据

             }
                        break;
         case E_CMD_PACKET_INPUT_STATUS: //消息未读数ACK
             {

                 //回一个数据

             }
                        break;
             default:
                 break;
         }

    
}
@end

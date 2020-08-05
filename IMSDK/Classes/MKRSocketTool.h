//
//  MKRSocketTool.h
//  MKTest
//
//  Created by 周进 on 2019/7/16.
//  Copyright © 2019 Ligin. All rights reserved.
//

#ifndef MKRSocketTool_h
#define MKRSocketTool_h

#define CommunicationHeaderLength 5  //通讯头部长度
#define HeaderLength  62  //消息头部长度




#define USE_OFFICIAL_ENVIORMENT 0

#if USE_OFFICIAL_ENVIORMENT

#define SOCKET_IP     @"10.178.68.26"
#define SOCKET_PORT   8081

#else

#define SOCKET_IP     @"172.31.0.33"
#define SOCKET_PORT   8081

#endif


#define MSGMAXLENGTH  190
#define HEARTBEATINTERVAL 200  //心跳包间隔
#define SOCKETSENDTIMEOUT 5
#define SOCKETREADTIMEOUT (-1) //读取超时，切勿修改，会出问题
#define SOCKETCONNECTTIMEOUT 5 //连接超时
#define AUTOCONECTTIMES 4  //自动重连
#define SOCKETREQUESTTIMEOUT 10 //请求超时
//UserDefaults
#define MKRUserDefaults [NSUserDefaults standardUserDefaults]
//声明weak类型
#define NNWeakSelf(type) __weak typeof(type) weak##type = type;

#pragma mark ########定义系统的socket消息#########

#define SOCKET_HEARTBEAT_RSP_CODE  102
#define SOCKET_HEARTBEAT_REQ_CODE  101
#define SOCKET_SOMEWHRER_LOGIN_CODE  1999



//网络字节序
#define ntohs(x)    __DARWIN_OSSwapInt16(x) // 16位整数 网络字节序转主机字节序
#define htons(x)    __DARWIN_OSSwapInt16(x) // 16位整数 主机字节序转网络字节序
#define ntohl(x)    __DARWIN_OSSwapInt32(x)  //32位整数 网络字节序转主机字节序
#define htonl(x)    __DARWIN_OSSwapInt32(x) //32位整数 主机字节序转网络字节序
#pragma pack(1)



typedef struct _CHead
{
    unsigned char ecodeType;            // 0结构体，1 protobuf, 2 json, 3 绑定的结构体
    unsigned char msgType;                 // CMsgType
    unsigned short len;
    unsigned int  fromUid;              // 发送者id
    unsigned int  toUid;                // 接受者id 根据type判断是userId还是groupId
    unsigned long long timeStamp;
    char deviceId[32];     // 设备ID
    unsigned long long mqTag;
    unsigned short mqChanId;
} CHead;

typedef struct _CCommunicationPack
{
    unsigned short msgLen;
    unsigned char msgType;           // CMsgType
    unsigned char serialNo;
    unsigned char flag;
} CCommunicationPack;

typedef struct _CBind
{
    unsigned char deviceType;
    char token[64];
    unsigned char versionNo[10];
} CBind;

#define PACKET_MAXLEN        1400
#define PACKET_HEADLEN       5
#define MSG_MAXLEN           1200

#define TOCKEN_MAXLEN        64
#define DEVICEID_MAXLEN       32
#define CONTENT_MAXLEN       128
typedef enum _CMsgType
{
    E_CMD_PACKET_UNKNOWN = 0,
    E_CMD_PACKET_HEARBEAT = 1,
    E_CMD_PACKET_HEARBEATACK = 2,
    E_CMD_PACKET_BIND = 3,
    E_CMD_PACKET_BINDACK =4,
    E_CMD_PACKET_OFFLINE = 5,
    E_CMD_PACKET_OFFLINEACK = 6,
    E_CMD_PACKET_KICKOFF = 7,
    E_CMD_PACKET_KICKOFFACK = 8,
    E_CMD_P2PMSG = 9,    //私聊消息类型
    E_CMD_P2PMSGACK = 10,   //P2PMSGACK消息类型
    E_CMD_CHATROOMMSG =11,//聊天室消息类型
    E_CMD_CHATROOMMSGACK = 12,   //ACK消息类型
    E_CMD_CHATROOM_USERACTION=13,//聊天室用户操作
    E_CMD_CHATROOM_USERACTIONACK=14,//聊天室用户操作ACK
    E_CMD_CHATROOM_SETTINGS=15,//聊天室设置
    E_CMD_CHATROOM_SETTINGSACK=16,//聊天室设置ACK
    E_CMD_CHATROOM_USERLIST =17,//聊天室用户列表
    E_CMD_CHATROOM_USERLISTACK =18,//聊天室用户列表ACK
    E_CMD_CHATROOM_USERHEART =19,//聊天室心跳
    E_CMD_CHATROOM_USERHEARTACK =20,//聊天室心跳ACK
    E_CMD_ROBOT_MSG_NOTIFY =21,//机器人消息通知
    E_CMD_ROBOT_MSG_NOTIFYACK =22,//机器人消息通知ACK
    E_CMD_MSG_READED=23,    //消息已读
    E_CMD_MSG_READEDACK =24, //消息已读ACK
    E_CMD_MSG_UNREAD_COUNT=25,    //消息未读数
    E_CMD_MSG_UNREAD_COUNTACK=26, //消息未读数ACK
    E_CMD_COMMUNITY_USERACTION=27,//社区用户操作
    E_CMD_COMMUNITY_USERACTIONACK=28,//社区用户操作ACK
    E_CMD_PGC_DYNAMIC_MSG=29,//PGC动态消息
    E_CMD_PGC_DYNAMIC_MSGACK=30,//PGC动态消息ACK
    E_CMD_PACKET_INPUT_STATUS = 31,//输入状态，只需要消息头，不需要消息体和ACK
    E_CMD_GROUPMSG = 33,//群聊消息类型
    E_CMD_GROUPMSGACK = 34,//群聊消息类型ACK
} CMsgType;


#define tokens       [UserModel currentUserModelInstance].accessToken
#define myUserId     [[UserModel currentUserModelInstance].userId intValue]
#define deviceIds    uniqueDeviceIdentifier()
#define ChatRoomId   10000


#define MessageDataListLength  20

#pragma Mark  *********************Notification
#define  NOTIFICATION_ALLMESSAGE      @"NOTIFICATIONMESSAGERESPONSE"
#define  NOTIFICATION_USERVERIFY    @"NOTIFICATIONUSERVERIFY"
#define  NOTIFICATION_BINDSUCCESS   @"NOTIFICATIONBINDSUCCESS"

#define  NOTIFICATION_NEWMessage    @"NOTIFICATIONNEWMessage"
#endif /* MKRSocketTool_h */

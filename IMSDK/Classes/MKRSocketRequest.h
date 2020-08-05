//
//  MKRSocketRequest.h
//  MaoKRadioPlayer正式环境
//
//  Created by 周进 on 2019/4/25.
//  Copyright © 2019 Muzen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MKRMessageData.h"
#import "MKRSocketSplit.h"
#import "MKRChatMessageModel.h"

typedef NS_ENUM(NSInteger ,MKRREQUESTSTATUS){
    MKRREQUESTSTART,
    MKRREQUESTTING,
    MKRREQUESTFINSHED, 
};
typedef void(^socketSuccess)(__kindof GPBMessage *msg);

@interface MKRSocketRequest : NSObject
/**< 返回的数据 */
@property (nonatomic, copy) MKRSocketSplit *rsponseData;
/**超时时间*/
@property (nonatomic,assign) NSInteger timeOut;
//请求数据体
@property (nonatomic,strong) MKRMessageData *messageData;
//失败回调
@property (nonatomic,copy) MKRSocketRequestFailed failed;
//成功回调
@property (nonatomic,copy) MKRSocketRequestFinished finished;
//管理数据更新
@property (nonatomic,strong) RACSubject *subject;

//MARK: 请求解析数据返回
- (void)startRequest;
//通过返回的msgtype 映射protobuf的响应体
+(NSString *)convertFrom:(CMsgType)type;
//MARK: 发送单聊消息
+(void)sendP2pRequest:(NSString *)content toUserId:(NSInteger)toUserId;
//MARK: 发送聊天室消息
+ (MKRChatMessageModel *)sendChatRoomMessage:(NSString *)content toChatRoomId:(NSInteger)chatRoomId;
//MARK: 聊天室操作
+(void)sendUserActionMessage:(NSString *)content;

//MARK: 发送聊天室心跳
+(void)sendChatRoomHearBeat;

@end

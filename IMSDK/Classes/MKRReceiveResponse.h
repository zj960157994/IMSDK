//
//  MKRReceiveResponse.h
//  Leigod
//
//  Created by 周进 on 2020/7/17.
//  Copyright © 2020 leigod. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface MKRReceiveResponse : NSObject

//MARK: 收到聊天室是消息返回ack
+(void)chatRoomResponseWithRoomMsg:(MKRSocketSplit *)response;

//MARK: 消息9类型接收返回10的response
+(void)p2pMsgResponseWithP2p:(MKRSocketSplit *)responseData;

+(void)chatroomUserActionAckResponse:(MKRSocketSplit *)response;

@end



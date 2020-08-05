//
//  MKRSocket.h
//  MaoKRadioPlayer正式环境
//
//  Created by 周进 on 2019/4/15.
//  Copyright © 2019年 Muzen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MKRProtocolbuffer.h"
#import "MKRSocketRequest.h"

@protocol MKRSocketDelegate <NSObject>

-(void)didReceiverData:(NSData *)data;

@end


typedef NS_ENUM(NSInteger ,MKRSOCKETCONNECTSTATUS){
    MKRSOCKETCONNECTED = 0,//连接完成
    MKRSOCKETCONNECTING = 1,//连接中
    MKRSOCKETCONNECTFAILED = 2 //连接失败
};
typedef void(^connect_Success_Block)(void);
typedef void(^connect_Failure_Block)(NSError *error);

@interface MKRSocket : NSObject
@property(nonatomic,strong,readonly) GCDAsyncSocket *socket;

@property (nonatomic, assign) MKRSOCKETCONNECTSTATUS connectStatus;
//代理
@property (nonatomic,weak) id<MKRSocketDelegate> delegate;
//断开服务器 
-(void)disconnect;
//连接成功回调
-(void)connectSuccess:(connect_Success_Block)connectBlock;
//失败链接回调
-(void)connectFailure:(connect_Failure_Block)connectBlock;
//链接服务器
- (BOOL)connecteServerWith:(NSString *)host  onPort:(uint16_t)port success:(connect_Success_Block)successBlock failed:(connect_Failure_Block)failedBlock;

@end

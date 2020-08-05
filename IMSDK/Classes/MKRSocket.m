//
//  MKRSocket.m
//  MaoKRadioPlayer正式环境
//
//  Created by 周进 on 2019/4/15.
//  Copyright © 2019年 Muzen. All rights reserved.
//

#import "MKRSocket.h"
#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"
#import "GPBProtocolBuffers.h"


#import "MKRSocketRequest.h"
#import "MKRProtocolbuffer.h"


@interface MKRSocket()<GCDAsyncSocketDelegate>

//全局Socket
@property(nonatomic,strong,readwrite) GCDAsyncSocket *socket;
//链接成功
@property (nonatomic, copy) connect_Success_Block connectBlock;
//链接失败
@property (nonatomic, copy) connect_Failure_Block failureBlock;

@property (nonatomic,strong) NSMutableData *completeData;

//心跳
@property (nonatomic,strong) NSTimer *heartBeat;

@end

@implementation MKRSocket

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self socket];
        _completeData = [NSMutableData data];
    }
    return self;
}

//MARK: 单利创建 全局唯一
- (GCDAsyncSocket *)socket{
    if (!_socket) {
        _socket = [[GCDAsyncSocket alloc]
                   initWithDelegate:self
                   delegateQueue:dispatch_get_global_queue(0, 0)];
    }
    return _socket;
}


//MARK: 链接服务器
- (BOOL)connecteServerWith:(NSString *)host  onPort:(uint16_t)port success:(connect_Success_Block)successBlock failed:(connect_Failure_Block)failedBlock{
    static BOOL success;
    self.connectStatus = MKRSOCKETCONNECTING;
    if (!self.socket.isConnected) {
        NSError *err;
        success = [self.socket connectToHost:host onPort:port withTimeout:SOCKETCONNECTTIMEOUT error:&err];
        if (err != nil)
        {
            if (failedBlock) {
                failedBlock(err);
            }
        }
        if (success) {
            if (successBlock) {
                successBlock();
            }
        }
    }
    return success;
}

//MARK: 链接成功
-(void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port{
    self.connectStatus = MKRSOCKETCONNECTED;
    if (_connectBlock) {
        _connectBlock();
    }
    [_socket readDataWithTimeout:SOCKETREADTIMEOUT tag:1];
    NSLog(@"链接成功");
}

//MARK: socket断开
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(nullable NSError *)err{
    self.connectStatus = MKRSOCKETCONNECTFAILED;
    if (self.failureBlock) {
        self.failureBlock(err);
    }
    [self disconnect];
    NSLog(@"链接断开:%@",[err localizedDescription]);
    [[MKRUserVerify shareInstance] connectToVerify];
}

//MARK: 发送成功
- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag{
    [_socket readDataWithTimeout:SOCKETREADTIMEOUT tag:tag];
    NSLog(@"发送成功");
}

//MARK: 接收信息
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    [self.socket readDataWithTimeout:SOCKETREADTIMEOUT tag:tag];
    if (_delegate && [_delegate respondsToSelector:@selector(didReceiverData:)]) {
        [_delegate performSelector:@selector(didReceiverData:) withObject:data];
    }
    [self.socket readDataWithTimeout:SOCKETREADTIMEOUT tag:tag];
    NSLog(@"接收数据成功");
}

//MARK: 断开服务器
-(void)disconnect{
    [_socket disconnect];
    _socket = nil;
}
//MARK: 连接成功回调
- (void)connectSuccess:(connect_Success_Block)connectBlock{
    _connectBlock = connectBlock;
}
//MARK: 链接失败
- (void)connectFailure:(connect_Failure_Block)connectBlock{
    _failureBlock = connectBlock;
}


@end

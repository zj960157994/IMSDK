//
//  MKRDealData.m
//  MaoKingRadioPlayer
//
//  Created by 周进 on 2020/7/13.
//  Copyright © 2020 MaoKing. All rights reserved.
//

#import "MKRDealData.h"

static char *receiveQueueName = "com.message.receivequeue";
static char *sendQueueName = "com.message.sendqueue";
static MKRDealData *instance = nil;
@interface MKRDealData()<MKRSocketDelegate>

//内部的队列 异步线程同步执行
@property(nonatomic,strong) dispatch_queue_t receiveQueue;
//内部的队列 异步线程同步执行
@property(nonatomic,strong) dispatch_queue_t sendQueue;
//返回数据的data
@property (nonatomic,strong) NSMutableData *completeData;
//请求字典
@property (nonatomic,strong) NSMutableDictionary *requestDict;
@end


@implementation MKRDealData

+ (MKRDealData *)shareInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[MKRDealData alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _receiveQueue = dispatch_queue_create(receiveQueueName, DISPATCH_QUEUE_CONCURRENT);
        _sendQueue = dispatch_queue_create(sendQueueName, DISPATCH_QUEUE_CONCURRENT);
        _nnSocket = [[MKRSocket alloc] init];
        _nnSocket.delegate = self;
        _msgManager = [[MKRMessageManager alloc] init];
        _requestDict = [NSMutableDictionary dictionary];
        [self completeData];
        
    }
    return self;
}

- (NSMutableData *)completeData{
    if (!_completeData) {
        _completeData = [NSMutableData data];
    }
    return _completeData;
}


-(void)sendRequest:(MKRSocketRequest *)request {
    
    __weak typeof(self) wSelf = self;
    dispatch_barrier_async(_sendQueue, ^{
        [wSelf.nnSocket.socket writeData:request.messageData.requestData withTimeout:SOCKETSENDTIMEOUT tag:0];
        [wSelf.nnSocket.socket readDataWithTimeout:SOCKETREADTIMEOUT tag:0];
        [wSelf.requestDict setValue:request forKey:PTString(@"%d",request.messageData.header.timeStamp)];
    });
 
}


#pragma mkrdelegate

-(void)didReceiverData:(NSData *)data{
    __weak typeof(self) wSelf = self;
    dispatch_barrier_async(_receiveQueue, ^{
        //解析数据
        NSLog(@"%@",data);
        if (data.length<CommunicationHeaderLength) {
            FLog(@"包体不够5个字节data:%@",data);
            return;
        }
        NSData *cpackData = [data getSubDataWithRange:NSMakeRange(0, CommunicationHeaderLength)];
        CCommunicationPack  cpack;
        [cpackData getBytes:&cpack length:sizeof(cpack)];
        cpack = [MKRMessageData ntoh_term_pack:cpack];
        NSLog(@"datalength:%lu",(unsigned long)cpack.msgLen);
        if (cpack.msgType == E_CMD_PACKET_HEARBEATACK) {
            //心跳包
            [wSelf sureHeartBeat];
            return;
        }
                 
        if (cpack.msgLen != data.length) {
            //接收的数据长度不相等
            FLog(@"出现了丢包断包的粘包的情况data:%@",data);
            if (cpack.msgLen<data.length) {
                FLog(@"真实包长度大于消息头length长度data:%@",data);
            }else{
                FLog(@"真实包长度小于消息头length长度data:%@",data);
            }
            return;
        }
        if (data.length<(CommunicationHeaderLength+HeaderLength)) {
            //丢弃 理想状态
            //处理方法 等待下个包体
            FLog(@"包长度小于消息头+通讯头长度data:%@",data);
             NSLog(@"comunpack ack:%d",cpack.msgType);
            return;
        }
        CHead header;
        NSData *headerData = [data getSubDataWithRange:NSMakeRange(CommunicationHeaderLength, HeaderLength)];
        [headerData getBytes:&header length:sizeof(header)];
        NSLog(@"ack:%d",header.msgType);
        //解析消息体
        //计算消息体的长度
        CHead tempHead = [MKRMessageData ntoh_term_head:header];
        GPBMessage *bodyMsg;
        NSInteger bodyLength = tempHead.len - HeaderLength;
        if (bodyLength>0) {
            NSData *bodydata = [data getSubDataWithRange:NSMakeRange(HeaderLength+CommunicationHeaderLength, bodyLength)];
            NSError *error;
            NSString *ackType = [MKRSocketRequest convertFrom:header.msgType];
            Class responseClass =  NSClassFromString(ackType);
            bodyMsg = [responseClass parseFromData:bodydata error:&error];
            if (error) {
                FLog(@"protobuf error:%@,data:%@",error,data);
                NSLog(@"protobuf error:%@",error);
            }
            NSLog(@"protobuf parse result:%@",bodyMsg);
        }else{
            FLog(@"包体长度为0");
        }
        
        MKRSocketSplit *res = [MKRSocketSplit dataSplit:tempHead pack:cpack body:bodyMsg];
        [wSelf.msgManager dealDataParseData:res];
        //消息组装成消息体返回
        [wSelf removeReq:res];
        NSLog(@"走到了解析数据最后一行");
    });

}
//MARK: 从队列移除
-(void)removeReq:(MKRSocketSplit *)data{
    
   MKRSocketRequest *request = [self.requestDict objectForKey:PTString(@"%d",data.header.timeStamp)];
    if (request) {
        request.rsponseData = [data copy];
        [request.subject sendNext:PTString(@"%d",data.header.timeStamp)];
        [self.requestDict removeObjectForKey:PTString(@"%d",data.header.timeStamp)];
    }
}

//MARK: 确认收到心跳消息
-(void)sureHeartBeat{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(noReceiverHeartBeat) afterDelay:HEARTBEATINTERVAL];

}
-(void)noReceiverHeartBeat{
    //重连
    [[MKRUserVerify shareInstance] connectToVerify];
}


@end

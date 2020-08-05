//
//  MKRUserVerify.m
//  MaoKRadioPlayer
//
//  Created by 周进 on 2019/7/15.
//  Copyright © 2019 Muzen. All rights reserved.
//

#import "MKRUserVerify.h"
#import "MKRDBHelper.h"
#import "MKRChatMessageModel.h"
#define bindTimeout 5
static char *HeartBeatQueueName = "com.nn.heartbeat";
static MKRUserVerify *instance = nil;

@interface MKRUserVerify()
//心跳定时器
@property (nonatomic,strong) NSTimer *timer;
//一个队列中处理心跳和绑定
@property(nonatomic,strong) dispatch_queue_t heartQueue;
//绑定定时器
@property (nonatomic,strong) NSTimer *bindTimer;
//当前绑定请求
@property (nonatomic,strong) MKRSocketRequest *request;

@end
@implementation MKRUserVerify

- (instancetype)init
{
    self = [super init];
    if (self) {
        _heartQueue = dispatch_queue_create(HeartBeatQueueName, DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

+(MKRUserVerify *)shareInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[MKRUserVerify alloc] init];
    });
    return instance;
}

//MARK: 链接然后认证
-(void)connectToVerify{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(parseDatas) name:NOTIFICATION_USERVERIFY object:nil];
    if (![LogicForProject isUserAuth]) {
        return;
    }
    dispatch_async(_heartQueue, ^{
        @weakify(self);
         [[[MKRDealData shareInstance] nnSocket] connecteServerWith:SOCKET_IP onPort:SOCKET_PORT success:^{
             @strongify(self);
             [self sendBind];
             [self createBindTimer];
         } failed:^(NSError *error) {
             if (self.failed) {
                 self.failed(error);
             }
             self.failed = nil;
             self.finished = nil;
         }];
    });
 
    
}

//MARK: socket断开
-(void)disconnect{
    [[MKRDealData shareInstance].nnSocket disconnect];
}

//MARK: 发送绑定请求
-(void)sendBind{
    
        self.request = [[MKRSocketRequest alloc] init];
        NSMutableData *data = [NSMutableData data];

        unsigned short nlens = sizeof(CHead)+sizeof(CBind)+sizeof(CCommunicationPack);
        CCommunicationPack pack = {
            nlens,
            3,
            0,
            0
        };
        self.request.messageData.communPack = pack;
        NSTimeInterval start = [[NSDate date] timeIntervalSince1970]*1000;
        unsigned short hlen = sizeof(CHead)+sizeof(CBind);
        CHead header = {
            0,
            3,
            hlen,
            myUserId,
            0,
            [[NSDate date] timeIntervalSince1970]*1000,
            0,
            0,
            0
        };
    
        memcpy(header.deviceId, [deviceIds UTF8String], DEVICEID_MAXLEN);
        self.request.messageData.header = header;
        CBind bind = {
            2,
            ""
        };
        if (tokens) {
             memcpy(bind.token, [tokens UTF8String], TOCKEN_MAXLEN);
        }else{
            memcpy(bind.token, "", TOCKEN_MAXLEN);
        }
        
        self.request.messageData.bindCmd = bind;
        NSLog(@"绑定时间戳:%f",start);
        [self.request startRequest];
        //绑定定时器
}

-(void)createBindTimer{
    @weakify(self)
    dispatch_async(_heartQueue, ^{
        @strongify(self);
        self.bindTimer = [NSTimer scheduledTimerWithTimeInterval:SOCKETSENDTIMEOUT target:[YYWeakProxy proxyWithTarget:self] selector:@selector(sendBind) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] run];
    });

}

#pragma mark -- 请求超时处理
-(void)requestTimeout{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    NSError *err = [NSError errorWithDomain:@"errmsg" code:1 userInfo:@{NSLocalizedDescriptionKey:@"请求超时,请稍后重试"}];
    if (self.failed) {
        self.failed(err);
    }
    self.failed = nil;
    self.finished = nil;
}
//MARK: 解析数据
-(void)parseDatas{
    if (self.bindTimer) {
        [self.bindTimer invalidate];
        self.bindTimer = nil;
    }
    
    //判断对象
    self.isFinished = YES;
    //发送聊天消息
    NSLog(@"bind_ack");
    if (self.finished) {
        self.finished(nil);
    }
    self.failed = nil;
    self.finished = nil;
    //启动心跳
    [self start];
    //创建数据库
    [[MKRDBHelper shareInstance] openDB];
    //IM的链接绑定成功通知
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_BINDSUCCESS object:nil];
}

- (void)setFinished:(MKRSocketRequestFinished)finished{
    _finished = finished;
}

- (void)setFailed:(MKRSocketRequestFailed)failed{
    _failed = failed;
}


-(void)createTimer{
    [self stopTimer];
    @weakify(self)
    dispatch_async(_heartQueue, ^{
        @strongify(self);
        [self MKRSocketHeartBeat];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:HEARTBEATINTERVAL target:self selector:@selector(MKRSocketHeartBeat) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] run];
    });

}
-(void)start{
    [self createTimer];
}

- (void)MKRSocketHeartBeat{
    NSLog(@"心跳发送");
    MKRSocketRequest *request = [[MKRSocketRequest alloc] init];
    unsigned short nlens = sizeof(CHead);
    CCommunicationPack pack = {
      nlens,
      E_CMD_PACKET_HEARBEAT,
      0,
      0
    };
    request.messageData.communPack = pack;
    unsigned short hlen = sizeof(CHead);
    NSTimeInterval start = [[NSDate date] timeIntervalSince1970]*1000;
    CHead header = {
      0,
      E_CMD_PACKET_HEARBEAT,
      hlen,
      myUserId,
      0,
      [[NSDate date] timeIntervalSince1970]*1000,
      0,
      0,
      0
    };
    NSTimeInterval end = [[NSDate date] timeIntervalSince1970]*1000;
    memcpy(header.deviceId, [deviceIds UTF8String], 32); //deviceid
    request.messageData.header = header;
    [request startRequest];
}



-(void)pauseTimer{
    if(self.timer){
        [self.timer setFireDate:[NSDate distantFuture]];
    }
}
-(void)resumeTimer{
    if(self.timer){
        [self.timer setFireDate:[NSDate date]];
    }
}
-(void)stopTimer{
    if(self.timer){
        [self.timer invalidate];
        self.timer = nil;
        
    }
}

-(void)dealloc{
    [self stopTimer];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end

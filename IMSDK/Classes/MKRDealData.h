//
//  MKRDealData.h
//  MaoKingRadioPlayer
//
//  Created by 周进 on 2020/7/13.
//  Copyright © 2020 MaoKing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MKRMessageManager.h"

@interface MKRDealData : NSObject
//socket
@property (nonatomic,strong) MKRSocket *nnSocket;
//消息请求
@property (nonatomic,strong,readonly) NSMutableArray *requestsArr;
//消息管理器
@property (nonatomic,strong) MKRMessageManager *msgManager;

+(MKRDealData *)shareInstance;
//发送
-(void)sendRequest:(MKRSocketRequest *)request;


@end

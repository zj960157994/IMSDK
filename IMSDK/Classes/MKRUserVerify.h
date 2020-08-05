//
//  MKRUserVerify.h
//  MaoKRadioPlayer
//
//  Created by 周进 on 2019/7/15.
//  Copyright © 2019 Muzen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MKRSocketApi.h"

@interface MKRUserVerify : NSObject

//MARK: 完成绑定
@property (nonatomic, assign) BOOL isFinished;

+(MKRUserVerify *)shareInstance;

@property (nonatomic,copy) MKRSocketRequestFinished finished;
@property (nonatomic,copy) MKRSocketRequestFailed failed;

/**< 链接并验证 */
-(void)connectToVerify;
//MARK: socket断开
-(void)disconnect;

//MARK: 心跳发送
-(void)start;
-(void)pauseTimer;
-(void)resumeTimer;
-(void)stopTimer;

@end


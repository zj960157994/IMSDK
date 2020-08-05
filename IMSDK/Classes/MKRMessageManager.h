//
//  MKRMessageManager.h
//  Leigod
//
//  Created by 周进 on 2020/7/17.
//  Copyright © 2020 leigod. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKRMessageManager : NSObject

@property (nonatomic,strong,readonly) RACSubject *subject;

-(void)dealDataParseData:(MKRSocketSplit *)responseData;

@end

NS_ASSUME_NONNULL_END

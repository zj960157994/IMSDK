//
//  MKRSocketApi.h
//  MaoKRadioPlayer
//
//  Created by 周进 on 2019/4/28.
//  Copyright © 2019 Muzen. All rights reserved.
//

#ifndef MKRSocketApi_h
#define MKRSocketApi_h

/** 请求完成的Block */
typedef void(^MKRSocketRequestFinished)(id responseObject);
/** 请求失败的block */
typedef void(^MKRSocketRequestFailed)(NSError *error);

//1.规定 一次请求的命令
//请求体为 CMD_req 例如 radio_category_req
//数据返回体 CMD_rsp 例如 radio_category_rsp
//这些请求体和返回体，在protocolbuffer 文件中都存在

//获取电台分类
static NSString *const CMD_RADIO_CATEGORY = @"BroadcastCategories";
//获取电台分类下电台
static NSString *const CMD_RADIO_PROGRAMS = @"AppGetBroadcasts";

#endif /* MKRSocketApi_h */

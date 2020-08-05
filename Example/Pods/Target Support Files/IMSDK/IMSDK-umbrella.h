#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "MKRChatMessageModel.h"
#import "MKRDBHelper.h"
#import "MKRDBModel.h"
#import "MKRDBProtocol.h"
#import "MKRDealData.h"
#import "MKRMessageData.h"
#import "MKRMessageManager.h"
#import "MKRProtocolbuffer.h"
#import "MKRReceiveResponse.h"
#import "MKRSocket.h"
#import "MKRSocketApi.h"
#import "MKRSocketRequest.h"
#import "MKRSocketSplit.h"
#import "MKRSocketTool.h"
#import "MKRUserVerify.h"

FOUNDATION_EXPORT double IMSDKVersionNumber;
FOUNDATION_EXPORT const unsigned char IMSDKVersionString[];


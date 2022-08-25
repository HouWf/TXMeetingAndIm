//
//  TRTCMeetingDef.h
//  TRTCScenesDemo
//
//  Created by xcoderliu on 4/21/20.
//  Copyright © 2020 xcoderliu. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "TUIMeetingKit.h"


// 用户基本信息（IMSDK中获取）
@interface TXUserInfo : NSObject

@property (nonatomic, strong) NSString *userId;    // 用户ID
@property (nonatomic, strong) NSString *userName;  // 用户名称（昵称）
@property (nonatomic, strong) NSString *avatarURL; // 用户头像URL
@property (nonatomic, strong) NSString *nameCard;   // 群名片

@end


// 会议用户信息
@interface TRTCMeetingUserInfo : TXUserInfo

// 用户是否打开了视频
@property (nonatomic, assign) BOOL isVideoAvailable;

// 用户是否打开音频
@property (nonatomic, assign) BOOL isAudioAvailable;

// 用户是否打开扬声器
@property (nonatomic, assign) BOOL isSpearkerAvailable;

// 是否对用户静画（不播放该用户的视频）
@property (nonatomic, assign) BOOL isMuteVideo;

// 是否对用户静音（不播放改用户的音频）
@property (nonatomic, assign) BOOL isMuteAudio;


// 业务自定义，待调试
// 举手
@property (nonatomic, assign) BOOL isHoldHand;
// 共享屏幕
@property (nonatomic, assign) BOOL isShareScreen;
// 被移交的主持人(间接主持人)
@property (nonatomic, assign) BOOL isIndirectManager;
// 是否开启过语音激励
@property (nonatomic, assign) BOOL haveOpenExs;


@end

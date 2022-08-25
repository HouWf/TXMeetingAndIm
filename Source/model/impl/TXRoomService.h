//
//  TXRoomService.h
//  TRTCScenesDemo
//
//  Created by J J on 2020/5/29.
//  Copyright © 2020 xcoderliu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TRTCMeetingDef.h"
#import <ImSDK_Plus/ImSDK_Plus.h>

@protocol TXRoomServiceDelegate <NSObject>

- (void)onRoomDestroy:(NSString *_Nullable)roomId;
- (void)onRoomRecvRoomTextMsg:(NSString *_Nullable)roomId message:(NSString *_Nullable)message
                     userInfo:(TXUserInfo *_Nullable)userInfo;
- (void)onRoomRecvRoomCustomMsg:(NSString *_Nullable)roomId cmd:(NSString *_Nullable)cmd
                        message:(NSString *_Nullable)message userInfo:(TXUserInfo *_Nonnull)userInfo;
- (void)onC2CRecvRoomCustomMsg:(NSString *_Nullable)userId cmd:(NSString *_Nullable)cmd
                        message:(NSString *_Nullable)message userInfo:(TXUserInfo *_Nonnull)userInfo;
// 某人被踢出群
- (void)onMemberKickedWithOpUser:(TXUserInfo *_Nonnull)opUser memberList:(NSArray<TXUserInfo *>*_Nonnull)memberList;
/**
 * 主持人更改回调
 *
 * @param previousUserId 更改前的主持人
 * @param currentUserId  更改后的主持人
 */
- (void)onRoomMasterChanged:(NSString *_Nonnull)previousUserId
              currentUserId:(NSString *_Nonnull)currentUserId;


/// 群成员新变更
/// @param groupID 群组ID
/// @param changeMemberIdList 成员ID列表
- (void)onMemberInfoChanged:(NSString *)groupID changeMemberIdList:(NSArray <NSString *> *)changeMemberIdList;

@end

typedef void(^TXCallback)(NSInteger code, NSString *_Nullable message);
typedef void(^TXUserListCallback)(NSInteger code, NSString *_Nullable message, NSArray <TXUserInfo*> *_Nullable userList);

NS_ASSUME_NONNULL_BEGIN

@interface TXRoomService : NSObject

@property (nonatomic, weak) id<TXRoomServiceDelegate> delegate;

+ (instancetype)sharedInstance;

- (void)login:(NSInteger) sdkAppId userId:(NSString *)userId userSign:(NSString *)userSign callback:(TXCallback) callback;

- (void)logout:(TXCallback) callback;

- (void)setSelfProfile:(NSString *)userName avatarURL:(NSString *)avatarURL callback:(TXCallback) callback;

- (void)setGroupMemberInfo:(NSString*)groupID userId:(NSString *)userId nameCard:(NSString *)nameCard callback:(TXCallback)callback;

- (void)createRoom:(NSString *)roomId roomInfo:(NSString *)roomInfo coverUrl:(NSString *)coverUrl callback:(TXCallback) callback;

- (void)destroyRoom:(TXCallback) callback;

- (void)enterRoom:(NSString *)roomId callback:(TXCallback) callback;

- (void)exitRoom:(TXCallback) callback;

- (void)getUserInfo:(NSArray *)userList callback:(TXUserListCallback) callback;

- (void)getGroupMembersInfo:(NSString*)groupID memberList:(NSArray<NSString*>*)memberIdList callback:(TXUserListCallback)callback;

- (void)sendRoomTextMsg:(NSString *)msg callback:(TXCallback) callback;

- (void)sendRoomCustomMsg:(NSString *)cmd message:(NSString *)message callback:(TXCallback) callback;

- (void)sendC2CCustomMsg:(NSString *)cmd message:(NSString *)message to:(NSString *)userId callback:(TXCallback)callback;

- (void)getGroupHistoryMessageList:(NSString *)groupID count:(int)count lastMsg:(V2TIMMessage*)lastMsg succ:(V2TIMMessageListSucc)succ fail:(V2TIMFail)fail;
// 踢人
- (void)kickedUser:(NSString *)userId callback:(TXCallback) callback;
// 切换用户角色
- (void)transferGroupOwner:(NSString *)userId callback:(TXCallback) callback;

- (BOOL)isLogin;

- (BOOL)isEnterRoom;

- (NSString *)getRoomId;

- (NSString *)getOwnerUserId;

- (NSString *)getMyselfUserId;

- (NSString *)getCreaterUserId;

// 重置主持人ID
- (void)resetOwnerUserId:(NSString *)userId;

// 是否是会议IM群主（当前主持人）
- (BOOL)isOwner;
// 是否是会议创建者（初始主持人）
- (BOOL)isCreater;

- (void)cleanStatus;

@end

NS_ASSUME_NONNULL_END

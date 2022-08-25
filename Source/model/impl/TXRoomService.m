//
//  TXRoomService.m
//  TRTCScenesDemo
//
//  Created by J J on 2020/5/29.
//  Copyright © 2020 xcoderliu. All rights reserved.
//

#import "TXRoomService.h"

#import <ImSDK_Plus/ImSDK_Plus.h>

#import "IMProtocol.h"
#import "TXMeetingPair.h"
#import "MeetingLocalized.h"

@interface TXRoomService() <V2TIMSimpleMsgListener, V2TIMGroupListener, V2TIMSDKListener>

@property (nonatomic, assign) BOOL mIsInitIMSDK;
@property (nonatomic, assign) BOOL mIsLogin;
@property (nonatomic, assign) BOOL mIsEnterRoom;

@property (nonatomic, strong) NSString *mRoomId;
@property (nonatomic, strong) NSString *mSelfUserId;
@property (nonatomic, strong) NSString *mOwnerUserId;

@end

NSString *TAG = @"TXMeetingRoomService";
NSInteger CODE_ERROE = -1;

@implementation TXRoomService

static TXRoomService *_sharedInstance = nil;

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[TXRoomService alloc] init];
    });
    return _sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.mIsInitIMSDK = NO;
        self.mIsLogin = NO;
        self.mIsEnterRoom = NO;
        
        self.mSelfUserId = @"";
        self.mOwnerUserId = @"";
        self.mRoomId = @"";
    }
    return self;
}

- (void)login:(NSInteger)sdkAppId userId:(NSString *)userId userSign:(NSString *)userSign callback:(TXCallback)callback {
    // 先初始化 IM
    if (!_mIsInitIMSDK) {
        _mIsInitIMSDK = [V2TIMManager.sharedInstance initSDK:(int)sdkAppId config:nil listener:nil];
        [V2TIMManager.sharedInstance addSimpleMsgListener:self];
        [V2TIMManager.sharedInstance setGroupListener:self];
        [V2TIMManager.sharedInstance addIMSDKListener:self];
        
        if (!_mIsInitIMSDK) {
            if (callback) {
                callback(CODE_ERROE, @"init im sdk error.");
            }
            return;
        }
    }
    
    // 登陆到 IM
    NSString *loginedUserId = V2TIMManager.sharedInstance.getLoginUser;
    if (loginedUserId != nil && [loginedUserId isEqualToString:userId]) {
        //已经登陆过了
        _mIsLogin = YES;
        _mSelfUserId = userId;
        if (callback) {
            callback(0, @"login im successful.");
        }
        return;
    }
    
    if (self.isLogin) {
        if (callback) {
            callback(CODE_ERROE, @"start login fail, you have been login, can't login twice.");
        }
        return;
    }
    
    [V2TIMManager.sharedInstance login:userId userSig:userSign succ:^{
        self.mIsLogin = true;
        self.mSelfUserId = userId;
        if (callback) {
            callback(0, @"login im success.");
        }
        
    } fail:^(int code, NSString *desc) {
        NSLog(@"login failed: code[%d] desc[%@]", code, desc);
        if (callback) {
            callback(code, desc);
        }
    }];
}


- (void)logout:(TXCallback)callback {
    if (!self.isLogin) {
        if (callback) {
            callback(CODE_ERROE, @"start logout fail, not login yet.");
        }
        return;
    }
    
    if (self.isEnterRoom) {
        if (callback != nil) {
            callback(CODE_ERROE, [NSString stringWithFormat:@"start logout fail, you are in room: %@ , please exit room before logout.", _mRoomId]);
        }
        return;
    }
    
    [V2TIMManager.sharedInstance logout:^{
        self.mIsLogin = false;
        self.mSelfUserId = @"";
        if (callback) {
            callback(0, @"logout im success.");
        }
    } fail:^(int code, NSString *desc) {
        if (callback) {
            callback(code, desc);
        }
    }];
}

- (void)setSelfProfile:(NSString *)userName avatarURL:(NSString *)avatarURL callback:(TXCallback)callback {
    if (!self.isLogin) {
        if (callback) {
            callback(CODE_ERROE, @"set profile fail, not login yet.");
        }
        return;
    }
    
    V2TIMUserFullInfo *info = [[V2TIMUserFullInfo alloc] init];
    info.nickName = userName;
    info.faceURL = avatarURL;
    
    [[V2TIMManager sharedInstance] setSelfInfo:info succ:^{
        if (callback) {
            callback(0, @"set profile success.");
        }
    } fail:^(int code, NSString *desc) {
        if (callback) {
            callback(code, desc);
        }
    }];
}

- (void)setGroupMemberInfo:(NSString*)groupID userId:(NSString *)userId nameCard:(NSString *)nameCard callback:(TXCallback)callback {
    if (!self.isLogin || userId.length == 0) {
        if (callback) {
            callback(CODE_ERROE, @"set profile fail, not login yet.");
        }
        return;
    }
    V2TIMGroupMemberFullInfo *fullInfo = [[V2TIMGroupMemberFullInfo alloc] init];
    fullInfo.userID = userId;
    fullInfo.nameCard = nameCard;
    fullInfo.customInfo = @{@"groupNickName":[nameCard dataUsingEncoding:NSUTF8StringEncoding] };
    [[V2TIMManager sharedInstance] setGroupMemberInfo:groupID info:fullInfo succ:^{
        if (callback) {
            callback(0, @"set profile success.");
        }
    } fail:^(int code, NSString *desc) {
        if (callback) {
            callback(code, desc);
        }
    }];
//    [[V2TIMManager sharedInstance] getGroupMembersInfo:groupID memberList:@[userId] succ:^(NSArray<V2TIMGroupMemberFullInfo *> *memberList) {
//        V2TIMGroupMemberFullInfo *fullInfo = memberList[0];
//        fullInfo.nameCard = nameCard;
//        fullInfo.customInfo = @{@"groupNickName":[nameCard dataUsingEncoding:NSUTF8StringEncoding] };
//        [[V2TIMManager sharedInstance] setGroupMemberInfo:groupID info:fullInfo succ:^{
//            if (callback) {
//                callback(0, @"set profile success.");
//            }
//        } fail:^(int code, NSString *desc) {
//            if (callback) {
//                callback(code, desc);
//            }
//        }];
//    } fail:^(int code, NSString *desc) {
//
//    }];
    
}

- (void)createRoom:(NSString *)roomId roomInfo:(NSString *)roomInfo coverUrl:(NSString *)coverUrl callback:(TXCallback)callback {
    if (self.isEnterRoom) {
        if (callback) {
            callback(CODE_ERROE, [NSString stringWithFormat:@"you have been in room :%@ can't create another room: %@", _mRoomId, roomId]);
        }
        return;
    }
    
    if (!self.isLogin) {
        if (callback) {
            callback(CODE_ERROE, @"im  not login yet, create room fail.");
        }
        return;
    }
    
    [V2TIMManager.sharedInstance createGroup:@"Meeting" groupID:roomId groupName:roomInfo succ:^(NSString *groupID) {
        self.mIsEnterRoom = true;
        self.mRoomId = roomId;
        self.mOwnerUserId = self.mSelfUserId;
        
        if (callback) {
            callback(0, @"create room success.");
        }
        
    } fail:^(int code, NSString *desc) {
        NSString *msg = [NSString stringWithFormat:@"%@", desc];
        if (code == 10036) {
            msg = LocalizeReplaceXX(MeetingLocalize(@"Demo.TRTC.Buy.chatroom"), @"https://cloud.tencent.com/document/product/269/11673");
        } else if (code == 10037) {
            msg = LocalizeReplaceXX(MeetingLocalize(@"Demo.TRTC.Buy.grouplimit"), @"https://cloud.tencent.com/document/product/269/11673");
        } else if (code == 10038) {
            msg = LocalizeReplaceXX(MeetingLocalize(@"Demo.TRTC.Buy.groupmemberlimit"), @"https://cloud.tencent.com/document/product/269/11673");
        }
        
        if (code == 10025) {
            self.mIsEnterRoom = true;
            self.mRoomId = roomId;
            self.mOwnerUserId = self.mSelfUserId;
            
            if(callback) {
                callback(0, @"create room success.");
            }
        }
        else {
            NSLog(@"createGroup failed: code[%d] msg[%@]", code, msg);
            if (callback) {
                callback(code, msg);
            }
        }
    }];
}

- (void)destroyRoom:(TXCallback)callback {
    [V2TIMManager.sharedInstance dismissGroup:self.mRoomId succ:^{
        [self cleanStatus];
        
        
        if (callback) {
            callback(0, @"destroy room success.");
        }
    } fail:^(int code, NSString *desc) {
        if (callback) {
            callback(code, desc);
        }
    }];
}

- (void)enterRoom:(NSString *)roomId callback:(TXCallback)callback {
    [V2TIMManager.sharedInstance joinGroup:roomId msg:@"" succ:^{
        NSArray *groupArray = [[NSArray alloc] initWithObjects:roomId, nil];
        [V2TIMManager.sharedInstance getGroupsInfo:groupArray succ:^(NSArray<V2TIMGroupInfoResult *> *groupResultList) {
            if (!groupResultList.count) {
                if (callback) {
                    callback(-1, @"groupResultList is null");
                }
            }
            else {
                
                V2TIMGroupInfoResult *result = [groupResultList objectAtIndex:0];
                if (result) {
                    self.mRoomId = roomId;
                    self.mIsEnterRoom = true;
                    self.mOwnerUserId = result.info.owner;
                    
                    if (callback) {
                        callback(0, @"enter room success.");
                    }
                } else {
                    if (callback) {
                        callback(-1, @"groupResultList is null");
                    }
                }
            }
            
        } fail:^(int code, NSString *desc) {
            if (callback) {
                callback(-1, [NSString stringWithFormat:@"getGroupsInfo error, enter room fail. code: %d msg:%@", code, desc]);
            }
        }];
        
    } fail:^(int code, NSString *desc) {
        if (code == 10013) {
            self.mRoomId = roomId;
            self.mIsEnterRoom = true;
            // self.mOwnerUserId = ""; // TODO
            
            if (callback) {
                callback(0, @"enter room success.");
            }
        } else {
            //10015: 群组 ID 非法，请检查群组 ID 是否填写正确。
            if (callback) {
                callback(code, desc);
            }
        }
    }];
}

- (void)exitRoom:(TXCallback)callback {
    if (!self.isEnterRoom) {
        if (callback) {
            callback(CODE_ERROE, @"not enter room yet, can't exit room.");
        }
        return;
    }
    
    [V2TIMManager.sharedInstance quitGroup:self.mRoomId succ:^{
        [self cleanStatus];
        if (callback) {
            callback(0, @"exit room success.");
        }
    } fail:^(int code, NSString *desc) {
        if (callback) {
            callback(code, desc);
        }
    }];
}

- (void)getUserInfo:(NSArray *)userList callback:(TXUserListCallback)callback {
    NSArray<TXUserInfo *> *array = [[NSArray alloc] init];
    if (!self.isEnterRoom) {
        if (callback) {
            callback(CODE_ERROE, @"get user info list fail, not enter room yet", array);
        }
        return;
    }
    
    if (userList == nil || userList.count == 0) {
        if (callback) {
            callback(CODE_ERROE, @"get user info list fail, user list is empty", array);
        }
        return;
    }
    [[V2TIMManager sharedInstance] getUsersInfo:userList succ:^(NSArray<V2TIMUserFullInfo *> *infoList) {
        NSMutableArray<TXUserInfo *>*infoArray = [NSMutableArray array];
        if (infoList != nil && infoList.count != 0) {
            for (int i = 0; i < infoList.count; i ++) {
                TXUserInfo *userInfo = [[TXUserInfo alloc] init];
                userInfo.userName = infoList[i].nickName;
                userInfo.userId = infoList[i].userID;
                userInfo.avatarURL = infoList[i].faceURL;
                [infoArray addObject:userInfo];
            }
        }
        if (callback) {
            callback(0, @"success", infoArray);
        }
    } fail:^(int code, NSString *desc) {
        if (callback) {
            callback(code, desc, array);
        }
    }];
}

- (void)getGroupMembersInfo:(NSString*)groupID memberList:(NSArray<NSString*>*)memberIdList callback:(TXUserListCallback)callback;
{
    NSArray<TXUserInfo *> *array = [[NSArray alloc] init];
    if (!self.isEnterRoom) {
        if (callback) {
            callback(CODE_ERROE, @"get user info list fail, not enter room yet", array);
        }
        return;
    }
    
    if (memberIdList == nil || memberIdList.count == 0) {
        if (callback) {
            callback(CODE_ERROE, @"get user info list fail, user list is empty", array);
        }
        return;
    }
    
    [[V2TIMManager sharedInstance] getGroupMembersInfo:groupID memberList:memberIdList succ:^(NSArray<V2TIMGroupMemberFullInfo *> *memberList) {
        NSMutableArray<TXUserInfo *>*infoArray = [NSMutableArray array];
        if (memberList != nil && memberList.count != 0) {
            for (int i = 0; i < memberList.count; i ++) {
                TXUserInfo *userInfo = [[TXUserInfo alloc] init];
                userInfo.userName = memberList[i].nickName;
                userInfo.userId = memberList[i].userID;
                userInfo.avatarURL = memberList[i].faceURL;
                if (memberList[i].nameCard.length > 0) {
                    userInfo.nameCard = memberList[i].nameCard;
                }
                else{
                    userInfo.nameCard = [[NSString alloc] initWithData:memberList[i].customInfo[@"groupNickName"] encoding:NSUTF8StringEncoding];
                }
                [infoArray addObject:userInfo];
            }
        }
        if (callback) {
            callback(0, @"success", infoArray);
        }
    } fail:^(int code, NSString *desc) {
        if (callback) {
            callback(code, desc, array);
        }
    }];
}

- (void)sendRoomTextMsg:(NSString *)msg callback:(TXCallback)callback {
    if (!self.isEnterRoom) {
        if (callback) {
            callback(-1, @"send room text fail, not enter room yet.");
        }
        return;
    }

    [V2TIMManager.sharedInstance sendGroupTextMessage:msg to:self.mRoomId priority:V2TIM_PRIORITY_LOW succ:^{
        if (callback) {
            callback(0, @"send group message success.");
        }
    } fail:^(int code, NSString *desc) {
        if (callback) {
            callback(code, desc);
        }
    }];
}

- (void)sendRoomCustomMsg:(NSString *)cmd message:(NSString *)message callback:(TXCallback)callback {
    if (!self.isEnterRoom) {
        if (callback) {
            callback(-1, @"send room custom msg fail, not enter room yet.");
        }
        return;
    }
    
    NSData *customData = [[IMProtocol getCusMsgJsonStr:cmd msg:message] dataUsingEncoding:NSUTF8StringEncoding];
    
    [V2TIMManager.sharedInstance sendGroupCustomMessage:customData to:self.mRoomId priority:V2TIM_PRIORITY_LOW succ:^{
        if (callback) {
            callback(0, @"send group message success.");
        }
    } fail:^(int code, NSString *desc) {
        if (callback) {
            callback(code, desc);
        }
    }];
}

- (void)sendC2CCustomMsg:(NSString *)cmd message:(NSString *)message to:(NSString *)userId callback:(TXCallback)callback{
    NSData *customData = [[IMProtocol getCusMsgJsonStr:cmd msg:message] dataUsingEncoding:NSUTF8StringEncoding];
    [V2TIMManager.sharedInstance sendC2CCustomMessage:customData to:userId succ:^{
        if (callback) {
            callback(0, @"send group message success.");
        }
    } fail:^(int code, NSString *desc) {
        if (callback) {
            callback(code, desc);
        }
    }];
}

- (void)getGroupHistoryMessageList:(NSString *)groupID count:(int)count lastMsg:(V2TIMMessage*)lastMsg succ:(V2TIMMessageListSucc)succ fail:(V2TIMFail)fail{
    [V2TIMManager.sharedInstance getGroupHistoryMessageList:groupID count:count lastMsg:lastMsg succ:^(NSArray<V2TIMMessage *> *msgs) {
        NSMutableArray <V2TIMMessage *> *msgArray = [NSMutableArray array];
        for (V2TIMMessage *mode in msgs) {
            if (mode.elemType == V2TIM_ELEM_TYPE_TEXT) {
                [msgArray addObject:mode];
            }
        }
        if (succ) {
            succ(msgArray);
        }
    } fail:fail];
}

- (void)kickedUser:(NSString *)userId callback:(TXCallback) callback{
    if (!userId.length) {
        return;
    }
    [V2TIMManager.sharedInstance kickGroupMember:self.mRoomId memberList:@[userId] reason:@"主持人踢出" succ:^(NSArray<V2TIMGroupMemberOperationResult *> *resultList) {
        if (callback) {
            callback(0, @"success");
        }
    } fail:^(int code, NSString *desc) {
        if (callback) {
            callback(1, desc);
        }
    }];
}

- (void)transferGroupOwner:(NSString *)userId callback:(TXCallback) callback{
    [V2TIMManager.sharedInstance transferGroupOwner:self.mRoomId member:userId succ:^{
        if (callback) {
            callback(0, @"success");
        }
    } fail:^(int code, NSString *desc) {
        if (callback) {
            callback(1, desc);
        }
    }];
}

- (BOOL)isLogin {
    return _mIsLogin;
}

- (BOOL)isEnterRoom {
    return _mIsLogin && _mIsEnterRoom;
}

- (NSString *)getRoomId{
    return _mRoomId;
}

- (NSString *)getOwnerUserId {
    return _mOwnerUserId;
}

- (NSString *)getMyselfUserId{
    return _mSelfUserId;
}

- (NSString *)getCreaterUserId{
    // TODO: 根据接口返回设置
    return @"987";
}

- (void)resetOwnerUserId:(NSString *)userId
{
    _mOwnerUserId = userId;
}

- (BOOL)isOwner {
    return [_mSelfUserId isEqualToString:_mOwnerUserId];
}

- (BOOL)isCreater{
//    TODO:  根据接口回参进行设置
    return [self.mSelfUserId hasPrefix:@"987"];//[self.mRoomId hasPrefix:[self getCreaterUserId]];
}

- (void)cleanStatus {
    self.mIsEnterRoom = false;
    self.mRoomId = @"";
    self.mOwnerUserId = @"";
    [V2TIMManager.sharedInstance removeSimpleMsgListener:self];
    [V2TIMManager.sharedInstance removeGroupListener:self];
    [V2TIMManager.sharedInstance removeIMSDKListener:self];
}

#pragma mark - V2TIMSimpleMsgListener

/// 收到群文本消息
- (void)onRecvGroupTextMessage:(NSString *)msgID groupID:(NSString *)groupID sender:(V2TIMGroupMemberInfo *)info text:(NSString *)text {
    if (![groupID isEqualToString:self.mRoomId]) {
        return;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(onRoomRecvRoomTextMsg:message:userInfo:)]) {
        TXUserInfo *userInfo = [[TXUserInfo alloc] init];
        userInfo.avatarURL = info.faceURL;
        userInfo.userId = info.userID;
        userInfo.userName = info.nickName;
        [self.delegate onRoomRecvRoomTextMsg:self.mRoomId message:text userInfo:userInfo];
    }
}

/// 收到群自定义（信令）消息
- (void)onRecvGroupCustomMessage:(NSString *)msgID groupID:(NSString *)groupID sender:(V2TIMGroupMemberInfo *)info customData:(NSData *)data {
    if (![groupID isEqualToString:self.mRoomId]) {
        return;
    }
    
    NSError *err = NULL;
    NSDictionary *jsonObj = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&err];
    if (err) {
        NSLog(@"json parse failed");
        return;
    }

    NSString *version = [jsonObj valueForKey:KEY_VERSION];
    if (![version isEqualToString:VALUE_PROTOCOL_VERSION]) {
        NSLog(@"protocol version is not match, ignore msg.");
        return;
    }
    
    int action = [[jsonObj valueForKey:KEY_ACTION] intValue];
    if (action == CODE_ROOM_CUSTOM_MESSAGE) {
        TXUserInfo *userInfo = [[TXUserInfo alloc] init];
        userInfo.avatarURL = info.faceURL;
        userInfo.userId = info.userID;
        userInfo.userName = info.nickName;
        
        TXMeetingPair *cusPair = [[TXMeetingPair alloc] init];
        cusPair = [IMProtocol parseCusMsg:jsonObj];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(onRoomRecvRoomCustomMsg:cmd:message:userInfo:)]) {
            [self.delegate onRoomRecvRoomCustomMsg:self.mRoomId cmd:cusPair.first message:cusPair.second userInfo:userInfo];
        }
    }
}

/// 收到 C2C 自定义（信令）消息
- (void)onRecvC2CCustomMessage:(NSString *)msgID sender:(V2TIMUserInfo *)info customData:(NSData *)data{
 
    NSError *err = NULL;
    NSDictionary *jsonObj = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&err];
    if (err) {
        NSLog(@"json parse failed");
        return;
    }

    NSString *version = [jsonObj valueForKey:KEY_VERSION];
    if (![version isEqualToString:VALUE_PROTOCOL_VERSION]) {
        NSLog(@"protocol version is not match, ignore msg.");
        return;
    }
    
    int action = [[jsonObj valueForKey:KEY_ACTION] intValue];
    if (action == CODE_ROOM_CUSTOM_MESSAGE) {
        TXUserInfo *userInfo = [[TXUserInfo alloc] init];
        userInfo.avatarURL = info.faceURL;
        userInfo.userId = info.userID;
        userInfo.userName = info.nickName;
        
        TXMeetingPair *cusPair = [[TXMeetingPair alloc] init];
        cusPair = [IMProtocol parseCusMsg:jsonObj];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(onC2CRecvRoomCustomMsg:cmd:message:userInfo:)]) {
            [self.delegate onC2CRecvRoomCustomMsg:msgID cmd:cusPair.first message:cusPair.second userInfo:userInfo];
        }
    }
}


#pragma mark - V2TIMGroupListener
         
/// 某个已加入的群被解散了（该群所有的成员都能收到）
- (void)onGroupDismissed:(NSString *)groupID opUser:(V2TIMGroupMemberInfo *)opUser {
    // 如果发现房间已经解散，那么内部退一次房间
    [self exitRoom:^(NSInteger code, NSString *msg) {
        NSString *roomId = self.mRoomId;
        [self cleanStatus];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(onRoomDestroy:)]) {
            [self.delegate onRoomDestroy:roomId];
        }
    }];
}

- (void)onMemberKicked:(NSString *)groupID opUser:(V2TIMGroupMemberInfo *)opUser memberList:(NSArray<V2TIMGroupMemberInfo *>*)memberList{
    TXUserInfo *opUserInfo = [[TXUserInfo alloc] init];
    opUserInfo.avatarURL = opUser.faceURL;
    opUserInfo.userId = opUser.userID;
    opUserInfo.userName = opUser.nickName;
    NSMutableArray *memberListArr = NSMutableArray.array;
    for (NSInteger index = 0; index < memberList.count; index++) {
        V2TIMGroupMemberInfo *model = memberList[index];
        TXUserInfo *memberInfo = [[TXUserInfo alloc] init];
        memberInfo.avatarURL = model.faceURL;
        memberInfo.userId = model.userID;
        memberInfo.userName = model.nickName;
        [memberListArr addObject:memberInfo];
    }
    
    if ([self.delegate respondsToSelector:@selector(onMemberKickedWithOpUser:memberList:)]) {
        [self.delegate onMemberKickedWithOpUser:opUserInfo memberList:memberListArr];
    }
}

/// 某个群成员新变更
/// @param groupID 群ID
/// @param changeInfoList 成员变更信息
- (void)onMemberInfoChanged:(NSString *)groupID changeInfoList:(NSArray <V2TIMGroupMemberChangeInfo *> *)changeInfoList;
{
    NSMutableArray *changeMemberIdList = [NSMutableArray array];
    for (NSInteger index = 0; index < changeInfoList.count; index++) {
        [changeMemberIdList addObject:changeInfoList[index].userID];
    }
    if ([self.delegate respondsToSelector:@selector(onMemberInfoChanged:changeMemberIdList:)]) {
        [self.delegate onMemberInfoChanged:groupID changeMemberIdList:changeMemberIdList];
    }
}

/// 某个已加入的群的信息被修改了（该群所有的成员都能收到）
- (void)onGroupInfoChanged:(NSString *)groupID changeInfoList:(NSArray <V2TIMGroupChangeInfo *> *)changeInfoList{
    if (groupID && [self.mRoomId isEqualToString:groupID]) {
        __weak typeof(self) wealSelf = self;
        [changeInfoList enumerateObjectsUsingBlock:^(V2TIMGroupChangeInfo * _Nonnull obj,
                                                     NSUInteger idx,
                                                     BOOL * _Nonnull stop) {
            NSLog(@"on group info changed (roomId=%@ type=%d value=%@)",self.mRoomId,obj.type,obj.value);
            __strong typeof(wealSelf) strongSelf = wealSelf;
            if (obj.type == V2TIM_GROUP_INFO_CHANGE_TYPE_OWNER) {///< 群主变更
                if ([strongSelf.delegate respondsToSelector:@selector(onRoomMasterChanged:currentUserId:)]) {
                    NSString *previousUserId = self.mOwnerUserId;
                    self.mOwnerUserId = obj.value;

//                    TUIRoomUserInfo *masterInfo = [TUIRoomUserManage getUser:obj.value];
//                    masterInfo.role = TUIRoomMaster;
                    
                    [strongSelf.delegate onRoomMasterChanged:previousUserId currentUserId:obj.value];
                }
            }
        }];
    }
}

// MARK: - V2TIMSDKListener
/// SDK 正在连接到服务器
- (void)onConnecting;
{
    
}
/// SDK 已经成功连接到服务器
- (void)onConnectSuccess;
{
    
}
/// SDK 连接服务器失败
- (void)onConnectFailed:(int)code err:(NSString*)err;
{
    
}
/// 当前用户被踢下线，此时可以 UI 提示用户，并再次调用 V2TIMManager 的 login() 函数重新登录。
- (void)onKickedOffline;
{
//  TODO:  最简单的方式是用过notification全局通知，在我的南瑞里面接收通知
    // Notification_CurrentDiviceOffLine
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Notification_CurrentDiviceOffLine" object:nil];
}
/// 在线时票据过期：此时您需要生成新的 userSig 并再次调用 V2TIMManager 的 login() 函数重新登录。
- (void)onUserSigExpired;
{
    
}
/// 当前用户的资料发生了更新
- (void)onSelfInfoUpdated:(V2TIMUserFullInfo *)Info;
{
    
}
@end

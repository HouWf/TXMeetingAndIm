//
//  ViewController.m
//  tx-test
//
//  Created by 候文福 on 2022/1/29.
//

#import "ViewController.h"


static NSString *userNameKey = @"USER_NICKNAME";
static NSString *userIdKey = @"USER_ID";

@interface ViewController ()

@property (nonatomic, strong) UIButton *button;

@property (nonatomic, strong) UITextField *nameField;

@property (nonatomic, strong) UITextField *idField;

@property (nonatomic, strong) UILabel *messageLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"登录";
    
    NSString *name = [[NSUserDefaults standardUserDefaults] objectForKey:userNameKey];
    NSString *userid = [[NSUserDefaults standardUserDefaults] objectForKey:userIdKey];
    self.nameField.text = name;
    self.idField.text = userid;
    [self.nameField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(100);
        make.centerX.equalTo(self.view);
        make.width.mas_equalTo(200);
        make.height.mas_equalTo(30);
    }];
    
    [self.idField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.height.equalTo(self.nameField);
        make.top.equalTo(self.nameField.mas_bottom).offset(20);
    }];
    
    [self.button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.idField.mas_bottom).offset(50);
        make.left.equalTo(self.view).offset(100);
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(50);
    }];
    
    [self.messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.button.mas_bottom).offset(50);
        make.left.mas_equalTo(30);
        make.right.mas_equalTo(-30);
        make.height.mas_lessThanOrEqualTo(300);
    }];
    
    __weak typeof(self) weakSelf = self;
    [[ProfileManager shared] autoLoginWithSuccess:^{
        [weakSelf loginIM:^(BOOL success) {
            if (success) {
                [self loginSuccess];
            }
        }];
        
    } failed:^(NSString * _Nonnull err) {
        self.messageLabel.text = [NSString stringWithFormat:@"登录失败：\n %@", err];
    }];
    
}

- (void)loginIM:(void(^)(BOOL success))complate {
    ProfileManager *fileManager = [ProfileManager shared];
    NSString *userId = [fileManager curUserID];
    NSString *userSig = [fileManager curUserSig];
    NSString *user = [[V2TIMManager sharedInstance] getLoginUser];
    if (user != userId) {
        __weak typeof(self) weakSelf = self;
        [fileManager IMLoginWithUserSig:userSig success:^{
            [fileManager synchronizUserInfo];
            
            [fileManager setNickNameWithName:weakSelf.nameField.text success:^{
                [[NSUserDefaults standardUserDefaults] setObject:weakSelf.nameField.text forKey:userNameKey];
            } failed:^(NSString * _Nonnull err) {
                weakSelf.messageLabel.text = [NSString stringWithFormat:@"昵称设置失败：\n %@", err];
            }];
            complate(true);
        } failed:^(NSString * _Nonnull err) {
            weakSelf.messageLabel.text = [NSString stringWithFormat:@"IM登录失败：\n %@", err];
            complate(false);
        }];
    }else{
        complate(true);
    }
}

- (void)enterRoom{
    if (self.nameField.text.length == 0 || self.idField.text.length == 0) {
        self.messageLabel.text = @"请输入昵称和用户ID";
        return;
    }
    
    V2TIMLoginStatus loginStatus = [[ProfileManager shared] getV2ImLoginStatus];
    //    是否已登录
    if (loginStatus == V2TIM_STATUS_LOGINED) {
        if(@"直接进入会议"){
            // 直接进入会议通讯界面
            //  参照TRTCMeetingNewViewController+UI中enterroom()方法
        }
        else{
            // 进入创建会议界面
            [self getMeeting];
        }
    }
    else {
        // 如果未登录，先登录，成功后循环当前enterRoom()方法逻辑
        [self loginWithPhone:self.idField.text code:@""];
    }
}

- (void)loginWithPhone:(NSString *)phone code:(NSString *)code {
    __weak typeof(self) weakSelf = self;
    [[ProfileManager shared] loginWithPhone:phone code:code success:^{
        [self loginIM:^(BOOL success) {
            if (success) {
                [[NSUserDefaults standardUserDefaults] setObject:self.idField.text forKey:userIdKey];
                [weakSelf loginSuccess];
            }
        }];
    } failed:^(NSString * _Nonnull err) {
        weakSelf.messageLabel.text = [NSString stringWithFormat:@"登录失败：\n %@", err];
    } auto: NO];
}

- (void)loginSuccess{

    NSString *name = [ProfileManager shared].curUserModel.name;
    NSString *beforeName = [[NSUserDefaults standardUserDefaults] objectForKey:userNameKey];
    if (name.length == 0) {
        __weak typeof(self) weakSelf = self;
        [[ProfileManager shared] synchronizUserInfo];
        [[ProfileManager shared] setNickNameWithName:beforeName success:^{
            [weakSelf getMeeting];
        } failed:^(NSString * _Nonnull err) {
            weakSelf.messageLabel.text = [NSString stringWithFormat:@"昵称设置失败：\n %@", err];
        }];
        
    }
    else {
        [self getMeeting];
    }
}

- (void)getMeeting{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSInteger sdkId = [[ProfileManager shared] getAPPID];
        NSString *userId = [[ProfileManager shared] curUserID];
        NSString *userSig = [[ProfileManager shared] curUserSig];
        
        [[TRTCMeeting sharedInstance] login:(int)sdkId userId:userId userSig:userSig callback:^(NSInteger code, NSString * _Nullable message) {
            NSLog(@"Login code=%ld message=%@", (long)code, message);
            // 根据业务增加逻辑
            TRTCMeetingNewViewController *vc = [[TRTCMeetingNewViewController alloc] init];
            vc.title = @"进入会议";
            
            [vc enterRoom];
            
//                vc.setScanInfo(info: ["roomId":"2222"]) // 扫码进入
//              会议设置 start
//                let roomId = UInt32("11111") // 会议ID
//                let openCamera = false       // 会议开启摄像头
//                let openMic = false          // 开启麦克风
//                let openSpeaker = false
//                UserDefaults.standard.set(roomId, forKey: "TRTCMeetingRoomIDKey")
//                UserDefaults.standard.set(openCamera, forKey: "TRTCMeetingOpenCameraKey")
//                UserDefaults.standard.set(openMic, forKey: "TRTCMeetingOpenMicKey")
//                UserDefaults.standard.set(openSpeaker, forKey: "TRTCMeetingOpenSpeakerKey")
//              end
            
            [self.navigationController pushViewController:vc animated:YES];
        }];
    });
}

#pragma mark - lazy

- (UIButton *)button{
    if (!_button) {
        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        _button.backgroundColor = UIColor.yellowColor;
        [_button setTitle:@"进入会议" forState:UIControlStateNormal];
        [_button setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
        _button.titleLabel.font = [UIFont systemFontOfSize:10];
        [_button addTarget:self action:@selector(enterRoom) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_button];
    }
    return _button;
}

- (UITextField *)nameField{
    if (!_nameField) {
        _nameField = [[UITextField alloc] init];
        _nameField.placeholder = @"请输入昵称";
        _nameField.borderStyle = UITextBorderStyleRoundedRect;
        _nameField.font = [UIFont systemFontOfSize:15];
        [self.view addSubview:_nameField];
    }
    return _nameField;
}

- (UITextField *)idField{
    if (!_idField) {
        _idField = [[UITextField alloc] init];
        _idField.placeholder = @"请输入用户ID";
        _idField.borderStyle = UITextBorderStyleRoundedRect;
        _idField.font = [UIFont systemFontOfSize:15];
        _idField.keyboardType = UIKeyboardTypeNumberPad;
        [self.view addSubview:_idField];
    }
    return _idField;
}

- (UILabel *)messageLabel{
    if (!_messageLabel) {
        _messageLabel = [[UILabel alloc] init];
        _messageLabel.font = [UIFont systemFontOfSize:10];
        _messageLabel.numberOfLines = 0;
        _messageLabel.textColor = UIColor.lightGrayColor;
        [self.view addSubview:_messageLabel];
    }
    return _messageLabel;
}

@end

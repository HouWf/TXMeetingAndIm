# TXMeetingAndIm
基于TUIMeeting的腾讯视频会议，支持自定义弹幕，支持自定义群组聊天

### 使用步骤
1. Download或者clone项目到本地
2. Target：tx-test中找到Debuge/GenerateTestUserSig.swift类
3. 替换SDKAPPID和SECRETKEY，如果没有则需要去https://console.cloud.tencent.com/avc创建一个
4. 启动项目查看效果

### 相关说明：
/**
 * 腾讯云 SDKAppId，需要替换为您自己账号下的 SDKAppId。
 *
 * 进入腾讯云云通信[控制台](https://console.cloud.tencent.com/avc) 创建应用，即可看到 SDKAppId，
 * 它是腾讯云用于区分客户的唯一标识。
 */
let SDKAPPID: Int = 0;

/**
 *  签名过期时间，建议不要设置的过短
 *
 *  时间单位：秒
 *  默认时间：7 x 24 x 60 x 60 = 604800 = 7 天
 */
let EXPIRETIME: Int = 604800;

/**
 * 计算签名用的加密密钥，获取步骤如下：
 *
 * step1. 进入腾讯云云通信[控制台](https://console.cloud.tencent.com/avc) ，如果还没有应用就创建一个，
 * step2. 单击“应用配置”进入基础配置页面，并进一步找到“帐号体系集成”部分。
 * step3. 点击“查看密钥”按钮，就可以看到计算 UserSig 使用的加密的密钥了，请将其拷贝并复制到如下的变量中
 *
 * 注意：该方案仅适用于调试Demo，正式上线前请将 UserSig 计算代码和密钥迁移到您的后台服务器上，以避免加密密钥泄露导致的流量盗用。
 * 文档：https://cloud.tencent.com/document/product/269/32688#Server
 */
let SECRETKEY = "";


### Demo研发着重要说明：Demo中有表情版权，仅可做Demo演示使用，请替换成自己的表情，勿直接使用，否则我们将有权追究相关法律责任。
**表情已移除**
- 具体表情配置请参照：TUIMeeting/TRTC/ui/IMView/Utils/EmoTools.swift配置，在TUIMeeting/TRTC/MeetingAssets/IM/emo文件夹中增加对应name图片

### 截图
<img width="416" alt="image" src="https://user-images.githubusercontent.com/31474080/186554230-0f29a38a-f8ac-459e-b85f-d2cfe2aa327c.png">
<img width="412" alt="image" src="https://user-images.githubusercontent.com/31474080/186554341-d0a1b257-19a1-4331-9d34-dcc89d89c516.png">
<img width="411" alt="image" src="https://user-images.githubusercontent.com/31474080/186554342-9e68df08-5c35-466e-80c2-b77ce87c3453.png">
<img width="399" alt="image" src="https://user-images.githubusercontent.com/31474080/186554343-aacaa878-8ec8-4378-8323-c7b0e9503022.png">




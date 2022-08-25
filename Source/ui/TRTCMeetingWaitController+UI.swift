//
//  TRTCMeetingWaitController+UI.swift
//  TUIMeeting
//
//  Created by 候文福 on 2022/1/24.
//

import Foundation


extension TRTCMeetingWaitController {
    
    func setupUI(){
        view.backgroundColor = UIColor.init(red: 29, green: 34, blue: 35)

        customNavBackView.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalTo(view)
            make.height.equalTo(topPadding + 45)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(customNavBackView)
            make.top.equalTo(topPadding + 10)
        }
        
        leaveButton.snp.makeConstraints { (make) in
            make.right.equalTo(-15)
            make.centerY.equalTo(titleLabel)
        }
        
        viewBackgroundView.snp.makeConstraints { (make) in
            make.top.equalTo(customNavBackView.snp.bottom)
            make.left.right.bottom.equalTo(view)
        }
        
        meetingTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(40)
            make.left.right.equalTo(viewBackgroundView)
        }
        
        themeTipLabel.snp.makeConstraints { (make) in
            make.left.equalTo(20)
            make.width.equalTo(70)
            make.top.equalTo(meetingTitleLabel.snp.bottom).offset(30)
        }
        
        themeValueLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(themeTipLabel)
            make.left.equalTo(themeTipLabel.snp.right).offset(10)
            make.right.equalTo(-20)
        }
        
        timeTipLabel.snp.makeConstraints { (make) in
            make.top.equalTo(themeTipLabel.snp.bottom).offset(20)
            make.left.width.equalTo(themeTipLabel)
        }
        
        timeValueLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(timeTipLabel)
            make.left.right.equalTo(themeValueLabel)
        }
        
        optionTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(timeTipLabel.snp.bottom).offset(40)
            make.left.equalTo(timeTipLabel)
            make.right.equalTo(-20)
        }
        
        micSwitchView.snp.makeConstraints { (make) in
            make.top.equalTo(optionTitleLabel.snp.bottom).offset(20)
            make.left.equalTo(optionTitleLabel.snp.left)
            make.right.equalTo(optionTitleLabel.snp.right)
            make.height.equalTo(40)
        }
        
        speakerSwitchView.snp.makeConstraints { (make) in
            make.left.right.height.equalTo(micSwitchView)
            make.top.equalTo(micSwitchView.snp.bottom).offset(10)
        }
        
        cameraSwitchView.snp.makeConstraints { (make) in
            make.left.right.height.equalTo(speakerSwitchView)
            make.top.equalTo(speakerSwitchView.snp.bottom).offset(10)
        }
        
        
    }
 
}

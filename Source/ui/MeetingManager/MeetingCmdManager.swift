//
//  MeetingCmdManager.swift
//  TUIMeeting
//
//  Created by 候文福 on 2022/1/24.
//

import Foundation

@objc public class MeetingCmdManager: NSObject {
    @objc public static let shared = MeetingCmdManager()
    private override init() {}
    
    @objc var meetingCtrModel: MeetingControlModel = MeetingManager.shared.meetingCtrModel

   
    
}

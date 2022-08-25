//
//  utils.swift
//  Alamofire
//
//  Created by 候文福 on 2022/3/14.
//

import Foundation

@objc public class Tools: NSObject
{
    @objc public static let shared = Tools()
    private override init() {}

    /// GCD定时器倒计时⏳
    ///   - timeInterval: 循环间隔时间
    ///   - repeatCount: 重复次数
    ///   - handler: 循环事件, 闭包参数： 1. timer， 2. 剩余执行次数
    public func DispatchTimer(timeInterval: Double, repeatCount:Int, handler:@escaping (DispatchSourceTimer?, Int)->())
    {
        let timer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.main)
        var count = repeatCount
        timer.schedule(wallDeadline: .now(), repeating: timeInterval)
        timer.setEventHandler(handler: {
            count -= 1
            DispatchQueue.main.async {
                handler(timer, count)
            }
            if count == 0 {
                timer.cancel()
            }
        })
        timer.resume()
    }
    
    // 延迟
    public func DispatchTimer(delay:Double, timeInterval: Double, repeatCount:Int, handler:@escaping (DispatchSourceTimer?, Int)->()) -> DispatchSourceTimer
    {
        let timer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.main)
        if repeatCount <= 0 {
            timer.cancel()
            return timer
        }
        var count = repeatCount
        timer.schedule(wallDeadline: .now() + delay, repeating: timeInterval)
        timer.setEventHandler(handler: {
            count -= 1
            DispatchQueue.main.async {
                handler(timer, count)
            }
            if count <= 0 {
                timer.cancel()
            }
        })
        timer.resume()
        return timer
    }
  

    /// GCD定时器循环操作
    ///   - timeInterval: 循环间隔时间
    ///   - handler: 循环事件
    public func DispatchTimer(timeInterval: Double, handler:@escaping (DispatchSourceTimer?)->()) -> DispatchSourceTimer
    {
        let timer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.main)
        timer.schedule(deadline: .now(), repeating: timeInterval)
        timer.setEventHandler {
            DispatchQueue.main.async {
                handler(timer)
            }
        }
        timer.resume()
        return timer
    }

    /// GCD延时操作
    ///   - after: 延迟的时间
    ///   - handler: 事件
    public func DispatchAfter(after: Double, handler:@escaping ()->())
    {
        DispatchQueue.main.asyncAfter(deadline: .now() + after) {
            handler()
        }
    }

}

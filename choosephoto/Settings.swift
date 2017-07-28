//
//  Settings.swift
//  choosephoto
//
//  Created by 神楽坂雅詩 on 2017/7/28.
//  Copyright © 2017年 KagurazakaYashi. All rights reserved.
//

import UIKit
import AVFoundation

class Settings: NSObject {
    var 拍摄品质:AVCaptureSession.Preset = AVCaptureSession.Preset.photo
    var 色彩格式:Int = 1111970369
    var 默认摄像头:Int = 0
    var 快门音效:Bool = true
    var 每行显示:Int = 2
    var 清空时不需要确认:Bool = true
    var 点击HOME按钮时完全退出:Bool = false
    var 缓存限制:Int = 100
    var 单点图片时返回照片列表:Bool = false
    var 保存图片后返回照片列表:Bool = true
    var 使用第三方社会化分享:Bool = false
    
    func 载入设置() {
        let 配置文件:UserDefaults = UserDefaults.standard
        if 配置文件.object(forKey: "拍摄品质") != nil {
            let 拍摄品质代码 = 配置文件.object(forKey: "拍摄品质") as! Int
            switch 拍摄品质代码 {
            case 1:
                拍摄品质 = .low
                break
            case 2:
                拍摄品质 = .medium
                break
            case 3:
                拍摄品质 = .high
                break
            case 4:
                拍摄品质 = .cif352x288
                break
            case 5:
                拍摄品质 = .vga640x480
                break
            case 6:
                拍摄品质 = .hd1280x720
                break
            case 7:
                拍摄品质 = .hd1920x1080
                break
            case 8:
                拍摄品质 = .hd4K3840x2160
                break
            case 9:
                拍摄品质 = .iFrame960x540
                break
            case 10:
                拍摄品质 = .iFrame1280x720
                break
            default:
                break
            }
        }
        if 配置文件.object(forKey: "色彩格式") != nil {
            色彩格式 = 配置文件.object(forKey: "色彩格式") as! Int
        }
        if 配置文件.object(forKey: "默认摄像头") != nil {
            默认摄像头 = 配置文件.object(forKey: "默认摄像头") as! Int
        }
        if 配置文件.object(forKey: "快门音效") != nil {
            快门音效 = 配置文件.object(forKey: "快门音效") as! Bool
        }
        if 配置文件.object(forKey: "每行显示") != nil {
            每行显示 = 配置文件.object(forKey: "每行显示") as! Int
        }
        if 配置文件.object(forKey: "清空时不需要确认") != nil {
            清空时不需要确认 = 配置文件.object(forKey: "清空时不需要确认") as! Bool
        }
        if 配置文件.object(forKey: "点击HOME按钮时完全退出") != nil {
            点击HOME按钮时完全退出 = 配置文件.object(forKey: "点击HOME按钮时完全退出") as! Bool
        }
        if 配置文件.object(forKey: "缓存限制") != nil {
            缓存限制 = 配置文件.object(forKey: "缓存限制") as! Int
        }
        if 配置文件.object(forKey: "单点图片时返回照片列表") != nil {
            单点图片时返回照片列表 = 配置文件.object(forKey: "单点图片时返回照片列表") as! Bool
        }
        if 配置文件.object(forKey: "保存图片后返回照片列表") != nil {
            保存图片后返回照片列表 = 配置文件.object(forKey: "保存图片后返回照片列表") as! Bool
        }
        if 配置文件.object(forKey: "使用第三方社会化分享") != nil {
            使用第三方社会化分享 = 配置文件.object(forKey: "使用第三方社会化分享") as! Bool
        }
    }
}

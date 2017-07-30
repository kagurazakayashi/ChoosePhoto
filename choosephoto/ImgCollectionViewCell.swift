//
//  ImgCollectionViewCell.swift
//  choosephoto
//
//  Created by 神楽坂雅詩 on 2017/7/22.
//  Copyright © 2017年 KagurazakaYashi. All rights reserved.
//

import UIKit
import QuartzCore

class ImgCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var 缩略图框: UIImageView!
    
    public func 设置缩略图(图片:UIImage) {
        self.layer.borderColor = 全局主题颜色[0]
        self.backgroundColor = UIColor.gray
//        let 屏幕宽度 = UIScreen.main.bounds.size.width
//        let 列宽度:CGFloat = 屏幕宽度 / 列数
//        let 列高度:CGFloat = 图片.size.height / 图片.size.width * 列宽度
//        self.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: 列宽度, height: 列高度)
//        self.缩略图框.frame = CGRect(x: 0, y: 0, width: 列宽度, height: 列高度)
        缩略图框.image = 图片
    }
}

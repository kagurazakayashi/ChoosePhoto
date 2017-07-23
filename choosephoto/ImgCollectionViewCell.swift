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
        缩略图框.image = 图片
    }
    
}

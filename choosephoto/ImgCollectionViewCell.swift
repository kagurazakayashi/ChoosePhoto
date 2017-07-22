//
//  ImgCollectionViewCell.swift
//  choosephoto
//
//  Created by 神楽坂雅詩 on 2017/7/22.
//  Copyright © 2017年 KagurazakaYashi. All rights reserved.
//

import UIKit

class ImgCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var 缩略图框: UIImageView!
    
    public func 设置缩略图(图片:UIImage) {
        缩略图框.image = 图片
    }
    
}

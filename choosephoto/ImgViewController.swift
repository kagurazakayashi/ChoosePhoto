//
//  ImgViewController.swift
//  choosephoto
//
//  Created by 神楽坂雅詩 on 2017/7/23.
//  Copyright © 2017年 KagurazakaYashi. All rights reserved.
//

import UIKit

class ImgViewController: UIViewController, UITabBarDelegate {
    
    @IBOutlet weak var 滚动框: UIScrollView!
    @IBOutlet weak var 图片框: UIImageView!
    @IBOutlet weak var 底部工具栏: UITabBar!
    
    var 上次手指位置:CGPoint = CGPoint(x: 0, y: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        底部工具栏.delegate = self
        图片归位()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func 装入图片(图片:UIImage) {
        图片框.image = 图片
    }
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if tabBar.tag == 1000 {
            switch item.tag {
            case 1001: //返回
                关闭图片浏览器()
                break
            case 1002: //保存
                UIImageWriteToSavedPhotosAlbum(图片框.image!, self, nil, nil)
                关闭图片浏览器()
                break
            case 1003: //复位
                图片归位()
                break
            case 1004: //分享
                let 分享控制器:UIActivityViewController = UIActivityViewController(activityItems: [图片框.image!], applicationActivities: nil)
                self.present(分享控制器, animated: true, completion: nil)
                break
            default:
                break
            }
        }
    }
    
    func 关闭图片浏览器() {
        dismiss(animated: true) {
            self.图片框.image = nil
        }
    }
    func 图片归位() {
        图片框.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        图片框.frame = CGRect(x: 0, y: 0, width: 滚动框.frame.width, height: 滚动框.frame.height-49)
    }
    
    func 正在保存到相册(image: UIImage, didFinishSavingWithError error: NSErrorPointer, contextInfo: UnsafeRawPointer) {
        if error != nil
        {
            print("保存到相册失败")
            return
        }
        print("已保存到相册")
    }
    
    @IBAction func 双指拖动(_ sender: UIPinchGestureRecognizer) {
        if (sender.state == UIGestureRecognizerState.began || sender.state == UIGestureRecognizerState.changed) {
            var 放大倍数:CGFloat = sender.scale
            if 放大倍数 < 1 {
                放大倍数 = 1.0
            }
            图片框.transform = CGAffineTransform(scaleX: 放大倍数, y: 放大倍数)
        }
    }
    
    @IBAction func 单指拖动(_ sender: UIPanGestureRecognizer) {
        let 滚动框手指位置:CGPoint = sender.location(in: 滚动框)
        if (sender.state == UIGestureRecognizerState.changed) {
            let 差异位置:CGPoint = CGPoint(x: (滚动框手指位置.x-上次手指位置.x), y: (滚动框手指位置.y-上次手指位置.y))
            上次手指位置 = 滚动框手指位置
            图片框.frame = CGRect(x: (图片框.frame.origin.x+差异位置.x), y: (图片框.frame.origin.y+差异位置.y), width: 图片框.frame.width, height: 图片框.frame.height)
        } else if (sender.state == UIGestureRecognizerState.began) {
            上次手指位置 = 滚动框手指位置
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

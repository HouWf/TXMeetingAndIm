//
//  MeetingMainImView+collectionView.swift
//  TUIMeeting
//
//  Created by 候文福 on 2022/8/14.
//

import Foundation
import UIKit

protocol EmoCellDelegate: AnyObject {
    func didselectItem(_ emoItem: IMEmoModel)
}

class emoView : UIView {
    
    lazy var imageView: UIImageView = {
        let view = UIImageView()
        self.addSubview(view)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView.snp.makeConstraints { make in
            make.width.height.equalTo(30)
            make.center.equalToSuperview()
        }
        imageView.backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class emoCell : UICollectionViewCell {
    
    weak var delegate: EmoCellDelegate!
   
    var emoItems = [IMEmoModel]() {
        didSet {
            configEmoItems(models: emoItems)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override var isSelected: Bool {
        didSet {
            
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configEmoItems(models:  [IMEmoModel]){
        // 单个表情宽高
        let emoitemSize = EmoTools.shared.getEmoSize()
        //每行显示6个
        let imgCount: CGFloat = EmoTools.shared.rowCount
        //每个图片宽高
        let imageW = emoitemSize.width
        let imageH = emoitemSize.height
        //间隙
        let padding = 5.0
        
        for index in 0...models.count - 1{
            let model = models[index]
            let picName = model.pic
            let img = UIImage.init(named: picName, in: MeetingBundle(), compatibleWith: nil)
            
            let view = emoView.init()
            view.imageView.image = img
            view.backgroundColor = .clear
            view.tag = index
            let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(itemTap))
            view.addGestureRecognizer(tapGesture)
            contentView.addSubview(view)

            //求余,用于X轴索引(每一行达到6的整数时,求余就是零)
            let yu =  CGFloat(index).truncatingRemainder(dividingBy: imgCount)
            //X轴坐标
            let X = yu * (imageW + padding) + padding
            //y轴坐标(索引除以每行的个数,得到每行的y轴坐标)
            let Y = CGFloat( index / Int(imgCount)) * (imageH + padding)
            
            view.snp.makeConstraints { make in
                make.left.equalTo(X)
                make.top.equalTo(Y)
                make.width.equalTo(imageW)
                make.height.equalTo(imageH)
            }
        }
    }
    
    @objc func itemTap(gesture: UITapGestureRecognizer){
        let model = self.emoItems[gesture.view!.tag]
        self.delegate?.didselectItem(model)
    }
}

extension MeetingMainImView: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource, EmoCellDelegate{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let row = EmoTools.shared.rowCount
        let column = EmoTools.shared.columnCount
        return Int(ceil(Double( self.emoSource.count) / (row * column)))
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "emoCell", for: indexPath) as! emoCell
        let perCount = Int(EmoTools.shared.rowCount * EmoTools.shared.columnCount)
        let startIndex = indexPath.row * perCount
        let endIndex = (startIndex + perCount < self.emoSource.count ? startIndex + perCount : self.emoSource.count)
        var attendeeModels = [IMEmoModel]()
        for index in startIndex..<endIndex {
            if index < self.emoSource.count {
                attendeeModels.append(self.emoSource[index])
            }
        }
        cell.emoItems = attendeeModels
        cell.delegate = self
        return cell
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: itemWidth, height: itemHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let delay = abs(velocity.x) > 0.3 ? 0.3 : 0.0
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            let offsetYu = Int(scrollView.contentOffset.x) % Int(scrollView.frame.width)
            let offsetMuti = CGFloat(offsetYu) / (scrollView.frame.width)
            let curPage = (offsetMuti > 0.5 ? 1 : 0) + (Int(scrollView.contentOffset.x) / Int(scrollView.frame.width))
            self.pageControl.currentPage = curPage
            scrollView.setContentOffset(CGPoint(x: Int(scrollView.frame.width) * curPage, y: 0), animated: true)
        }
    }
    
    // EmoCellDelegate
    func didselectItem(_ emoItem: IMEmoModel) {
        print("\(emoItem.name)")
        self.sendEmo(itemModel: emoItem)
    }
    
}



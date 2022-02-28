//
//  DiaryCollectionViewCell.swift
//  Diary
//
//  Created by limyunhwi on 2022/02/27.
//

import UIKit

class DiaryCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    //이 생성자는 UIView가 xib나 스토리보드에서 생성될 때 이 생성자를 통해 객체가 생성된다.
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        //셀의 테두리 그리기
        self.contentView.layer.cornerRadius = 3.0
        self.contentView.layer.borderWidth = 1.0
        self.contentView.layer.borderColor = UIColor.black.cgColor
    }
}

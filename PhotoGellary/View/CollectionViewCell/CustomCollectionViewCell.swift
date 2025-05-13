//
//  CustomCollectionViewCell.swift
//  PhotoGellary
//
//  Created by TONMOY BISHWAS on 13/8/24.
//

import UIKit

class CustomCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "CustomCollectionViewCell"
    static func nib() -> UINib {
        return UINib(nibName: "CustomCollectionViewCell", bundle: nil)
    }
    
    @IBOutlet weak var imgPhoto: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}

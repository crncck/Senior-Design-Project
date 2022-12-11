//
//  ProfileCell.swift
//  FinalProject
//
//  Created by Ceren Çiçek on 16.04.2022.
//

import UIKit

class ProfileCell: UICollectionViewCell {

    // MARK: - Properties

    var viewModel: PostViewModel? {
        didSet { configure() }
    }

    private let postImageView: UIImageView = {
        let iv = UIImageView()
//        iv.layer.cornerRadius = 10
        iv.image = #imageLiteral(resourceName: "venom-7")
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .lightGray

        addSubview(postImageView)
        postImageView.fillSuperview()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure() {
        guard let viewModel = viewModel else { return }

        postImageView.sd_setImage(with: viewModel.imageUrl)

        backgroundColor = .clear

    }

    private var shadowLayer: CAShapeLayer!

    override func layoutSubviews() {
        super.layoutSubviews()

        if shadowLayer == nil {
            shadowLayer = CAShapeLayer()
            shadowLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: 12).cgPath
            shadowLayer.fillColor = UIColor.white.cgColor

            shadowLayer.shadowColor = UIColor.gray.cgColor
            shadowLayer.shadowPath = shadowLayer.path
            shadowLayer.shadowOffset = CGSize(width: 3, height: 3)
            shadowLayer.shadowOpacity = 0.4
            shadowLayer.shadowRadius = 8

            layer.insertSublayer(shadowLayer, at: 0)
            //layer.insertSublayer(shadowLayer, below: nil) // also works
        }
    }


}



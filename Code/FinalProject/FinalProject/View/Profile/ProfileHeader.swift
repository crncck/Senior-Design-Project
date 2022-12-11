//
//  ProfileHeader.swift
//  FinalProject
//
//  Created by Ceren Çiçek on 16.04.2022.
//

import UIKit
import SDWebImage

protocol ProfileHeaderDelegate: class {
    func header(_ profileHeader: ProfileHeader, didTapActionButtonFor user: User)
}

class ProfileHeader: UICollectionReusableView {

    // MARK: - Properties

    var viewModel: ProfileHeaderViewModel? {
        didSet { configure() }
    }

    weak var delegate: ProfileHeaderDelegate?

    private let profileImageView: UIImageView = {

        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()

    private let backgroundImageView: UIImageView = {

        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textAlignment = .center
        return label
    }()

    // lazy --> because of addTarget
    private lazy var editProfileFollowButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Loading", for: .normal)
        button.layer.cornerRadius = 10
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.layer.borderWidth = 0.5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(handleEditProfileFollowTapped), for: .touchUpInside)
        return button
    }()

    // lazy --> because of using in func before initialization
    private lazy var postsLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    private lazy var followersLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    private lazy var followingLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .white

        addSubview(backgroundImageView)
        backgroundImageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor)

        let blurEffect = UIBlurEffect(style: .systemThickMaterialLight)
        let blurredEffectView = UIVisualEffectView(effect: blurEffect)
        blurredEffectView.alpha = 0.6
        addSubview(blurredEffectView)
        blurredEffectView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor)

        let outerView = UIView(frame: CGRect(x: 0, y: 0, width: 120, height: 120))
        outerView.clipsToBounds = false
        outerView.layer.shadowColor = UIColor.black.cgColor
        outerView.layer.shadowOpacity = 1
        outerView.layer.shadowOffset = CGSize.zero
        outerView.layer.shadowRadius = 5
        outerView.layer.shadowPath = UIBezierPath(roundedRect: outerView.bounds, cornerRadius: 60).cgPath

        outerView.setDimensions(height: 120, width: 120)
        outerView.addSubview(profileImageView)
        profileImageView.layer.cornerRadius =  120 / 2
        profileImageView.anchor(top: outerView.topAnchor, left: outerView.leftAnchor, bottom: outerView.bottomAnchor, right: outerView.rightAnchor)

        let profileImageStack = UIStackView(arrangedSubviews: [outerView, nameLabel])
        profileImageStack.distribution = .fill
        profileImageStack.axis = .vertical
        profileImageStack.spacing = 20

        addSubview(profileImageStack)
        profileImageStack.centerX(inView: self, topAnchor: topAnchor, paddingTop: 25)

        let labelStack = UIStackView(arrangedSubviews: [postsLabel, followersLabel, followingLabel])
        labelStack.distribution = .fillEqually
        labelStack.spacing = 20

        addSubview(labelStack)
        labelStack.centerX(inView: self, topAnchor: profileImageStack.bottomAnchor, paddingTop: 20)

        addSubview(editProfileFollowButton)
        editProfileFollowButton.anchor(top: labelStack.bottomAnchor, left: leftAnchor,
                                       right: rightAnchor, paddingTop: 20,
                                       paddingLeft: 50, paddingRight: 50)
        editProfileFollowButton.setHeight(35)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Actions

    @objc func handleEditProfileFollowTapped() {
        guard let viewModel = viewModel else { return }
        delegate?.header(self, didTapActionButtonFor: viewModel.user)
    }

    // MARK: - Helpers

    func configure() {
        nameLabel.text = viewModel?.fullname
        profileImageView.sd_setImage(with: viewModel?.profileImageUrl)
        backgroundImageView.sd_setImage(with: viewModel?.profileImageUrl)

        editProfileFollowButton.setTitle(viewModel?.followButtonText, for: .normal)
        editProfileFollowButton.setTitleColor(viewModel?.followButtonTextColor, for: .normal)
        editProfileFollowButton.backgroundColor = viewModel?.followButtonBackgroundColor
        editProfileFollowButton.isHidden = viewModel?.user.isCurrentUser ?? false

        postsLabel.attributedText = viewModel?.numberOfPosts
        followersLabel.attributedText = viewModel?.numberOfFollowers
        followingLabel.attributedText = viewModel?.numberOfFollowing
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
        }
    }
}

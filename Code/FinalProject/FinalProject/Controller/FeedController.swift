//
//  FeedController.swift
//  FinalProject
//
//  Created by Ceren Çiçek on 15.04.2022.
//

import UIKit
import Firebase

private let reuseIdentifier = "Cell"

class FeedController: UICollectionViewController {

    private var posts = [Post]() {
        didSet { collectionView.reloadData() }
    }

    var post: Post? {
        didSet { collectionView.reloadData() }
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
        fetchPosts()

        if post != nil {
            chechIfUserLikedPosts()
        }
    }

    // MARK: - Actions

    @objc func handleRefresh() {
        posts.removeAll()
        fetchPosts()
    }

    @objc func handleLogout() {
        do {
            try Auth.auth().signOut()
            let controller = LoginController()
            controller.delegate = self.tabBarController as? MainTabController
            let nav = UINavigationController(rootViewController: controller)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true, completion: nil)
        } catch {
            print("Failed to sign out")
        }
    }

    // MARK: - API

    func fetchPosts() {
        guard post == nil else { return }

        PostService.fetchFeedPosts { (posts) in
            self.posts = posts
            self.chechIfUserLikedPosts()
            self.collectionView.refreshControl?.endRefreshing()
        }
    }

    func chechIfUserLikedPosts() {
        if let post = post {
            PostService.checkIfUserLikedPost(post: post) { (didLike) in
                self.post?.didLike = didLike
            }
        } else {
            posts.forEach { (post) in
                PostService.checkIfUserLikedPost(post: post) { (didLike) in
                    if let index = self.posts.firstIndex(where: { $0.postId == post.postId }) {
                        self.posts[index].didLike = didLike
                    }
                }
            }
        }

    }



    // MARK: - Helpers

    func configureUI() {

        collectionView.bounces = true
        collectionView.backgroundColor = .white
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false

        collectionView.register(FeedCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        if post == nil {

            let button = UIButton.init(type: .custom)
            button.setImage(#imageLiteral(resourceName: "logout"), for: .normal)
            button.setHeight(20)
            button.setWidth(20)
            button.addTarget(self, action: #selector(handleLogout), for: .touchUpInside)

            self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
        }

        navigationItem.title = "Feed"

        let refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView.refreshControl = refresher

//        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
//            layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
//        }
    }
}

// MARK: - UICollectionViewDataSource

extension FeedController {

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return post == nil ? posts.count : 1
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as!FeedCell

        cell.delegate = self

        if let post = post {
            cell.viewModel = PostViewModel(post: post)
        } else {
            cell.viewModel = PostViewModel(post: posts[indexPath.row])
        }
        
        return cell
    }

}

// MARK: - UICollectionViewDelegateFlowLayout

extension FeedController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {

        return UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let width = view.frame.width - 40

        // 8 corresponds to the spacing bottom of the profileImageView and 40 for the size of it
        var height = width + 8 + 40 + 8

        // 50 for image and 60 for the labels below the image
        height += 50 + 60

        return CGSize(width: width, height: height)
    }

}

// MARK: - FeedCellDelegate

extension FeedController: FeedCellDelegate {
    func cell(_ cell: FeedCell, wantsToShowProfileFor uid: String) {
        UserService.fetchUser(withUid: uid) { (user) in
            let controller = ProfileController(user: user)
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }

    func cell(_ cell: FeedCell, wantsToShowCommentsFor post: Post) {
        let controller = CommentController(post: post)
        navigationController?.pushViewController(controller, animated: true)
    }

    func cell(_ cell: FeedCell, didLike post: Post) {
        guard let tab = tabBarController as? MainTabController else { return }
        guard let user = tab.user else { return }

        cell.viewModel?.post.didLike.toggle()

        if post.didLike {
            PostService.unlikePost(post: post) { _ in
                cell.likeButton.setImage(#imageLiteral(resourceName: "like_unselected"), for: .normal)
                cell.likeButton.tintColor = .black
                cell.viewModel?.post.likes = post.likes - 1
            }
        } else {
            PostService.likePost(post: post) { _ in
                cell.likeButton.setImage(#imageLiteral(resourceName: "like_selected"), for: .normal)
                cell.likeButton.tintColor = .red
                cell.viewModel?.post.likes = post.likes + 1

                NotificationService.uploadNotification(toUid: post.ownerUid, fromUser: user,
                                                       type: .like, post: post)
            }
        }
    }
}

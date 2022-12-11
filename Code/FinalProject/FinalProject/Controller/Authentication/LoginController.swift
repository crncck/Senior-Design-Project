//
//  LoginController.swift
//  FinalProject
//
//  Created by Ceren Çiçek on 15.04.2022.
//

import UIKit

protocol AuthenticationDelegate: class {
    func authenticationDidComplete()
}

class LoginController: UIViewController {

    // MARK: - Properties

    private var viewModel = LoginViewModel()
    weak var delegate: AuthenticationDelegate?

    private let iconImage : UIImageView = {
        let iv = UIImageView(image: #imageLiteral(resourceName: "artista_white"))
        iv.contentMode = .scaleAspectFill
        return iv
    }()

    private let emailTextField : UITextField = {
        let tf = CustomTextField(placeholder: "E-mail")
        tf.keyboardType = .emailAddress
        return tf
    }()

    private let passwordTextField : UITextField = {
        let tf = CustomTextField(placeholder: "Password")
        tf.isSecureTextEntry = true
        return tf
    }()

    private let loginButton : UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Login", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1).withAlphaComponent(0.5)
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.isEnabled = false
        button.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        return button

    }()

    private let forgotPasswordButton : UIButton = {
        let button = UIButton(type: .system)
        button.attributedTitle(firstSentence: "Forgot your password?", secondSentence: "Get help.")
        button.addTarget(self, action: #selector(handleShowResetPassword), for: .touchUpInside)
        return button
    }()

    private let dontHaveAccountButton : UIButton = {
        let button = UIButton(type: .system)
        button.attributedTitle(firstSentence: "Don't have an account?", secondSentence: "Sign Up")
        button.addTarget(self, action: #selector(handleShowSignUp), for: .touchUpInside)
        return button
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
        configureNotificationObservers()

    }

    // MARK: - Actions

    @objc func handleShowSignUp() {
        let controller = RegistrationController()
        controller.delegate = delegate
        navigationController?.pushViewController(controller, animated: true)
    }

    @objc func textDidChange(sender: UITextField) {
        if sender == emailTextField {
            viewModel.email = sender.text
        } else {
            viewModel.password = sender.text
        }

        updateForm()
    }

    @objc func handleLogin() {
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }

        AuthService.logUserIn(withEmail: email, password: password) { (result, error) in
            if let error = error {
                print("Failed to log user in \(error.localizedDescription)")
                return
            }

            self.delegate?.authenticationDidComplete()

        }
    }

    @objc func handleShowResetPassword() {
        let controller = ResetPasswordController()
        controller.delegate = self
        controller.email = emailTextField.text
        navigationController?.pushViewController(controller, animated: true)
    }

    // MARK: - Helpers

    func configureUI() {
        configureGradientLayer()

        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        let blurredEffectView = UIVisualEffectView(effect: blurEffect)
        blurredEffectView.alpha = 0.2
        view.addSubview(blurredEffectView)
        blurredEffectView.anchor(width: view.frame.width, height: view.frame.height)

        navigationController?.navigationBar.isHidden = true
        navigationController?.navigationBar.barStyle = .black

        view.addSubview(iconImage)
        iconImage.centerX(inView: view)
        iconImage.setDimensions(height: 80, width: 120)
        iconImage.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 70)

        let stack = UIStackView(arrangedSubviews: [emailTextField, passwordTextField, loginButton, forgotPasswordButton])
        stack.axis = .vertical
        stack.spacing = 20

        view.addSubview(stack)
        stack.anchor(top: iconImage.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor,
                     paddingTop: 32, paddingLeft: 32, paddingRight: 32)

        view.addSubview(dontHaveAccountButton)
        dontHaveAccountButton.centerX(inView: view)
        dontHaveAccountButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor)

    }

    func configureNotificationObservers() {
        emailTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
    }

}


// MARK: - FormViewModel

extension LoginController: FormViewModel {
    func updateForm() {
        loginButton.backgroundColor = viewModel.buttonBackgroundColor
        loginButton.setTitleColor(viewModel.buttonTitleColor, for: .normal)
        loginButton.isEnabled = viewModel.formIsValid
    }
}

// MARK: - ResetPasswordControllerDelegate

extension LoginController: ResetPasswordControllerDelegate {
    func controllerDidSendResetPasswordLink(_ controller: ResetPasswordController) {
        navigationController?.popViewController(animated: true)
        showMessage(withTitle: "Success", message: "We sent a link to your email address to reset your password.")
    }
}

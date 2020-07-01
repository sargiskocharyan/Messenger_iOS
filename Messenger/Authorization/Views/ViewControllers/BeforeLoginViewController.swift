//
//  ViewController.swift
//  Messenger
//
//  Created by Employee1 on 5/21/20.
//  Copyright © 2020 Employee1. All rights reserved.
//

import UIKit
import Lottie

class BeforeLoginViewController: UIViewController, UITextFieldDelegate {
    
    //MARK: @IBOutlets
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var emailDescriptionLabel: UILabel!
    @IBOutlet weak var aboutPgLabel: UILabel!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var emaiCustomView: CustomTextField!
    @IBOutlet weak var AVView: UIView!
    @IBOutlet weak var animationTopConstraint: NSLayoutConstraint!
    
    
    
    // @IBOutlet weak var taboutLabelTopConstraint: NSLayoutConstraint!
    //MARK: Properties
    var headerShapeView = HeaderShapeView()
    var bottomView = BottomShapeView()
    var viewModel = BeforeLoginViewModel()
    let gradientColor = CAGradientLayer()
    var topWidth = CGFloat()
    var topHeight = CGFloat()
    var bottomWidth = CGFloat()
    var bottomHeight = CGFloat()
    var constant = 0
    
    //MARK: @IBAction
    
    @IBAction func continueButtonAction(_ sender: UIButton) {
        checkEmail()
    }
    
   
    //MARK: Lifecycle methods
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureViews()
        continueButton.setTitle("continue".localized(), for: .normal)

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emaiCustomView.delagate = self
        emaiCustomView.textField.delegate = self
        navigationController?.isNavigationBarHidden = true
        continueButton.isEnabled = false
        self.emaiCustomView.textField.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: .editingChanged)
        showAnimation()
        emailDescriptionLabel.text = "email_will_be_used_to_confirm".localized()
        self.hideKeyboardWhenTappedAround()
        setObservers()
        emaiCustomView.textField.returnKeyType = .done
        constant = Int(animationTopConstraint.constant)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        continueButton.setGradientBackground(view: self.view, gradientColor)
    }
    
    override func viewDidLayoutSubviews() {
        self.emaiCustomView.handleRotate()
        let minRect = CGRect(x: 0, y: 0, width: 0, height: 0)
        let maxRectBottom = CGRect(x: 0, y: view.frame.height - bottomHeight, width: bottomWidth, height: bottomHeight)
        let maxRect = CGRect(x: self.view.frame.size.width - topWidth, y: 0, width: topWidth, height: topHeight)
        if (self.view.frame.height < self.view.frame.width) {
            headerShapeView.frame = minRect
            bottomView.frame = minRect
        } else {
            headerShapeView.frame = maxRect
            bottomView.frame = maxRectBottom
        }
        self.gradientColor.removeFromSuperlayer()
        continueButton.setGradientBackground(view: self.view, gradientColor)
        continueButton.layer.cornerRadius = 8
        aboutPgLabel.text = "enter_your_email".localized()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        print(size)
        if size.width > size.height {
            constant = -50
        } else {
            constant = 148
        }
    }
    

    
    //MARK: Helper methods
    func configureViews() {
        bottomWidth = view.frame.width * 0.6
        bottomHeight = view.frame.height * 0.08
        bottomView.frame = CGRect(x: 0, y: view.frame.height - bottomHeight, width: bottomWidth, height: bottomHeight)
        self.view.addSubview(bottomView)
        topWidth = view.frame.width * 0.83
        topHeight =  view.frame.height * 0.3
        self.view.addSubview(headerShapeView)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField.text!.isValidEmail() {
            checkEmail()
        }
        return true
    }
    
    @objc func textFieldDidChange(textField: UITextField){
        if !textField.text!.isValidEmail() {
            continueButton.isEnabled = false
        } else {
            continueButton.isEnabled = true
        }
    }
    
    @objc func handleKeyboardNotification(notification: NSNotification) {
           if let userInfo = notification.userInfo {
               let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
               let isKeyboardShowing = notification.name == UIResponder.keyboardWillShowNotification
               if self.view.frame.height - emailDescriptionLabel.frame.maxY < keyboardFrame!.height {
                   animationTopConstraint.constant = CGFloat(isKeyboardShowing ? constant - (Int(keyboardFrame!.height) - Int((self.view.frame.height - emailDescriptionLabel.frame.maxY))) : constant)
               } else {
                   animationTopConstraint.constant = CGFloat(constant)
               }
               UIView.animate(withDuration: 0, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
                   self.view.layoutIfNeeded()
               }, completion: nil)
           }
       }
       
       func setObservers() {
           NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillShowNotification, object: nil)
           NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillHideNotification, object: nil)
       }
       
       func checkEmail() {
           activityIndicator.startAnimating()
           viewModel.emailChecking(email: emaiCustomView.textField.text!) { (responseObject, error) in
               if (error != nil) {
                   DispatchQueue.main.async {
                       self.activityIndicator.stopAnimating()
                       let alert = UIAlertController(title: "error_message".localized(), message: error?.rawValue, preferredStyle: .alert)
                       alert.addAction(UIAlertAction(title: "ok".localized(), style: .default, handler: nil))
                       self.present(alert, animated: true)
                   }
               } else {
                   DispatchQueue.main.async {
                       let vc = ConfirmCodeViewController.instantiate(fromAppStoryboard: .main)
                       vc.email = self.emaiCustomView.textField.text
                       vc.isExists = responseObject?.mailExist
                       vc.code = responseObject?.code
                       self.navigationController?.pushViewController(vc, animated: true)
                       self.activityIndicator.stopAnimating()
                   }
               }
           }
       }
       
       func showAnimation() {
           let checkMarkAnimation =  AnimationView(name:  "message")
           AVView.contentMode = .scaleAspectFit
           checkMarkAnimation.animationSpeed = 1
           checkMarkAnimation.frame = self.AVView.bounds
           checkMarkAnimation.loopMode = .loop
           checkMarkAnimation.play()
           self.AVView.addSubview(checkMarkAnimation)
       }
}

//MARK: Extension
extension BeforeLoginViewController: CustomTextFieldDelegate {
    func texfFieldDidChange(placeholder: String) {
        if !emaiCustomView.textField.text!.isValidEmail() {
            emaiCustomView.errorLabel.text = emaiCustomView.errorMessage
            emaiCustomView.errorLabel.textColor = .red
            emaiCustomView.border.backgroundColor = .red
        } else {
            emaiCustomView.border.backgroundColor = .blue
            emaiCustomView.errorLabel.textColor = .blue
            emaiCustomView.errorLabel.text = emaiCustomView.successMessage
        }
    }
}


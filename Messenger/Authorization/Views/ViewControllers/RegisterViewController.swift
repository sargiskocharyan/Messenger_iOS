//
//  RegisterViewController.swift
//  Messenger
//
//  Created by Employee1 on 5/25/20.
//  Copyright © 2020 Employee1. All rights reserved.
//

import UIKit
import DropDown

class RegisterViewController: UIViewController, UITextFieldDelegate {
    //MARK: @IBOutlets
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var usernameCustomView: CustomTextField!
    @IBOutlet weak var viewOnScroll: UIView!
    @IBOutlet weak var stackViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var lastnameCustomView: CustomTextField!
    @IBOutlet weak var nameCustomView: CustomTextField!
    @IBOutlet weak var createAccountButton: UIButton!
    @IBOutlet weak var header: HeaderShapeView!
    @IBOutlet weak var universityTextField: UITextField!
    @IBOutlet var storyboardView: UIView!
    @IBOutlet weak var headerTopConstraint: NSLayoutConstraint!
    
    //MARK: Properties
    var headerShapeView = HeaderShapeView()
    var viewModel: RegisterViewModel?
    var topWidth = CGFloat()
    var topHeight = CGFloat()
    let bottomView = BottomShapeView()
    var bottomWidth = CGFloat()
    var bottomHeight = CGFloat()
    var isMore = false
    let dropDown = DropDown()
    let moreOrLessImageView = UIImageView()
    var universities: [University] = []
    var constant: CGFloat = 0
    let button = UIButton()
    var authRouter: AuthRouter?
    
    //MARK: @IBActions
    @IBAction func createAccountAction(_ sender: UIButton) {
        var id: String?
        switch SharedConfigs.shared.appLang {
        case AppLangKeys.Arm:
            id = self.universities.first { (university) -> Bool in
                university.name == self.universityTextField.text!
                }?._id
        case AppLangKeys.Rus:
            id = self.universities.first { (university) -> Bool in
                university.nameRU == self.universityTextField.text!
                }?._id
        default:
            id = self.universities.first { (university) -> Bool in
                university.nameEN == self.universityTextField.text!
                }?._id
        }
        viewModel!.updateUser(name: nameCustomView.textField.text!, lastname: lastnameCustomView.textField.text!, username: usernameCustomView.textField.text!, university: id!) { (user, error) in
            if (error != nil) {
                DispatchQueue.main.async {
                    self.showErrorAlert(title: "error_message".localized(), errorMessage: error!.rawValue)
                }
            } else if user != nil {
                DispatchQueue.main.async {
                    let userModel: UserModel = UserModel(name: user!.name, lastname: user!.lastname, username: user!.username, email: user!.email, university: user!.university, token: SharedConfigs.shared.signedUser?.token ?? "", id: user!.id, avatarURL: user?.avatarURL, tokenExpire: SharedConfigs.shared.signedUser?.tokenExpire)
                    UserDataController().populateUserProfile(model: userModel)
                    self.authRouter?.showCongratulationsViewController()
                }
            }
        }
    }
    
    @IBAction func skipButtonAction(_ sender: UIButton) {
        authRouter?.showCongratulationsViewController()
    }
    
    //MARK: Lifecycles
    override func viewDidLayoutSubviews() {
        print("viewDidLayoutSubviews")
        dropDown.width = button.frame.width
        nameCustomView.handleRotate()
        lastnameCustomView.handleRotate()
        usernameCustomView.handleRotate()
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureView()
        setNeedsStatusBarAppearanceUpdate()
        self.navigationController?.navigationBar.isTranslucent = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        let navigationBar = self.navigationController?.navigationBar
        
        navigationBar?.shadowImage = nil
        navigationBar?.setBackgroundImage(nil, for: .default)
        navigationBar?.isTranslucent = false
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .default
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        header.backgroundColor = .clear
        stackViewTopConstraint.constant = self.view.frame.height * 0.3
        universityTextField.underlinedUniversityTextField()
        self.navigationController?.isNavigationBarHidden = true
        createAccountButton.isEnabled = false
        constant = stackViewTopConstraint.constant
        nameCustomView.delagate = self
        lastnameCustomView.delagate = self
        usernameCustomView.delagate = self
        nameCustomView.textField.delegate = self
        lastnameCustomView.textField.delegate = self
        usernameCustomView.textField.delegate = self
        addDropDown()
        getUniversities()
        skipButton.setTitle("skip".localized(), for: .normal)
        createAccountButton.setTitle("create_account".localized(), for: .normal)
        universityTextField.placeholder = "select_university".localized()
        self.hideKeyboardWhenTappedAround()
        setObservers()
        createAccountButton.isEnabled = false
        createAccountButton.backgroundColor = UIColor.lightGray.withAlphaComponent(0.4)
        createAccountButton.titleLabel?.textColor = UIColor.lightGray
        nameCustomView.textField.addTarget(self, action: #selector(nameTextFieldAction), for: .editingChanged)
        usernameCustomView.textField.addTarget(self, action: #selector(usernameTextFieldAction), for: .editingChanged)
        lastnameCustomView.textField.addTarget(self, action: #selector(lastnameTextFieldAction), for: .editingChanged)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        dropDown.hide()
        moreOrLessImageView.image = UIImage(named: "more")
        if size.width > size.height {
            constant = 50
        } else {
            constant = size.height * 0.3
            stackViewTopConstraint.constant = CGFloat(constant)
        }
    }
    
    //MARK: Helper methodes
    func checkFields() {
        var id: String?
        switch SharedConfigs.shared.appLang {
        case AppLangKeys.Arm:
            id = self.universities.first { (university) -> Bool in
                university.name == self.universityTextField.text!
                }?._id
        case AppLangKeys.Rus:
            id = self.universities.first { (university) -> Bool in
                university.nameRU == self.universityTextField.text!
                }?._id
        default:
            id = self.universities.first { (university) -> Bool in
                university.nameEN == self.universityTextField.text!
                }?._id
        }
        if (nameCustomView.textField.text?.isValidNameOrLastname())! && (lastnameCustomView.textField.text?.isValidNameOrLastname())! && (usernameCustomView.textField.text?.isValidUsername())! && id != nil {
            createAccountButton.backgroundColor = .clear
            createAccountButton.titleLabel?.textColor = .white
            createAccountButton.isEnabled = true
        } else {
            createAccountButton.isEnabled = false
            createAccountButton.backgroundColor = UIColor.lightGray.withAlphaComponent(0.4)
            createAccountButton.titleLabel?.textColor = UIColor.lightGray
        }
    }
    
    @objc func nameTextFieldAction() {
        checkFields()
    }
    
    @objc func usernameTextFieldAction() {
        checkFields()
    }
    
    @objc func lastnameTextFieldAction() {
        checkFields()
    }
    
    func getUniversities() {
        viewModel!.getUniversities { (responseObject, error) in
            if(error != nil) {
                DispatchQueue.main.async {
                    self.showErrorAlert(title: "error_message".localized(), errorMessage: error!.rawValue)
                }
            } else if responseObject != nil {
                self.universities = responseObject!
                switch SharedConfigs.shared.appLang {
                case AppLangKeys.Arm:
                    self.dropDown.dataSource = self.universities.map({ (university) -> String in
                        university.name
                    })
                case AppLangKeys.Rus:
                    self.dropDown.dataSource = self.universities.map({ (university) -> String in
                        university.nameRU
                    })
                case AppLangKeys.Eng:
                    self.dropDown.dataSource = self.universities.map({ (university) -> String in
                        university.nameEN
                    })
                default:
                    self.dropDown.dataSource = self.universities.map({ (university) -> String in
                        university.nameEN
                    })
                }
            }
        }
    }
    
    func raiseStackView(_ keyboardFrame: CGRect?, _ isKeyboardShowing: Bool, _ customView: UIView) {
        if self.view.frame.height - (constant + customView.frame.maxY) < keyboardFrame!.height {
            stackViewTopConstraint.constant = isKeyboardShowing ? constant - (keyboardFrame!.height - (self.view.frame.height - (constant + customView.frame.maxY + 15))) : constant
        } else {
            stackViewTopConstraint.constant = constant
        }
    }
    
    @objc func handleKeyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
            let isKeyboardShowing = notification.name == UIResponder.keyboardWillShowNotification
            
            if usernameCustomView.textField.isFirstResponder {
                raiseStackView(keyboardFrame, isKeyboardShowing, usernameCustomView)
            } else if lastnameCustomView.textField.isFirstResponder {
                raiseStackView(keyboardFrame, isKeyboardShowing, lastnameCustomView)
            } else if nameCustomView.textField.isFirstResponder {
                raiseStackView(keyboardFrame, isKeyboardShowing, nameCustomView)
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
    
    func configureView() {
        bottomWidth = view.frame.width * 0.6
        bottomHeight = view.frame.height * 0.08
        bottomView.frame = CGRect(x: 0, y: view.frame.height - bottomHeight, width: bottomWidth, height: bottomHeight)
        topWidth = view.frame.width * 0.83
        topHeight =  view.frame.height * 0.3
    }
    
    func addImage() {
        universityTextField.addSubview(moreOrLessImageView)
        moreOrLessImageView.image = UIImage(named: "more")
        moreOrLessImageView.topAnchor.constraint(equalTo: universityTextField.topAnchor, constant: 20).isActive = true
        moreOrLessImageView.rightAnchor.constraint(equalTo: universityTextField.rightAnchor, constant: 0).isActive = true
        moreOrLessImageView.heightAnchor.constraint(equalToConstant: 10).isActive = true
        moreOrLessImageView.widthAnchor.constraint(equalToConstant: 25).isActive = true
        moreOrLessImageView.isUserInteractionEnabled = true
        moreOrLessImageView.anchor(top: universityTextField.topAnchor, paddingTop: 20, bottom: universityTextField.bottomAnchor, paddingBottom: 15, left: nil, paddingLeft: 0, right: universityTextField.rightAnchor, paddingRight: 0, width: 25, height: 10)
    }
    
    func addButton() {
        button.addTarget(self, action: #selector(imageTapped), for: .touchUpInside)
        self.universityTextField.addSubview(button)
        button.topAnchor.constraint(equalTo: universityTextField.topAnchor, constant: 0).isActive = true
        button.rightAnchor.constraint(equalTo: universityTextField.rightAnchor, constant: 0).isActive = true
        button.leftAnchor.constraint(equalTo: universityTextField.leftAnchor, constant: 0).isActive = true
        button.heightAnchor.constraint(equalToConstant: universityTextField.frame.height).isActive = true
        button.widthAnchor.constraint(equalToConstant: universityTextField.frame.width).isActive = true
        button.anchor(top: universityTextField.topAnchor, paddingTop: 0, bottom: universityTextField.bottomAnchor, paddingBottom: 0, left: universityTextField.leftAnchor, paddingLeft: 0, right: universityTextField.rightAnchor, paddingRight: 0, width: universityTextField.frame.width, height: universityTextField.frame.height)
    }
    
    func addDropDown() {
        addButton()
        addImage()
        dropDown.anchorView = button
        dropDown.direction = .any
        dropDown.bottomOffset = CGPoint(x: 0, y:((dropDown.anchorView?.plainView.bounds.height)! + universityTextField.frame.height + 5 - 25))
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            self.universityTextField.text = item
            self.moreOrLessImageView.image = UIImage(named: "more")
            self.isMore = false
        }
        dropDown.width = universityTextField.frame.width
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: self.universityTextField.frame.height))
        universityTextField.rightView = paddingView
        universityTextField.rightViewMode = UITextField.ViewMode.always
    }
    
    @objc func imageTapped() {
        checkFields()
        if isMore {
            isMore = false
            dropDown.hide()
            moreOrLessImageView.image = UIImage(named: "more")
        }
        else { 
            isMore = true
            dropDown.show()
            moreOrLessImageView.image = UIImage(named: "less")
        }
    }
    
}

@IBDesignable
class GradientView: UIView {
    @IBInspectable var firstColor: UIColor = UIColor.clear {
        didSet {
            updateView()
        }
    }
    @IBInspectable var secondColor: UIColor = UIColor.clear {
        didSet {
            updateView()
        }
    }
    
    override class var layerClass: AnyClass {
        get {
            return CAGradientLayer.self
        }
    }
    
    @IBInspectable var isHorizontal: Bool = true {
        didSet {
            updateView()
        }
    }
    func updateView() {
        let layer = self.layer as! CAGradientLayer
        layer.colors = [firstColor, secondColor].map{$0.cgColor}
        if (self.isHorizontal) {
            layer.startPoint = CGPoint(x: 0, y: 0.5)
            layer.endPoint = CGPoint (x: 1, y: 0.5)
        } else {
            layer.startPoint = CGPoint(x: 0.5, y: 0)
            layer.endPoint = CGPoint (x: 0.5, y: 1)
        }
    }
    
}


//MARK: Extension
extension RegisterViewController: CustomTextFieldDelegate {
    func texfFieldDidChange(placeholder: String) {
        if placeholder == "name".localized() {
            if !nameCustomView.textField.text!.isValidNameOrLastname() {
                nameCustomView.errorLabel.text = nameCustomView.errorMessage
                nameCustomView.errorLabel.textColor = .red
                nameCustomView.border.backgroundColor = .red
            } else {
                nameCustomView.border.backgroundColor = .blue
                nameCustomView.errorLabel.textColor = .blue
                nameCustomView.errorLabel.text = nameCustomView.successMessage
            }
        }
        if placeholder == "lastname".localized() {
            if !lastnameCustomView.textField.text!.isValidNameOrLastname() {
                lastnameCustomView.errorLabel.text = lastnameCustomView.errorMessage
                lastnameCustomView.errorLabel.textColor = .red
                lastnameCustomView.border.backgroundColor = .red
            } else {
                lastnameCustomView.border.backgroundColor = .blue
                lastnameCustomView.errorLabel.textColor = .blue
                lastnameCustomView.errorLabel.text = lastnameCustomView.successMessage
            }
        }
        if placeholder == "username".localized() {
            if !usernameCustomView.textField.text!.isValidUsername() {
                usernameCustomView.errorLabel.text = usernameCustomView.errorMessage
                usernameCustomView.errorLabel.textColor = .red
                usernameCustomView.border.backgroundColor = .red
            } else {
                usernameCustomView.border.backgroundColor = .blue
                usernameCustomView.errorLabel.textColor = .blue
                usernameCustomView.errorLabel.text = usernameCustomView.successMessage
            }
        }
        
    }
}

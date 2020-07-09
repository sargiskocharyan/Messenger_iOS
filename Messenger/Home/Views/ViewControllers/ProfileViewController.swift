//
//  ProfileViewController.swift
//  Messenger
//
//  Created by Employee1 on 6/2/20.
//  Copyright © 2020 Employee1. All rights reserved.
//

import UIKit
import DropDown
import AVFoundation

protocol ProfileViewControllerDelegate: class {
    func changeLanguage(key: String)
}

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //MARK: IBOutlets
    @IBOutlet weak var hidePersonalDataLabel: UILabel!
    @IBOutlet weak var switchMode: UISwitch!
    @IBOutlet weak var universityLabel: UILabel!
    @IBOutlet weak var lastnameLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var contactView: UIView!
    @IBOutlet weak var contactsLabel: UILabel!
    @IBOutlet weak var phoneTextLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var nameTextLabel: UILabel!
    @IBOutlet weak var darkModeLabel: UILabel!
    @IBOutlet weak var lastnameTextLabel: UILabel!
    @IBOutlet weak var languageLabel: UILabel!
    @IBOutlet weak var logoutLabel: UILabel!
    @IBOutlet weak var languageView: UIView!
    @IBOutlet weak var darkModeView: UIView!
    @IBOutlet weak var logoutView: UIView!
    @IBOutlet weak var headerUsernameLabel: UILabel!
    @IBOutlet weak var flagImageView: UIImageView!
    @IBOutlet weak var logOutLanguageVerticalConstraint: NSLayoutConstraint!
    @IBOutlet weak var logOutDarkModeVerticalConstraint: NSLayoutConstraint!
    @IBOutlet weak var headerEmailLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //MARK: Properties
    var dropDown = DropDown()
    let viewModel = ProfileViewModel()
    let socketTaskManager = SocketTaskManager.shared
    let center = UNUserNotificationCenter.current()
    var imagePicker = UIImagePickerController()
    weak var delegate: ProfileViewControllerDelegate?
    
    //MARK: Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        setFlagImage()
        setBorder(view: contactView)
        setBorder(view: languageView)
        setBorder(view: darkModeView)
        setBorder(view: logoutView)
        checkInformation()
        checkVersion()
        setImage()
        configureImageView()
        addGestures()
        defineSwithState()
        localizeStrings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkInformation()
    }
    
    //MARK: Helper methods
    @IBAction func editButton(_ sender: Any) {
        let vc = EditInformationViewController.instantiate(fromAppStoryboard: .main)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func setImage() {
        ImageCache.shared.getImage(url: SharedConfigs.shared.signedUser?.avatarURL ?? "") { (image) in
            DispatchQueue.main.async {
                self.userImageView.image = image
            }
        }
    }
    
    func localizeStrings() {
        hidePersonalDataLabel.text = "hide_personal_data".localized()
        headerEmailLabel.text = "email".localized()
        headerUsernameLabel.text = "username".localized()
        phoneTextLabel.text = "phone:".localized()
        nameTextLabel.text = "name:".localized()
        lastnameTextLabel.text = "lastname:".localized()
        contactsLabel.text = "contacts".localized()
        languageLabel.text = "language".localized()
        darkModeLabel.text = "dark_mode".localized()
        logoutLabel.text = "log_out".localized()
        self.navigationController?.navigationBar.topItem?.title = "profile".localized()
    }
    
    func defineSwithState() {
        if SharedConfigs.shared.mode == "dark" {
            switchMode.isOn = true
        } else {
            switchMode.isOn = false
        }
    }
    
    
    func setFlagImage() {
        if SharedConfigs.shared.appLang == AppLangKeys.Eng {
            flagImageView.image = UIImage(named: "English")
        } else if SharedConfigs.shared.appLang == AppLangKeys.Rus {
            flagImageView.image = UIImage(named: "Russian")
        } else if SharedConfigs.shared.appLang == AppLangKeys.Arm {
            flagImageView.image = UIImage(named: "Armenian")
        }
    }
    
    @IBAction func selectMode(_ sender: UISwitch) {
        if sender.isOn {
            UIApplication.shared.windows.forEach { window in
                window.overrideUserInterfaceStyle = .dark
            }
            SharedConfigs.shared.setMode(selectedMode: "dark")
        } else {
            UIApplication.shared.windows.forEach { window in
                window.overrideUserInterfaceStyle = .light
            }
            SharedConfigs.shared.setMode(selectedMode: "light")
        }
          self.viewDidLoad()
    }
    
    func configureImageView() {
        let cameraView = UIView()
        view.addSubview(cameraView)
        userImageView.backgroundColor = .clear
        cameraView.backgroundColor = UIColor(red: 128/255, green: 94/255, blue: 251/255, alpha: 1)
        cameraView.bottomAnchor.constraint(equalTo: userImageView.bottomAnchor, constant: 0).isActive = true
        cameraView.rightAnchor.constraint(equalTo: userImageView.rightAnchor, constant: 0).isActive = true
        cameraView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        cameraView.widthAnchor.constraint(equalToConstant: 30).isActive = true
        cameraView.isUserInteractionEnabled = true
        cameraView.anchor(top: nil, paddingTop: 20, bottom: userImageView.bottomAnchor, paddingBottom: 0, left: nil, paddingLeft: 0, right: userImageView.rightAnchor, paddingRight: 0, width: 30, height: 30)
        cameraView.contentMode = . scaleAspectFill
        cameraView.layer.cornerRadius = 15
        cameraView.clipsToBounds = true
        let cameraImageView = UIImageView()
        cameraImageView.image = UIImage(named: "camera")
        cameraView.addSubview(cameraImageView)
        cameraImageView.backgroundColor = UIColor(red: 128/255, green: 94/255, blue: 251/255, alpha: 1)
        cameraImageView.bottomAnchor.constraint(equalTo: cameraView.bottomAnchor, constant: 5).isActive = true
        cameraImageView.rightAnchor.constraint(equalTo: cameraView.rightAnchor, constant: 5).isActive = true
        cameraImageView.topAnchor.constraint(equalTo: cameraView.topAnchor, constant: 5).isActive = true
        cameraImageView.leftAnchor.constraint(equalTo: cameraView.leftAnchor, constant: 5).isActive = true
        cameraImageView.isUserInteractionEnabled = true
        cameraImageView.anchor(top: cameraView.topAnchor, paddingTop: 5, bottom: cameraView.bottomAnchor, paddingBottom: 5, left: cameraView.leftAnchor, paddingLeft: 5, right: cameraView.rightAnchor, paddingRight: 5, width: 30, height: 30)
        let tapCamera = UITapGestureRecognizer(target: self, action: #selector(self.handleCameraTap(_:)))
        cameraImageView.addGestureRecognizer(tapCamera)
        userImageView.contentMode = . scaleAspectFill
        userImageView.layer.cornerRadius = 50
        userImageView.clipsToBounds = true
    }
    
    func addGestures() {
        let tapLogOut = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        logoutView.addGestureRecognizer(tapLogOut)
        let tapContacts = UITapGestureRecognizer(target: self, action: #selector(self.handleContactsTap(_:)))
        contactView.addGestureRecognizer(tapContacts)
        let tapLanguage = UITapGestureRecognizer(target: self, action: #selector(self.handleLanguageTab(_:)))
        languageView.addGestureRecognizer(tapLanguage)
        let tapImage = UITapGestureRecognizer(target: self, action: #selector(self.handleImageTap(_:)))
        userImageView.isUserInteractionEnabled = true
        userImageView.addGestureRecognizer(tapImage)
    }
    
    @objc func handleCameraTap(_ sender: UITapGestureRecognizer? = nil) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
                 imagePicker.delegate = self
                 imagePicker.sourceType = .camera;
                 imagePicker.allowsEditing = false
                 self.present(imagePicker, animated: true, completion: nil)
                     }
             AVCaptureDevice.requestAccess(for: AVMediaType.video) { response in
                 if response {
                     print("Permission allowed")
                 } else {
                     print("Permission don't allowed")
                 }
             }
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            imagePicker.sourceType = .savedPhotosAlbum
            imagePicker.allowsEditing = false
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    @objc func handleImageTap(_ sender: UITapGestureRecognizer? = nil) {
        let imageView = UIImageView(image: userImageView.image)
        let closeButton = UIButton()
        imageView.addSubview(closeButton)
        closeButton.topAnchor.constraint(equalTo: imageView.topAnchor, constant: 20).isActive = true
        closeButton.rightAnchor.constraint(equalTo: imageView.rightAnchor, constant: 20).isActive = true
        closeButton.heightAnchor.constraint(equalToConstant: 25).isActive = true
        closeButton.widthAnchor.constraint(equalToConstant: 25).isActive = true
        closeButton.isUserInteractionEnabled = true
        closeButton.anchor(top: imageView.topAnchor, paddingTop: 20, bottom: nil, paddingBottom: 15, left: nil, paddingLeft: 0, right: imageView.rightAnchor, paddingRight: 10, width: 25, height: 25)
        
        let deleteImageButton = UIButton()
        imageView.addSubview(deleteImageButton)
        deleteImageButton.bottomAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20).isActive = true
        deleteImageButton.bottomAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20).isActive = true
        deleteImageButton.rightAnchor.constraint(equalTo: imageView.rightAnchor, constant: 20).isActive = true
        deleteImageButton.heightAnchor.constraint(equalToConstant: 25).isActive = true
        deleteImageButton.widthAnchor.constraint(equalToConstant: 25).isActive = true
        deleteImageButton.isUserInteractionEnabled = true
        deleteImageButton.anchor(top: imageView.topAnchor, paddingTop: 20, bottom: nil, paddingBottom: 15, left: nil, paddingLeft: 0, right: imageView.rightAnchor, paddingRight: 10, width: 25, height: 25)
        closeButton.setImage(UIImage(named: "trash"), for: .normal)
        
        
        if SharedConfigs.shared.mode == "dark" {
            closeButton.setImage(UIImage(named: "white@_"), for: .normal)
            imageView.backgroundColor = .black
        } else {
            closeButton.setImage(UIImage(named: "close"), for: .normal)
            imageView.backgroundColor = .white
        }
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        imageView.tag = 3
        closeButton.addTarget(self, action: #selector(dismissFullscreenImage), for: .touchUpInside)
        self.view.addSubview(imageView)
        imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        imageView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        imageView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        imageView.isUserInteractionEnabled = true
        imageView.anchor(top: view.topAnchor, paddingTop: 0, bottom: view.bottomAnchor, paddingBottom: 0, left: view.leftAnchor, paddingLeft: 0, right: view.rightAnchor, paddingRight: 0, width: 25, height: 25)
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = true
    }

    @objc func dismissFullscreenImage() {
        self.navigationController?.isNavigationBarHidden = false
        self.tabBarController?.tabBar.isHidden = false
        view.viewWithTag(3)?.removeFromSuperview()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        activityIndicator.startAnimating()
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[.originalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        viewModel.uploadImage(image: image) { (error, avatarURL) in
            if error != nil {
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "error_message".localized(), message: error?.rawValue, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "ok".localized(), style: .default, handler: nil))
                    self.present(alert, animated: true)
                    self.activityIndicator.stopAnimating()
                }
            } else {
                ImageCache.shared.getImage(url: avatarURL ?? "") { (image) in
                    DispatchQueue.main.async {
                        self.userImageView.image = image
                        self.activityIndicator.stopAnimating()
                    }
                }
            }
        }
    }
    
    @objc func handleContactsTap(_ sender: UITapGestureRecognizer? = nil) {
        let vc = ContactsViewController.instantiate(fromAppStoryboard: .main)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func handleLanguageTab(_ sender: UITapGestureRecognizer? = nil) {
        addDropDown()
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {        
        viewModel.logout { (error) in
            if (error != nil) {
                if error == NetworkResponse.authenticationError {
                    UserDataController().logOutUser()
                    DispatchQueue.main.async {
                        let vc = BeforeLoginViewController.instantiate(fromAppStoryboard: .main)
                        let nav = UINavigationController(rootViewController: vc)
                        let window: UIWindow? = UIApplication.shared.windows[0]
                        window?.rootViewController = nav
                        window?.makeKeyAndVisible()
                    }
                }
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "error_message".localized(), message: error?.rawValue, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "ok".localized(), style: .default, handler: nil))
                    self.present(alert, animated: true)
                }
                return
            }
            else {
                DispatchQueue.main.async {
                    UserDataController().logOutUser()
                    let vc = BeforeLoginViewController.instantiate(fromAppStoryboard: .main)
                    let nav = UINavigationController(rootViewController: vc)
                    let window: UIWindow? = UIApplication.shared.windows[0]
                    window?.rootViewController = nav
                    window?.makeKeyAndVisible()
                }
            }
            self.socketTaskManager.disconnect()
        }
    }
    
    func setBorder(view: UIView) {
        view.layer.masksToBounds = true
        view.layer.borderWidth = 1
        let color = UIColor.lightGray.withAlphaComponent(0.5)
        view.layer.borderColor = color.cgColor
    }
    
    func addDropDown() {
        dropDown.anchorView = languageView 
        dropDown.direction = .any
        dropDown.width = languageView.frame.width
        dropDown.dataSource = ["English", "Russian", "Armenian"]
        dropDown.bottomOffset = CGPoint(x: 0, y:(dropDown.anchorView?.plainView.bounds.height)!)
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            if item == "Russian" {
                self.flagImageView.image = UIImage(named: "Russian")
                SharedConfigs.shared.setAppLang(lang: AppLangKeys.Rus)
            } else if item == "English" {
                self.flagImageView.image = UIImage(named: "English")
                SharedConfigs.shared.setAppLang(lang: AppLangKeys.Eng)
            } else if item == "Armenian" {
                self.flagImageView.image = UIImage(named: "Armenian")
                SharedConfigs.shared.setAppLang(lang: AppLangKeys.Arm)
            }
            self.delegate?.changeLanguage(key: AppLangKeys.Arm)
            self.viewDidLoad()
        }
        if SharedConfigs.shared.mode == "dark" {
            dropDown.backgroundColor = UIColor.gray //(red: 18/255, green: 19/255, blue: 18/255, alpha: 1)
        } else {
            dropDown.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
        }
        dropDown.cellNib = UINib(nibName: "CustomCell", bundle: nil)
        dropDown.customCellConfiguration = { (index: Index, item: String, cell: DropDownCell) -> Void in
            guard let cell = cell as? CustomCell else { return }
            if SharedConfigs.shared.mode == "dark" {
                cell.optionLabel.textColor = UIColor.white
                   } else {
                cell.optionLabel.textColor = UIColor.black
                   }
            cell.countryImageView.image = UIImage(named: "\(item)")
        }
        dropDown.show()
    }
    
    func checkInformation() {
        let user = SharedConfigs.shared.signedUser
        if user?.name == nil {
            nameLabel.text = "name".localized()
        } else {
            nameLabel.text = user?.name
            if SharedConfigs.shared.mode == "dark" {
              nameLabel.textColor = .white
            } else {
                nameLabel.textColor = .black
            }
        }
        if user?.lastname == nil {
            lastnameLabel.text = "lastname".localized()
            lastnameLabel.textColor = .lightGray
        } else {
            lastnameLabel.text = user?.lastname
            if SharedConfigs.shared.mode == "dark" {
              lastnameLabel.textColor = .white
            } else {
                lastnameLabel.textColor = .black
            }
        }
        if user?.email == nil {
            emailLabel.text = "email".localized()
            emailLabel.textColor = .lightGray
        } else {
            emailLabel.text = user?.email
            if SharedConfigs.shared.mode == "dark" {
              emailLabel.textColor = .white
            } else {
                emailLabel.textColor = .black
            }
        }
        if user?.username == nil {
            usernameLabel.text = "username".localized()
            usernameLabel.textColor = .lightGray
        } else {
            usernameLabel.text = user?.username
            if SharedConfigs.shared.mode == "dark" {
              usernameLabel.textColor = .white
            } else {
                usernameLabel.textColor = .black
            }
        }
        
        if user?.university == nil {
            universityLabel.text = "university".localized()
            universityLabel.textColor = .lightGray
        } else {
            if SharedConfigs.shared.mode == "dark" {
              universityLabel.textColor = .white
            } else {
                universityLabel.textColor = .black
            }
            universityLabel.text = user?.university?.name
            switch SharedConfigs.shared.appLang {
            case AppLangKeys.Arm:
                universityLabel.text = user?.university?.name
            case AppLangKeys.Rus:
                universityLabel.text = user?.university?.nameRU
            case AppLangKeys.Eng:
                universityLabel.text = user?.university?.nameEN
            default:
                universityLabel.text = user?.university?.nameEN
            }
        }
        
    }
    
    private func checkVersion() {
        if #available(iOS 13.0, *) {
            logOutDarkModeVerticalConstraint.priority = UILayoutPriority(rawValue: 990)
            logOutLanguageVerticalConstraint.priority = UILayoutPriority(rawValue: 900)
        } else {
            logOutDarkModeVerticalConstraint.priority = UILayoutPriority(rawValue: 900)
            logOutLanguageVerticalConstraint.priority = UILayoutPriority(rawValue: 990)
            darkModeView.isHidden = true
        }
    }    
}

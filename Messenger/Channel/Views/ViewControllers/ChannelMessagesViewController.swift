//
//  ChannelMessagesViewController.swift
//  Messenger
//
//  Created by Employee1 on 9/29/20.
//  Copyright © 2020 Dynamic LLC. All rights reserved.
//

import UIKit

enum MessageMode {
    case edit
    case main
}

class ChannelMessagesViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    //MARK: @IBOutlets
    @IBOutlet weak var nameOfChannelButton: UIButton!
    @IBOutlet weak var universalButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    
    //MARK: Properties
    var mainRouter: MainRouter?
    var viewModel: ChannelMessagesViewModel?
    var channelMessages: ChannelMessages = ChannelMessages(array: [], statuses: [])
    var channelInfo: ChannelInfo!
    var isPreview: Bool?
    var check: Bool!
    var arrayOfSelectedMesssgae: [String] = []
    var bottomConstraint: NSLayoutConstraint?
    var indexPath: IndexPath?
    var isLoadedMessages = false
    var mode: MessageMode!
    let deleteMessageButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(named: "imputColor")
        return button
    }()
    let messageInputContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "imputColor")
        return view
    }()
    let inputTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = ""
        return textField
    }()
    let sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage.init(named: "send"), for: .normal)
        return button
    }()
    var selectedImage: UIImage?
    
    //MARK: LifeCycles
   
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        self.getChannelMessages()
        mode = .main
        selectedImage = nil
        setObservers()
        isPreview = true
        check = true
        setLineOnHeaderView()
        headerView.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
        tableView.allowsMultipleSelection = false
    }
    
 
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
        navigationController?.navigationBar.isHidden = true
        nameOfChannelButton.setTitle(channelInfo?.channel?.name, for: .normal)
        tableView.allowsMultipleSelection = false
        inputTextField.placeholder = "enter_message".localized()
        self.tableView.allowsSelection = false
        checkChannelRole()
        setInputMessage()
    }
    
    
    //MARK: Helper methods
    private func setupInputComponents() {
        messageInputContainerView.addSubview(inputTextField)
        messageInputContainerView.addSubview(sendButton)
        messageInputContainerView.layer.borderWidth = 1
        messageInputContainerView.layer.borderColor = UIColor(white: 0.5, alpha: 0.5).cgColor
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.rightAnchor.constraint(equalTo: messageInputContainerView.rightAnchor, constant: -10).isActive = true
        sendButton.heightAnchor.constraint(equalToConstant: 25).isActive = true
        sendButton.topAnchor.constraint(equalTo: messageInputContainerView.topAnchor, constant: 10).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 25).isActive = true
        sendButton.isUserInteractionEnabled = true
        let uploadImageView = UIImageView()
        uploadImageView.isUserInteractionEnabled = true
        uploadImageView.image = UIImage(named: "upload_image_icon")
        uploadImageView.translatesAutoresizingMaskIntoConstraints = false
        uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleUploadTap)))
        messageInputContainerView.addSubview(uploadImageView)
        uploadImageView.leftAnchor.constraint(equalTo: messageInputContainerView.leftAnchor).isActive = true
        uploadImageView.centerYAnchor.constraint(equalTo: messageInputContainerView.centerYAnchor).isActive = true
        uploadImageView.widthAnchor.constraint(equalToConstant: 44).isActive = true
        uploadImageView.heightAnchor.constraint(equalToConstant: 44).isActive = true
        inputTextField.translatesAutoresizingMaskIntoConstraints = false
        inputTextField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -37).isActive = true
        inputTextField.leftAnchor.constraint(equalTo: uploadImageView.rightAnchor, constant: 5).isActive = true
        inputTextField.bottomAnchor.constraint(equalTo: messageInputContainerView.bottomAnchor, constant: 0).isActive = true
        inputTextField.heightAnchor.constraint(equalToConstant: 48).isActive = true
        inputTextField.isUserInteractionEnabled = true
    }
    
    @objc func handleUploadTap() {
        let imagePickerController = UIImagePickerController()
        
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        
        present(imagePickerController, animated: true, completion: nil)
    }
    
    fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
        return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
    }

    // Helper function inserted by Swift 4.2 migrator.
    fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
        guard let input = input else { return nil }
        return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
    }

    // Helper function inserted by Swift 4.2 migrator.
    fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
        return input.rawValue
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
//            uploadToFirebaseStorageUsingImage(selectedImage)
            //nkary ka arden
            self.selectedImage = selectedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func setInputMessage() {
        if channelInfo.channel?.openMode == true && channelInfo.role != 3 {
            addConstraints()
            setupInputComponents()
        } else if channelInfo.channel?.openMode == false && (channelInfo.role == 1 || channelInfo.role == 0) {
            addConstraints()
            setupInputComponents()
        }
    }
    
       func checkChannelRole() {
        if (channelInfo.role == 0 || channelInfo.role == 1) {
            if isLoadedMessages {
                if channelMessages.array?.count != nil && channelMessages.array!.count > 0 {
                    check = true
                    universalButton.isHidden = false
                    universalButton.setTitle("edit".localized(), for: .normal)
                }
            }
        } else if channelInfo.role == 2 {
            check = false
            universalButton.isHidden = true
        } else {
            messageInputContainerView.removeFromSuperview()
            check = false
            universalButton.isHidden = false
            universalButton.setTitle("join".localized(), for: .normal)
        }
    }
  
    func setView(_ str: String) {
        if channelMessages.array?.count == 0 {
            DispatchQueue.main.async {
                let noResultView = UIView(frame: self.view.frame)
                self.tableView.addSubview(noResultView)
                noResultView.tag = 26
                noResultView.backgroundColor = UIColor(named: "imputColor")
                let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.width * 0.8, height: 50))
                noResultView.addSubview(label)
                label.translatesAutoresizingMaskIntoConstraints = false
                label.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: 0).isActive = true
                label.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0).isActive = true
                label.center = self.view.center
                label.text = str
                label.textColor = .lightGray
                label.textAlignment = .center
            }
        } else {
            removeView()
        }
    }
    
    func removeView() {
        DispatchQueue.main.async {
            let resultView = self.view.viewWithTag(26)
            resultView?.removeFromSuperview()
        }
    }
    
    func setLineOnHeaderView()  {
        let line = UIView()
        headerView.addSubview(line)
        line.translatesAutoresizingMaskIntoConstraints = false
        line.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0).isActive = true
        line.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 0).isActive = true
        line.widthAnchor.constraint(equalToConstant: self.view.frame.width).isActive = true
        line.heightAnchor.constraint(equalToConstant: 1).isActive = true
        line.backgroundColor = UIColor(red: 209/255, green: 209/255, blue: 209/255, alpha: 1)
    }
    
    func addConstraints() {
        view.addSubview(messageInputContainerView)
        messageInputContainerView.translatesAutoresizingMaskIntoConstraints = false
        bottomConstraint = messageInputContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        bottomConstraint?.isActive = true
        messageInputContainerView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 1).isActive = true
        messageInputContainerView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: -1).isActive = true
        messageInputContainerView.heightAnchor.constraint(equalToConstant: 48).isActive = true
        messageInputContainerView.isUserInteractionEnabled = true
        messageInputContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        tableViewBottomConstraint.constant = 48
        sendButton.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
    }
    
    func setDeleteMessageButton()  {
        inputTextField.addSubview(deleteMessageButton)
        deleteMessageButton.translatesAutoresizingMaskIntoConstraints = false
        deleteMessageButton.setTitle("delete".localized(), for: .normal)
        deleteMessageButton.setTitleColor(.white, for: .normal)
        deleteMessageButton.tag = 333
        deleteMessageButton.titleLabel?.font = UIFont.systemFont(ofSize: 20.0)
        deleteMessageButton.backgroundColor = UIColor(red: 128/255, green: 94/255, blue: 250/255, alpha: 1)
        deleteMessageButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        deleteMessageButton.leftAnchor.constraint(equalTo: messageInputContainerView.leftAnchor, constant: 0).isActive = true
        deleteMessageButton.bottomAnchor.constraint(equalTo: messageInputContainerView.bottomAnchor, constant: 0).isActive = true
        deleteMessageButton.heightAnchor.constraint(equalToConstant: 48).isActive = true
        deleteMessageButton.addTarget(self, action: #selector(deleteMessages), for: .touchUpInside)
    }
    
    @objc func deleteMessages() {
        if arrayOfSelectedMesssgae.count > 0 {
            showAlertBeforeDeleteMessage()
        } else {
            self.check = !self.check
            self.isPreview = self.check
            UIView.setAnimationsEnabled(false)
            self.tableView.beginUpdates()
            self.tableView.reloadData()
            self.tableView.endUpdates()
            self.inputTextField.placeholder = "enter_message".localized()
            self.universalButton.setTitle("edit".localized(), for: .normal)
            self.tableView.allowsMultipleSelection = false
            self.tableView.allowsSelection = false
            self.sendButton.isHidden = false
            self.removeDeleteButton()
        }
    }
    
    func removeDeleteButton()  {
        DispatchQueue.main.async {
            self.view.viewWithTag(333)?.removeFromSuperview()
        }
    }
    
    func getnewMessage(message: Message, _ name: String?, _ lastname: String?, _ username: String?, isSenderMe: Bool) {
        if message.owner == channelInfo.channel?._id {
            DispatchQueue.main.async {
                self.channelMessages.array!.append(message)
                self.removeView()
                self.tableView.insertRows(at: [IndexPath(row: self.channelMessages.array!.count - 1, section: 0)], with: .automatic)
                let indexPath = IndexPath(item: self.channelMessages.array!.count - 1, section: 0)
                self.tableView?.scrollToRow(at: indexPath, at: .bottom, animated: true)
                if self.channelInfo.role == 0 || self.channelInfo.role == 1 {
                    self.universalButton.isHidden = false
                    self.universalButton.setTitle("edit".localized(), for: .normal)
                }
            }
        }
    }
    
    @objc func sendMessage() {
        if mode == .edit {
            mode = .main
            sendButton.setImage(UIImage.init(named: "send"), for: .normal)
            if inputTextField.text != "" {
                if let cell = tableView.cellForRow(at: indexPath!) as? SendMessageTableViewCell {
                    self.viewModel?.editChannelMessageBySender(id: cell.id!, text: self.inputTextField.text!, completion: { (error) in
                        if error != nil {
                            DispatchQueue.main.async {
                                self.showErrorAlert(title: "error".localized(), errorMessage: error!.rawValue)
                            }
                        } else {
                            DispatchQueue.main.async {
                                cell.messageLabel.text = self.inputTextField.text
                                self.inputTextField.text = ""
                            }
                        }
                    })
                }
            }
        } else {
            if selectedImage == nil && inputTextField.text != "" {
                let text = inputTextField.text
                inputTextField.text = ""
                SocketTaskManager.shared.sendChanMessage(message: text!, channelId: channelInfo!.channel!._id)
                removeView()
            } else {
                HomeNetworkManager().sendImage(tmpImage: selectedImage, channelId: self.channelInfo.channel?._id ?? "", text: inputTextField.text ?? "") { (error) in
                    self.selectedImage = nil
                    if error != nil {
                        DispatchQueue.main.async {
                            self.showErrorAlert(title: "error".localized(), errorMessage: error!.rawValue)
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.inputTextField.text = ""
                        }
                    }
                }
            }
        }
    }
    
    func setObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func showAlertBeforeDeleteMessage() {
        let alert = UIAlertController(title: "attention".localized(), message: "are_you_sure_want_to_delete_selected_messages".localized(), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "delete".localized(), style: .default, handler: { (_) in
            if self.arrayOfSelectedMesssgae.count == 0 {
                self.deleteMessageButton.isEnabled = false
            } else {
                self.deleteMessageButton.isEnabled = true
            }
            self.viewModel?.deleteChannelMessages(id: (self.channelInfo?.channel!._id)!, ids: self.arrayOfSelectedMesssgae, completion: { (error) in
                if error != nil {
                    DispatchQueue.main.async {
                        self.showErrorAlert(title: "error".localized(), errorMessage: error!.rawValue)
                    }
                } else {
                    self.channelMessages.array = self.channelMessages.array?.filter({ (message) -> Bool in
                        return !(self.arrayOfSelectedMesssgae.contains(message._id!))
                    })
                    DispatchQueue.main.async {
                        UIView.setAnimationsEnabled(false)
                        self.tableView.reloadData()
                    }
                }
                self.check = !self.check
                self.isPreview = self.check
                DispatchQueue.main.async {
                    UIView.setAnimationsEnabled(false)
                    self.tableView.beginUpdates()
                    self.tableView.reloadData()
                    self.tableView.endUpdates()
                    self.universalButton.setTitle("edit".localized(), for: .normal)
                    self.inputTextField.placeholder = "enter_message".localized()
                    self.tableView.allowsMultipleSelection = false
                    self.tableView.allowsSelection = false
                    self.sendButton.isHidden = false
                    self.removeDeleteButton()
                }
                self.arrayOfSelectedMesssgae = []
                if self.channelMessages.array?.count == 0 {
                    self.setView("there_is_no_messages")
                    DispatchQueue.main.async {
                        self.universalButton.isHidden = true
                    }
                    
                }
            })
        }))
        alert.addAction(UIAlertAction(title: "cancel".localized(), style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    @objc func handleKeyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
            let isKeyboardShowing = notification.name == UIResponder.keyboardWillShowNotification
            bottomConstraint?.constant = isKeyboardShowing ? -keyboardFrame!.height  : 0
            tableViewBottomConstraint.constant = isKeyboardShowing ? keyboardFrame!.height + 48 : 48
            UIView.animate(withDuration: 0, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
                self.view.layoutIfNeeded()
            }, completion: { (completed) in
                if isKeyboardShowing {
                    if (self.channelMessages.array != nil && (self.channelMessages.array?.count)! > 1) {
                        let indexPath1 = IndexPath(item: (self.channelMessages.array?.count)! - 1, section: 0)
                        self.tableView?.scrollToRow(at: indexPath1, at: .bottom, animated: true)
                    }
                }
            })
        }
    }
    
    @IBAction func nameOfChannelButtonAction(_ sender: Any) {
        DispatchQueue.main.async {
            switch self.channelInfo?.role {
            case 0:
                self.mainRouter?.showAdminInfoViewController(channelInfo: self.channelInfo!)
            case 1:
                self.mainRouter?.showModeratorInfoViewController(channelInfo: self.channelInfo!)
            default:
                self.mainRouter?.showChannelInfoViewController(channelInfo: self.channelInfo!)
            }
        }
    }
    
    @IBAction func backButtonAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func universalButtonAction(_ sender: Any) {
        if channelInfo?.role == 3 {
            viewModel?.subscribeToChannel(id: channelInfo!.channel!._id, completion: { (subResponse, error) in
                if error != nil {
                    DispatchQueue.main.async {
                        self.showErrorAlert(title: "error".localized(), errorMessage: error!.rawValue)
                    }
                } else {
                    SharedConfigs.shared.signedUser?.channels?.append(self.channelInfo.channel!._id)
                    self.channelInfo?.role = 2
                    if self.channelInfo.channel?.openMode ?? false {
                        DispatchQueue.main.async {
                            self.addConstraints()
                            self.setupInputComponents()
                        }
                    }
                    if self.mainRouter?.channelListViewController?.mode == .main {
                        self.mainRouter?.channelListViewController?.channels.append(self.channelInfo!)
                        self.mainRouter?.channelListViewController?.channelsInfo = (self.mainRouter?.channelListViewController?.channels)!
                        DispatchQueue.main.async {
                            self.mainRouter?.channelListViewController?.tableView.reloadData()
                        }
                    } else {
                        self.mainRouter?.channelListViewController?.channels.append(self.channelInfo!)
                        for i in 0..<self.mainRouter!.channelListViewController!.foundChannels.count {
                            if self.mainRouter!.channelListViewController!.foundChannels[i].channel?._id == self.channelInfo?.channel?._id {
                                self.mainRouter!.channelListViewController!.foundChannels[i].role = 2
                                break
                            }
                        }
                        self.mainRouter?.channelListViewController?.channelsInfo = (self.mainRouter?.channelListViewController?.foundChannels)!
                        DispatchQueue.main.async {
                            self.mainRouter?.channelListViewController?.tableView.reloadData()
                        }
                    }
                    DispatchQueue.main.async {
                        self.mainRouter?.channelListViewController?.tableView.reloadData()
                        self.universalButton.isHidden = true
                    }
                    
                }
            })
        }  else if channelInfo?.role == 0 || channelInfo?.role == 1 {
            check = !check
            isPreview = check
            DispatchQueue.main.async {
                self.tableView.allowsMultipleSelection = true
                UIView.setAnimationsEnabled(false)
                self.tableView.beginUpdates()
                self.tableView.reloadData()
                self.tableView.endUpdates()
                if !self.isPreview! {
                    self.setDeleteMessageButton()
                    self.inputTextField.placeholder = ""
                    self.universalButton.setTitle("cancel".localized(), for: .normal)
                    self.tableView.allowsMultipleSelection = true
                    self.sendButton.isHidden = true
                } else {
                    self.sendButton.isHidden = false
                    self.tableView.allowsMultipleSelection = false
                    self.inputTextField.placeholder = "enter_message".localized()
                    self.tableView.allowsSelection = false
                    self.universalButton.setTitle("edit".localized(), for: .normal)
                    self.removeDeleteButton()
                }
            }
        }
    }
    
    func getChannelMessages() {
        viewModel?.getChannelMessages(id: self.channelInfo!.channel!._id, dateUntil: "", completion: { (messages, error) in
            if error != nil {
                DispatchQueue.main.async {
                    self.showErrorAlert(title: "error".localized(), errorMessage: error!.rawValue)
                }
            } else if messages != nil {
                self.isLoadedMessages = true
                self.channelMessages = messages!
                if messages?.array?.count != 0 {
                    self.channelMessages.array!.reverse()
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        if self.channelInfo.role == 0 || self.channelInfo.role == 1 {
                            self.check = true
                            self.universalButton.isHidden = false
                            self.universalButton.setTitle("edit".localized(), for: .normal)
                        }
                        if self.channelMessages.array!.count > 0 {
                            self.tableView.scrollToRow(at: IndexPath(row: self.channelMessages.array!.count - 1, section: 0), at: .top, animated: false)
                        }
                    }
                } else {
                    self.setView("there_is_no_publication_yet".localized())
                    DispatchQueue.main.async {
                        if self.channelInfo.role == 0 || self.channelInfo.role == 1 {
                            self.universalButton.isHidden = true
                        }
                    }
                }
            }
        })
    }
    
    @objc func handleTap(gestureReconizer: UILongPressGestureRecognizer) {
        if gestureReconizer.state == UIGestureRecognizer.State.began {
            let touchPoint = gestureReconizer.location(in: tableView)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                let cell = tableView.cellForRow(at: indexPath) as? SendMessageTableViewCell
                print("cell?.messageLabel.text \(String(describing: cell?.messageLabel.text))")
                let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "delete".localized(), style: .default, handler: { (action) in
                    self.viewModel?.deleteChannelMessageBySender(ids: [cell?.id ?? ""], completion: { (error) in
                        if error != nil {
                            DispatchQueue.main.async {
                                self.showErrorAlert(title: "error".localized(), errorMessage: error!.rawValue)
                            }
                        }
                    })
                }))
                alert.addAction(UIAlertAction(title: "edit".localized(), style: .default, handler: { (action) in
                    self.mode = .edit
                    self.sendButton.setImage(UIImage.init(systemName: "checkmark.circle.fill"), for: .normal)
                    self.indexPath = indexPath
                    self.inputTextField.text = cell?.messageLabel.text
                }))
                alert.addAction(UIAlertAction(title: "cancel".localized(), style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            
        }
    }
    
    func handleMessageEdited(message: Message) {
        if message.owner == channelInfo.channel?._id {
            for i in 0..<(channelMessages.array?.count ?? 0) {
                if channelMessages.array?[i]._id == message._id {
                    channelMessages.array?[i] = message
                    DispatchQueue.main.async {
                        if message.senderId == SharedConfigs.shared.signedUser?.id {
                            (self.tableView.cellForRow(at: IndexPath(row: i, section: 0)) as? SendMessageTableViewCell)?.messageLabel.text = message.text
                        } else {
                            (self.tableView.cellForRow(at: IndexPath(row: i, section: 0)) as? RecieveMessageTableViewCell)?.messageLabel.text = message.text
                        }
                    }
                    break
                }
            }
        }
    }
    
    func handleChannelMessageDeleted(messages: [Message]) {
        for message in messages {
            if message.owner == channelInfo.channel?._id {
                var i = 0
                DispatchQueue.main.async {
                    while i < self.channelMessages.array?.count ?? 0 {
                        if self.channelMessages.array?[i]._id == message._id {
                            self.channelMessages.array?.remove(at: i)
                            self.tableView.deleteRows(at: [IndexPath(row: i, section: 0)], with: .automatic)
                            if self.channelMessages.array?.count == 0 {
                                self.setView("there_is_no_publication_yet".localized())
                            }
                        } else {
                            i += 1
                        }
                    }
                }
            }
        }
    }
}

//MARK: Extensions
extension ChannelMessagesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return channelMessages.array!.count
    }
    
    //MARK: HeightForRowAt indexPath
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var size: CGSize?
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        size = CGSize(width: self.view.frame.width * 0.6 - 100, height: 1500)
       
        if channelMessages.array?.count ?? 0 > indexPath.row {
            let frame = NSString(string: channelMessages.array![indexPath.row].text ?? "").boundingRect(with: size!, options: options, attributes: nil, context: nil)
            if channelMessages.array![indexPath.row].type == "image" {
                return UITableView.automaticDimension
            }
            return channelMessages.array![indexPath.row].senderId == SharedConfigs.shared.signedUser?.id ?  frame.height + 30 : frame.height + 30 + 20
        } else {
            return 0
        }
    }
    
    //MARK: WillDeselectRowAt indexPath
    func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? {
        if channelMessages.array![indexPath.row].senderId == SharedConfigs.shared.signedUser?.id {
            let cell = tableView.cellForRow(at: indexPath) as? SendMessageTableViewCell
            arrayOfSelectedMesssgae = arrayOfSelectedMesssgae.filter({ (id) -> Bool in
                return  id != channelMessages.array![indexPath.row]._id
            })
            cell!.checkImageView?.image = UIImage.init(systemName: "circle")
        } else {
            let cell = tableView.cellForRow(at: indexPath) as? RecieveMessageTableViewCell
            arrayOfSelectedMesssgae = arrayOfSelectedMesssgae.filter({ (id) -> Bool in
                return  id != channelMessages.array![indexPath.row]._id
            })
            cell!.checkImage?.image = UIImage.init(systemName: "circle")
        }
        return indexPath
    }
    
    
    //MARK: DidSelectRowAt indexPath
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        arrayOfSelectedMesssgae.append(channelMessages.array![indexPath.row]._id!)
        let image = UIImage.init(systemName: "checkmark.circle.fill")
        if channelMessages.array![indexPath.row].senderId == SharedConfigs.shared.signedUser?.id {
            let cell = tableView.cellForRow(at: indexPath) as? SendMessageTableViewCell
            cell?.checkImageView?.image = image
        } else {
            let cell = tableView.cellForRow(at: indexPath) as? RecieveMessageTableViewCell
            cell!.checkImage.image = image
        }
    }
    
    //MARK: CellForRowAt indexPath
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
          let tap = UILongPressGestureRecognizer(target: self, action: #selector(handleTap))
        if channelMessages.array![indexPath.row].senderId == SharedConfigs.shared.signedUser?.id {
            if channelMessages.array![indexPath.row].type == "image" {
                let cell = tableView.dequeueReusableCell(withIdentifier: "sendImageMessage", for: indexPath) as! SendImageMessageTableViewCell
                ImageCache.shared.getImage(url: channelMessages.array![indexPath.row].image?.imageURL ?? "", id: channelMessages.array![indexPath.row]._id ?? "", isChannel: false) { (image) in
                    DispatchQueue.main.async {
                        cell.setPostedImage(image: image)
                    }
                }
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "sendMessageCell", for: indexPath) as! SendMessageTableViewCell
                cell.id = channelMessages.array![indexPath.row]._id
                cell.readMessage.isHidden = true
                cell.messageLabel.backgroundColor = UIColor(red: 126/255, green: 192/255, blue: 235/255, alpha: 1)
                cell.messageLabel.text = channelMessages.array![indexPath.row].text
                cell.messageLabel.sizeToFit()
                cell.contentView.addGestureRecognizer(tap)
                cell.checkImageView?.image = UIImage.init(systemName: "circle")
                if  (channelInfo?.role == 0 || channelInfo?.role == 1) {
                    cell.setCheckImage()
                    cell.setCheckButton(isPreview: isPreview!)
                } else {
                    cell.checkImageView?.isHidden = true
                }
                return cell
            }
        } else {
            if channelMessages.array![indexPath.row].type == "image" {
                let cell = tableView.dequeueReusableCell(withIdentifier: "sendImageMessage", for: indexPath) as! SendImageMessageTableViewCell
                ImageCache.shared.getImage(url: channelMessages.array![indexPath.row].image?.imageURL ?? "", id: channelMessages.array![indexPath.row]._id ?? "", isChannel: false) { (image) in
                    DispatchQueue.main.async {
                        cell.setPostedImage(image: image)
                    }
                }
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "receiveMessageCell", for: indexPath) as! RecieveMessageTableViewCell
                cell.messageLabel.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
                cell.messageLabel.text = channelMessages.array![indexPath.row].text
                for i in 0..<(channelInfo.channel?.subscribers?.count)! {
                    if channelInfo.channel?.subscribers?[i].user == channelMessages.array![indexPath.row].senderId {
                        cell.nameLabel.text = channelInfo.channel?.subscribers?[i].name
                        ImageCache.shared.getImage(url: channelInfo.channel?.subscribers?[i].avatarURL ?? "", id: channelInfo.channel?.subscribers?[i].user ?? "", isChannel: false) { (image) in
                            DispatchQueue.main.async {
                                cell.userImageView.image = image
                            }
                        }
                        break
                    }
                }
                cell.messageLabel.sizeToFit()
                if (channelInfo?.role == 0 || channelInfo?.role == 1) {
                    cell.setCheckImage()
                    cell.setCheckButton(isPreview: isPreview!)
                } else {
                    cell.checkImage.isHidden = true
                }
                return cell
            }
        }
    }
}

extension UITableView {
    func reloadData(completion:@escaping ()->()) {
        UIView.animate(withDuration: 0, animations: { self.reloadData() })
        { _ in completion() }
    }
}

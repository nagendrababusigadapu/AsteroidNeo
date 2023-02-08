//
//  ViewController.swift
//  Asteroid
//
//  Created by Nagendra Babu Sigadapu on 07/02/23.
//

import UIKit
import Lottie

class searchViewController: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var startDate: UITextField!
    @IBOutlet weak var endDate: UITextField!
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    //MARK: - Properties
    private let searchViewModel = SearchViewModel()
    private var selectedTextField:UITextField?
    private var lottieAnimation: LottieAnimationView?
    
    //MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    

    //MARK: - IBActions
    @IBAction func submitBtnTapped(_ sender: Any) {
        showErrorMsg()
        guard let startDate = startDate.text, let endDate = endDate.text, !startDate.isEmpty, !endDate.isEmpty else {
            showErrorMsg(msg: Constants.emptyDatesMessage, isShow: false)
            return
        }
        /// before making api request compare the dates and it return tuple
        let status = comparingDates(startDate: startDate, endDate: endDate)
        
        if status.0 {
            callAPI(startDate: startDate, endDate: endDate)
        }else {
            let msg = status.1
            showErrorMsg(msg: msg, isShow: false)
            return
        }
        
        
        
    }
}

//MARK: - Private methods

extension searchViewController {
    
    //MARK: - Setup UI
    private func setupUI(){
    
        startDate.delegate = self
        endDate.delegate = self
        
        addPickerToTextField(startDate)
        addPickerToTextField(endDate)
        
        submitBtn.layer.cornerRadius = 5
        submitBtn.layer.borderWidth = 2.0
        submitBtn.layer.borderColor = UIColor.hexStringToUIColor(hex: "9bacbf").cgColor
    }
    
    //MARK: - Done Action
    @objc private func doneAction(_ textField: UITextField){
        
        if let datePickerView = selectedTextField?.inputView as? UIDatePicker {
            DispatchQueue.main.async { [weak self] in
                self?.selectedTextField?.resignFirstResponder()
                self?.selectedTextField?.text = datePickerView.date.toString()
            }
        }
    }
    
    //MARK: - Cancel Action
    @objc private func cancelAction(){
        selectedTextField?.resignFirstResponder()
    }
    
    /// it will add datePicker to the respected textfield
    private func addPickerToTextField(_ textField:UITextField){
        textField.layer.cornerRadius = 15.0
        textField.layer.borderWidth = 2.0
        textField.layer.borderColor = UIColor.hexStringToUIColor(hex: "F6F6F6").cgColor
        
        let parentView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 24))
        let imageView = UIImageView(image: UIImage(named: "calendar"))
        imageView.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        imageView.contentMode = .scaleAspectFit
        parentView.addSubview(imageView)
        textField.rightView = parentView
        textField.rightViewMode = .always
        
        textField.datePicker(target: self,
                             doneAction: #selector(doneAction(_:)),
                                     cancelAction: #selector(cancelAction),
                                     datePickerMode: .date)
    }
    
    ///handling comaring dates
    private func comparingDates(startDate:String?, endDate:String?) -> (Bool,String?){
        
        guard let startDate = startDate?.toDate(), let endDate = endDate?.toDate() else {
            return (false,Constants.emptyDatesMessage )
        }
        if startDate == endDate {
            return (false,Constants.sameDatesMessage)
        }else{
            let diffInDays = Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 0
            if (diffInDays > 7) || (diffInDays < -7) {
                return (false,Constants.dateLimitMessage)
            }else{
                return (true,nil)
            }
        }
       
    }

    
    private func showErrorMsg(msg:String? = "",isShow:Bool? = true){
        DispatchQueue.main.async { [weak self] in
            self?.errorLabel.text = msg
            self?.errorLabel.isHidden = isShow ?? true ? true : false
            
        }
    }
    
}

//MARK: - UITextFieldDelegate Methods

extension searchViewController: UITextFieldDelegate {
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        showErrorMsg()
        self.selectedTextField = textField
    }
    
}

/// sending user inputs to view model and recieving the response from view model
extension searchViewController {
    /// handling api calling through viewmodel
    private func callAPI(startDate:String, endDate:String){
        showLoader(status: true)
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            
            self?.searchViewModel.startDate = startDate
            self?.searchViewModel.endDate = endDate

            self?.searchViewModel.fetchData(completion: { isSuccess, error in
                self?.showLoader(status: false)
                if (isSuccess) {
                    guard let vc = self?.storyboard?.instantiateViewController(withIdentifier: "ResultViewController") as? ResultViewController else {
                        return
                    }
                    vc.searchVM = self?.searchViewModel
                    self?.navigationController?.pushViewController(vc, animated: true)
                }else{
                    self?.showLoader(status: false)
                    self?.showAlert(msg: error ?? Constants.globalMessage)
                }
            })
        }
    }
}

//MARK: - Lottie Loader

extension searchViewController{
    /// loader
    private func showLoader(status:Bool){
        if status {
            lottieAnimation = LottieAnimationView(name: "loader")
            lottieAnimation?.frame = view.bounds
            lottieAnimation?.contentMode = .scaleAspectFill
            lottieAnimation?.frame = CGRect(x: 0, y: 0, width: 200, height: 300)
            lottieAnimation?.center = self.view.center
            lottieAnimation?.isHidden = false
            view.isUserInteractionEnabled = false
            view.addSubview(lottieAnimation!)
            lottieAnimation?.loopMode = .loop
            lottieAnimation?.play()
        }else{
            view.isUserInteractionEnabled = true
            lottieAnimation?.stop()
            lottieAnimation?.isHidden = true
        }
        
    }
    
    
    
    ///Show alert
    func showAlert(msg:String){
        self.openAlert(title: Constants.appName,
                              message: msg,
                              alertStyle: .alert,
                              actionTitles: ["Okay"],
                              actionStyles: [.default],
                              actions: [{_ in  }])
    }
}





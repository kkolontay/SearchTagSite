//
//  InputConditionViewController.swift
//  ResearchSite
//
//  Created by kkolontay on 12/13/16.
//  Copyright © 2016 kkolontay.etachki.com. All rights reserved.
//
import UIKit
import Foundation

class InputConditionViewController: UIViewController, UITextFieldDelegate{

    @IBOutlet weak var inputURLTextField: UITextField!
    @IBOutlet weak var quantityThreadTextField: UITextField!
    @IBOutlet weak var searchTextTextField: UITextField!
    @IBOutlet weak var maxQuantityURLTextField: UITextField!
    @IBOutlet weak var myScrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
   // var connection:NetworkConnectionToSite?
    var quantityThread: Int?
    var maxReferences: Int?
    var urlString: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        inputURLTextField.delegate = self
        quantityThreadTextField.delegate = self
        searchTextTextField.delegate = self
        maxQuantityURLTextField.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_ :)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_ :)), name: .UIKeyboardWillHide, object: nil)
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func keyboardWillShow(_ notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {

            let insets:UIEdgeInsets = UIEdgeInsetsMake(myScrollView.contentInset.top, 0.0, keyboardSize.height + 20, 0.0)
            
            myScrollView.contentInset = insets
            myScrollView.scrollIndicatorInsets = insets
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    
    func keyboardWillHide(_ notification: NSNotification) {
     
        let insets:UIEdgeInsets = UIEdgeInsetsMake(myScrollView.contentInset.top, 0.0, 0.0, 0.0)
        
        myScrollView.contentInset = insets
        myScrollView.scrollIndicatorInsets = insets
          }
    
    
    @IBAction func goButtonPressed(_ sender: UIButton) {
         quantityThread = 1
         maxReferences = 1
        if  quantityThreadTextField.text?.isEmpty == false , let quantityThreadTemp = Int(quantityThreadTextField.text!)   {
            if quantityThreadTemp > 0 && quantityThreadTemp < 15 {
                quantityThread = quantityThreadTemp
            }
        }
        if maxQuantityURLTextField.text?.isEmpty == false, let quantityURL = Int(maxQuantityURLTextField.text!) {
            if quantityURL > 0 && quantityURL < 100 {
            maxReferences = quantityURL
            }
        }
        if canOpenURL(string: inputURLTextField.text) {
            urlString = inputURLTextField.text!
            
        } else {
            _ = AlertController(self, error: "Не верный формат ссылки.")
            return
        }
        if searchTextTextField.text?.isEmpty == true {
            _ = AlertController(self, error: "Ввудите текст для поиска.")
            return
        }
        performSegue(withIdentifier: "search", sender: nil)
     }

    func canOpenURL(string: String?) -> Bool {
        
        let regEx = "((http|https)://)?((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+"
        let predicate = NSPredicate(format:"SELF MATCHES %@", argumentArray:[regEx])
        return predicate.evaluate(with: string)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "search" {
            let controller = segue.destination as! ThreadListViewController
            controller.maximumThread = quantityThread
            controller.lookingForText = searchTextTextField.text
            controller.maximumLookingForString = maxReferences
            controller.urlString = urlString
        }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
}
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}

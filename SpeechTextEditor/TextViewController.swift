//
//  TextViewController.swift
//  SpeechTextEditor
//
//  Created by 王乙飞 on 2017/5/2.
//  Copyright © 2017年 王乙飞. All rights reserved.
//

import UIKit
import CoreData

class TextViewController: UIViewController,UITextViewDelegate{
    var textIndex:Int?
    
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.textView.delegate=self
        
        self.textView.backgroundColor = UIColor.clear
        self.textView.textAlignment = NSTextAlignment.left
        self.textView.textColor = UIColor.darkText
        self.textView.font = UIFont(name: "GillSans", size: 20.0)
        
        self.textView.isEditable = true
        self.textView.isUserInteractionEnabled = true
        self.textView.isScrollEnabled = true
        
        //self.app = UIApplication.shared.delegate as! AppDelegate
        //self.context = app.persistentContainer.viewContext
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("viewWillAppear")
        print(self.textIndex!)
        self.textView.text="wefcser王乙飞"
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        print("textViewShouldBeginEditing")
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        print("textViewDidBeginEditing")
    }
    
    func textViewDidChange(_ textView: UITextView) {
        print("textViewDidChange")
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        print("textViewShouldEndEditing")
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        print("textViewDidEndEditing")
    }
    
    @IBAction func back(_ sender: UIBarButtonItem) {
        print(self.navigationItem.title!)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func save(_ sender: UIBarButtonItem) {
        let text = NSEntityDescription.insertNewObject(forEntityName: "Text", into: context) as! Text
        text.date=NSDate()
        text.content=self.textView.text
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString = formatter.string(from: text.date! as Date)
        print(dateString)
        
        do {
            try context.save()
            print("保存成功！")
        } catch {
            fatalError("不能保存：\(error)")
        }
    }
}

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
    
    let fetchRequest = NSFetchRequest<Text>(entityName:"Text")
    var isUpdate:Bool?
    var isSave:Bool=true
    var textDate:Date?
    var textContent:String?
    
    @IBOutlet weak var textView: UITextView!
    
    let alertController = UIAlertController(title: "提示",
                                            message: "修改尚未保存，是否保存？", preferredStyle: .alert)

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
        //定义事件
        let cancelAction = UIAlertAction(title: "否", style: .cancel, handler: {
            action in
            self.textDate=nil
            self.textContent=nil
            self.dismiss(animated: true, completion: nil)
            
        })
        let okAction = UIAlertAction(title: "是", style: .default, handler: {
            action in
            //保存
            //查询操作
            do {
                let fetchedObjects = try context.fetch(self.fetchRequest)
                
                //遍历查询的结果
                for info in fetchedObjects{
                    //更新对象
                    if(info.date! as Date==self.textDate){
                        info.content=self.textView.text
                        break
                    }
                }
                try! context.save()
            } catch {
                fatalError("不能更新：\(error)")
            }
            NSLog("更新成功")
            self.textDate=nil
            self.textContent=nil
            self.dismiss(animated: true, completion: nil)
        })
        self.alertController.addAction(cancelAction)
        self.alertController.addAction(okAction)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("viewWillAppear")
        if(self.textDate==nil){
            self.textDate=NSDate() as Date
        }else{
            //查询操作
            do {
                let fetchedObjects = try context.fetch(self.fetchRequest)
                
                //遍历查询的结果
                for info in fetchedObjects{
                    if(info.date! as Date==self.textDate){
                        self.textContent=info.content
                        break
                    }
                }
            } catch {
                fatalError("不能查询：\(error)")
            }
        }
        self.textView.text=textContent
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
        self.isSave=false
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
        if(self.isSave){
            self.textDate=nil
            self.textContent=nil
            self.dismiss(animated: true, completion: nil)
        }else{
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    @IBAction func save(_ sender: UIBarButtonItem) {
        if(self.isSave){
            return
        }
        if(self.isUpdate!){
            //查询操作
            do {
                let fetchedObjects = try context.fetch(self.fetchRequest)
                
                //遍历查询的结果
                for info in fetchedObjects{
                    //更新对象
                    if(info.date! as Date==self.textDate){
                        info.content=self.textView.text
                        break
                    }
                }
                try! context.save()
            } catch {
                fatalError("不能更新：\(error)")
            }
            NSLog("更新成功")
        }else{
            let text = NSEntityDescription.insertNewObject(forEntityName: "Text", into: context) as! Text
            text.date=self.textDate! as NSDate
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
            self.isUpdate=true
        }
        self.isSave=true
    }
}

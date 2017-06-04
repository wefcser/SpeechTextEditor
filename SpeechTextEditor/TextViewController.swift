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
    var isSpeak:Bool=false
    
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var speak: UIButton!
    
    let unSaveAlertController = UIAlertController(title: "修改尚未保存，是否保存？",
                                                  message: nil,
                                                  preferredStyle: .alert)
    let saveSuccessAlertController = UIAlertController(title: "保存成功！",
                                                       message: nil,
                                                       preferredStyle: .alert)
    let saveFailureAlertController = UIAlertController(title: "保存失败！",
                                                       message: nil,
                                                       preferredStyle: .alert)
//    let speakAlertController = UIAlertController(title: "正在录音...",
//                                                 message: nil,
//                                                 preferredStyle: .alert)
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
        
        self.speak.setTitle("开始听写", for: .normal)
        //self.app = UIApplication.shared.delegate as! AppDelegate
        //self.context = app.persistentContainer.viewContext
        //提示框定义事件
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
                //显示保存失败提示框
                self.present(self.saveFailureAlertController, animated: true, completion: nil)
                //一秒钟后自动消失
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                    self.presentedViewController?.dismiss(animated: false, completion: nil)
                    self.textDate=nil
                    self.textContent=nil
                    self.dismiss(animated: true, completion: nil)
                }
                fatalError("不能更新：\(error)")
            }
            NSLog("更新成功")
            self.textDate=nil
            self.textContent=nil
            self.dismiss(animated: true, completion: nil)
        })
        self.unSaveAlertController.addAction(cancelAction)
        self.unSaveAlertController.addAction(okAction)
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
            //显示未保存提示框
            self.present(self.unSaveAlertController, animated: true, completion: nil)
        }
    }
    
    @IBAction func save(_ sender: UIBarButtonItem) {
        if(self.isSave){
            //显示保存成功提示框
            self.present(self.saveSuccessAlertController, animated: true, completion: nil)
            //一秒钟后自动消失
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                self.presentedViewController?.dismiss(animated: false, completion: nil)
            }
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
                //显示保存失败提示框
                self.present(self.saveFailureAlertController, animated: true, completion: nil)
                //一秒钟后自动消失
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                    self.presentedViewController?.dismiss(animated: false, completion: nil)
                }
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
                //显示保存失败提示框
                self.present(self.saveFailureAlertController, animated: true, completion: nil)
                //一秒钟后自动消失
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                    self.presentedViewController?.dismiss(animated: false, completion: nil)
                }
                fatalError("不能保存：\(error)")
            }
            self.isUpdate=true
        }
        
        self.isSave=true
        //显示保存成功提示框
        self.present(self.saveSuccessAlertController, animated: true, completion: nil)
        //两秒钟后自动消失
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
            self.presentedViewController?.dismiss(animated: false, completion: nil)
        }
        return
    }
    
    @IBAction func touchToSpeak(_ sender: UIButton) {
        if(self.isSpeak){
            self.isSpeak=false
            self.speak.setTitle("开始听写", for: .normal)
            //
            
        }else{
            self.isSpeak=true
            self.speak.setTitle("结束听写", for: .normal)
            //
            
        }
    }
}

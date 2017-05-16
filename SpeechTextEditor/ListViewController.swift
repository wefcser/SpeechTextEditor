//
//  ViewController.swift
//  SpeechTextEditor
//
//  Created by 王乙飞 on 2017/5/2.
//  Copyright © 2017年 王乙飞. All rights reserved.
//

import UIKit
import CoreData

let app:AppDelegate = UIApplication.shared.delegate as! AppDelegate
let context:NSManagedObjectContext = app.persistentContainer.viewContext

class ListViewController: UIViewController,UITableViewDelegate, UITableViewDataSource{

    let fetchRequest = NSFetchRequest<Text>(entityName:"Text")
    let descOffset:Int = 5
    var isUpdate:Bool = false
    var items:[Date:String] = [:]
    var keys:[Date] = []
    var destDate:Date?=nil
    var isListChange = false
    @IBOutlet weak var textList: UITableView!
    
    override func viewDidLoad() {
        print("viewDidLoad begin")
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.textList.delegate=self
        self.textList.dataSource=self
        
        print("viewDidLoad end")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier=="showTextView"){
            let dest=segue.destination as! TextViewController
            dest.navigationItem.title="textView"
            dest.isUpdate=self.isUpdate
            dest.textDate=self.destDate
            if(self.destDate != nil){
                dest.textContent=self.items[self.destDate!]
            }
        }
        print("prepare")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("List view will appear")
        // 本地数据查询遍历
        // 查询条件设置
        //fetchRequest.fetchLimit = 10 //限定查询结果的数量
        //fetchRequest.fetchOffset = 0 //查询的偏移量
        
        //let predicate = NSPredicate(format: "", "")
        //fetchRequest.predicate = predicate

        do {
            let fetchedObjects = try context.fetch(fetchRequest)
            self.keys=[]
            //遍历查询的结果
            for text in fetchedObjects{
                //var offset:Int
                //                if(text.content?.s<=self.descOffset){
                //                    offset=text.content?.endIndex.
                //                }else{
                //                    offset=self.descOffset
                //                }
                let index = text.content?.index((text.content?.startIndex)!, offsetBy: descOffset)
                self.keys.append(text.date! as Date)
                self.items[text.date! as Date]=text.content?.substring(to: index!)
            }
            self.keys.sort()
        }catch {
            fatalError("不能查询：\(error)")
        }
        self.textList.reloadData()

    }
    
    @IBAction func goTextView(_ sender: UIButton) {
        self.isUpdate=false
        self.destDate=nil
        self.performSegue(withIdentifier: "showTextView", sender: self)
        print("back")
    }
    //返回几组
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    //返回行数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    //每一行高度
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    //每一行内容
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier: String = "cellModel1"
        var cell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        if(cell==nil){
            print("cell nil")
            cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: cellIdentifier)
            cell!.textLabel?.font = UIFont.systemFont(ofSize: 14)
            cell!.selectionStyle = .gray
            cell!.accessoryType = UITableViewCellAccessoryType.none
        }
        //date to string
        cell!.textLabel?.text = date2String(date: keys[indexPath.row])
        cell!.detailTextLabel?.text = items[keys[indexPath.row]]
        
        return cell!
    }
    //点击一行
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //释放选中效果
        tableView.deselectRow(at: indexPath, animated: true)
        let cell:UITableViewCell! = tableView.cellForRow(at: indexPath)
        
        print(cell!.textLabel?.text!)
        
        self.isUpdate=true
        self.destDate=self.keys[indexPath.row]
        self.performSegue(withIdentifier: "showTextView", sender: self)
    }
    /*
    //删除一行
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let index=indexPath.row as Int
        self.items.remove(at: index)
        self.textList.deleteRows(at: [indexPath], with: UITableViewRowAnimation.top)
        NSLog("删除\(indexPath.row)")
    }
    //删除按钮内容设置
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "删除"
    }*/
    //
    //自定义编辑操作,自定义按钮样式
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction:UITableViewRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "删除", handler: {(action:UITableViewRowAction,indexPath: IndexPath) in
            //临时信息删除
            let index:Int = indexPath.row
            let date:Date = self.keys[index]
            self.keys.remove(at: index)
            self.items.removeValue(forKey: date)
            self.textList.deleteRows(at: [indexPath], with: UITableViewRowAnimation.top)
            //本地数据删除
            let dateString = date.description
            print(dateString)
            //设置查询条件
            //let predicate = NSPredicate(format: "date = '"+dateString+"'", "")
            //self.fetchRequest.predicate = predicate
            
            //查询操作
            do {
                let fetchedObjects = try context.fetch(self.fetchRequest)
                
                //遍历查询的结果
                for info in fetchedObjects{
                    //删除对象
                    if(info.date! as Date==date){
                        context.delete(info)
                        break
                    }
                }
                //重新保存-更新到数据库
                try! context.save()
            } catch {
                fatalError("不能更新：\(error)")
            }
            NSLog("删除\(indexPath.row)")
        })
        //deleteAction.backgroundColor = UIColor.green
        deleteAction.backgroundEffect = UIBlurEffect(style:UIBlurEffectStyle.dark)
        return [deleteAction]
    }
    
    func date2String(date:Date)->String{
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString = formatter.string(from: date as Date)
        return dateString
    }
}


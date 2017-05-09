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

    var items:[Date:String?] = [:]
    var keys:[Date] = []
    @IBOutlet weak var textList: UITableView!
    
    override func viewDidLoad() {
        print("viewDidLoad begin")
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.textList.delegate=self
        self.textList.dataSource=self
        
        let fetchRequest = NSFetchRequest<Text>(entityName:"Text")
        //let predicate = NSPredicate(format: "", "")
        //fetchRequest.predicate = predicate
        
        do {
            let fetchedObjects = try context.fetch(fetchRequest)
            
            //遍历查询的结果
            for text in fetchedObjects{
                let index = text.content?.index((text.content?.startIndex)!, offsetBy: 5)
                self.keys.append(text.date! as Date)
                self.items[text.date! as Date]=text.content?.substring(to: index!)
            }
            self.keys.sort()
        }
        catch {
            fatalError("不能保存：\(error)")
        }
        
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
            dest.textIndex=3
        }
        print("prepare")
    }
    
    @IBAction func goTextView(_ sender: UIButton) {
        print("go")
        self.performSegue(withIdentifier: "showTextView", sender: self)
        print("goback")
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
        print("cell begin")
        let cellIdentifier: String = "cellModel1"
        var cell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        if(cell==nil){
            print("cell nil")
            cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: cellIdentifier)
            cell!.textLabel?.font = UIFont.systemFont(ofSize: 14)
            cell!.selectionStyle = .gray
            cell!.accessoryType = UITableViewCellAccessoryType.none
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString = formatter.string(from: keys[indexPath.row] as Date)
        cell!.textLabel?.text=dateString
        //cell!.contentView.
        //cell!.imageView?.image = UIImage(named:"cellImage.png")
        //cell!.detailTextLabel?.text = "详细信息介绍"
        
        print("cell end")
        return cell!
    }
    //点击一行
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //释放选中效果
        tableView.deselectRow(at: indexPath, animated: true)
        let cell:UITableViewCell! = tableView.cellForRow(at: indexPath)
        
        print(cell!.textLabel?.text!)
        
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
//    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
////        let deleteAction:UITableViewRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "删除", handler: {(action:UITableViewRowAction,indexPath: IndexPath) in
////            let index=indexPath.row as Int
////            self.items.remove(at: index)
////            self.textList.deleteRows(at: [indexPath], with: UITableViewRowAnimation.top)
////            NSLog("删除\(indexPath.row)")
//        })
//        //deleteAction.backgroundColor = UIColor.green
//        deleteAction.backgroundEffect = UIBlurEffect(style:UIBlurEffectStyle.dark)
//        return [deleteAction]
//    }
}


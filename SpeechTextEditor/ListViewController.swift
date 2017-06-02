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

extension String {
    var length: Int { return self.characters.count }
}

class ListViewController: UIViewController,UITableViewDelegate, UITableViewDataSource{

    let fetchRequest = NSFetchRequest<Text>(entityName:"Text")
    var isUpdate:Bool = false
    var items:[Date:String] = [:]
    var keys:[Date] = []
    var destDate:Date?=nil
    var isListChange = false
    let descLines:Int = 3
    let delta:CGFloat = 36.287109375
    var screenWidth:CGFloat = 0
    var screenHeight:CGFloat = 0
    var labelWidth:CGFloat = 0
    let labelMaxHeight:CGFloat = 60.861328125
    @IBOutlet weak var textList: UITableView!
    
    override func viewDidLoad() {
        print("viewDidLoad begin")
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.textList.delegate=self
        self.textList.dataSource=self
        // 隐藏TableView分割线
        let footerView:UIView = UIView()
        footerView.backgroundColor = UIColor.clear
        self.textList.tableFooterView = footerView
        //获得设备高度，宽度
        let r:CGRect = UIScreen.main.bounds
        self.screenWidth = r.maxX
        self.screenHeight = r.maxY
        self.labelWidth = r.maxX-16
        print(self.labelWidth)
        
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
                let offset=(text.content?.length)!
                let index = text.content?.index((text.content?.startIndex)!, offsetBy: offset)
                let content:String = (text.content?.substring(to: index!))!
                self.keys.append(text.date! as Date)
                self.items[text.date! as Date] = content
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
        if(indexPath.row>=self.keys.count){
            return self.labelMaxHeight+self.delta
        }else{
            //cell height 高度计算
            let content:String = items[keys[indexPath.row]]!
            var contentHeight:CGFloat = self.getLabelHeigh(labelStr: content, font: UIFont.systemFont(ofSize: 17.0), width: self.labelWidth)
            if(contentHeight>self.labelMaxHeight){
                contentHeight=self.labelMaxHeight
            }
            print(contentHeight)
            let cellHeight = contentHeight + self.delta

            return cellHeight
        }
    }
    //每一行内容
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier: String = "ListCell"
        let cell: ListCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! ListCell
        //cell content 显示多行
        cell.content.numberOfLines = self.descLines
        cell.content.lineBreakMode = NSLineBreakMode.byTruncatingTail

        //date to string
        cell.date.text = date2String(date: keys[indexPath.row])
        cell.content.text = items[keys[indexPath.row]]
        
        return cell
    }
    //点击一行
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //释放选中效果
        tableView.deselectRow(at: indexPath, animated: true)
        //let cell:UITableViewCell! = tableView.cellForRow(at: indexPath)
        
        //print(cell!.textLabel?.text!)
        
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
    
    func getLabelHeigh(labelStr:String,font:UIFont,width:CGFloat) -> CGFloat {
        let statusLabelText: NSString = labelStr as NSString
        let size = CGSize.init(width: width, height: 900)
        let dic = NSDictionary(object: font, forKey: NSFontAttributeName as NSCopying)
        
        let strSize = statusLabelText.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: dic as? [String : AnyObject], context: nil).size
        
        return strSize.height
    }
    
    func getLabelWidth(labelStr:String,font:UIFont,height:CGFloat) -> CGFloat {
        let statusLabelText: NSString = labelStr as NSString
        let size = CGSize.init(width: 900, height: height)
        let dic = NSDictionary(object: font, forKey: NSFontAttributeName as NSCopying)
        
        let strSize = statusLabelText.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: dic as? [String : AnyObject], context: nil).size
        
        return strSize.width
    }
    

}


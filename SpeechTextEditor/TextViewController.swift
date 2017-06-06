//
//  TextViewController.swift
//  SpeechTextEditor
//
//  Created by 王乙飞 on 2017/5/2.
//  Copyright © 2017年 王乙飞. All rights reserved.
//

import UIKit
import CoreData

class TextViewController: UIViewController,UITextViewDelegate,IFlySpeechRecognizerDelegate{
    
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
                    NSLog("更新成功")
                    self.isSave=true
                    //显示保存成功提示框
                    self.present(self.saveSuccessAlertController, animated: true, completion: nil)
                    //一秒钟后自动消失
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                        self.presentedViewController?.dismiss(animated: false, completion: nil)
                    }
                    //1.5秒钟后自动消失
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5) {
                        self.textDate=nil
                        self.textContent=nil
                        self.dismiss(animated: true, completion: nil)
                    }

                } catch {
                    //显示保存失败提示框
                    self.present(self.saveFailureAlertController, animated: true, completion: nil)
                    //一秒钟后自动消失
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                        self.presentedViewController?.dismiss(animated: false, completion: nil)
                    }
                    fatalError("不能更新：\(error)")
                }
                
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
                    self.isUpdate=true
                    self.isSave=true
                    //显示保存成功提示框
                    self.present(self.saveSuccessAlertController, animated: true, completion: nil)
                    //一秒钟后自动消失
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                        self.presentedViewController?.dismiss(animated: false, completion: nil)
                    }
                    //1.5秒钟后自动消失
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5) {
                        self.textDate=nil
                        self.textContent=nil
                        self.dismiss(animated: true, completion: nil)
                    }

                } catch {
                    //显示保存失败提示框
                    self.present(self.saveFailureAlertController, animated: true, completion: nil)
                    //一秒钟后自动消失
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                        self.presentedViewController?.dismiss(animated: false, completion: nil)
                    }
                    fatalError("不能保存：\(error)")
                }
            }
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
        super.viewWillAppear(animated)
        
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
        //初始化识别对象
        self.initRecognizer()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        
        super.viewWillDisappear(animated)
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
                NSLog("更新成功")
                self.isSave = true
                //显示保存成功提示框
                self.present(self.saveSuccessAlertController, animated: true, completion: nil)
                //一秒钟后自动消失
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                    self.presentedViewController?.dismiss(animated: false, completion: nil)
                }
            } catch {
                //显示保存失败提示框
                self.present(self.saveFailureAlertController, animated: true, completion: nil)
                //一秒钟后自动消失
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                    self.presentedViewController?.dismiss(animated: false, completion: nil)
                }
                fatalError("不能更新：\(error)")
            }
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
                NSLog("更新成功")
                self.isUpdate=true
                self.isSave = true
                //显示保存成功提示框
                self.present(self.saveSuccessAlertController, animated: true, completion: nil)
                //一秒钟后自动消失
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                    self.presentedViewController?.dismiss(animated: false, completion: nil)
                }

            } catch {
                //显示保存失败提示框
                self.present(self.saveFailureAlertController, animated: true, completion: nil)
                //一秒钟后自动消失
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                    self.presentedViewController?.dismiss(animated: false, completion: nil)
                }
                fatalError("不能保存：\(error)")
            }
        }
        
        return
    }
    //IFlySpeechRecognizerDelegate
    var iFlySpeechRecognizer:IFlySpeechRecognizer? = nil
    
    @IBAction func touchToSpeak(_ sender: UIButton) {
        if(self.isSpeak){
            self.isSpeak=false
            self.speak.setTitle("开始听写", for: .normal)
            //
            self.iFlySpeechRecognizer?.stopListening()
            
        }else{
            //
            self.iFlySpeechRecognizer?.cancel()
            
            //设置音频来源为麦克风
            self.iFlySpeechRecognizer?.setParameter(IFLY_AUDIO_SOURCE_MIC, forKey:"audio_source")
            
            //设置听写结果格式为json
            self.iFlySpeechRecognizer?.setParameter("json", forKey:IFlySpeechConstant.result_TYPE())
            
            //保存录音文件，保存在sdk工作路径中，如未设置工作路径，则默认保存在library/cache下
            self.iFlySpeechRecognizer?.setParameter("asr.pcm", forKey:IFlySpeechConstant.asr_AUDIO_PATH())
            
            self.iFlySpeechRecognizer?.delegate=self
            
            let ret:Bool = self.iFlySpeechRecognizer!.startListening()
            
            if (ret) {
                self.isSpeak=true
                self.speak.setTitle("结束听写", for: .normal)
            }else{
                NSLog("启动识别服务失败，请稍后重试")//可能是上次请求未结束，暂不支持多路并发
            }
            
        }
    }
    //IFlySpeechRecognizerDelegate 协议实现
    //识别结果返回代理
    func onResults(_ results:[Any]?,isLast:Bool) -> Void{
        if(results == nil){
            return
        }
        
        let resultString:NSMutableString = Ifly.resultString(results![0] as! [AnyHashable:Any])
        
        let result:String = NSString.localizedStringWithFormat("%@%@", self.textView.text, (resultString as String)) as String
        let resultFromJson:String =  ISRDataHelper.string(fromJson: resultString as String!)
        self.textView.text = self.textView.text+resultFromJson
        self.isSave = false
        
        if (isLast){
            NSLog("听写结果(json)：%@测试", result)
        }
        //NSLog(result as String)
        //NSLog("resultFromJson=%@",resultFromJson)
        //NSLog(isLast.description)
    }
    //识别会话结束返回代理
    func onError(_ error:IFlySpeechError){
        NSLog(error.errorDesc)
    }
    //停止录音回调
    func onEndOfSpeech(){
        NSLog("停止录音")
    }
    //开始录音回调
    func onBeginOfSpeech(){
        NSLog("开始录音")
    }
    //音量回调函数
    func onVolumeChanged(volume:Int){
    }
    //会话取消回调
    func onCancel(){
        NSLog("识别取消")
    }
    //设置识别参数
    func initRecognizer(){

        if (self.iFlySpeechRecognizer == nil) {
            self.iFlySpeechRecognizer = IFlySpeechRecognizer.sharedInstance()
            
            self.iFlySpeechRecognizer?.setParameter("", forKey:IFlySpeechConstant.params())
            
            //设置听写模式
            self.iFlySpeechRecognizer?.setParameter("iat", forKey:IFlySpeechConstant.ifly_DOMAIN())
        }
        self.iFlySpeechRecognizer?.delegate = self;
        
        if (self.iFlySpeechRecognizer != nil) {
            let instance = IATConfig.sharedInstance()
            
            //设置最长录音时间
            self.iFlySpeechRecognizer?.setParameter(instance?.speechTimeout, forKey:IFlySpeechConstant.speech_TIMEOUT())
            //设置后端点
            self.iFlySpeechRecognizer?.setParameter(instance!.vadEos, forKey:IFlySpeechConstant.vad_EOS())
            //设置前端点
            self.iFlySpeechRecognizer?.setParameter(instance!.vadBos, forKey:IFlySpeechConstant.vad_BOS())
            //网络等待时间
            self.iFlySpeechRecognizer?.setParameter("20000", forKey:IFlySpeechConstant.net_TIMEOUT())
            
            //设置采样率，推荐使用16K
            self.iFlySpeechRecognizer?.setParameter(instance!.sampleRate, forKey:IFlySpeechConstant.sample_RATE())
            
            let chinese:String = IATConfig.chinese()
            let english:String = IATConfig.english()
            let language:String = instance!.language
            if (language == chinese) {
                //设置语言
                self.iFlySpeechRecognizer?.setParameter(instance!.language, forKey:IFlySpeechConstant.language());
                //设置方言
                self.iFlySpeechRecognizer?.setParameter(instance!.accent, forKey:IFlySpeechConstant.accent())
            }else if (language == english) {
                self.iFlySpeechRecognizer?.setParameter(instance!.language, forKey:IFlySpeechConstant.language())
            }
            //设置是否返回标点符号
            self.iFlySpeechRecognizer?.setParameter(instance!.dot, forKey:IFlySpeechConstant.asr_PTT())
            
        }
        
//        //初始化录音器
//        if (pcmRecorder == nil)
//        {
//            pcmRecorder = [IFlyPcmRecorder sharedInstance];
//        }
//        
//        _pcmRecorder.delegate = self;
//        
//        [_pcmRecorder setSample:[IATConfig sharedInstance].sampleRate];
//        
//        [_pcmRecorder setSaveAudioPath:nil];    //不保存录音文件
    }
    
}

//
//  TextViewController.swift
//  SpeechTextEditor
//
//  Created by 王乙飞 on 2017/5/2.
//  Copyright © 2017年 王乙飞. All rights reserved.
//

import UIKit

class TextViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var text: UITextView!
    
    @IBAction func back(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func save(_ sender: UIBarButtonItem) {
        
    }
}

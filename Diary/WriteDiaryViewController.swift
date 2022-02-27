//
//  WriteDiaryViewController.swift
//  Diary
//
//  Created by limyunhwi on 2022/02/27.
//

import UIKit

class WriteDiaryViewController: UIViewController {
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentsTextView: UITextView!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var confirmButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureContentsTextView()
    }
    
    //내용 텍스트필드의 UI 수정하기
    private func configureContentsTextView(){
        let borderColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1.0)//alpha 값이 0.0에 가까울 수록 투명도가 올라간다.(0.0 ~ 1.0)
        //RGB값에는 alpha값과 동일하게 0.0에서 1.0 사이의 값을 넣어주어야 한다. 따라서 설정하려는 RGB값을 255로 나눠주어야 한다.
        self.contentsTextView.layer.borderColor = borderColor.cgColor//layer관련해 색을 설정할 때는 UIColor가 아닌 cgColor로 설정해야 한다.그래서 UIColor에 있는 cgColor프로퍼티를 사용한다.
        self.contentsTextView.layer.borderWidth = 0.5 //테두리 두께
        self.contentsTextView.layer.cornerRadius = 5.0
    }
    
    @IBAction func tapConfirmButton(_ sender: UIBarButtonItem) {
    }
}

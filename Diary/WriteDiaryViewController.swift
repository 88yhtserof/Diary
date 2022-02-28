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
    
    private let datePicker = UIDatePicker()
    private var diaryDate: Date? //datePicker에서 선택한 날짜를 저장할 프로퍼티
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureContentsTextView()
        self.configureDatePicker()
        self.confirmButton.isEnabled = false
        self.configureInputField()
    }
    
    //내용 텍스트필드의 UI 구성하기
    private func configureContentsTextView(){
        let borderColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1.0)//alpha 값이 0.0에 가까울 수록 투명도가 올라간다.(0.0 ~ 1.0)
        //RGB값에는 alpha값과 동일하게 0.0에서 1.0 사이의 값을 넣어주어야 한다. 따라서 설정하려는 RGB값을 255로 나눠주어야 한다.
        self.contentsTextView.layer.borderColor = borderColor.cgColor//layer관련해 색을 설정할 때는 UIColor가 아닌 cgColor로 설정해야 한다.그래서 UIColor에 있는 cgColor프로퍼티를 사용한다.
        self.contentsTextView.layer.borderWidth = 0.5 //테두리 두께
        self.contentsTextView.layer.cornerRadius = 5.0
    }
    
    //DatePicker 구성하기
    private func configureDatePicker(){
        self.datePicker.datePickerMode = .date
        self.datePicker.preferredDatePickerStyle = .wheels
        self.datePicker.addTarget(self, action: #selector(datePickerValueDidChange), for: .valueChanged) //for : 어떤 이벤트에 앞서 설정한 타겟과 액션이 실행될건지 설정
        //addTarget메서드는 UIController객체가 이벤트에 응답하는 방식을 설정하는 메서드이다.
        self.datePicker.locale = Locale(identifier: "ko_KR")
        self.dateTextField.inputView = self.datePicker //dateTextField를 선택했을 때 키보드가 아닌 datePicker가 표시되게 된다.
    }
    
    //입력 필드 구성하기
    private func configureInputField(){
        //등록버튼 활성화 여부를 판단하기 위해 '내용'은 delegate 할당하는 방법을 사용했고
        //'제목'은 addTarger메서드를 사용하는 방법을 사용
        self.contentsTextView.delegate = self
        self.titleTextField.addTarget(self, action: #selector(titleTextFieldDidChange(_:)), for: .editingChanged) //addTarget메서드는 타겟 객체와 이벤트, 액션을 연결해 준다.
        //위 코드는 titleTextField가 수정될 때마다 titleTextFieldDidChange메서드가 호출된다.
        self.dateTextField.addTarget(self, action: #selector(dateTextfieldDidChange(_:)), for: .editingChanged)
        //dateTextField는 다른 텍스트필드와 다르게 키보드가 아닌 DatePicker가 작동되므로 .editngChange 이벤트가 발생하지 않는다. 따라서 DatePicker가 변했을 때 .editChange 이벤트를 직접 발생시켜줘야 한다.
    }
    
    @IBAction func tapConfirmButton(_ sender: UIBarButtonItem) {
    }
    
    //DatePicker에서 날짜 선택 시 행동할 액션 - 날짜 선택시 날짜 텍스트 필드에 해당 날짜가 뜨도록 구현
    @objc private func datePickerValueDidChange(){
        let formmater = DateFormatter() //날짜와 텍스트를 변환해주는 역할. date타입을 문자열로 변환하거나 날짜형태의 문자열을 date타입으로 변환시켜주는 역할을 한다.
        formmater.dateFormat = "yyyy년 MM월 dd일 EEEEE" //EEEEE 예) 토
        formmater.locale = Locale(identifier: "ko_KR")//dateFormat이 한국어 되게끔 한다.
        self.diaryDate = datePicker.date
        self.dateTextField.text = formmater.string(from: datePicker.date)
        
        //dateTextField는 다른 텍스트필드와 다르게 키보드가 아닌 DatePicker가 작동되므로 .editngChange 이벤트가 발생하지 않는다. 따라서 DatePicker가 변했을 때 .editChange 이벤트를 직접 발생시켜줘야 한다.
        self.dateTextField.sendActions(for: .editingChanged)
    }
    
    @objc private func titleTextFieldDidChange(_ textField: UITextField){
        self.vaildateInputField()
    }
    
    @objc private func dateTextfieldDidChange(_ textField: UITextField){
        self.vaildateInputField()
    }
    
    //빈 화면을 터치 했을 때 키보드 또는 DatePicker가 내려가도록 하기
    //뷰 또는 화면에 한 번 이상의 터치가 발생했다고 이 객체에게 알려준다.
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)//뷰가 첫 번째 응답 상태를 사라지게 하도록 하기
    }
    
    //등록버튼의 활성화여부를 판단하는 메서드
    private func vaildateInputField(){
        self.confirmButton.isEnabled = !(self.titleTextField.text?.isEmpty ?? true) && !(self.contentsTextView.text?.isEmpty ?? true) && !(self.dateTextField.text?.isEmpty ?? true)
    }
}

extension WriteDiaryViewController: UITextViewDelegate{
    //일기 내용이 입력될 때마다 호출
    //텍스트 필드에 텍스트가 채워질 때마다 호출되는 메서드-사용자가 텍스트를 변경할 때마다 delegate에게 알려준다.
    func textViewDidChange(_ textView: UITextView) {
        vaildateInputField() //텍스트 필드의 상태가 변경될 때마다 호출되어 등록 버튼의 활성화 여부를 계속 판단한다.
    }
}

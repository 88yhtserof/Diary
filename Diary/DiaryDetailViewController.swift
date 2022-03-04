//
//  DiaryDetailViewController.swift
//  Diary
//
//  Created by limyunhwi on 2022/02/27.
//

import UIKit

//일기장의 특정 일기 삭제하기 위한 Delegate 패턴
//나중에 즐겨찾기 구현 시 이 삭제 기능은 Notification Center기능으로 대체될 예정
protocol DiaryDetailViewControllerDelegate: AnyObject {
    func didSelectDelete(indexPath: IndexPath)
    func didSelectStar(indexPath: IndexPath, isStar: Bool) //즐겨찾기 여부를 전달받을 수 있는 메서드
}

class DiaryDetailViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentsTextView: UITextView!
    @IBOutlet weak var dateLabel: UILabel!
    var starButton: UIBarButtonItem?
    
    weak var delegate: DiaryDetailViewControllerDelegate?
    
    var diary: Diary?
    var indexPath: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView() //상세 뷰 내용 초기화
    }
    
    //뷰를 프로퍼티값으로 초기화 시켜주는 메서드
    //뷰 구성하기
    private func configureView(){
        guard let diary = self.diary else {return}
        self.titleLabel.text = diary.title
        self.contentsTextView.text = diary.contents
        self.dateLabel.text = self.dateToString(date: diary.date)
        self.starButton = UIBarButtonItem(image: nil, style: .plain, target: self, action: #selector(tapStarButton)) //UIBarButtonItem 생성, 버튼 tap 시 action 실행
        self.starButton?.image = diary.isStar ? UIImage(systemName: "star.fill") : UIImage(systemName: "star") //즐겨찾기 설정 유무에 따라 이미지 설정
        self.starButton?.tintColor = .orange
        self.navigationItem.rightBarButtonItem = self.starButton //NavigationBar에 즐겨찾기 버튼 추가
    }
    
    //Date타입을 String타입으로 전환하는 메서드
    private func dateToString(date: Date)-> String{
        let formetter = DateFormatter()
        formetter.dateFormat = "yy년 MM월 dd일 EEEEE"
        formetter.locale = Locale(identifier: "ko_KR")
        return formetter.string(from: date)
    }
    
    //수정 완료 이벤트 발생 시 호출될 셀렉트 함수
    @objc func editDiaryNotification(_ notification: Notification){
        guard let diary = notification.object as? Diary else {return}//Notification.object 프로퍼티를 통해서 포스트될 때 보낸 객체를 가져올 수 있다.
        guard let row = notification.userInfo?["indexPath.row"] as? Int else {return} //userInfo 프로퍼티를 통해 포스트될 때 전달된 딕셔너리를 가져올 수 잇다.
        
        self.diary = diary //수정된 객체로 diary를 업데이트하고
        self.configureView() //뷰를 다시 초기화한다.
    }
    
    @IBAction func tapEditButton(_ sender: UIButton) {
        //수정 버튼 클릭 시 작성 화면으로 이동
        guard let writeDiaryViewController = self.storyboard?.instantiateViewController(withIdentifier: "WriteDiaryViewController") as? WriteDiaryViewController else {return}
        guard let indexPath = self.indexPath else {return}
        guard let diary = self.diary else {return}
        writeDiaryViewController.diaryEditorMode = .edit(indexPath, diary) //작성 화면으로 넘어갔을 때 새 일기 작성이 아닌 수정이라는 것을 알 수 있다.
        
        NotificationCenter.default.addObserver(self, //어떤 인스턴스에서 옵져빙할 것인지 알려주는 파라이터
                                               selector: #selector(editDiaryNotification(_:)),//관찰하고 있다가 이벤트를 감지하면 해당 함수 호출
                                               name: NSNotification.Name("editDiary"),//해당 이름의 Notification 이벤트를 관찰하도록 설정
                                               object: nil)
        //옵져버를 추가하게 되면 특정 이름의 Notification 이벤트가 발생하였는지 계속 관찰을 하고 특정한 이름의 이벤트가 발생하면 특정 행동을 수행하게 된다.
        //이렇게 수정 버튼을 클릭 했을 때 "editDiary" Notification를 관찰하는 옵져버가 추가가 되고요, 작성화면에서 수정된 Diary 객체가 NotificationCenter를 통해서 포스트될 때 editDiaryNotification 메서드가 호출되게 된다.
        
        self.navigationController?.pushViewController(writeDiaryViewController, animated: true)
    }
    
    @objc func tapStarButton(){
        guard let isStar = self.diary?.isStar else {return}
        guard let indexPath = indexPath else {return}
        
        //버튼 클릭 시 isStar의 Bool값의 반대로 이미지 설정
        if isStar { //true, 즉 즐겨찾기되어있다면 즐겨찾기 해제해준다.
            self.starButton?.image = UIImage(systemName: "star")
        }else{//false라면 즐겨찾기 설정해준다.
            self.starButton?.image = UIImage(systemName: "star.fill")
        }
        self.diary?.isStar = !isStar //현재 설정된 값의 반대로 설정
        self.delegate?.didSelectStar(indexPath: indexPath, isStar: self.diary?.isStar ?? false) //즐겨찾기 상태 전달하기
    }
    
    @IBAction func tapDeleteButton(_ sender: UIButton) {
        guard let indexPath = self.indexPath else {return}
        self.delegate?.didSelectDelete(indexPath: indexPath)
        
        self.navigationController?.popViewController(animated: true)
    }
    
    /*
     deinit이란
     deinitialization 소멸자
     소멸자는 클래스의 인스턴스가 메모리에서 해제될 떄 호출되는 함수이다.
     swift의 소멸자는 구조체가 아닌 클래스에서만 사용 가능하다.
     */
    deinit {
        NotificationCenter.default.removeObserver(self)//인스턴스가 소멸될 때 해당 인스터스에 추가된 옵져버가 모두 지워지게 한다.
    }
}

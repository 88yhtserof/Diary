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
}

class DiaryDetailViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentsTextView: UITextView!
    @IBOutlet weak var dateLabel: UILabel!
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
    }
    
    //Date타입을 String타입으로 전환하는 메서드
    private func dateToString(date: Date)-> String{
        let formetter = DateFormatter()
        formetter.dateFormat = "yy년 MM월 dd일 EEEEE"
        formetter.locale = Locale(identifier: "ko_KR")
        return formetter.string(from: date)
    }
    
    @IBAction func tapEditButton(_ sender: UIButton) {
        //수정 버튼 클릭 시 작성 화면으로 이동
        guard let writeDiaryViewController = self.storyboard?.instantiateViewController(withIdentifier: "WriteDiaryViewController") as? WriteDiaryViewController else {return}
        guard let indexPath = self.indexPath else {return}
        guard let diary = self.diary else {return}
        writeDiaryViewController.diaryEditorMode = .edit(indexPath, diary) //작성 화면으로 넘어갔을 때 새 일기 작성이 아닌 수정이라는 것을 알 수 있다.
        
        self.navigationController?.pushViewController(writeDiaryViewController, animated: true)
    }
    
    @IBAction func tapDeleteButton(_ sender: UIButton) {
        guard let indexPath = self.indexPath else {return}
        self.delegate?.didSelectDelete(indexPath: indexPath)
        
        self.navigationController?.popViewController(animated: true)
    }
}

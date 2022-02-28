//
//  ViewController.swift
//  Diary
//
//  Created by limyunhwi on 2022/02/27.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var diaryList = [Diary]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureCollectionView()
    }
    
    //collectionView의 속성을 설정하는 메서드
    private func configureCollectionView(){
        self.collectionView.collectionViewLayout = UICollectionViewFlowLayout()//코드로 CollectionView을 배치할거기 때문에 이렇게 작성
        self.collectionView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10) //컬렉션 뷰에 표시되는 콘텐츠의 좌우 상하의 간격이 10만큼 생긴다.
        
        //컬렉션 뷰의 컨텐츠와 레이아웃을 설정하기 위해 다음과같이 프로토콜을 채택한다.
        self.collectionView.delegate = self //레이아웃을 위해,UICollectionViewDelegateFlowLayout를 채택했음
        self.collectionView.dataSource = self//컨텐츠 관리를 위해
    }
    
    //화면 전환 바로 직전에 호출된다.
    //일기 작성 화면 이동은 세그웨이를 통해 이동하기 때문에 prepare 메서드를 사용한다.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let writeDiaryViewController = segue.destination as? WriteDiaryViewController {
            //WriteDiaryViewDelegate의 메서드 또는 프로퍼티를 사용하기 위해 WriteDiaryViewDelegate로 형변환
            writeDiaryViewController.delegate = self
        }
    }
    
    //Date타입을 전달받으면 String을 반환할 메서드
    private func dateToString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yy년 MM월 dd일 EEEEE"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
}

//WriteDiaryViewDelegate에서 데이터를 전달받아 데이터 설정하기
extension ViewController: WriteDiaryViewDelegate {
    func didSelectReigster(diary: Diary) {
        self.diaryList.append(diary) //일기를 등록할 때마다 다이어리 리스트에 추가된다.
        self.collectionView.reloadData() //일기가 추가될 때마다 컬렉션 뷰의 데이터를 재로드한다.
    }
}

//collectionView로 보여지는 컨텐츠를 관리하는 객체이다.
extension ViewController: UICollectionViewDataSource {
    //지정된 섹션에 표시할 셀의 개수를 묻는 메서드
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.diaryList.count
    }
    
    //컬렉션 뷰의 지정된 위치에 표시할 셀을 요청하는 메서드 - 테이블뷰의 cellForRow와 유사
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DiaryCell", for: indexPath) as? DiaryCollectionViewCell else {return UICollectionViewCell()}
        //스토리보드에서 구성한 커스텀 셀을 가져오기위해 "DiaryCell"id를 사용한다.
        //다운캐스팅에 실패하면 빈 UICollectionView가 반환되게 한다.
        //테이블뷰와 마찬가지로 dequeueReusableCell을 이용하게 되면 withReuseIndentifier를 통해 전달받은 재사용식별자를 통해 제사용가능한 CollectionCell을 찾고 이를 반환해줍니다.
        
        let diary = self.diaryList[indexPath.row] //해당 인덱스의 일기를 가져온다.
        cell.titleLabel.text = diary.title //제목 설정
        cell.dateLabel.text = self.dateToString(date: diary.date) //날짜 설정
        return cell
        
    }
}

//컬렉션 뷰의 레이아웃 구성을 위해 UICollectionViewDelegateFlowLayout 채택하기
extension ViewController: UICollectionViewDelegateFlowLayout{
    //셀의 사이즈를 설정할 메서드
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //셀이 행에 두 개씩 있도록 하기 위해 셀의 너비를 화면의 절반, 여기에 아까 설정한 좌우 contentInset만큼 빼준다.
        return CGSize(width: (UIScreen.main.bounds.width / 2) - 20, height: 200)
    }
}

//
//  ViewController.swift
//  Diary
//
//  Created by limyunhwi on 2022/02/27.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var diaryList = [Diary]() {
        //프로퍼티 옵져버
        didSet{//값 변경 직후
            self.saveDiaryList()//값이 변경될 때마다 saveDiaryList메서드가 호출된다.
            //즉 변경될 때마다 추가 또는 삭제, 변경 등될 때마다 UserDefaults에 이러한 변화가 저장된다.
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureCollectionView() //컬렉션 뷰 구성하기
        self.loadDiaryList() //UserDefaults에 저장된 데이터 불러오기
        //수정 이벤트를 받기 위한 NotificationCenter의 옵져버 생성
        NotificationCenter.default.addObserver(self, //옵져벼를 추가할 인스턴스
                                               selector: #selector(editDiaryNotification(_:)), //옵져버가 이벤트를 감지했을 때 호출될 메서드
                                               name: NSNotification.Name("editDiary"), //감지할 이벤트 이름
                                               object: nil)
    }
    
    //collectionView의 속성을 설정하는 메서드
    private func configureCollectionView(){
        self.collectionView.collectionViewLayout = UICollectionViewFlowLayout()//코드로 CollectionView을 배치할거기 때문에 이렇게 작성
        self.collectionView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10) //컬렉션 뷰에 표시되는 콘텐츠의 좌우 상하의 간격이 10만큼 생긴다.
        
        //컬렉션 뷰의 컨텐츠와 레이아웃을 설정하기 위해 다음과같이 프로토콜을 채택한다.
        self.collectionView.delegate = self //레이아웃을 위해,UICollectionViewDelegateFlowLayout를 채택했음
        self.collectionView.dataSource = self//컨텐츠 관리를 위해
    }
    
    @objc func editDiaryNotification(_ notification:Notification){
        guard let diary = notification.object as? Diary else {return}
        guard let row = notification.userInfo?["indexPath.row"] as? Int else {return}
        self.diaryList[row] = diary
        //날짜가 수정되었을 수도 있으니 다시 내림차순 (최신 일기가 상단에) 정렬
        self.diaryList = self.diaryList.sorted{
            $0.date.compare($1.date) == .orderedDescending //내림차순정렬
        }
        
        self.collectionView.reloadData() //수정된 리스트에 맞게 컬렉션 뷰도 수정한다.
    }
    
    //화면 전환 바로 직전에 호출된다.
    //일기 작성 화면 이동은 세그웨이를 통해 이동하기 때문에 prepare 메서드를 사용한다.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let writeDiaryViewController = segue.destination as? WriteDiaryViewController {
            //WriteDiaryViewDelegate의 메서드 또는 프로퍼티를 사용하기 위해 WriteDiaryViewDelegate로 형변환
            writeDiaryViewController.delegate = self
        }
    }
    
    private func saveDiaryList() {
        //DiaryList를 딕셔너리 형태로 맵핑한다.
        let data = self.diaryList.map{
            [//key:value
                "title": $0.title,
                "contents": $0.contents,
                "date": $0.date,
                "isStar": $0.isStar
            ]
        }
        
        let userDefaults = UserDefaults.standard //userDefaults에 접근할 수 있도록 standard 프로퍼티를 사용하여 userDefaults의 객체를 상수화한다.
        userDefaults.set(data, forKey: "DiaryList")
    }
    
    //UserDefaults에 저장된 값 불러오기
    private func loadDiaryList() {
        let userDefaults = UserDefaults.standard //UserDefaults에 접근하기
        guard let data = userDefaults.object(forKey: "DiaryList") as? [[String:Any]] else {return} //object는 Any타입으로 반환되기 때문에 딕셔너리 배열형태로 형변환 한다.
        
        self.diaryList = data.compactMap{//nil을 제외한 원소를 맵핑한다.
            guard let title = $0["title"] as? String else {return nil} //배열의 원소인 딕셔너리에 title 키를 사용해 value 가져오기. value가 Any 타입이므로 String으로 타입 변환
            guard let contents = $0["contents"] as? String else {return nil}
            guard let date = $0["date"] as? Date else {return nil}
            guard let isStar = $0["isStar"] as? Bool else {return nil}
            
            return Diary(title: title, contents: contents, date: date, isStar: isStar)
        }
        
        //목록을 최신 순으로 정렬하기
        self.diaryList = self.diaryList.sorted{
            $0.date.compare($1.date) == .orderedDescending //내림차순으로 정렬되게 하라. 즉, 최신 글이 가장 앞에 위치하도록 배치
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

extension ViewController: UICollectionViewDelegate {
    //특정 아이템, 즉 특정 cell이 선택되었을 때 호출되는 메서드
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //특정 셀이 선택되었을 때 해당하는 셀의 상세화면이 Push되도록 한다.
        //DiaryDetailViewController를 인스턴스화 하여 프로퍼티에 접근할 수 있게 해 화면 간 데이터를 전달한다.
        guard let diaryDetailViewController = self.storyboard?.instantiateViewController(withIdentifier: "DiaryDetailViewController") as? DiaryDetailViewController else {return}
        let diary = self.diaryList[indexPath.row]
        diaryDetailViewController.diary = diary
        diaryDetailViewController.indexPath = indexPath
        //DiaryDetailViewController로 화면 전환하기 직전에 해당 뷰컨트롤러의 프로퍼티에 접근하여 delegate 임명하기
        diaryDetailViewController.delegate = self
        
        self.navigationController?.pushViewController(diaryDetailViewController, animated: true)
    }
}

//WriteDiaryViewDelegate에서 데이터를 전달받아 데이터 설정하기
extension ViewController: WriteDiaryViewDelegate {
    func didSelectReigster(diary: Diary) {
        self.diaryList.append(diary) //일기를 등록할 때마다 다이어리 리스트에 추가된다.
        //목록을 최신 순으로 정렬하기
        self.diaryList = self.diaryList.sorted{
            $0.date.compare($1.date) == .orderedDescending //내림차순으로 정렬되게 하라. 즉, 최신 글이 가장 앞에 위치하도록 배치
        }
        self.collectionView.reloadData() //일기가 추가될 때마다 컬렉션 뷰의 데이터를 재로드한다.
    }
}

//DiaryDetailViewControllerDelegate를 통해 데이터 전달받기
extension ViewController: DiaryDetailViewControllerDelegate {
    func didSelectDelete(indexPath: IndexPath) {
        self.diaryList.remove(at: indexPath.row) //리스트에서도 지우고
        self.collectionView.deleteItems(at: [indexPath])//collectionView에서도 지우기
    }
}

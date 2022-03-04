//
//  StarViewController.swift
//  Diary
//
//  Created by limyunhwi on 2022/02/27.
//

import UIKit

class StarViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var diaryList = [Diary]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.loadStarDiaryList()
    }
    
    //즐겨찾기 일기 리스트를 CollectionView로 나타내기
    private func configureCollectionView(){
        self.collectionView.collectionViewLayout = UICollectionViewFlowLayout()
        self.collectionView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }
    
    private func dateToString(date: Date) -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = "yy년 MM월 dd일 EEEEE"
        formatter.locale = Locale(identifier: "ko_KR")
        
        return formatter.string(from: date)
    }
    
    //UserDefaults에 저장된 Diary 객체를 받아오는데 isStar가 true인 경우만 받아온다.
    private func loadStarDiaryList() {
        let userDefaults = UserDefaults.standard
        guard let data = userDefaults.object(forKey: "DiaryList") as? [[String: Any]] else {return} //object에서 Any 타입을 반환하기 때문에 딕셔너리 타입으로 타입 캐스팅한다. guard문으로 타입 캐스팅 실패할 경우를 대비한다.
        self.diaryList = data.compactMap{//불러온 데이터를 Diary 타입이 되도록 맵핑해준다.
            guard let title = $0["title"] as? String else {return nil}
            guard let contents = $0["contents"] as? String else {return nil}
            guard let date = $0["date"] as? Date else {return nil}
            guard let isStar = $0["isStar"] as? Bool else {return nil}
            
            return Diary(title: title, contents: contents, date: date, isStar: isStar)
        }.filter({//주어진 조건을 만족하는 원소 배열을 반환한다.
            $0.isStar == true //즐겨찾기 설정되어있는 일기만
        }).sorted(by: {
            $0.date.compare($1.date) == .orderedDescending //날짜 내림차순 정렬, 즉 최신순
        })
        
        self.collectionView.reloadData()
    }
}

extension StarViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.diaryList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StarCell", for: indexPath) as? StarCollectionViewCell else {return UICollectionViewCell()} //다운캐스팅 실패 시 빈 아이템 할당
        let diary = self.diaryList[indexPath.row] //해당 인덱스의 일기 가져오기
        cell.titleLabel.text = diary.title
        cell.dateLabel.text = self.dateToString(date: diary.date)
        
        return cell
    }
}

extension StarViewController: UICollectionViewDelegateFlowLayout {
    //셀의 크기를 반환하는 메서드
    //리스트 형태로 구성하기 위해 width를 화면 크기로 설정한다. 주의: contentsInset의 좌우 값만큼 빼주어야 한다.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width - 20, height: 80)
    }
}

extension StarViewController: UICollectionViewDelegate{
    //cell 클릭 시 해당 cell의 상세 화면으로 전환, 즉 해당 cell의 일기 데이터를 넘겨준다.
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let diaryDetailViewController = self.storyboard?.instantiateViewController(withIdentifier: "DiaryDetailViewController") as? DiaryDetailViewController else {return}
        diaryDetailViewController.diary = self.diaryList[indexPath.row]
        diaryDetailViewController.indexPath = indexPath
        
        self.navigationController?.pushViewController(diaryDetailViewController, animated: true)
    }
}

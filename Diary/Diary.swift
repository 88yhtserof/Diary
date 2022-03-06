//
//  Diary.swift
//  Diary
//
//  Created by limyunhwi on 2022/02/28.
//

import Foundation

struct Diary {
    var uuidString: String //범용 단일 식별자 UniversalUniqueIdentifier
    var title: String
    var contents: String
    var date: Date
    var isStar: Bool //즐겨찾기
}

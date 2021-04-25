//
//  DataStruct.swift
//  DinInLiao
//
//  Created by LIU SHANG WEI on 2021/4/20.
//

import Foundation

struct Menu: Codable {
    let records: [Record]
}

struct Record: Codable {
    let fields: Fields
}
struct Fields: Codable {
    let id: Int
    let goodsName: String
    let description: String
}

struct Order: Encodable {
    let records: [Record]
    struct Record: Encodable {
        let fields: Fields
    }
    struct Fields: Encodable {
        let orderName: String
        let goodsName: String
        let size: String
        let sugar: String
        let temp: String
        let plus: String
    }
}
struct Size {
    let type = ["中杯","大杯"]
}
struct Sugar {
    let level = ["正常糖","少糖","半糖","微糖","無糖"]
}
struct Temp {
    let level = ["正常冰","少冰","微冰","完全去冰","熱"]
}
struct Plus {
    let type = ["","白玉","墨玉"]
}

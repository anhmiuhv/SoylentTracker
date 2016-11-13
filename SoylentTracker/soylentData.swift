//
//  soylentData.swift
//  SoylentTracker
//
//  Created by Linh Hoang on 11/12/16.
//  Copyright © 2016 Linh Hoang. All rights reserved.
//

import Foundation

struct PropertyKey {
    static let numberOfBottle = "numOfBottle"
}

class SoylentData: NSObject, NSCoding {
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("soylentData")
    var data: [String: Int] = [:]
    func encode(with aCoder: NSCoder) {
        aCoder.encode(data, forKey: PropertyKey.numberOfBottle)
    }

    required convenience init?(coder aDecoder: NSCoder) {
        let data = aDecoder.decodeObject(forKey: PropertyKey.numberOfBottle) as! [String: Int]
        self.init(data: data)
    }

    init(data: [String: Int]) {
        self.data = data
    }
}

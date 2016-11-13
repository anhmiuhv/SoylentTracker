//
//  Utils.swift
//  SoylentTracker
//
//  Created by Linh Hoang on 11/12/16.
//  Copyright © 2016 Linh Hoang. All rights reserved.
//

import Foundation

struct Util {
    static func string(from date: Date) -> String{
        let day = Date()
        let calendar = Calendar.current
        let date = calendar.dateComponents([.day, .month, .year], from: day).description
        return date
    }
}

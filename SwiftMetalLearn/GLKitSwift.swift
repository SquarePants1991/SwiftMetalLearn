//
//  GLKitSwift.swift
//  SwiftMetalLearn
//
//  Created by wang yang on 2017/5/2.
//  Copyright © 2017年 wangyang. All rights reserved.
//

import GLKit

extension GLKMatrix4 {
    var raw: [Float] {
        return (0..<16).map { i in self[i] }
    }
}

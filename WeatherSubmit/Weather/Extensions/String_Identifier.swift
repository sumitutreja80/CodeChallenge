//
//  String_Identifier.swift
//  weather
//
//  Created by Utreja, Sumit on 19/12/20.
//  Copyright © 2020 Utreja, Sumit. All rights reserved.
//

import Foundation

extension Character {
    var isAscii: Bool {
        return unicodeScalars.allSatisfy { $0.isASCII }
    }
    var ascii: UInt32? {
        return isAscii ? unicodeScalars.first?.value : nil
    }
}

extension StringProtocol {
    var asciiValues: [UInt32] {
        return compactMap { $0.ascii }
    }
}

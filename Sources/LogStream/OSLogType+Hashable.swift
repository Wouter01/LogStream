//
//  OSLogType+Hashable.swift
//  
//
//  Created by Wouter Hennen on 22/05/2023.
//

import OSLog

extension OSLogType: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.rawValue)
    }
}

//
//  Result.swift
//  wispr-swift
//
//  Created by bagpack on 2018/02/02.
//

import Foundation

public enum Result {
    case success(payload: Payload)
    case failure(error: Error)
}

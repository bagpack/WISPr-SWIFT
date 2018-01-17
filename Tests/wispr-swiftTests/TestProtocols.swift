//
//  TestProtocols.swift
//  wispr-swiftTests
//
//  Created by bagpack on 2018/02/14.
//

import Foundation


protocol TestBundleUsable: class {
     func readBundle(forResource: String, withExtension: String) -> String
}

extension TestBundleUsable {
    func readBundle(forResource: String, withExtension: String) -> String {
        let testBundle = Bundle(for: type(of: self))
        let url = testBundle.url(forResource: forResource, withExtension: withExtension)!
        return try! String(contentsOf: url)
    }
}

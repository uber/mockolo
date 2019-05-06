


let docComment1 = """
//
//  Copyright © Some Co, Inc. All rights reserved.
//

import Foundation

/**
 * This is a long doc comment
 * that contains multi-lines
 * which describes a protocol
 * and types that conform to this protocol
 * and also contains the mock annotation
 * in this comment.
 * \(String.mockAnnotation)
 */
public protocol DocProtocol {
    func foo(arg: Bool, tag: Int)
    func bar(name: String, more: Float)
}
"""

let docComment2 = """
//
//  Copyright © Some Co, Inc. All rights reserved.
//

import Foundation

/**
* This is a long doc comment
* that contains multi-lines
* which describes a protocol
* and types that conform to this protocol
* and also contains the mock annotation
* in this comment.
*/
/// \(String.mockAnnotation)
public protocol DocProtocol {
func foo(arg: Bool, tag: Int)
func bar(name: String, more: Float)
}
"""

let docCommentMock = """
import Foundation

public class DocProtocolMock: DocProtocol {
    
    public init() {
        
    }
    
    var fooCallCount = 0
    public var fooHandler: ((Bool, Int) -> ())?
    public func foo(arg: Bool, tag: Int)  {
        fooCallCount += 1
        if let fooHandler = fooHandler {
            return fooHandler(arg, tag)
        }
        
    }
    var barCallCount = 0
    public var barHandler: ((String, Float) -> ())?
    public func bar(name: String, more: Float)  {
        barCallCount += 1
        if let barHandler = barHandler {
            return barHandler(name, more)
        }
        
    }
}
"""

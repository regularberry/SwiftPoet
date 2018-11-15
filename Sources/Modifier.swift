//
//  Modifier.swift
//  SwiftPoet
//
//  Created by Kyle Dorman on 11/10/15.
//
//

import Foundation

open class Modifier: NSObject {

    public let rawString: String

    public init(rawString: String) {
        self.rawString = rawString
    }

    public static let Open = Modifier(rawString: "open")
    public static let Public = Modifier(rawString: "public")
    public static let Internal = Modifier(rawString: "internal")
    public static let Fileprivate = Modifier(rawString: "fileprivate")
    public static let Private = Modifier(rawString: "private")

    public static let Static = Modifier(rawString: "static")
    public static let Final = Modifier(rawString: "final")
    public static let Klass = Modifier(rawString: "class")

    public static let Mutating = Modifier(rawString: "mutating")
    public static let Throws = Modifier(rawString: "throws")
    public static let Convenience = Modifier(rawString: "convenience")
    public static let Override = Modifier(rawString: "override")
    public static let Required = Modifier(rawString: "required")

    open override var hashValue: Int {
        return rawString.hashValue
    }

    //    case DidSet
    //    case Lazy
    //    case WillSet
    //    case Weak
    //    case Optional

    public static func equivalentAccessLevel(parentModifiers pm: Set<Modifier>, childModifiers cm: Set<Modifier>)
        -> Bool
    {
        let parentAccessLevel = Modifier.accessLevel(pm)
        let childAccessLevel = Modifier.accessLevel(cm)

        // TODO: fix this algorithm; checking childAccessLevel should be <= not !=
        // therefore, we should split out access modifiers to its own type, and
        // implement comparison operations
        if parentAccessLevel == .Private {
            return true
        }
        else if parentAccessLevel == .Fileprivate && childAccessLevel != .Private {
            return true
        }
        else if parentAccessLevel == .Internal && childAccessLevel != .Fileprivate {
            return true
        }
        else if parentAccessLevel == .Public && childAccessLevel != .Internal {
            return true
        }
        else if parentAccessLevel == .Open && childAccessLevel == .Open {
            return true
        }
        return false
    }

    public static func accessLevel(_ modifiers: Set<Modifier>)
        -> Modifier
    {
        if modifiers.contains(.Private) {
            return .Private
        }
        else if modifiers.contains(.Fileprivate) {
            return .Fileprivate
        }
        else if modifiers.contains(.Public) {
            return .Public
        }
        else if modifiers.contains(.Open) {
            return .Open
        }
        else {
            return .Internal
        }
    }
}

public func ==(lhs: Modifier, rhs: Modifier) -> Bool {
    return lhs.rawString == rhs.rawString
}

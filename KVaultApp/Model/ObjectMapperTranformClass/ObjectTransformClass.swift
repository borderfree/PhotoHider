//
//  ObjectTransformClass.swift
//  Centreel
//
//  Created by Kishan on 22/10/18.
//  Copyright © 2018 Alchemy. All rights reserved.
//

import UIKit

class ObjectTransformClass: NSObject {

}

// for handle null value // need to single class refer TransformOf.swift
open class ObservableBoolTransform: TransformType {
    public func transformToJSON(_ value: BehaviorRelay<Bool>?) -> String? {
        return CheckNullString(value: value?.value ?? "0")
    }
    
    public func transformFromJSON(_ value: Any?) -> BehaviorRelay<Bool>? {
        return BehaviorRelay<Bool>(value: CheckNullString(value: value ?? "0").boolValue())
    }
   
    
    public typealias Object = BehaviorRelay<Bool>
    public typealias JSON = String
    
    public init() {}
    
}

// for handle null value // need to single class refer TransformOf.swift
open class ObservableStringTransform: TransformType {
    public func transformFromJSON(_ value: Any?) -> BehaviorRelay<String>? {
        return BehaviorRelay<String>(value: CheckNullString(value: value ?? ""))
    }
    
    public func transformToJSON(_ value: BehaviorRelay<String>?) -> String? {
        return CheckNullString(value: value?.value ?? "")
    }
    
    public typealias Object = BehaviorRelay<String>
    public typealias JSON = String
    
    public init() {}
    
}

// for handle null value // need to single class refer TransformOf.swift
open class StringTransform: TransformType {
    public typealias Object = String
    public typealias JSON = String
    
    public init() {}
    public func transformFromJSON(_ value: Any?) -> String? {
        return CheckNullString(value: value ?? "")
    }
    
    public func transformToJSON(_ value: String?) -> String? {
        return CheckNullString(value: value ?? "")
    }
}

// for handle null value // need to single class refer TransformOf.swift
open class DoubleTransform: TransformType {
    public func transformFromJSON(_ value: Any?) -> Double? {
         return CheckNullString(value: value ?? "0.0").doubleValue()
    }
    
    public func transformToJSON(_ value: Double?) -> String? {
        return CheckNullString(value: value ?? "0.0")
    }
    
    public typealias Object = Double
    public typealias JSON = String
    
    public init() {}
}


// for handle null value // need to single class refer TransformOf.swift
open class FloatTransform: TransformType {
    public func transformFromJSON(_ value: Any?) -> Float? {
        return CheckNullString(value: value ?? 0.0).floatValues()
    }
    
    public func transformToJSON(_ value: Float?) -> String? {
        return CheckNullString(value: value ?? 0.0)
    }
  
    public typealias Object = Float
    public typealias JSON = String
    
    public init() {}
}

// for handle null value // need to single class refer TransformOf.swift
open class IntergerTransform: TransformType {
    public func transformToJSON(_ value: NSInteger?) -> String? {
        return CheckNullString(value: value ?? 0)

    }
    
    public func transformFromJSON(_ value: Any?) -> NSInteger? {
        return CheckNullString(value: value ?? 0).integerValue()
    }
    
   
    
    public typealias Object = NSInteger
    public typealias JSON = String
    
    public init() {}
}

// for handle null value
open class BoolTransform: TransformType {
    
    public typealias Object = Bool
    public typealias JSON = String
    
    public init() {}
    public func transformFromJSON(_ value: Any?) -> Bool? {
        return CheckNullString(value: value ?? "0").boolValue()
    }
    
    public func transformToJSON(_ value: Bool?) -> String? {
        return CheckNullString(value: value ?? "0")
    }
}



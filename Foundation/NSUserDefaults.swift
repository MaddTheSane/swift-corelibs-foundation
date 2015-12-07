// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2015 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See http://swift.org/LICENSE.txt for license information
// See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//

import CoreFoundation

public let NSGlobalDomain: String = "NSGlobalDomain"
public let NSArgumentDomain: String = "NSArgumentDomain"
public let NSRegistrationDomain: String = "NSRegistrationDomain"

private var registeredDefaults = [String: AnyObject]()
private var sharedDefaults = NSUserDefaults()

public class NSUserDefaults : NSObject {
    private let suite: String?
    
    public class func standardUserDefaults() -> NSUserDefaults {
        return sharedDefaults
    }
    public class func resetStandardUserDefaults() {
        sharedDefaults.synchronize()
        sharedDefaults = NSUserDefaults()
    }
    
    public convenience override init() {
        self.init(suiteName: nil)!
    }
    public init?(suiteName suitename: String?) {
        suite = suitename
    } //nil suite means use the default search list that +standardUserDefaults uses
    
    public func objectForKey(defaultName: String) -> AnyObject? {
        func getFromRegistered() -> AnyObject? {
            return registeredDefaults[defaultName]
        }
        
        guard let anObj = CFPreferencesCopyAppValue(suite?._cfObject ?? defaultName._cfObject, kCFPreferencesCurrentApplication) else {
            return getFromRegistered()
        }
        
        //Force the returned value to an NSObject
        switch CFGetTypeID(anObj) {
        case CFStringGetTypeID():
            return (anObj as! CFStringRef)._swiftObject
            
        case CFNumberGetTypeID():
            return unsafeBitCast(anObj, NSNumber.self)
            
        case CFURLGetTypeID():
            return (anObj as! CFURLRef)._nsObject
            
        case CFArrayGetTypeID():
            return (anObj as! CFArrayRef)._nsObject
            
        case CFDictionaryGetTypeID():
            return (anObj as! CFDictionaryRef)._nsObject

        case CFDataGetTypeID():
            return (anObj as! CFDataRef)._nsObject
            
        default:
            return getFromRegistered()
        }
    }
    public func setObject(value: AnyObject?, forKey defaultName: String) {
        guard let value = value else {
            CFPreferencesSetAppValue(suite?._cfObject ?? defaultName._cfObject, nil, kCFPreferencesCurrentApplication)
            return
        }
        
        var cfType: CFTypeRef? = nil
		
		//FIXME: is this needed? Am I overcomplicating things?
        //Foundation types
        if let bType = value as? NSNumber {
            cfType = bType._cfObject
        } else if let bType = value as? NSString {
            cfType = bType._cfObject
        } else if let bType = value as? NSArray {
            cfType = bType._cfObject
        } else if let bType = value as? NSDictionary {
            cfType = bType._cfObject
        } else if let bType = value as? NSURL {
            cfType = bType._cfObject
        } else if let bType = value as? NSData {
            cfType = bType._cfObject
            //Swift types
        } else if let bType = value as? String {
            cfType = bType._cfObject
        } else if let bType = value as? Int {
            cfType = NSNumber(integer: bType)._cfObject
        } else if let bType = value as? UInt {
            cfType = NSNumber(unsignedInteger: bType)._cfObject
        } else if let bType = value as? Int32 {
            cfType = NSNumber(int: bType)._cfObject
        } else if let bType = value as? UInt32 {
            cfType = NSNumber(unsignedInt: bType)._cfObject
        } else if let bType = value as? Int64 {
            cfType = NSNumber(longLong: bType)._cfObject
        } else if let bType = value as? UInt64 {
            cfType = NSNumber(unsignedLongLong: bType)._cfObject
        } else if let bType = value as? Bool {
            cfType = NSNumber(bool: bType)._cfObject
        } else if let bType = value as? [NSObject: AnyObject] {
            let nsDict = NSMutableDictionary()
            for (key, value) in bType {
                nsDict[key] = value
            }
            cfType = nsDict._cfObject
        } else if let bType = value as? [AnyObject] {
            cfType = NSArray(array: bType)._cfObject
        }
        
        CFPreferencesSetAppValue(suite?._cfObject ?? defaultName._cfObject, cfType, kCFPreferencesCurrentApplication)
    }
    public func removeObjectForKey(defaultName: String) {
        CFPreferencesSetAppValue(suite?._cfObject ?? defaultName._cfObject, nil, kCFPreferencesCurrentApplication)
    }
    
    public func stringForKey(defaultName: String) -> String? {
        guard let aVal = objectForKey(defaultName), bVal = aVal as? String else {
            return nil
        }
        return bVal
    }
    public func arrayForKey(defaultName: String) -> [AnyObject]? {
        guard let aVal = objectForKey(defaultName), bVal = aVal as? [AnyObject] else {
            return nil
        }
        return bVal
    }
    public func dictionaryForKey(defaultName: String) -> [String : AnyObject]? {
        guard let aVal = objectForKey(defaultName), bVal = aVal as? [String: AnyObject] else {
            return nil
        }
        return bVal
    }
    public func dataForKey(defaultName: String) -> NSData? {
        guard let aVal = objectForKey(defaultName), bVal = aVal as? NSData else {
            return nil
        }
        return bVal
    }
    public func stringArrayForKey(defaultName: String) -> [String]? {
        guard let aVal = objectForKey(defaultName), bVal = aVal as? [String] else {
            return nil
        }
        return bVal
    }
    public func integerForKey(defaultName: String) -> Int {
        guard let aVal = objectForKey(defaultName), bVal = aVal as? NSNumber else {
            return 0
        }
        return bVal.integerValue
    }
    public func floatForKey(defaultName: String) -> Float {
        guard let aVal = objectForKey(defaultName), bVal = aVal as? NSNumber else {
            return 0
        }
        return bVal.floatValue
    }
    public func doubleForKey(defaultName: String) -> Double {
        guard let aVal = objectForKey(defaultName), bVal = aVal as? NSNumber else {
            return 0
        }
        return bVal.doubleValue
    }
    public func boolForKey(defaultName: String) -> Bool {
        guard let aVal = objectForKey(defaultName), bVal = aVal as? NSNumber else {
            return false
        }
        return bVal.boolValue
    }
    public func URLForKey(defaultName: String) -> NSURL? {
        guard let aVal = objectForKey(defaultName), bVal = aVal as? NSURL else {
            return nil
        }
        return bVal
    }
    
    public func setInteger(value: Int, forKey defaultName: String) {
        setObject(NSNumber(integer: value), forKey: defaultName)
    }
    public func setFloat(value: Float, forKey defaultName: String) {
        setObject(NSNumber(float: value), forKey: defaultName)
    }
    public func setDouble(value: Double, forKey defaultName: String) {
        setObject(NSNumber(double: value), forKey: defaultName)
    }
    public func setBool(value: Bool, forKey defaultName: String) {
        setObject(NSNumber(bool: value), forKey: defaultName)
    }
    public func setURL(url: NSURL?, forKey defaultName: String) {
        setObject(url, forKey: defaultName)
    }
    
    public func registerDefaults(registrationDictionary: [String : AnyObject]) {
        for (key, value) in registrationDictionary {
            registeredDefaults[key] = value
        }
    }
    
    public func addSuiteNamed(suiteName: String) {
        CFPreferencesAddSuitePreferencesToApp(kCFPreferencesCurrentApplication, suiteName._cfObject)
    }
    public func removeSuiteNamed(suiteName: String) {
        CFPreferencesRemoveSuitePreferencesFromApp(kCFPreferencesCurrentApplication, suiteName._cfObject)
    }
    
    public func dictionaryRepresentation() -> [String : AnyObject] {
        guard let aPref = CFPreferencesCopyMultiple(nil, kCFPreferencesCurrentApplication, kCFPreferencesCurrentUser, kCFPreferencesCurrentHost),
            bPref = (aPref._nsObject) as? [String: AnyObject] else {
                return registeredDefaults
        }
        var allDefaults = registeredDefaults
        
        for (key, value) in bPref {
            allDefaults[key] = value
        }
        
        return allDefaults
    }
    
    public var volatileDomainNames: [String] { NSUnimplemented() }
    public func volatileDomainForName(domainName: String) -> [String : AnyObject] { NSUnimplemented() }
    public func setVolatileDomain(domain: [String : AnyObject], forName domainName: String) { NSUnimplemented() }
    public func removeVolatileDomainForName(domainName: String) { NSUnimplemented() }
    
    public func persistentDomainForName(domainName: String) -> [String : AnyObject]? { NSUnimplemented() }
    public func setPersistentDomain(domain: [String : AnyObject], forName domainName: String) { NSUnimplemented() }
    public func removePersistentDomainForName(domainName: String) { NSUnimplemented() }
    
    public func synchronize() -> Bool { return CFPreferencesAppSynchronize(kCFPreferencesCurrentApplication) }
    
    public func objectIsForcedForKey(key: String) -> Bool { NSUnimplemented() }
    public func objectIsForcedForKey(key: String, inDomain domain: String) -> Bool { NSUnimplemented() }
}

public let NSUserDefaultsDidChangeNotification: String = "NSUserDefaultsDidChangeNotification"


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

public class NSUserDefaults : NSObject {
    private let appID: String
    private let suite: String?
    
    public class func standardUserDefaults() -> NSUserDefaults { NSUnimplemented() }
    public class func resetStandardUserDefaults() { NSUnimplemented() }
    
    public convenience override init() {
        self.init(suiteName: nil)!
    }
    public init?(suiteName suitename: String?) {
        suite = suitename
        appID = NSBundle.mainBundle().bundleIdentifier ?? "whut"
    } //nil suite means use the default search list that +standardUserDefaults uses
    
    public func objectForKey(defaultName: String) -> AnyObject? {
        return CFPreferencesCopyAppValue(defaultName._cfObject, appID._cfObject)
    }
    public func setObject(value: AnyObject?, forKey defaultName: String) {
        CFPreferencesSetAppValue(defaultName._cfObject, value, appID._cfObject)
    }
    public func removeObjectForKey(defaultName: String) {
        CFPreferencesSetAppValue(defaultName._cfObject, nil, appID._cfObject)
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
        return CFPreferencesGetAppIntegerValue(defaultName._cfObject, appID._cfObject, nil)
    }
    public func floatForKey(defaultName: String) -> Float {
        guard let aVal = objectForKey(defaultName), bVal = aVal as? NSNumber else {
            return 0
        }
        return bVal.floatValue
        
    }
    public func doubleForKey(defaultName: String) -> Double {
        guard let aVal = objectForKey(defaultName), bVal = aVal as? Double else {
            return 0
        }
        return bVal
    }
    public func boolForKey(defaultName: String) -> Bool {
        return CFPreferencesGetAppBooleanValue(defaultName._cfObject, appID._cfObject, nil)
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
    
    public func registerDefaults(registrationDictionary: [String : AnyObject]) { NSUnimplemented() }
    
    public func addSuiteNamed(suiteName: String) {
        CFPreferencesAddSuitePreferencesToApp(appID._cfObject, suiteName._cfObject)
    }
    public func removeSuiteNamed(suiteName: String) {
        CFPreferencesRemoveSuitePreferencesFromApp(appID._cfObject, suiteName._cfObject)
    }
    
    public func dictionaryRepresentation() -> [String : AnyObject] {
        guard let aPref = CFPreferencesCopyMultiple(nil, appID._cfObject, kCFPreferencesCurrentUser, kCFPreferencesCurrentHost),
            bPref = (aPref._nsObject) as? [String: AnyObject] else {
                return [:]
        }
        return bPref
    }
    
    public var volatileDomainNames: [String] { NSUnimplemented() }
    public func volatileDomainForName(domainName: String) -> [String : AnyObject] { NSUnimplemented() }
    public func setVolatileDomain(domain: [String : AnyObject], forName domainName: String) { NSUnimplemented() }
    public func removeVolatileDomainForName(domainName: String) { NSUnimplemented() }
    
    public func persistentDomainForName(domainName: String) -> [String : AnyObject]? { NSUnimplemented() }
    public func setPersistentDomain(domain: [String : AnyObject], forName domainName: String) { NSUnimplemented() }
    public func removePersistentDomainForName(domainName: String) { NSUnimplemented() }
    
    public func synchronize() -> Bool { return CFPreferencesAppSynchronize(appID._cfObject) }
    
    public func objectIsForcedForKey(key: String) -> Bool { NSUnimplemented() }
    public func objectIsForcedForKey(key: String, inDomain domain: String) -> Bool { NSUnimplemented() }
}

public let NSUserDefaultsDidChangeNotification: String = "NSUserDefaultsDidChangeNotification"


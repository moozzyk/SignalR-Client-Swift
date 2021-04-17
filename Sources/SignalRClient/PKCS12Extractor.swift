//
//  File.swift
//  SignalRClient
//
//  Created by Pótári Gábor on 17/04/2021.
//

import Foundation

public struct NetworkIdentityAndTrust {
    public var identityRef: SecIdentity
    public var trust: SecTrust
    public var certArray: NSArray
}

class PKCS12Extractor {
    public class func extractIdentity(certData: NSData, certPassword:String) -> NetworkIdentityAndTrust {
        var identityAndTrust: NetworkIdentityAndTrust!
        var securityError: OSStatus = errSecSuccess

        var items: CFArray?
        let certOptions: Dictionary = [ kSecImportExportPassphrase as String : certPassword ];
        
        securityError = SecPKCS12Import(certData, certOptions as CFDictionary, &items)
        if securityError == errSecSuccess {
            let certItems:CFArray = items!
            let certItemsArray:Array = certItems as Array
            let dict: AnyObject? = certItemsArray.first
         
            if let certEntry: Dictionary = dict as? Dictionary<String, AnyObject> {
                let identityPointer: AnyObject? = certEntry["identity"]
                let secIdentityRef: SecIdentity = identityPointer as! SecIdentity
                let trustPointer:AnyObject? = certEntry["trust"]
                let trustRef:SecTrust = trustPointer as! SecTrust
             
               
                var certRef: SecCertificate?
                SecIdentityCopyCertificate(secIdentityRef, &certRef)
                let certArray:NSMutableArray = NSMutableArray()
                certArray.add(certRef!)
             
                identityAndTrust = NetworkIdentityAndTrust(identityRef: secIdentityRef, trust: trustRef, certArray: certArray)
            }
        }

        return identityAndTrust
    }
}

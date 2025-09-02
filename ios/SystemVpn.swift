//
//  SystemVpn.swift
//  react-native-system-vpn
//
//  Created by SystemVPN Team
//  Migrated from react-native-vpn-ipsec
//

import Foundation
import NetworkExtension
import Security
import KeychainAccess
import React



public struct KeychainWrapper {
  
  public static var instance: Keychain {
    return Keychain(service: Bundle.main.bundleIdentifier  ?? "org.keychain.rnvpn")
  }
  
  public static func setPassword(_ password: String, forVPNID VPNID: String) {
    let key = NSURL(string: VPNID)!.lastPathComponent!
    _ = try? instance.remove(key)
    instance[key] = password
  }
  
  public static func setSecret(_ secret: String, forVPNID VPNID: String) {
    let key = NSURL(string: VPNID)!.lastPathComponent!
    _ = try? instance.remove("\(key)psk")
    instance["\(key)psk"] = secret
  }
  
  public static func passwordRefForVPNID(_ VPNID: String) -> Data? {
    let key = NSURL(string: VPNID)!.lastPathComponent!
    return instance[attributes: key]?.persistentRef
  }
  
  public static func secretRefForVPNID(_ VPNID: String) -> Data? {
    let key = NSURL(string: VPNID)!.lastPathComponent!
    if let data = instance[attributes: "\(key)psk"]?.data, let value = String(data: data, encoding: .utf8) {
      if !value.isEmpty {
        return instance[attributes: "\(key)psk"]?.persistentRef
      }
    }
    return nil
  }
  
  
  public static func setCertificate(_ secret: String, forVPNID VPNID: String) {
    let key = NSURL(string: VPNID)!.lastPathComponent!
    _ = try? instance.remove("\(key)cert")
    instance["\(key)cert"] = secret
  }
  
  public static func certificateRefForVPNID(_ VPNID: String) -> Data? {
    let key = NSURL(string: VPNID)!.lastPathComponent!
    if let data = instance[attributes: "\(key)cert"]?.data, let value = String(data: data, encoding: .utf8) {
      if !value.isEmpty {
        return instance[attributes: "\(key)cert"]?.persistentRef
      }
    }
    return nil
  }
  
  
  
  
  
  
  
  public static func destoryKeyForVPNID(_ VPNID: String) {
    let key = NSURL(string: VPNID)!.lastPathComponent!
    _ = try? instance.remove(key)
    _ = try? instance.remove("\(key)psk")
    _ = try? instance.remove("\(key)cert")
  }
  
  public static func passwordStringForVPNID(_ VPNID: String) -> String? {
    let key = NSURL(string: VPNID)!.lastPathComponent!
    return instance[key]
  }
  
  public static func secretStringForVPNID(_ VPNID: String) -> String? {
    let key = NSURL(string: VPNID)!.lastPathComponent!
    return instance["\(key)psk"]
  }
  
}



@objc(SystemVpn)
class SystemVpn: RCTEventEmitter {
  
  @objc let vpnManager = NEVPNManager.shared();
  @objc let defaultErr = NSError()
  
  override static func requiresMainQueueSetup() -> Bool {
    return false
  }
  
  override func supportedEvents() -> [String]! {
    return [ "stateChanged" ]
  }
  
  @objc
  func prepare(_ resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
    
    self.vpnManager.loadFromPreferences {[weak self] (error) in
      if error != nil {
        print(error.debugDescription)
      }
      else{
        print("No error from loading VPN viewDidLoad")
      }
      
      
      if self?.vpnManager.connection.status == .invalid{
        let p = NEVPNProtocolIPSec()
        p.username = "vpn"
        p.serverAddress = "127.0.0.1"
        p.authenticationMethod = .sharedSecret
        p.useExtendedAuthentication = true
        self?.vpnManager.protocolConfiguration  = p
        self?.vpnManager.isEnabled = true
        self?.vpnManager.localizedDescription = "vpn"
        
        self?.vpnManager.saveToPreferences { error in
          if let err = error {
            print("Failed to save profile: \(err.localizedDescription)")
          } else {
            
          }
        }
        
      }
    }
    
    // Register to be notified of changes in the status. These notifications only work when app is in foreground.
    NotificationCenter.default.addObserver(forName: NSNotification.Name.NEVPNStatusDidChange, object : nil , queue: nil) {
      notification in
      let nevpnconn = notification.object as! NEVPNConnection
      self.sendEvent(withName: "stateChanged", body: [ "state" : checkNEStatus(status: nevpnconn.status) ])
    }
    
    resolve(nil)
  }
  
  
  
  @objc
  func connect(_ config: NSDictionary, address: NSString, username: NSString, password: NSString, secret: NSString, disconnectOnSleep: Bool, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
    
    loadReference(config, address: address, username: username, password: password, secret: secret, disconnectOnSleep: disconnectOnSleep, findEventsWithResolver: resolve, rejecter: reject, isPrepare: false)
  }
  
  @objc
  func saveConfig(_ config: NSDictionary, address: NSString, username: NSString, password: NSString, secret: NSString, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
    
    loadReference(config, address: address, username: username, password: password, secret: secret, disconnectOnSleep: false, findEventsWithResolver: resolve, rejecter: reject, isPrepare: true)
  }
  
  @objc
  func loadReference(_ config: NSDictionary, address: NSString, username: NSString, password: NSString, secret: NSString, disconnectOnSleep: Bool, findEventsWithResolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock, isPrepare: Bool) {
    
    if !isPrepare{
      self.sendEvent(withName: "stateChanged", body: [ "state" : 1 ])
    }
    self.vpnManager.loadFromPreferences { (error) -> Void in
      
      if error != nil {
        print("VPN Preferences error: 1")
      } else {
        if let type = config["type"] as? String{
          if "ipsec" == type{
            let p = NEVPNProtocolIPSec()
            p.username = username as String
            p.serverAddress = address as String
            if let authenticationMethod  = config["authenticationMethod"] as? NSInteger {
              p.authenticationMethod  = NEVPNIKEAuthenticationMethod.init(rawValue: authenticationMethod) ?? .none
            }
            else{
              p.authenticationMethod = NEVPNIKEAuthenticationMethod.none
            }
            
            if let cert = config["cert"] as? String,cert.count>0{
              let identityData = cert.data(using: .utf8)
              p.identityData = identityData
            }
            
            
            KeychainWrapper.setSecret(secret as String, forVPNID: "secret")
            KeychainWrapper.setPassword(password as String, forVPNID: "password")
            
            
            p.sharedSecretReference = KeychainWrapper.secretRefForVPNID("secret")
            p.passwordReference = KeychainWrapper.passwordRefForVPNID("password")
            
            
            
            p.useExtendedAuthentication = true
            p.disconnectOnSleep = disconnectOnSleep
            
            self.vpnManager.protocolConfiguration = p
          }
          else if "ikev2" == type{
            let p = NEVPNProtocolIKEv2()
            
            p.username = username as String
            p.serverAddress = address as String
            if let authenticationMethod  = config["authenticationMethod"] as? NSInteger {
              p.authenticationMethod  = NEVPNIKEAuthenticationMethod.init(rawValue: authenticationMethod) ?? .none
              
            }
            else{
              p.authenticationMethod = NEVPNIKEAuthenticationMethod.none
            }
            if let cert = config["cert"] as? String,cert.count>0{
              let identityData = cert.data(using: .utf8)
              p.identityData = identityData
            }
            
            if password.length > 0 {
              KeychainWrapper.setPassword(password as String, forVPNID: "password")
              p.passwordReference = KeychainWrapper.passwordRefForVPNID("password")
            }
            if secret.length > 0{
              KeychainWrapper.setSecret(secret as String, forVPNID: "secret")
              p.sharedSecretReference = KeychainWrapper.secretRefForVPNID("secret")
            }
            
            if let remoteIdentifier = config.value(forKey: "remoteIdentifier") as? String{
              p.remoteIdentifier = remoteIdentifier
            }
            if let localIdentifier = config.value(forKey: "localIdentifier") as? String{
              p.localIdentifier = localIdentifier
            }
            
            if let certificateType = config.value(forKey: "certificateType") as? Int{
              p.certificateType = .init(rawValue: certificateType) ?? .RSA
            }
            
            if let identityData = config.value(forKey: "identityData") as? String,identityData.count > 0{
              p.identityData = identityData.data(using: .utf8)
            }
            
            if let ikeSecurityAssociationParameters = config.value(forKey: "ikeSecurityAssociationParameters") as? NSDictionary ,
               let encryptionAlgorithm = ikeSecurityAssociationParameters["encryptionAlgorithm"] as? Int,
               let integrityAlgorithm = ikeSecurityAssociationParameters["integrityAlgorithm"] as? Int,
               let diffieHellmanGroup = ikeSecurityAssociationParameters["diffieHellmanGroup"] as? Int,
               let lifetimeMinutes = ikeSecurityAssociationParameters["lifetimeMinutes"] as? Int{
              
              p.ikeSecurityAssociationParameters.encryptionAlgorithm = .init(rawValue: encryptionAlgorithm) ?? .algorithmAES256
              
              p.ikeSecurityAssociationParameters.integrityAlgorithm  = .init(rawValue: integrityAlgorithm) ?? .SHA256
              
              p.ikeSecurityAssociationParameters.diffieHellmanGroup  = .init(rawValue: diffieHellmanGroup) ?? .group14
              
              p.ikeSecurityAssociationParameters.lifetimeMinutes  = Int32(lifetimeMinutes)
              
              
            }
            
            if let childSecurityAssociationParameters = config.value(forKey: "childSecurityAssociationParameters") as? NSDictionary ,
               let encryptionAlgorithm = childSecurityAssociationParameters["encryptionAlgorithm"] as? Int,
               let integrityAlgorithm = childSecurityAssociationParameters["integrityAlgorithm"] as? Int,
               let diffieHellmanGroup = childSecurityAssociationParameters["diffieHellmanGroup"] as? Int,
               let lifetimeMinutes = childSecurityAssociationParameters["lifetimeMinutes"] as? Int{
              
              p.childSecurityAssociationParameters.encryptionAlgorithm = .init(rawValue: encryptionAlgorithm) ?? .algorithmAES256
              
              p.childSecurityAssociationParameters.integrityAlgorithm  = .init(rawValue: integrityAlgorithm) ?? .SHA256
              
              p.childSecurityAssociationParameters.diffieHellmanGroup  = .init(rawValue: diffieHellmanGroup) ?? .group14
              
              p.childSecurityAssociationParameters.lifetimeMinutes  = Int32(lifetimeMinutes)
              
              
            }
            
            p.useExtendedAuthentication = true
            p.disconnectOnSleep = disconnectOnSleep
            self.vpnManager.protocolConfiguration = p
            
          }
          
          
          
          
        }
        
        
        
        
        
        
        var rules = [NEOnDemandRule]()
        let rule = NEOnDemandRuleConnect()
        rule.interfaceTypeMatch = .any
        rules.append(rule)
        
        self.vpnManager.onDemandRules = rules
        
        
        self.vpnManager.isEnabled = true
        
        if isPrepare{
          self.vpnManager.saveToPreferences { error in
            if error != nil {
              print("VPN Preferences error: 2")
              reject("VPN_ERR", "VPN Preferences error: 2", error)
            } else {
              print("VPN Reference Saved")
              resolve(nil)
            }
          }
        }else{
          self.vpnManager.saveToPreferences { error in
            if error != nil {
              print("VPN Preferences error: 2")
              reject("VPN_ERR", "VPN Preferences error: 2", error)
            } else {
              // ✅ 关键修复：保存后重新加载配置
              self.vpnManager.loadFromPreferences { loadError in
                if loadError != nil {
                  print("VPN Load after save error")
                  reject("VPN_ERR", "VPN Load after save error", loadError)
                  return
                }
                
                // 确保配置已启用
                self.vpnManager.isEnabled = true
                
                // 现在安全启动VPN
                var startError: NSError?
                do {
                  try self.vpnManager.connection.startVPNTunnel()
                } catch let error as NSError {
                  startError = error
                  print(startError ?? "VPN Manager cannot start tunnel")
                  reject("VPN_ERR", "VPN Manager cannot start tunnel", startError)
                } catch {
                  print("Fatal Error")
                  reject("VPN_ERR", "Fatal Error", NSError(domain: "", code: 200, userInfo: nil))
                  fatalError()
                }
                if startError != nil {
                  print("VPN Preferences error: 3")
                  print(startError ?? "Start Error")
                  reject("VPN_ERR", "VPN Preferences error: 3", startError)
                } else {
                  print("VPN started successfully..")
                  resolve(nil)
                }
              }
            }
          }
        }
      }
    }
  }
  
  @objc
  func disconnect(_ resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
    self.vpnManager.connection.stopVPNTunnel()
    resolve(nil)
  }
  
  @objc
  func getCurrentState(_ resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
    let status = checkNEStatus(status: self.vpnManager.connection.status)
    if(status.intValue < 6){
      resolve(status)
    } else {
      reject("VPN_ERR", "Unknown state", NSError())
    }
  }
  @objc
  func clearKeychainRefs(_ resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
    KeychainWrapper.destoryKeyForVPNID("secret")
    KeychainWrapper.destoryKeyForVPNID("password")
    resolve(nil)
  }
  
  @objc
  func getConnectionTimeSecond(_ resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
    resolve(Int(Date().timeIntervalSince(vpnManager.connection.connectedDate ?? Date())))
  }
  
  
  @objc
  func getCharonErrorState(_ resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
    // iOS doesn't have charon, always return NO_ERROR
    resolve(0)
  }
  
  
}


func checkNEStatus( status:NEVPNStatus ) -> NSNumber {
  switch status {
  case .connecting:
    return 2
  case .connected:
    return 3
  case .disconnecting:
    return 5
  case .disconnected:
    return 1
  case .invalid:
    return 0
  case .reasserting:
    return 4
  @unknown default:
    return 6
  }
}

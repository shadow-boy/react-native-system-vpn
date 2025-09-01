//
//  SystemVpnBridge.mm
//  react-native-system-vpn
//
//  Created by SystemVPN Team
//

#import <Foundation/Foundation.h>
#import "SystemVpnBridge.h"

#ifdef RCT_NEW_ARCH_ENABLED
@interface RCT_EXTERN_MODULE(SystemVpn, RCTEventEmitter)

RCT_EXTERN_METHOD(supportedEvents)

RCT_EXTERN_METHOD(prepare:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(connect:(NSDictionary *)config 
                  address:(NSString *)address 
                 username:(NSString *)username 
                 password:(NSString *)password 
                   secret:(NSString *)secret 
         disconnectOnSleep:(BOOL)disconnectOnSleep 
                  resolver:(RCTPromiseResolveBlock)resolve 
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(saveConfig:(NSDictionary *)config 
                     address:(NSString *)address 
                    username:(NSString *)username 
                    password:(NSString *)password 
                      secret:(NSString *)secret 
                    resolver:(RCTPromiseResolveBlock)resolve 
                    rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(disconnect:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(getCurrentState:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(getConnectionTimeSecond:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(getCharonErrorState:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(clearKeychainRefs:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)


@end

#else

@interface RCT_EXTERN_MODULE(SystemVpn, RCTEventEmitter)

RCT_EXTERN_METHOD(supportedEvents)

RCT_EXTERN_METHOD(prepare:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(connect:(NSDictionary *)config 
                  address:(NSString *)address 
                 username:(NSString *)username 
                 password:(NSString *)password 
                   secret:(NSString *)secret 
         disconnectOnSleep:(BOOL)disconnectOnSleep 
                  resolver:(RCTPromiseResolveBlock)resolve 
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(saveConfig:(NSDictionary *)config 
                     address:(NSString *)address 
                    username:(NSString *)username 
                    password:(NSString *)password 
                      secret:(NSString *)secret 
                    resolver:(RCTPromiseResolveBlock)resolve 
                    rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(disconnect:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(getCurrentState:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(getConnectionTimeSecond:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(getCharonErrorState:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(clearKeychainRefs:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)


@end

#endif

import SystemVpn, { type VPNConfigOptions } from './NativeSystemVpn';
import { NativeEventEmitter, type EmitterSubscription } from 'react-native';

// VPN state enums
export enum VpnState {
  invalid,
  disconnected,
  connecting,
  connected,
  reasserting,
  disconnecting,
}

// Error state enum (Android only)
export enum CharonErrorState {
  NO_ERROR,
  AUTH_FAILED,
  PEER_AUTH_FAILED,
  LOOKUP_FAILED,
  UNREACHABLE,
  GENERIC_ERROR,
  PASSWORD_MISSING,
  CERTIFICATE_UNAVAILABLE,
  UNDEFINED,
}

// Certificate types for iOS
export enum NEVPNIKEv2CertificateType {
  RSA = 1,
  ECDSA256 = 2,
  ECDSA384 = 3,
  ECDSA521 = 4,
  ed25519 = 5
}

// Export types
export type { VPNConfigOptions };

// Event emitter for state changes  
const eventEmitter = new NativeEventEmitter(SystemVpn as any);
export const STATE_CHANGED_EVENT_NAME = 'stateChanged';

// Event listener methods
export const onStateChangedListener = (
  callback: (state: { state: VpnState; charonState: CharonErrorState }) => void
): EmitterSubscription => {
  return eventEmitter.addListener(STATE_CHANGED_EVENT_NAME, (event: any) => {
    callback(event as { state: VpnState; charonState: CharonErrorState });
  });
};

export const removeOnStateChangeListener = (
  stateChangedEvent: EmitterSubscription
): void => {
  stateChangedEvent.remove();
};

// VPN control methods
export const prepare = (): Promise<void> => {
  return SystemVpn.prepare();
};

export const connect = (
  config: VPNConfigOptions,
  address: string,
  username: string,
  password: string,
  secret: string,
  disconnectOnSleep: boolean = false
): Promise<void> => {
  return SystemVpn.connect(config, address, username, password, secret, disconnectOnSleep);
};

export const saveConfig = (
  config: VPNConfigOptions,
  address: string,
  username: string,
  password: string,
  secret: string
): Promise<void> => {
  return SystemVpn.saveConfig(config, address, username, password, secret);
};

export const getCurrentState = (): Promise<VpnState> => {
  return SystemVpn.getCurrentState().then(state => state as VpnState);
};

export const getCharonErrorState = (): Promise<CharonErrorState> => {
  return SystemVpn.getCharonErrorState().then(state => state as CharonErrorState);
};

export const getConnectionTimeSecond = (): Promise<number> => {
  return SystemVpn.getConnectionTimeSecond();
};

export const disconnect = (): Promise<void> => {
  return SystemVpn.disconnect();
};

export const clearKeychainRefs = (): Promise<void> => {
  return SystemVpn.clearKeychainRefs();
};

// Default export for compatibility
export default SystemVpn;

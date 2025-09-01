import { TurboModuleRegistry, type TurboModule } from 'react-native';

export interface VPNConfigOptions {
  name: string;
  type: "ipsec" | "ikev2";
  authenticationMethod: number;
  address: string;
  username: string;
  password: string;
  secret?: string;
  identityData?: string;
  remoteIdentifier?: string;
  localIdentifier?: string;
  certificateType?: number;
  ikeSecurityAssociationParameters?: {
    encryptionAlgorithm: number;
    integrityAlgorithm: number;
    diffieHellmanGroup: number;
    lifetimeMinutes: number;
  };
  childSecurityAssociationParameters?: {
    encryptionAlgorithm: number;
    integrityAlgorithm: number;
    diffieHellmanGroup: number;
    lifetimeMinutes: number;
  };
}

export interface Spec extends TurboModule {
  // Preparation method
  prepare(): Promise<void>;
  
  // Connection methods
  connect(
    config: VPNConfigOptions,
    address: string,
    username: string,
    password: string,
    secret: string,
    disconnectOnSleep: boolean
  ): Promise<void>;
  
  saveConfig(
    config: VPNConfigOptions,
    address: string,
    username: string,
    password: string,
    secret: string
  ): Promise<void>;
  
  // State methods
  getCurrentState(): Promise<number>;
  getCharonErrorState(): Promise<number>;
  getConnectionTimeSecond(): Promise<number>;
  
  // Disconnect method
  disconnect(): Promise<void>;
  
  // Cleanup method
  clearKeychainRefs(): Promise<void>;
  

}

export default TurboModuleRegistry.getEnforcing<Spec>('SystemVpn');

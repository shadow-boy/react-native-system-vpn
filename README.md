# React Native System VPN

A React Native module for connecting to VPN using native system VPN APIs on both Android and iOS platforms. This is a new architecture (TurboModule) version migrated from [react-native-vpn-ipsec](https://github.com/shadow-boy/react-native-vpn-ipsec).

## Features

- 🔐 **IPSec and IKEv2 VPN Support**: Connect using industry-standard protocols
- 📱 **Cross-platform**: Works on both Android and iOS  
- 🚀 **New Architecture Ready**: Built for React Native's new architecture with TurboModules
- 🎯 **Native Performance**: Uses platform-native VPN implementations
- 🔄 **Real-time Status**: Get VPN connection state updates
- 🛡️ **Secure**: Leverages system keychain for credential storage

## Installation

```sh
npm install react-native-system-vpn
```

### iOS Setup

1. Enable Network Extensions capability in your iOS app
2. Add `NetworkExtension.framework` to your project (done automatically via CocoaPods)

### Android Setup

Add VPN permissions to your `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.BIND_VPN_SERVICE" />
```

## Usage

### Basic Example

```tsx
import React, { useEffect, useState } from 'react';
import {
  prepare,
  connect,
  disconnect,
  getCurrentState,
  onStateChangedListener,
  removeOnStateChangeListener,
  VpnState,
  CharonErrorState,
  type VPNConfigOptions,
  type EmitterSubscription,
} from 'react-native-system-vpn';

export default function VPNExample() {
  const [vpnState, setVpnState] = useState<VpnState>(VpnState.disconnected);
  const [listener, setListener] = useState<EmitterSubscription | null>(null);

  useEffect(() => {
    // Prepare VPN on component mount
    const initVPN = async () => {
      try {
        await prepare();
        console.log('VPN prepared successfully');
      } catch (error) {
        console.error('Failed to prepare VPN:', error);
      }
    };

    initVPN();

    // Set up state listener
    const stateListener = onStateChangedListener(
      (state: { state: VpnState; charonState: CharonErrorState }) => {
        console.log('VPN State changed:', state);
        setVpnState(state.state);
      }
    );
    setListener(stateListener);

    return () => {
      if (listener) {
        removeOnStateChangeListener(listener);
      }
    };
  }, []);

  const handleConnect = async () => {
    try {
      const config: VPNConfigOptions = {
        name: 'My VPN',
        type: 'ipsec', // or 'ikev2'
        authenticationMethod: 2, // 2 for shared secret, 1 for certificate
        address: 'vpn.example.com',
        username: 'your-username',
        password: 'your-password',
        secret: 'shared-secret', // optional
      };

      await connect(
        config,
        'vpn.example.com',
        'your-username', 
        'your-password',
        'shared-secret',
        false // disconnectOnSleep
      );
    } catch (error) {
      console.error('Failed to connect:', error);
    }
  };

  const handleDisconnect = async () => {
    try {
      await disconnect();
    } catch (error) {
      console.error('Failed to disconnect:', error);
    }
  };

  return (
    // Your UI here
  );
}
```

## API Reference

### Methods

#### `prepare(): Promise<void>`

Prepares the VPN service. Must be called before any other VPN operations.

- **Android**: Requests VPN permission from the user
- **iOS**: Initializes the VPN manager and sets up state monitoring

#### `connect(config, address, username, password, secret, disconnectOnSleep): Promise<void>`

Connects to a VPN server.

**Parameters:**
- `config`: VPNConfigOptions - VPN configuration object
- `address`: string - VPN server address
- `username`: string - Username for authentication  
- `password`: string - Password for authentication
- `secret`: string - Shared secret (optional)
- `disconnectOnSleep`: boolean - Whether to disconnect when device sleeps

#### `disconnect(): Promise<void>`

Disconnects the current VPN connection.

#### `getCurrentState(): Promise<VpnState>`

Gets the current VPN connection state.

**Returns:** Promise resolving to current VpnState

#### `getCharonErrorState(): Promise<CharonErrorState>`

Gets the current error state (Android only - returns NO_ERROR on iOS).

**Returns:** Promise resolving to current CharonErrorState

#### `getConnectionTimeSecond(): Promise<number>`

Gets the connection time in seconds.

**Returns:** Promise resolving to connection time

#### `clearKeychainRefs(): Promise<void>`

Clears stored keychain references for VPN credentials.

#### Event Listeners

#### `onStateChangedListener(callback): EmitterSubscription`

Registers a listener for VPN state changes.

**Parameters:**
- `callback`: Function that receives state updates

**Returns:** EmitterSubscription that can be used to remove the listener

#### `removeOnStateChangeListener(subscription): void`

Removes a previously registered state change listener.

**Parameters:**
- `subscription`: EmitterSubscription returned from onStateChangedListener

### Types

#### `VPNConfigOptions`

```typescript
interface VPNConfigOptions {
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
```

#### `VpnState`

```typescript
enum VpnState {
  invalid,      // VPN is in an invalid state
  disconnected, // VPN is disconnected
  connecting,   // VPN is connecting
  connected,    // VPN is connected
  reasserting,  // VPN is reasserting connection
  disconnecting,// VPN is disconnecting
}
```

#### `CharonErrorState` (Android only)

```typescript
enum CharonErrorState {
  NO_ERROR,                 // No error
  AUTH_FAILED,             // Authentication failed
  PEER_AUTH_FAILED,        // Peer authentication failed
  LOOKUP_FAILED,           // DNS lookup failed
  UNREACHABLE,             // Server unreachable
  GENERIC_ERROR,           // Generic error
  PASSWORD_MISSING,        // Password missing
  CERTIFICATE_UNAVAILABLE, // Certificate unavailable
  UNDEFINED,               // Undefined error
}
```

## Platform Differences

### Android
- Uses Android's built-in VPN service
- Requires VPN permission from user
- Supports StrongSwan-based IPSec/IKEv2
- Provides detailed error states via CharonErrorState

### iOS  
- Uses NetworkExtension framework
- Requires Network Extensions capability
- Supports native IPSec and IKEv2
- Stores credentials securely in keychain
- CharonErrorState always returns NO_ERROR

## Migration from react-native-vpn-ipsec

This library is a new architecture migration of [react-native-vpn-ipsec](https://github.com/shadow-boy/react-native-vpn-ipsec). Key differences:

1. **New Architecture**: Built with TurboModules for better performance
2. **TypeScript First**: Full TypeScript support with proper type definitions
3. **Consistent API**: Unified API across platforms
4. **Modern Patterns**: Uses modern React Native patterns and best practices

## Examples

See the [example](./example) directory for a complete working example.

## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.

## License

MIT

---

Made with [create-react-native-library](https://github.com/callstack/react-native-builder-bob)
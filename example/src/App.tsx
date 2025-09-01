import React, { useState, useEffect } from 'react';
import {
  Text,
  View,
  StyleSheet,
  TextInput,
  TouchableOpacity,
  Alert,
  ScrollView,
  Switch,
  type EmitterSubscription,
} from 'react-native';
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
} from 'react-native-system-vpn';

export default function App() {
  const [serverAddress, setServerAddress] = useState('');
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [secret, setSecret] = useState('');
  const [vpnState, setVpnState] = useState<VpnState>(VpnState.disconnected);
  const [connectionName, setConnectionName] = useState('My VPN');
  const [useIKEv2, setUseIKEv2] = useState(false);
  const [disconnectOnSleep, setDisconnectOnSleep] = useState(false);
  const [listener, setListener] = useState<EmitterSubscription | null>(null);

  useEffect(() => {
    // Prepare VPN on app start
    handlePrepare();

    // Set up state listener
    const stateListener = onStateChangedListener(
      (state: { state: VpnState; charonState: CharonErrorState }) => {
        console.log('VPN State changed:', state);
        setVpnState(state.state);
        
        if (state.charonState !== CharonErrorState.NO_ERROR) {
          Alert.alert('VPN Error', `Charon error: ${state.charonState}`);
        }
      }
    );
    setListener(stateListener);

    return () => {
      if (listener) {
        removeOnStateChangeListener(listener);
      }
    };
  }, []);

  const handlePrepare = async () => {
    try {
      await prepare();
      console.log('VPN prepared successfully');
    } catch (error) {
      console.error('Failed to prepare VPN:', error);
      Alert.alert('Error', 'Failed to prepare VPN');
    }
  };

  const handleConnect = async () => {
    if (!serverAddress || !username || !password) {
      Alert.alert('Error', 'Please fill in all required fields');
      return;
    }

    try {
      const config: VPNConfigOptions = {
        name: connectionName,
        type: useIKEv2 ? 'ikev2' : 'ipsec',
        authenticationMethod: secret ? 2 : 1, // 2 for shared secret, 1 for certificate
        address: serverAddress,
        username: username,
        password: password,
        secret: secret,
      };

      await connect(config, serverAddress, username, password, secret, disconnectOnSleep);
      console.log('VPN connection initiated');
    } catch (error) {
      console.error('Failed to connect VPN:', error);
      Alert.alert('Error', 'Failed to connect to VPN');
    }
  };

  const handleDisconnect = async () => {
    try {
      await disconnect();
      console.log('VPN disconnected');
    } catch (error) {
      console.error('Failed to disconnect VPN:', error);
      Alert.alert('Error', 'Failed to disconnect VPN');
    }
  };

  const handleGetState = async () => {
    try {
      const state = await getCurrentState();
      setVpnState(state);
      Alert.alert('VPN State', `Current state: ${VpnState[state]}`);
    } catch (error) {
      console.error('Failed to get VPN state:', error);
      Alert.alert('Error', 'Failed to get VPN state');
    }
  };

  const getStateText = () => {
    switch (vpnState) {
      case VpnState.invalid:
        return 'Invalid';
      case VpnState.disconnected:
        return 'Disconnected';
      case VpnState.connecting:
        return 'Connecting...';
      case VpnState.connected:
        return 'Connected';
      case VpnState.reasserting:
        return 'Reasserting...';
      case VpnState.disconnecting:
        return 'Disconnecting...';
      default:
        return 'Unknown';
    }
  };

  const getStateColor = () => {
    switch (vpnState) {
      case VpnState.connected:
        return '#4CAF50';
      case VpnState.connecting:
      case VpnState.reasserting:
        return '#FF9800';
      case VpnState.disconnecting:
        return '#F44336';
      default:
        return '#757575';
    }
  };

  return (
    <ScrollView style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.title}>System VPN Demo</Text>
        <View style={[styles.statusIndicator, { backgroundColor: getStateColor() }]}>
          <Text style={styles.statusText}>{getStateText()}</Text>
        </View>
      </View>

      <View style={styles.form}>
        <Text style={styles.label}>Connection Name</Text>
        <TextInput
          style={styles.input}
          value={connectionName}
          onChangeText={setConnectionName}
          placeholder="My VPN Connection"
        />

        <Text style={styles.label}>Server Address *</Text>
        <TextInput
          style={styles.input}
          value={serverAddress}
          onChangeText={setServerAddress}
          placeholder="vpn.example.com"
          autoCapitalize="none"
        />

        <Text style={styles.label}>Username *</Text>
        <TextInput
          style={styles.input}
          value={username}
          onChangeText={setUsername}
          placeholder="username"
          autoCapitalize="none"
        />

        <Text style={styles.label}>Password *</Text>
        <TextInput
          style={styles.input}
          value={password}
          onChangeText={setPassword}
          placeholder="password"
          secureTextEntry
        />

        <Text style={styles.label}>Shared Secret (optional)</Text>
        <TextInput
          style={styles.input}
          value={secret}
          onChangeText={setSecret}
          placeholder="shared secret"
          secureTextEntry
        />

        <View style={styles.switchContainer}>
          <Text style={styles.label}>Use IKEv2 (default: IPSec)</Text>
          <Switch value={useIKEv2} onValueChange={setUseIKEv2} />
        </View>

        <View style={styles.switchContainer}>
          <Text style={styles.label}>Disconnect on Sleep</Text>
          <Switch value={disconnectOnSleep} onValueChange={setDisconnectOnSleep} />
        </View>
      </View>

      <View style={styles.buttons}>
        <TouchableOpacity
          style={[styles.button, styles.connectButton]}
          onPress={handleConnect}
          disabled={vpnState === VpnState.connecting || vpnState === VpnState.connected}
        >
          <Text style={styles.buttonText}>Connect</Text>
        </TouchableOpacity>

        <TouchableOpacity
          style={[styles.button, styles.disconnectButton]}
          onPress={handleDisconnect}
          disabled={vpnState === VpnState.disconnected}
        >
          <Text style={styles.buttonText}>Disconnect</Text>
        </TouchableOpacity>

        <TouchableOpacity
          style={[styles.button, styles.statusButton]}
          onPress={handleGetState}
        >
          <Text style={styles.buttonText}>Get Status</Text>
        </TouchableOpacity>
      </View>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5',
  },
  header: {
    backgroundColor: '#2196F3',
    padding: 20,
    paddingTop: 60,
    alignItems: 'center',
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    color: 'white',
    marginBottom: 10,
  },
  statusIndicator: {
    paddingHorizontal: 20,
    paddingVertical: 8,
    borderRadius: 20,
  },
  statusText: {
    color: 'white',
    fontWeight: 'bold',
  },
  form: {
    padding: 20,
  },
  label: {
    fontSize: 16,
    fontWeight: '600',
    marginBottom: 5,
    marginTop: 15,
    color: '#333',
  },
  input: {
    borderWidth: 1,
    borderColor: '#ddd',
    borderRadius: 8,
    padding: 12,
    backgroundColor: 'white',
    fontSize: 16,
  },
  switchContainer: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginTop: 15,
    paddingVertical: 10,
  },
  buttons: {
    padding: 20,
    gap: 15,
  },
  button: {
    padding: 15,
    borderRadius: 8,
    alignItems: 'center',
  },
  connectButton: {
    backgroundColor: '#4CAF50',
  },
  disconnectButton: {
    backgroundColor: '#F44336',
  },
  statusButton: {
    backgroundColor: '#2196F3',
  },
  buttonText: {
    color: 'white',
    fontSize: 16,
    fontWeight: '600',
  },
});

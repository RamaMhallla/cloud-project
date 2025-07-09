import 'package:mqtt_client/mqtt_client.dart'; // Core MQTT library
import 'package:mqtt_client/mqtt_server_client.dart'; // Server client for MQTT
import 'package:flutter/foundation.dart'; // Provides VoidCallback

class MQTTService {
  final String broker = 'broker.hivemq.com';
  late final String clientId; // Unique client ID
  final String topic = 'health/patient1/sensors';

  late MqttServerClient _client; // MQTT client instance

  Function(String)? onMessageReceived; // Callback for received messages
  VoidCallback? onConnected; // Callback when connected
  VoidCallback? onDisconnected; // Callback when disconnected

  MQTTService() {
    clientId =
        'flutter_client_${DateTime.now().millisecondsSinceEpoch}'; // Generate unique client ID
    _client = MqttServerClient(broker, clientId); // Create MQTT client
    _client.port = 1883; // MQTT default port
    _client.keepAlivePeriod = 20; // Keep alive interval 20s
    _client.autoReconnect = true; // Enable auto reconnect
    _client.logging(on: true); // Enable logging in console

    // Assign internal callback handlers
    // if connected successfully => run connected fun
    _client.onConnected = _onConnected;
    _client.onDisconnected = _onDisconnected;
    _client.onSubscribed = _onSubscribed;
    _client.onSubscribeFail = _onSubscribeFail;
    _client.pongCallback = _pong; // if a ping is received =>run _pong

    _client.onAutoReconnect = () => print('🔄 Trying to auto reconnect...');
    _client.onAutoReconnected = () => print('✅ Auto reconnected!');

    // Define connection message
    final connMess = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .startClean()
        .withWillQos(MqttQos.atMostOnce); // QoS 0
    _client.connectionMessage = connMess;
  }
  // start clean means the broker will not maitain the past sessions

  Future<void> connect() async {
    try {
      print('⏳ Connecting to MQTT broker...');
      await _client.connect();
      // wait until connect successfully or fail the connect with the broker

      if (_client.connectionStatus?.state == MqttConnectionState.connected) {
        print('✅ Connected successfully, subscribing...');
        _client.subscribe(topic, MqttQos.atMostOnce);

        _client.updates?.listen((event) {
          final recMess = event[0].payload as MqttPublishMessage;
          final payload = MqttPublishPayload.bytesToStringAsString(
            recMess.payload.message,
          ); // convert the content of the msg from bytes to String (to be readable)
          print('📥 Message received: $payload');
          onMessageReceived?.call(
            payload,
          ); // call onMessageReceived fun and give it the payload
        });

        //call onConnected fun to update or change the status to "Connected"
        onConnected?.call();
      } else {
        print('❌ Connection failed - disconnecting');
        disconnect();
      }
    } catch (e) {
      // if an exception is happen like np internet or server is busy => error msg + disconnect
      print('❌ MQTT client connection failed: $e');
      disconnect();
    }
  }

  void disconnect() {
    print('🛑 Disconnecting MQTT client');
    _client.disconnect();
    onDisconnected?.call();
  }

  void _onConnected() {
    print('✅ MQTT Connected');
    onConnected?.call();
  }

  void _onDisconnected() {
    print('❌ MQTT Disconnected');
    final status = _client.connectionStatus;
    if (status != null) {
      print('Status state: ${status.state}');
      print('Connection status: ${status.toString()}');
    }
    onDisconnected?.call();
  }

  void _onSubscribed(String topic) {
    print('📡 Subscribed to $topic');
  }

  void _onSubscribeFail(String topic) {
    print('⚠️ Failed to subscribe $topic');
  }

  void _pong() {
    print('Ping response received');
  }
}

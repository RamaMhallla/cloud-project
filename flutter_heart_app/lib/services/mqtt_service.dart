import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:flutter/foundation.dart';

class MQTTService {
  final String broker = 'broker.hivemq.com';
  late final String clientId;
  final String topic = 'health/patient1/sensors';

  late MqttServerClient _client;

  Function(String)? onMessageReceived;
  VoidCallback? onConnected; // ✅ أضف هذا
  VoidCallback? onDisconnected; // ✅ وأضف هذا

  MQTTService() {
    clientId = 'flutter_client_${DateTime.now().millisecondsSinceEpoch}';
    _client = MqttServerClient(broker, clientId);
    _client.port = 1883;
    _client.keepAlivePeriod = 20;
    _client.autoReconnect = true;
    _client.logging(on: true);

    _client.onConnected = _onConnected;
    _client.onDisconnected = _onDisconnected;
    _client.onSubscribed = _onSubscribed;
    _client.onSubscribeFail = _onSubscribeFail;
    _client.pongCallback = _pong;

    _client.onAutoReconnect = () => print('🔄 Trying to auto reconnect...');
    _client.onAutoReconnected = () => print('✅ Auto reconnected!');

    final connMess = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .startClean()
        .withWillQos(MqttQos.atMostOnce);
    _client.connectionMessage = connMess;
  }

  Future<void> connect() async {
    try {
      print('⏳ Connecting to MQTT broker...');
      await _client.connect();

      if (_client.connectionStatus?.state == MqttConnectionState.connected) {
        print('✅ Connected successfully, subscribing...');
        _client.subscribe(topic, MqttQos.atMostOnce);

        _client.updates?.listen((event) {
          final recMess = event[0].payload as MqttPublishMessage;
          final payload = MqttPublishPayload.bytesToStringAsString(
            recMess.payload.message,
          );
          print('📥 Message received: $payload');
          onMessageReceived?.call(payload); // أفضل طريقة مختصرة
        });

        // نداء عند الاتصال
        onConnected?.call();
      } else {
        print('❌ Connection failed - disconnecting');
        disconnect();
      }
    } catch (e) {
      print('❌ MQTT client connection failed: $e');
      disconnect();
    }
  }

  void disconnect() {
    print('🛑 Disconnecting MQTT client');
    _client.disconnect();
    onDisconnected?.call(); // ← نداء عند فصل الاتصال
  }

  void _onConnected() {
    print('✅ MQTT Connected');
    onConnected?.call(); // ← أيضاً نداء من الكولباك الأساسي
  }

  void _onDisconnected() {
    print('❌ MQTT Disconnected');
    final status = _client.connectionStatus;
    if (status != null) {
      print('Status state: ${status.state}');
      print('Connection status: ${status.toString()}');
    }
    onDisconnected?.call(); // ← نداء عند انقطاع الاتصال
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

import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttTestPage extends StatefulWidget {
  const MqttTestPage({super.key});

  @override
  State<MqttTestPage> createState() => _MqttTestPageState();
}

class _MqttTestPageState extends State<MqttTestPage> {
  final String broker = 'broker.hivemq.com';
  final String topic = 'health/patient1/sensors';
  late MqttServerClient client;
  List<String> messages = [];

  @override
  void initState() {
    super.initState();
    connect();
  }

  Future<void> connect() async {
    client = MqttServerClient(
      broker,
      'flutter_test_client_${DateTime.now().millisecondsSinceEpoch}',
    );
    client.port = 1883;
    client.keepAlivePeriod = 20;
    client.logging(on: false);

    client.onConnected = () {
      print('✅ MQTT Connected');
      client.subscribe(topic, MqttQos.atMostOnce);
    };

    client.onDisconnected = () {
      print('❌ MQTT Disconnected');
    };

    client.onSubscribed = (String topic) {
      print('📡 Subscribed to $topic');
    };

    try {
      await client.connect();
    } catch (e) {
      print('❌ MQTT Connection failed: $e');
      client.disconnect();
    }

    client.updates?.listen((List<MqttReceivedMessage<MqttMessage?>>? event) {
      final MqttPublishMessage recMess =
          event![0].payload as MqttPublishMessage;
      final payload = MqttPublishPayload.bytesToStringAsString(
        recMess.payload.message,
      );
      print('📥 Message received: $payload');
      setState(() {
        messages.insert(0, payload); // Add new message to top
      });
    });
  }

  @override
  void dispose() {
    client.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MQTT Test Receiver')),
      body: ListView.builder(
        reverse: true, // to let new msg be at the top
        itemCount: messages.length,
        itemBuilder: (context, index) {
          return ListTile(title: Text(messages[index]));
        },
      ),
    );
  }
}

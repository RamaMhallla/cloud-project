import 'package:flutter/material.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'patient_dashboard.dart'; // Import to use AppColor

class PredictionPage extends StatefulWidget {
  final List<double> inputFeatures;
  final String name;
  final int age;
  final String gender;

  const PredictionPage({
    super.key,
    required this.inputFeatures,
    required this.name,
    required this.age,
    required this.gender,
  });

  @override
  State<PredictionPage> createState() => _PredictionPageState();
}

class _PredictionPageState extends State<PredictionPage> {
  String result = 'Analyzing...';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    runModel();
  }

  Future<void> runModel() async {
    try {
      final interpreter = await Interpreter.fromAsset(
        'assets/models/heart_model.tflite',
      );

      var input = [widget.inputFeatures];
      var output = List.filled(1 * 1, 0).reshape([1, 1]);

      interpreter.run(input, output);

      double prediction = output[0][0].toDouble();

      setState(() {
        result = prediction > 0.5 ? 'High Risk Detected' : 'Low Risk (Normal)';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        result = 'Error running model';
        _isLoading = false;
      });
    }
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 22, color: AppColor.primaryBlue),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: AppColor.textPrimary,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color: AppColor.darkBlue,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultIndicator() {
    if (_isLoading) {
      return const CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppColor.primaryBlue),
      );
    }

    final isHighRisk = result.contains('High');
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            isHighRisk
                ? AppColor.error.withOpacity(0.1)
                : AppColor.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isHighRisk ? AppColor.error : AppColor.success,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Icon(
            isHighRisk ? Icons.warning : Icons.check_circle,
            size: 48,
            color: isHighRisk ? AppColor.error : AppColor.success,
          ),
          const SizedBox(height: 12),
          Text(
            result,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isHighRisk ? AppColor.error : AppColor.success,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            isHighRisk
                ? 'Please consult a doctor immediately'
                : 'Your heart health appears normal',
            style: TextStyle(fontSize: 16, color: AppColor.lightBlue),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.lightBlue,
      appBar: AppBar(
        title: const Text('Heart Risk Prediction'),
        backgroundColor: AppColor.lightBlue,
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Patient Summary',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColor.darkBlue,
                  ),
                ),
                const SizedBox(height: 16),
                _buildInfoRow(Icons.person, 'Name:', widget.name),
                _buildInfoRow(Icons.cake, 'Age:', widget.age.toString()),
                _buildInfoRow(
                  Icons.wc,
                  'Gender:',
                  widget.gender[0].toUpperCase() + widget.gender.substring(1),
                ),
                const Divider(height: 32, thickness: 1),
                Text(
                  'Risk Assessment',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColor.darkBlue,
                  ),
                ),
                const SizedBox(height: 16),
                Center(child: _buildResultIndicator()),
                const SizedBox(height: 24),
                if (!_isLoading)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.primaryBlue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Return to Dashboard',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

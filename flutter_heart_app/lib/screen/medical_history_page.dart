import 'package:flutter/material.dart';

class MedicalHistoryPage extends StatelessWidget {
  const MedicalHistoryPage({super.key});

  // بيانات وهمية للسجل – لاحقًا يمكن ربطها من قاعدة بيانات
  final List<Map<String, String>> historyData = const [
    {"date": "2025-07-09", "type": "X-Ray", "result": "No pneumonia detected"},
    {"date": "2025-07-07", "type": "Heart Disease", "result": "Low risk (17%)"},
    {
      "date": "2025-07-04",
      "type": "Heart Disease",
      "result": "Moderate risk (52%)",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6F2F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF5B8FB9),
        title: const Text(
          'Medical History',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: historyData.length,
        itemBuilder: (context, index) {
          final entry = historyData[index];
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        entry["type"] == "X-Ray"
                            ? Icons.medical_information
                            : Icons.favorite,
                        color: const Color(0xFF003366),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        entry["type"]!,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF003366),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        entry["date"]!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF7F8C8D),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Result: ${entry["result"]!}",
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF333333),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ignore_for_file: depend_on_referenced_packages

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

class AppColor {
  // Primary colors
  static const primaryBlue = Color(0xFF5B8FB9); // Main soft blue
  static const lightBlue = Color(0xFFB6D0E2); // Light blue for backgrounds
  static const darkBlue = Color.fromARGB(
    255,
    7,
    72,
    137,
  ); // Dark blue for text and titles

  // Secondary colors
  static const softTeal = Color(0xFF7FB3B0); // Soft blue-green
  static const paleBlue = Color(0xFFE6F2F5); // Very light blue for backgrounds

  // Status colors
  static const success = Color(0xFF4CAF50); // Green for success
  static const warning = Color(0xFFFFA000); // Orange for warning
  static const error = Color(0xFFE53935); // Red for error

  // Text colors
  static const textPrimary = Color(0xFF2C3E50); // Blue-gray for primary text
  static const textSecondary = Color(
    0xFF7F8C8D,
  ); // Light gray for secondary text
}

class XRayAnalysisPage extends StatefulWidget {
  const XRayAnalysisPage({super.key});

  @override
  State<XRayAnalysisPage> createState() => _XRayAnalysisPageState();
}

class _XRayAnalysisPageState extends State<XRayAnalysisPage> {
  File? _image;
  String _result = 'No analysis performed yet';
  String _confidence = '';
  late Interpreter _interpreter;
  final picker = ImagePicker();
  bool _isLoading = false;
  bool _modelLoaded = false;

  @override
  void initState() {
    super.initState();
    loadModel();
  }

  Future<void> loadModel() async {
    try {
      setState(() => _isLoading = true);
      _interpreter = await Interpreter.fromAsset(
        'assets/models/chest_xray_model.tflite',
      );
      print('Model loaded successfully');
      setState(() {
        _modelLoaded = true;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading model: $e');
      setState(() {
        _result = 'Error loading analysis model';
        _isLoading = false;
      });
    }
  }

  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    setState(() {
      _image = File(pickedFile.path);
      _result = 'Image loaded, ready for analysis';
      _confidence = '';
    });
  }

  Future<void> analyzeImage() async {
    if (_image == null || !_modelLoaded) return;

    setState(() {
      _isLoading = true;
      _result = 'Analyzing image...';
    });

    try {
      // Read and process the image
      img.Image? imageInput = img.decodeImage(await _image!.readAsBytes());
      if (imageInput == null) {
        setState(() {
          _result = 'Error reading image';
          _isLoading = false;
        });
        return;
      }

      // Resize image to model input size (150x150)
      img.Image resizedImage = img.copyResize(
        imageInput,
        width: 150,
        height: 150,
      );

      var input = imageToByteListFloat32(resizedImage, 150);
      var output = List.filled(1 * 1, 0).reshape([1, 1]);

      _interpreter.run(input, output);

      double prediction = output[0][0];
      double confidence = prediction * 100;

      setState(() {
        if (prediction > 0.5) {
          _result = '⚠️ Pneumonia detected';
          _confidence = 'Confidence: ${confidence.toStringAsFixed(2)}%';
        } else {
          _result = '✅ Normal chest X-ray';
          _confidence = 'Confidence: ${(100 - confidence).toStringAsFixed(2)}%';
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _result = 'Error during analysis';
        _confidence = '';
        _isLoading = false;
      });
      print('Error during analysis: $e');
    }
  }

  List<List<List<List<double>>>> imageToByteListFloat32(
    img.Image image,
    int inputSize,
  ) {
    return [
      List.generate(inputSize, (y) {
        return List.generate(inputSize, (x) {
          var pixel = image.getPixel(x, y);
          var r = img.getRed(pixel) / 255.0;
          var g = img.getGreen(pixel) / 255.0;
          var b = img.getBlue(pixel) / 255.0;
          return [r, g, b];
        });
      }),
    ];
  }

  Widget _buildImagePreview() {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _image == null
                ? Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: AppColor.paleBlue,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.image,
                          size: 40,
                          color: AppColor.primaryBlue,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No X-ray image selected',
                          style: TextStyle(color: AppColor.textSecondary),
                        ),
                      ],
                    ),
                  ),
                )
                : ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(_image!, height: 200, fit: BoxFit.cover),
                ),
            if (_image != null) ...[
              const SizedBox(height: 12),
              Text(
                'Selected X-ray Image',
                style: TextStyle(color: AppColor.textSecondary, fontSize: 14),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, size: 24, color: AppColor.darkBlue),
                const SizedBox(width: 8),
                Text(
                  'Analysis Results',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColor.darkBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _isLoading
                ? Center(
                  child: CircularProgressIndicator(color: AppColor.primaryBlue),
                )
                : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _result,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color:
                            _result.startsWith('✅')
                                ? AppColor.success
                                : _result.startsWith('⚠️')
                                ? AppColor.error
                                : AppColor.textPrimary,
                      ),
                    ),
                    if (_confidence.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        _confidence,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColor.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.paleBlue,
      appBar: AppBar(
        title: const Text('X-Ray Analysis'),
        backgroundColor: AppColor.lightBlue,
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildImagePreview(),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: pickImage,
                    icon: const Icon(Icons.image),
                    label: const Text('Select Image'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.softTeal,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed:
                        _modelLoaded && _image != null ? analyzeImage : null,
                    icon: const Icon(Icons.analytics),
                    label: const Text('Analyze'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primaryBlue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildAnalysisCard(),
            if (!_modelLoaded && !_isLoading)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  'Analysis model not ready. Please try again later.',
                  style: TextStyle(
                    color: AppColor.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

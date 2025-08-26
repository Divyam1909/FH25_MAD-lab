import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../models/app_state.dart';
import '../widgets/cyber_card.dart';
import '../widgets/code_viewer.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 32),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildUploadSection(),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: _buildPreviewSection(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Upload Code',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFF00FF41),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Upload your custom encryption and attack algorithms for testing',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[400],
          ),
        ),
      ],
    );
  }

  Widget _buildUploadSection() {
    return Column(
      children: [
        _buildEncryptionUpload(),
        const SizedBox(height: 24),
        _buildAttackUpload(),
      ],
    );
  }

  Widget _buildEncryptionUpload() {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return CyberCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.lock,
                    color: Color(0xFF00FF41),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Encryption Algorithm',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00FF41).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'REQUIRED',
                      style: TextStyle(
                        fontSize: 10,
                        color: Color(0xFF00FF41),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Upload a Dart file containing your custom encryption algorithm. The file should export a class with encrypt() and decrypt() methods.',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isUploading ? null : () => _uploadFile(true),
                  icon: _isUploading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.black),
                          ),
                        )
                      : const Icon(Icons.upload),
                  label: Text(_isUploading ? 'Uploading...' : 'Upload Encryption Code'),
                ),
              ),
              if (appState.uploadedEncryptionCode != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00FF41).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Color(0xFF00FF41),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Encryption code uploaded successfully',
                        style: TextStyle(
                          color: Color(0xFF00FF41),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildAttackUpload() {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return CyberCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.warning,
                    color: Colors.orange,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Attack Algorithm',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'OPTIONAL',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Upload a Dart file containing your custom attack algorithm. The file should export a class with an attack() method.',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isUploading ? null : () => _uploadFile(false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.upload),
                  label: const Text('Upload Attack Code'),
                ),
              ),
              if (appState.uploadedAttackCode != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Colors.orange,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Attack code uploaded successfully',
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildPreviewSection() {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return CyberCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Code Preview',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              if (appState.uploadedEncryptionCode != null ||
                  appState.uploadedAttackCode != null) ...[
                DefaultTabController(
                  length: 2,
                  child: Column(
                    children: [
                      const TabBar(
                        labelColor: Color(0xFF00FF41),
                        unselectedLabelColor: Colors.grey,
                        indicatorColor: Color(0xFF00FF41),
                        tabs: [
                          Tab(text: 'Encryption'),
                          Tab(text: 'Attack'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 400,
                        child: TabBarView(
                          children: [
                            CodeViewer(
                              code: appState.uploadedEncryptionCode ??
                                  'No encryption code uploaded',
                            ),
                            CodeViewer(
                              code: appState.uploadedAttackCode ??
                                  'No attack code uploaded',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A0A0A),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.grey.withOpacity(0.3),
                    ),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.code,
                          size: 48,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Upload code to preview',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Future<void> _uploadFile(bool isEncryption) async {
    setState(() {
      _isUploading = true;
    });

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['dart'],
      );

      if (result != null) {
        PlatformFile file = result.files.first;
        if (file.bytes != null) {
          String content = String.fromCharCodes(file.bytes!);
          
          // Validate file content
          if (_validateDartFile(content, isEncryption)) {
            if (isEncryption) {
              Provider.of<AppState>(context, listen: false)
                  .setUploadedEncryptionCode(content);
            } else {
              Provider.of<AppState>(context, listen: false)
                  .setUploadedAttackCode(content);
            }
            
            _showSuccessSnackBar(isEncryption ? 'Encryption' : 'Attack');
          } else {
            _showErrorSnackBar('Invalid Dart file format');
          }
        }
      }
    } catch (e) {
      _showErrorSnackBar('Failed to upload file: $e');
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  bool _validateDartFile(String content, bool isEncryption) {
    // Basic validation - check for class definition and required methods
    if (isEncryption) {
      return content.contains('class') && 
             (content.contains('encrypt') || content.contains('decrypt'));
    } else {
      return content.contains('class') && content.contains('attack');
    }
  }

  void _showSuccessSnackBar(String type) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$type code uploaded successfully'),
        backgroundColor: const Color(0xFF00FF41),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
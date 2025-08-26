import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../services/encryption_service.dart';
import '../services/attack_service.dart';
import '../services/benchmark_service.dart';
import '../widgets/cyber_card.dart';
import '../widgets/simulation_visualizer.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  final TextEditingController _messageController = TextEditingController();
  String _encryptedMessage = '';
  String _decryptedMessage = '';
  List<String> _simulationLogs = [];
  bool _isRunningSimulation = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

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
                  flex: 2,
                  child: _buildTestConfiguration(),
                ),
                const SizedBox(width: 24),
                Expanded(
                  flex: 3,
                  child: _buildSimulationArea(),
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
          'Test Code',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFF00FF41),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Run encryption and attack simulations with multi-agent testing',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[400],
          ),
        ),
      ],
    );
  }

  Widget _buildTestConfiguration() {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return Column(
          children: [
            CyberCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Configuration',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Encryption Algorithm Selection
                  _buildDropdown(
                    'Encryption Algorithm',
                    appState.selectedEncryption,
                    appState.encryptionOptions,
                    (value) => appState.setSelectedEncryption(value!),
                    Icons.lock,
                  ),
                  const SizedBox(height: 20),
                  
                  // Attack Type Selection
                  _buildDropdown(
                    'Attack Type',
                    appState.selectedAttack,
                    appState.attackOptions,
                    (value) => appState.setSelectedAttack(value!),
                    Icons.warning,
                  ),
                  const SizedBox(height: 20),
                  
                  // Message Input
                  TextField(
                    controller: _messageController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: 'Test Message',
                      labelStyle: const TextStyle(color: Color(0xFF00FF41)),
                      hintText: 'Enter your message to encrypt and test...',
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF00FF41)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[600]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF00FF41)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Run Test Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isRunningSimulation || _messageController.text.isEmpty
                          ? null
                          : _runSimulation,
                      icon: _isRunningSimulation
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(Colors.black),
                              ),
                            )
                          : const Icon(Icons.play_arrow),
                      label: Text(
                        _isRunningSimulation ? 'Running Simulation...' : 'Run Simulation',
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Results Display
            if (_encryptedMessage.isNotEmpty || _decryptedMessage.isNotEmpty)
              CyberCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Results',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    if (_encryptedMessage.isNotEmpty) ...[
                      _buildResultItem('Encrypted:', _encryptedMessage, Colors.orange),
                      const SizedBox(height: 12),
                    ],
                    
                    if (_decryptedMessage.isNotEmpty) ...[
                      _buildResultItem('Decrypted:', _decryptedMessage, const Color(0xFF00FF41)),
                      const SizedBox(height: 12),
                    ],
                    
                    // Verification
                    if (_decryptedMessage.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: (_decryptedMessage == _messageController.text
                              ? const Color(0xFF00FF41)
                              : Colors.red).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _decryptedMessage == _messageController.text
                                  ? Icons.check_circle
                                  : Icons.error,
                              color: _decryptedMessage == _messageController.text
                                  ? const Color(0xFF00FF41)
                                  : Colors.red,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _decryptedMessage == _messageController.text
                                  ? 'Encryption/Decryption Successful'
                                  : 'Encryption/Decryption Failed',
                              style: TextStyle(
                                color: _decryptedMessage == _messageController.text
                                    ? const Color(0xFF00FF41)
                                    : Colors.red,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildSimulationArea() {
    return Column(
      children: [
        CyberCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Multi-Agent Simulation',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 300,
                child: SimulationVisualizer(
                  isRunning: _isRunningSimulation,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        
        // Simulation Logs
        CyberCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Simulation Logs',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: _clearLogs,
                    icon: const Icon(
                      Icons.clear,
                      color: Colors.grey,
                      size: 20,
                    ),
                    tooltip: 'Clear logs',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF0A0A0A),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[800]!),
                ),
                child: _simulationLogs.isEmpty
                    ? const Center(
                        child: Text(
                          'No simulation logs yet',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: _simulationLogs.length,
                        itemBuilder: (context, index) {
                          final log = _simulationLogs[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Text(
                              log,
                              style: TextStyle(
                                color: _getLogColor(log),
                                fontSize: 12,
                                fontFamily: 'monospace',
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(
    String label,
    String value,
    List<String> options,
    void Function(String?) onChanged,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: const Color(0xFF00FF41)),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00FF41),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          onChanged: onChanged,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
          ),
          dropdownColor: const Color(0xFF1A1A1A),
          items: options.map((String option) {
            return DropdownMenuItem<String>(
              value: option,
              child: Text(option),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildResultItem(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF0A0A0A),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontFamily: 'monospace',
            ),
          ),
        ),
      ],
    );
  }

  Color _getLogColor(String log) {
    if (log.contains('ERROR') || log.contains('FAILED')) return Colors.red;
    if (log.contains('SUCCESS') || log.contains('COMPLETED')) return const Color(0xFF00FF41);
    if (log.contains('WARNING')) return Colors.orange;
    if (log.contains('INFO')) return Colors.cyan;
    return Colors.grey;
  }

  void _clearLogs() {
    setState(() {
      _simulationLogs.clear();
    });
  }

  Future<void> _runSimulation() async {
    if (_messageController.text.isEmpty) return;

    setState(() {
      _isRunningSimulation = true;
      _simulationLogs.clear();
      _encryptedMessage = '';
      _decryptedMessage = '';
    });

    final appState = Provider.of<AppState>(context, listen: false);
    final encryptionService = Provider.of<EncryptionService>(context, listen: false);
    final attackService = Provider.of<AttackService>(context, listen: false);
    final benchmarkService = Provider.of<BenchmarkService>(context, listen: false);

    try {
      // Start benchmark
      final stopwatch = Stopwatch()..start();
      
      _addLog('INFO: Starting simulation...');
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Encryption phase
      _addLog('INFO: Encrypting message with ${appState.selectedEncryption}...');
      final encryptionResult = await encryptionService.encrypt(
        _messageController.text,
        appState.selectedEncryption,
        appState.uploadedEncryptionCode,
      );
      
      setState(() {
        _encryptedMessage = encryptionResult;
      });
      
      final encryptionTime = stopwatch.elapsedMilliseconds.toDouble();
      _addLog('SUCCESS: Message encrypted in ${encryptionTime}ms');
      
      // Multi-agent transmission simulation
      _addLog('INFO: Simulating multi-agent transmission...');
      await _simulateMultiAgentTransmission(encryptionResult);
      
      // Attack simulation
      _addLog('INFO: Launching ${appState.selectedAttack} attack...');
      final attackResult = await attackService.executeAttack(
        appState.selectedAttack,
        encryptionResult,
        appState.uploadedAttackCode,
      );
      
      if (attackResult.success) {
        _addLog('WARNING: Attack succeeded! Security vulnerability detected.');
      } else {
        _addLog('SUCCESS: Attack failed. Encryption held strong.');
      }
      
      // Decryption phase
      stopwatch.reset();
      _addLog('INFO: Decrypting message...');
      final decryptedResult = await encryptionService.decrypt(
        encryptionResult,
        appState.selectedEncryption,
        appState.uploadedEncryptionCode,
      );
      
      setState(() {
        _decryptedMessage = decryptedResult;
      });
      
      final decryptionTime = stopwatch.elapsedMilliseconds.toDouble();
      _addLog('SUCCESS: Message decrypted in ${decryptionTime}ms');
      
      // Generate benchmark results
      final benchmarkResult = BenchmarkResult(
        encryptionAlgorithm: appState.selectedEncryption,
        attackType: appState.selectedAttack,
        encryptionTime: encryptionTime,
        decryptionTime: decryptionTime,
        transmissionSpeed: 1000.0, // Simulated
        dataLossRate: 0.0, // Simulated
        attackSuccessRate: attackResult.success ? 100.0 : 0.0,
        securityScore: benchmarkService.calculateSecurityScore(
          encryptionTime,
          decryptionTime,
          attackResult.success ? 100.0 : 0.0,
        ),
        timestamp: DateTime.now(),
      );
      
      appState.addBenchmarkResult(benchmarkResult);
      _addLog('INFO: Benchmark results saved');
      
    } catch (e) {
      _addLog('ERROR: Simulation failed: $e');
    } finally {
      setState(() {
        _isRunningSimulation = false;
      });
    }
  }

  Future<void> _simulateMultiAgentTransmission(String encryptedData) async {
    final agents = ['Agent A', 'Agent B', 'Agent C', 'Destination'];
    
    for (int i = 0; i < agents.length - 1; i++) {
      await Future.delayed(const Duration(milliseconds: 300));
      _addLog('INFO: ${agents[i]} -> ${agents[i + 1]}: Transmitting data...');
      
      // Simulate random delays and potential issues
      if (DateTime.now().millisecondsSinceEpoch % 7 == 0) {
        _addLog('WARNING: Minor packet delay detected');
        await Future.delayed(const Duration(milliseconds: 200));
      }
      
      if (DateTime.now().millisecondsSinceEpoch % 13 == 0) {
        _addLog('WARNING: Network congestion - retransmitting...');
        await Future.delayed(const Duration(milliseconds: 150));
      }
    }
    
    _addLog('SUCCESS: Data successfully transmitted through all agents');
  }

  void _addLog(String message) {
    setState(() {
      _simulationLogs.add('[${DateTime.now().toIso8601String().substring(11, 19)}] $message');
    });
  }
}
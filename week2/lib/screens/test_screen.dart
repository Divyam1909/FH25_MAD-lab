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
        final disableCustomEnc = appState.uploadedEncryptionCode == null;
        final disableCustomAtk = appState.uploadedAttackCode == null;
        final disabledEnc = disableCustomEnc ? {'Custom'} : const <String>{};
        final disabledAtk = disableCustomAtk ? {'Custom'} : const <String>{};
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
                    appState.selectedEncryptionLabel,
                    appState.encryptionOptionLabels,
                    (value) => appState.setSelectedEncryption(value!),
                    Icons.lock,
                    disabledOptions: disabledEnc,
                  ),
                  const SizedBox(height: 20),
                  
                  // Attack Type Selection
                  _buildDropdown(
                    'Attack Type',
                    appState.selectedAttackLabel,
                    appState.attackOptionLabels,
                    (value) => appState.setSelectedAttack(value!),
                    Icons.warning,
                    disabledOptions: disabledAtk,
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
                          : const Icon(Icons.play_arrow_rounded),
                      label: Text(_isRunningSimulation ? 'Running...' : 'Run Simulation'),
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
          child: SimulationVisualizer(
            isRunning: _isRunningSimulation,
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
    IconData icon, {
    Set<String> disabledOptions = const <String>{},
  }) {
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
            final enabled = !disabledOptions.contains(option);
            return DropdownMenuItem<String>(
              value: option,
              enabled: enabled,
              child: Row(
                children: [
                  Text(option),
                  if (!enabled) ...[
                    const SizedBox(width: 6),
                    const Icon(Icons.lock, size: 14, color: Colors.grey),
                  ]
                ],
              ),
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

    final appState = Provider.of<AppState>(context, listen: false);
    if (appState.selectedEncryptionLabel == 'Custom' && appState.uploadedEncryptionCode == null) {
      _addLog('ERROR: Custom encryption selected but no code uploaded.');
      return;
    }
    if (appState.selectedAttackLabel == 'Custom' && appState.uploadedAttackCode == null) {
      _addLog('ERROR: Custom attack selected but no code uploaded.');
      return;
    }

    setState(() {
      _isRunningSimulation = true;
      _simulationLogs.clear();
      _encryptedMessage = '';
      _decryptedMessage = '';
    });

    final encryptionService = Provider.of<EncryptionService>(context, listen: false);
    final attackService = Provider.of<AttackService>(context, listen: false);
    final benchmarkService = Provider.of<BenchmarkService>(context, listen: false);

    try {
      // Start benchmark
      final stopwatch = Stopwatch()..start();
      
      _addLog('INFO: Starting simulation...');
      await Future.delayed(const Duration(milliseconds: 300));
      
      // Encryption phase
      _addLog('INFO: Encrypting message with ${appState.selectedEncryptionLabel}...');
      final encryptionResult = await encryptionService.encrypt(
        _messageController.text,
        appState.selectedEncryptionLabel,
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
      _addLog('INFO: Launching ${appState.selectedAttackLabel} attack...');
      final attackResult = await attackService.executeAttack(
        appState.selectedAttackLabel,
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
        appState.selectedEncryptionLabel,
        appState.uploadedEncryptionCode,
      );
      
      setState(() {
        _decryptedMessage = decryptedResult;
      });
      
      final decryptionTime = stopwatch.elapsedMilliseconds.toDouble();
      _addLog('SUCCESS: Message decrypted in ${decryptionTime}ms');
      
      // Generate benchmark results
      final benchmarkResult = BenchmarkResult(
        encryptionAlgorithm: appState.selectedEncryptionLabel,
        attackType: appState.selectedAttackLabel,
        encryptionTime: encryptionTime,
        decryptionTime: decryptionTime,
        transmissionSpeed: 1000.0,
        dataLossRate: 0.0,
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
    final path = [
      {'from': 'Client', 'to': 'Gateway'},
      {'from': 'Gateway', 'to': 'Edge Node'},
      {'from': 'Edge Node', 'to': 'Core Router'},
      {'from': 'Core Router', 'to': 'Destination'},
    ];

    // 1) Session setup (TLS-like handshake logs)
    _addLog('INFO: Initiating session setup (Client -> Gateway)');
    await Future.delayed(const Duration(milliseconds: 250));
    _addLog('INFO: Client: ClientHello (cipher_suites=[TLS_AES_256_GCM_SHA384,...])');
    await Future.delayed(const Duration(milliseconds: 200));
    _addLog('INFO: Gateway: ServerHello + Certificate + KeyShare');
    await Future.delayed(const Duration(milliseconds: 200));
    _addLog('INFO: Client: Verify Certificate, Key Agreement, Finished');
    await Future.delayed(const Duration(milliseconds: 200));
    _addLog('SUCCESS: Secure session established');

    // 2) Fragmentation + checksums + retransmits
    final mtu = 512;
    final chunks = <String>[];
    for (int i = 0; i < encryptedData.length; i += mtu) {
      final end = (i + mtu < encryptedData.length) ? i + mtu : encryptedData.length;
      chunks.add(encryptedData.substring(i, end));
    }
    _addLog('INFO: Fragmented payload into ${chunks.length} chunks (MTU=$mtu)');

    int seq = 0;
    for (final hop in path) {
      _addLog('INFO: ${hop['from']} -> ${hop['to']}: Link up, measuring latency and jitter');
      await Future.delayed(const Duration(milliseconds: 150));

      for (final chunk in chunks) {
        seq++;
        final checksum = chunk.codeUnits.fold<int>(0, (a, b) => (a + b) & 0xFFFF);
        _addLog('TX ${hop['from']} -> ${hop['to']} [SEQ=$seq, LEN=${chunk.length}, CRC=$checksum]');
        await Future.delayed(const Duration(milliseconds: 80));

        // Random network behaviors
        final now = DateTime.now().millisecondsSinceEpoch;
        if (now % 11 == 0) {
          _addLog('WARNING: ${hop['to']} ACK timeout for SEQ=$seq, scheduling retransmission');
          await Future.delayed(const Duration(milliseconds: 120));
          _addLog('TX RETRY ${hop['from']} -> ${hop['to']} [SEQ=$seq]');
        }
        if (now % 17 == 0) {
          _addLog('WARNING: Packet loss detected for SEQ=$seq, invoking fast retransmit');
          await Future.delayed(const Duration(milliseconds: 100));
          _addLog('TX FAST-RETX ${hop['from']} -> ${hop['to']} [SEQ=$seq]');
        }
        _addLog('RX ${hop['to']}: ACK SEQ=$seq');
      }

      _addLog('INFO: ${hop['to']}: Reassembly and integrity verification');
      await Future.delayed(const Duration(milliseconds: 200));
      _addLog('SUCCESS: ${hop['to']}: Payload verified, forwarding to next hop');
    }

    // 3) Destination side processing
    _addLog('INFO: Destination: Queuing payload for decryption pipeline');
    await Future.delayed(const Duration(milliseconds: 200));
    _addLog('SUCCESS: End-to-end delivery completed');
  }

  void _addLog(String message) {
    setState(() {
      _simulationLogs.add('[${DateTime.now().toIso8601String().substring(11, 19)}] $message');
    });
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/app_state.dart';
import '../services/benchmark_service.dart';
import '../widgets/cyber_card.dart';

class MetricsScreen extends StatelessWidget {
  const MetricsScreen({super.key});

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
            Consumer<AppState>(
              builder: (context, appState, child) {
                if (appState.benchmarkResults.isEmpty) {
                  return _buildEmptyState();
                }
                return _buildMetricsContent(appState, context);
              },
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
          'Metrics & Analytics',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFF00FF41),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Comprehensive analysis of encryption performance and security metrics',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[400],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: CyberCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 64,
              color: Colors.grey[600],
            ),
            const SizedBox(height: 16),
            Text(
              'No Test Data Available',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Run simulations to generate performance and security metrics.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsContent(AppState appState, BuildContext context) {
    final results = appState.benchmarkResults;
    final benchmarkService = Provider.of<BenchmarkService>(context, listen: false);

    final report = _buildReport(results, benchmarkService);

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildSummaryCard('Avg Security Score', '${report.averageSecurityScore.toInt()}%', Icons.security, Colors.blue)),
            const SizedBox(width: 16),
            Expanded(child: _buildSummaryCard('Avg Throughput', '${report.averageThroughput.toStringAsFixed(2)} B/s', Icons.speed, Colors.orange)),
            const SizedBox(width: 16),
            Expanded(child: _buildSummaryCard('Avg Latency', '${report.averageLatency.toStringAsFixed(2)} ms', Icons.timer, Colors.purple)),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildPerformanceChart(results)),
            const SizedBox(width: 16),
            Expanded(child: _buildSecurityScoreChart(results)),
          ],
        ),
        const SizedBox(height: 24),
        _buildRiskAssessment(results, benchmarkService),
        const SizedBox(height: 24),
        _buildResultsTable(results),
      ],
    );
  }

  _Report _buildReport(List<AdvancedBenchmarkResult> results, BenchmarkService benchmarkService) {
    if (results.isEmpty) return _Report.empty();

    final avgSec = results.map((r) => r.securityMetrics.overallSecurityScore).reduce((a, b) => a + b) / results.length;
    final avgThroughput = results.map((r) => r.performanceMetrics.throughput).reduce((a, b) => a + b) / results.length;
    final avgLatency = results.map((r) => r.performanceMetrics.latency).reduce((a, b) => a + b) / results.length;

    return _Report(
      averageSecurityScore: avgSec,
      averageThroughput: avgThroughput,
      averageLatency: avgLatency,
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return CyberCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceChart(List<AdvancedBenchmarkResult> results) {
    final encSeries = results.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.encryptionResult.encryptionTime));
    final decSeries = results.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.performanceMetrics.latency));

    return CyberCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Performance Over Time',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 300,
            child: LineChart(
              LineChartData(
                lineBarsData: [
                  LineChartBarData(
                    spots: encSeries.toList(),
                    color: const Color(0xFF00FF41),
                    isCurved: true,
                    barWidth: 2,
                    dotData: const FlDotData(show: false),
                  ),
                  LineChartBarData(
                    spots: decSeries.toList(),
                    color: Colors.orange,
                    isCurved: true,
                    barWidth: 2,
                    dotData: const FlDotData(show: false),
                  ),
                ],
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      getTitlesWidget: (value, meta) => Text('#${value.toInt()}', style: const TextStyle(fontSize: 10)),
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (value, meta) => Text(value.toInt().toString(), style: const TextStyle(fontSize: 10)),
                    ),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.withOpacity(0.2),
                      strokeWidth: 1,
                    );
                  },
                ),
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('Encryption', const Color(0xFF00FF41)),
              const SizedBox(width: 20),
              _buildLegendItem('Decryption', Colors.orange),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityScoreChart(List<AdvancedBenchmarkResult> results) {
    return CyberCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Security Scores',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 300,
            child: PieChart(
              PieChartData(
                sections: results.asMap().entries.map((entry) {
                  final colors = [
                    const Color(0xFF00FF41),
                    Colors.blue,
                    Colors.orange,
                    Colors.purple,
                    Colors.red,
                    Colors.yellow,
                  ];
                  final score = entry.value.securityMetrics.overallSecurityScore;
                  return PieChartSectionData(
                    value: score,
                    title: '${score.toInt()}%',
                    color: colors[entry.key % colors.length],
                    radius: 50,
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                }).toList(),
                centerSpaceRadius: 40,
                sectionsSpace: 2,
              ),
            ),
          ),
          const SizedBox(height: 16),
          ...results.asMap().entries.map((entry) {
            final colors = [
              const Color(0xFF00FF41),
              Colors.blue,
              Colors.orange,
              Colors.purple,
              Colors.red,
              Colors.yellow,
            ];
            final score = entry.value.securityMetrics.overallSecurityScore;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(width: 12, height: 12, color: colors[entry.key % colors.length]),
                  const SizedBox(width: 8),
                  Text('Result #${entry.key + 1}: ${score.toInt()}%'),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildRiskAssessment(List<AdvancedBenchmarkResult> results, BenchmarkService benchmarkService) {
    final highRiskCount = results.where((r) => r.securityMetrics.overallSecurityScore < 70).length;
    final mediumRiskCount = results.where((r) => r.securityMetrics.overallSecurityScore >= 70 && r.securityMetrics.overallSecurityScore < 85).length;
    final lowRiskCount = results.where((r) => r.securityMetrics.overallSecurityScore >= 85).length;

    return CyberCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Risk Assessment',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildRiskBadge('HIGH RISK', highRiskCount, Colors.red),
              const SizedBox(width: 12),
              _buildRiskBadge('MEDIUM RISK', mediumRiskCount, Colors.orange),
              const SizedBox(width: 12),
              _buildRiskBadge('LOW RISK', lowRiskCount, const Color(0xFF00FF41)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRiskBadge(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text('$label: $count', style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildResultsTable(List<AdvancedBenchmarkResult> results) {
    return CyberCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Detailed Results',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Algorithm')),
                DataColumn(label: Text('Security Level')),
                DataColumn(label: Text('Attack Type')),
                DataColumn(label: Text('Enc Time (ms)')),
                DataColumn(label: Text('Latency (ms)')),
                DataColumn(label: Text('Throughput (B/s)')),
                DataColumn(label: Text('Security Score')),
                DataColumn(label: Text('Timestamp')),
              ],
              rows: results.map((r) {
                return DataRow(cells: [
                  DataCell(Text(r.cryptoParameters.algorithm.name)),
                  DataCell(Text(r.cryptoParameters.securityLevel.name)),
                  DataCell(Text(r.attackParameters.attackType.name)),
                  DataCell(Text(r.encryptionResult.encryptionTime.toStringAsFixed(2))),
                  DataCell(Text(r.performanceMetrics.latency.toStringAsFixed(2))),
                  DataCell(Text(r.performanceMetrics.throughput.toStringAsFixed(2))),
                  DataCell(Text(r.securityMetrics.overallSecurityScore.toStringAsFixed(2))),
                  DataCell(Text(r.timestamp.toIso8601String())),
                ]);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _Report {
  final double averageSecurityScore;
  final double averageThroughput;
  final double averageLatency;

  _Report({required this.averageSecurityScore, required this.averageThroughput, required this.averageLatency});

  factory _Report.empty() => _Report(averageSecurityScore: 0, averageThroughput: 0, averageLatency: 0);
}
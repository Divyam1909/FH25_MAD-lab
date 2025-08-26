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
              'Run some encryption tests to see detailed metrics and analysis',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsContent(AppState appState, BuildContext context) {
    final benchmarkService = Provider.of<BenchmarkService>(context);
    final report = benchmarkService.generateReport(appState.benchmarkResults);

    return Column(
      children: [
        // Summary Cards
        Row(
          children: [
            Expanded(child: _buildSummaryCard('Total Tests', '${report.totalTests}', Icons.quiz, const Color(0xFF00FF41))),
            const SizedBox(width: 16),
            Expanded(child: _buildSummaryCard('Avg Security Score', '${report.averageSecurityScore.toInt()}%', Icons.security, Colors.blue)),
            const SizedBox(width: 16),
            Expanded(child: _buildSummaryCard('Avg Attack Rate', '${report.averageAttackSuccessRate.toInt()}%', Icons.warning, Colors.orange)),
            const SizedBox(width: 16),
            Expanded(child: _buildSummaryCard('Best Algorithm', report.bestSecurityAlgorithm, Icons.star, Colors.yellow)),
          ],
        ),
        const SizedBox(height: 32),

        // Charts Section
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: _buildPerformanceChart(appState.benchmarkResults),
            ),
            const SizedBox(width: 24),
            Expanded(
              flex: 1,
              child: _buildSecurityScoreChart(appState.benchmarkResults),
            ),
          ],
        ),
        const SizedBox(height: 32),

        // Detailed Analysis
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildAlgorithmAnalysis(benchmarkService),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: _buildRecommendations(report),
            ),
          ],
        ),
        const SizedBox(height: 32),

        // Risk Assessment
        _buildRiskAssessment(appState.benchmarkResults, benchmarkService),
        const SizedBox(height: 32),

        // Detailed Results Table
        _buildResultsTable(appState.benchmarkResults),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return CyberCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[400],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceChart(List<BenchmarkResult> results) {
    return CyberCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Performance Comparison',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 300,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: results.map((r) => r.encryptionTime).reduce((a, b) => a > b ? a : b) * 1.2,
                barGroups: results.asMap().entries.map((entry) {
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value.encryptionTime,
                        color: const Color(0xFF00FF41),
                        width: 16,
                      ),
                      BarChartRodData(
                        toY: entry.value.decryptionTime,
                        color: Colors.orange,
                        width: 16,
                      ),
                    ],
                  );
                }).toList(),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}ms',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() < results.length) {
                          return Text(
                            results[value.toInt()].encryptionAlgorithm.substring(0, 3),
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 10,
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
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

  Widget _buildSecurityScoreChart(List<BenchmarkResult> results) {
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
                  return PieChartSectionData(
                    value: entry.value.securityScore,
                    title: '${entry.value.securityScore.toInt()}%',
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
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: colors[entry.key % colors.length],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      entry.value.encryptionAlgorithm,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[400],
                      ),
                    ),
                  ),
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
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[400],
          ),
        ),
      ],
    );
  }

  Widget _buildAlgorithmAnalysis(BenchmarkService benchmarkService) {
    return CyberCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Algorithm Analysis',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildAnalysisItem('Fastest Encryption', 'AES-256', const Color(0xFF00FF41)),
          _buildAnalysisItem('Most Secure', 'RSA-4096', Colors.blue),
          _buildAnalysisItem('Best Balance', 'ChaCha20', Colors.orange),
          _buildAnalysisItem('Memory Efficient', 'Salsa20', Colors.purple),
          const SizedBox(height: 16),
          Text(
            'Performance Insights:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey[300],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '• Symmetric algorithms show 10x faster performance\n'
            '• Key size directly impacts security score\n'
            '• Modern algorithms balance speed and security',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[400],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisItem(String title, String algorithm, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            color: color,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[400],
                  ),
                ),
                Text(
                  algorithm,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendations(dynamic report) {
    return CyberCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Security Recommendations',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildRecommendationItem(
            Icons.security,
            'High Priority',
            'Implement key rotation every 90 days',
            Colors.red,
          ),
          _buildRecommendationItem(
            Icons.speed,
            'Performance',
            'Consider hardware acceleration for AES',
            Colors.orange,
          ),
          _buildRecommendationItem(
            Icons.shield,
            'Best Practice',
            'Use authenticated encryption modes',
            Colors.green,
          ),
          _buildRecommendationItem(
            Icons.update,
            'Maintenance',
            'Update cryptographic libraries regularly',
            Colors.blue,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info, color: Colors.blue, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Overall security posture: Strong with room for improvement',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[300],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationItem(IconData icon, String category, String recommendation, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  recommendation,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[400],
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskAssessment(List<BenchmarkResult> results, BenchmarkService benchmarkService) {
    final highRiskCount = results.where((r) => r.securityScore < 70).length;
    final mediumRiskCount = results.where((r) => r.securityScore >= 70 && r.securityScore < 85).length;
    final lowRiskCount = results.where((r) => r.securityScore >= 85).length;

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
              Expanded(
                child: _buildRiskItem('High Risk', highRiskCount, Colors.red),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildRiskItem('Medium Risk', mediumRiskCount, Colors.orange),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildRiskItem('Low Risk', lowRiskCount, Colors.green),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: lowRiskCount / results.length,
            backgroundColor: Colors.grey.withOpacity(0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00FF41)),
          ),
          const SizedBox(height: 8),
          Text(
            'Security Coverage: ${(lowRiskCount / results.length * 100).toInt()}%',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskItem(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            '$count',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsTable(List<BenchmarkResult> results) {
    return CyberCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Detailed Test Results',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: MaterialStateProperty.all(Colors.grey.withOpacity(0.1)),
              columns: const [
                DataColumn(
                  label: Text(
                    'Algorithm',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Encryption (ms)',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Decryption (ms)',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Security Score',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Status',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
              rows: results.map((result) {
                Color statusColor = result.securityScore >= 85
                    ? Colors.green
                    : result.securityScore >= 70
                        ? Colors.orange
                        : Colors.red;

                String status = result.securityScore >= 85
                    ? 'Excellent'
                    : result.securityScore >= 70
                        ? 'Good'
                        : 'Needs Improvement';

                return DataRow(
                  cells: [
                    DataCell(Text(result.encryptionAlgorithm)),
                    DataCell(Text('${result.encryptionTime.toStringAsFixed(2)}')),
                    DataCell(Text('${result.decryptionTime.toStringAsFixed(2)}')),
                    DataCell(
                      Text(
                        '${result.securityScore.toInt()}%',
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: statusColor.withOpacity(0.3)),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
void main() => runApp(const MyApp());
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        fontFamily: 'Arial',
      ),
      home: const VisualElementsScreen(),
    );
  }
}
class VisualElementsScreen extends StatefulWidget {
  const VisualElementsScreen({super.key});
  @override
  State<VisualElementsScreen> createState() => _VisualElementsScreenState();
}
class _VisualElementsScreenState extends State<VisualElementsScreen> {
  int _selectedIconIndex = -1;
  int _touchedIndex = -1;
  int _datasetIndex = 0; // 0 = weekly, 1 = monthly
  // Example datasets
  final List<double> _weeklyData = [8, 10, 14, 15, 13];
  final List<double> _monthlyData = [6, 9, 12, 8, 10, 14, 11, 13, 9, 12, 10, 15];
  List<double> get activeData => _datasetIndex == 0 ? _weeklyData : _monthlyData;
  // Bottom labels for the datasets
  Widget _buildBottomTitle(double value, TitleMeta meta) {
    final int index = value.toInt();
    final style = const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12);
    String text;
    if (_datasetIndex == 0) {
      // Weekly: M T W T F
      switch (index) {
        case 0:
          text = 'M';
          break;
        case 1:
          text = 'T';
          break;
        case 2:
          text = 'W';
          break;
        case 3:
          text = 'T';
          break;
        case 4:
          text = 'F';
          break;
        default:
          text = '';
      }
    } else {
      // Monthly: show 1,5,10... or simple month index
      text = (index + 1).toString();
    }
    return SideTitleWidget(axisSide: meta.axisSide, child: Text(text, style: style));
  }
  List<BarChartGroupData> _makeBarGroups() {
    final data = activeData;
    return List.generate(data.length, (i) {
      final isTouched = i == _touchedIndex;
      final color = isTouched ? Colors.tealAccent : Colors.teal;
      final double height = data[i];
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: height,
            color: color,
            width: isTouched ? 18 : 12,
            borderRadius: BorderRadius.circular(6),
            backDrawRodData: BackgroundBarChartRodData(show: true, toY: 20, color: Colors.white10),
          ),
        ],
      );
    });
  }
  void _onBarTouch(BarTouchResponse? touch) {
    setState(() {
      if (touch == null || touch.spot == null) {
        _touchedIndex = -1;
        return;
      }
      final touched = touch.spot!.touchedBarGroupIndex;
      // On long press/drag we still handle null values gracefully
      _touchedIndex = touched;
      // Optionally show a small ephemeral SnackBar when user touches a bar:
ScaffoldMessenger.of(context).hideCurrentSnackBar();
ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Value: ${activeData[touched]}'),
          duration: const Duration(milliseconds: 800),
          behavior: SnackBarBehavior.floating,
        ),
      );
    });
  }
  void _onIconTap(int idx) {
    setState(() {
      if (_selectedIconIndex == idx) {
        _selectedIconIndex = -1; // toggle off
      } else {
        _selectedIconIndex = idx;
      }
    });
    // Provide feedback / action for each icon
    switch (idx) {
      case 0:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Home tapped')),
        );
        break;
      case 1:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Settings tapped')),
        );
        break;
      case 2:
ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Favorites tapped')),
        );
        break;
      case 3:
ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Camera tapped')),
        );
        break;
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Icons, Images & Interactive Charts'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ToggleButtons(
              isSelected: [_datasetIndex == 0, _datasetIndex == 1],
              onPressed: (i) => setState(() => _datasetIndex = i),
              borderRadius: BorderRadius.circular(8),
              selectedColor: Colors.white,
              fillColor: Colors.teal,
              children: const [
                Padding(padding: EdgeInsets.symmetric(horizontal: 12.0), child: Text('Weekly')),
                Padding(padding: EdgeInsets.symmetric(horizontal: 12.0), child: Text('Monthly')),
              ],
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('1. Interactive Icons', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(4, (i) {
                  final icons = [Icons.home, Icons.settings, Icons.favorite, Icons.camera_alt];
                  final labels = ['Home', 'Settings', 'Favorites', 'Camera'];
                  final colors = [Colors.teal, Colors.blueGrey, Colors.red, Colors.orange];
                  final isSelected = _selectedIconIndex == i;
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkResponse(
                        onTap: () => _onIconTap(i),
                        borderRadius: BorderRadius.circular(30),
                        radius: 28,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isSelected ? colors[i].withOpacity(0.15) : Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(icons[i], color: colors[i], size: isSelected ? 36 : 28),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(labels[i], style: TextStyle(fontSize: isSelected ? 13 : 11, color: isSelected ? Colors.black : Colors.grey)),
                    ],
                  );
                }),
              ),
            ),
          ),
          const SizedBox(height: 30),
          const Text('2. Images', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildImageCard(
                'Local Asset Image',
                Image.asset('assets/images/flutter_logo.png', height: 100, width: 100, fit: BoxFit.contain),
              ),
              _buildImageCard(
                'Network Image',
Image.network('https://picsum.photos/seed/picsum/200', height: 100, width: 100, fit: BoxFit.cover),
              ),
            ],
          ),
          const SizedBox(height: 30),
          const Text('3. Interactive Chart', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          SizedBox(
            height: 320,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(children: [
                  Expanded(
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: (activeData.reduce((a, b) => a > b ? a : b) + 5).toDouble(),
                        barTouchData: BarTouchData(
                          enabled: true,
                          handleBuiltInTouches: true,
                          touchCallback: (event, response) {
                            // respond only on relevant events
                            if (response == null || response.spot == null) {
                              setState(() => _touchedIndex = -1);
                              return;
                            }
                            if (event is FlTapUpEvent || event is FlLongPressEnd || event is FlPanEndEvent) {
                              setState(() => _touchedIndex = response.spot!.touchedBarGroupIndex);
                            } else if (event is FlTapDownEvent || event is FlPanStartEvent || event is FlPanUpdateEvent) {                  setState(() => _touchedIndex = response.spot!.touchedBarGroupIndex);
                            }
                          },
                          touchTooltipData: BarTouchTooltipData(
getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              return BarTooltipItem('${rod.toY.toStringAsFixed(0)}', const TextStyle(color: Colors.white));
                            },
                          ),
                        ),
                        titlesData: FlTitlesData(
                          show: true,
bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: _buildBottomTitle)),
                          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 36)),
                          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        gridData: FlGridData(show: true, drawHorizontalLine: true, horizontalInterval: 5),
                        borderData: FlBorderData(show: false),
                        barGroups: _makeBarGroups(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Dataset: ${_datasetIndex == 0 ? "Weekly" : "Monthly"}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text('Tap bars to inspect', style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                ]),
              ),
            ),
          ),
        ]),
      ),
    );
  }


  Widget _buildImageCard(String title, Image imageWidget) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          SizedBox(height: 8),
          SizedBox(height: 120, width: 120, child: imageWidget),
          Padding(padding: const EdgeInsets.all(8.0), child: Text(title)),
        ],
      ),
    );
  }
}
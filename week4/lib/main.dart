import 'package:flutter/material.dart';

void main() {
  runApp(SustainableLifeApp());
}

class SustainableLifeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EcoTracker Pro',
      theme: ThemeData(
        primarySwatch: Colors.green,
        primaryColor: Colors.green[600],
        scaffoldBackgroundColor: Colors.grey[50],
        cardTheme: CardThemeData(
            elevation: 3,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12))),
      ),
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(),
    HabitsScreen(),
    EnergyScreen(),
    WasteScreen(),
    TrackersScreen(),
    ChallengesScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green[600],
        unselectedItemColor: Colors.grey,
        selectedFontSize: 12,
        unselectedFontSize: 10,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.eco), label: 'Habits'),
          BottomNavigationBarItem(icon: Icon(Icons.bolt), label: 'Energy'),
          BottomNavigationBarItem(icon: Icon(Icons.delete), label: 'Waste'),
          BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'Track'),
          BottomNavigationBarItem(
              icon: Icon(Icons.emoji_events), label: 'Challenges'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

// Enhanced Home Screen with comprehensive dashboard
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int ecoScore = 85;
  String currentStreak = '12 days';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('EcoTracker Pro'),
        backgroundColor: Colors.green[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: Icon(Icons.notifications), onPressed: () {}),
          IconButton(icon: Icon(Icons.settings), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Eco Score Card
            Card(
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                      colors: [Colors.green[400]!, Colors.green[600]!]),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Eco Score',
                            style:
                                TextStyle(color: Colors.white, fontSize: 18)),
                        Text('$ecoScore/100',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold)),
                        Text('Streak: $currentStreak',
                            style:
                                TextStyle(color: Colors.white70, fontSize: 14)),
                      ],
                    ),
                    CircularProgressIndicator(
                      value: ecoScore / 100,
                      backgroundColor: Colors.white30,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 8,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),

            Text('Today\'s Impact',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),

            // Today's metrics
            Row(
              children: [
                Expanded(
                    child: _buildMiniCard(
                        'CO2 Saved', '2.3 kg', Icons.eco, Colors.green)),
                SizedBox(width: 12),
                Expanded(
                    child: _buildMiniCard(
                        'Water Saved', '45 L', Icons.water_drop, Colors.blue)),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                    child: _buildMiniCard('Waste Reduced', '0.8 kg',
                        Icons.delete_outline, Colors.orange)),
                SizedBox(width: 12),
                Expanded(
                    child: _buildMiniCard(
                        'Energy Saved', '8.5 kWh', Icons.bolt, Colors.amber)),
              ],
            ),

            SizedBox(height: 20),
            Text('Quick Actions',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),

            // Quick action grid
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              childAspectRatio: 1.1,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _buildQuickAction(
                    'Water', Icons.water_drop, Colors.blue, () {}),
                _buildQuickAction(
                    'Transport', Icons.directions_bike, Colors.teal, () {}),
                _buildQuickAction('Energy', Icons.bolt, Colors.orange, () {}),
                _buildQuickAction('Waste', Icons.delete, Colors.red, () {}),
                _buildQuickAction(
                    'Meal', Icons.restaurant, Colors.green, () {}),
                _buildQuickAction(
                    'Shopping', Icons.shopping_bag, Colors.purple, () {}),
              ],
            ),

            SizedBox(height: 20),
            Text('Weekly Progress',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            _buildWeeklyChart(),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            SizedBox(height: 4),
            Text(value,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(title,
                style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction(
      String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            SizedBox(height: 4),
            Text(label,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyChart() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                  .map(
                    (day) => Column(
                      children: [
                        Text(day,
                            style: TextStyle(fontSize: 12, color: Colors.grey)),
                        SizedBox(height: 4),
                        Container(
                          width: 20,
                          height: 40 + (day.length % 3) * 20.0,
                          decoration: BoxDecoration(
                            color: Colors.green[400],
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ],
                    ),
                  )
                  .toList(),
            ),
            SizedBox(height: 8),
            Text('Eco Score Trend',
                style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

// Enhanced Energy Screen with detailed tracking
class EnergyScreen extends StatefulWidget {
  @override
  _EnergyScreenState createState() => _EnergyScreenState();
}

class _EnergyScreenState extends State<EnergyScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  // Energy data
  double todayUsage = 45.2;
  double monthlyUsage = 1250.0;
  double solarGenerated = 12.8;
  List<ApplianceUsage> appliances = [
    ApplianceUsage('Air Conditioner', 15.2, Icons.ac_unit, true),
    ApplianceUsage('Refrigerator', 8.5, Icons.kitchen, true),
    ApplianceUsage('Lighting', 6.8, Icons.lightbulb, false),
    ApplianceUsage('TV', 4.2, Icons.tv, false),
    ApplianceUsage('Washing Machine', 3.8, Icons.local_laundry_service, false),
    ApplianceUsage('Computer', 2.1, Icons.computer, true),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Energy Management'),
        backgroundColor: Colors.orange[600],
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(text: 'Overview'),
            Tab(text: 'Appliances'),
            Tab(text: 'Solar'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildAppliancesTab(),
          _buildSolarTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current usage card
          Card(
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                    colors: [Colors.orange[300]!, Colors.orange[500]!]),
              ),
              child: Column(
                children: [
                  Text('Current Usage',
                      style: TextStyle(color: Colors.white, fontSize: 18)),
                  SizedBox(height: 8),
                  Text('${todayUsage.toStringAsFixed(1)} kWh',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold)),
                  Text('Today', style: TextStyle(color: Colors.white70)),
                ],
              ),
            ),
          ),

          SizedBox(height: 16),

          // Usage comparison
          Row(
            children: [
              Expanded(
                child: _buildUsageCard(
                    'This Month',
                    '${monthlyUsage.toInt()} kWh',
                    'vs last month: -5%',
                    Colors.blue,
                    Icons.calendar_month),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildUsageCard(
                    'Cost Estimate',
                    '\$${(monthlyUsage * 0.12).toStringAsFixed(0)}',
                    'This month',
                    Colors.green,
                    Icons.attach_money),
              ),
            ],
          ),

          SizedBox(height: 16),

          // Energy tips
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.tips_and_updates, color: Colors.amber),
                      SizedBox(width: 8),
                      Text('Energy Saving Tips',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SizedBox(height: 12),
                  _buildTip('Set AC to 24°C to save 20% energy'),
                  _buildTip('Use LED bulbs - they consume 80% less energy'),
                  _buildTip('Unplug devices when not in use'),
                  _buildTip('Use natural light during day hours'),
                ],
              ),
            ),
          ),

          SizedBox(height: 16),

          // Peak hours info
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Peak Hours Alert',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('Avoid high energy usage during 6-10 PM to save money',
                      style: TextStyle(color: Colors.orange[700])),
                  SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: 0.7,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                  ),
                  SizedBox(height: 4),
                  Text('Current: Peak Time',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppliancesTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Appliance Usage',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 16),

          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: appliances.length,
            itemBuilder: (context, index) {
              final appliance = appliances[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        appliance.isOn ? Colors.green[100] : Colors.grey[100],
                    child: Icon(appliance.icon,
                        color:
                            appliance.isOn ? Colors.green[600] : Colors.grey),
                  ),
                  title: Text(appliance.name),
                  subtitle:
                      Text('${appliance.usage.toStringAsFixed(1)} kWh today'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('${(appliance.usage / todayUsage * 100).toInt()}%',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(width: 8),
                      Switch(
                        value: appliance.isOn,
                        onChanged: (value) {
                          setState(() {
                            appliance.isOn = value;
                          });
                        },
                        activeColor: Colors.green,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          SizedBox(height: 16),

          // Smart recommendations
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Smart Recommendations',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 12),
                  _buildRecommendation('Turn off AC when leaving',
                      'Save 15.2 kWh', Icons.ac_unit),
                  _buildRecommendation(
                      'Switch to LED lights', 'Save 4.8 kWh', Icons.lightbulb),
                  _buildRecommendation(
                      'Use timer for washing', 'Save 2.1 kWh', Icons.timer),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSolarTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Solar generation card
          Card(
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                    colors: [Colors.yellow[300]!, Colors.orange[400]!]),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Solar Generated',
                            style:
                                TextStyle(color: Colors.white, fontSize: 18)),
                        Text('${solarGenerated.toStringAsFixed(1)} kWh',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold)),
                        Text('Today', style: TextStyle(color: Colors.white70)),
                      ],
                    ),
                  ),
                  Icon(Icons.wb_sunny, color: Colors.white, size: 40),
                ],
              ),
            ),
          ),

          SizedBox(height: 16),

          // Solar vs consumption
          Row(
            children: [
              Expanded(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Icon(Icons.trending_up, color: Colors.green),
                        SizedBox(height: 8),
                        Text('Self Sufficient',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('${(solarGenerated / todayUsage * 100).toInt()}%'),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Icon(Icons.savings, color: Colors.amber),
                        SizedBox(height: 8),
                        Text('Money Saved',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('\$${(solarGenerated * 0.12).toStringAsFixed(1)}'),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 16),

          // Solar panel status
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Panel Status',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 12),
                  _buildPanelStatus('Panel 1', 98, Colors.green),
                  _buildPanelStatus('Panel 2', 95, Colors.green),
                  _buildPanelStatus('Panel 3', 87, Colors.yellow[700]!),
                  _buildPanelStatus('Panel 4', 92, Colors.green),
                ],
              ),
            ),
          ),

          SizedBox(height: 16),

          // Weather impact
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.wb_cloudy, color: Colors.blue),
                      SizedBox(width: 8),
                      Text('Weather Impact',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text('Partly cloudy - 15% reduction in solar output'),
                  SizedBox(height: 8),
                  Text('Tomorrow: Sunny - Expected 18.5 kWh generation',
                      style: TextStyle(color: Colors.green[600])),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsageCard(
      String title, String value, String subtitle, Color color, IconData icon) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color),
            SizedBox(height: 8),
            Text(value,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(title,
                style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            SizedBox(height: 4),
            Text(subtitle, style: TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildTip(String tip) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.circle, size: 6, color: Colors.grey),
          SizedBox(width: 8),
          Expanded(child: Text(tip, style: TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  Widget _buildRecommendation(String action, String saving, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.orange[600]),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(action, style: TextStyle(fontWeight: FontWeight.w500)),
                Text(saving,
                    style: TextStyle(fontSize: 12, color: Colors.green[600])),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildPanelStatus(String panel, int efficiency, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(panel)),
          Expanded(
            flex: 2,
            child: LinearProgressIndicator(
              value: efficiency / 100,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          SizedBox(width: 8),
          Text('$efficiency%', style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// Comprehensive Waste Management Screen
class WasteScreen extends StatefulWidget {
  @override
  _WasteScreenState createState() => _WasteScreenState();
}

class _WasteScreenState extends State<WasteScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  // Waste data
  List<WasteCategory> wasteData = [
    WasteCategory('Plastic', 2.5, 15.2, Colors.red, Icons.local_drink),
    WasteCategory('Paper', 1.8, 12.8, Colors.brown, Icons.description),
    WasteCategory('Organic', 3.2, 18.5, Colors.green, Icons.eco),
    WasteCategory('Metal', 0.8, 4.2, Colors.grey, Icons.hardware),
    WasteCategory('Glass', 1.2, 6.8, Colors.blue, Icons.wine_bar),
    WasteCategory('E-waste', 0.3, 1.5, Colors.purple, Icons.computer),
  ];

  double recyclingRate = 68.5;
  int compostDays = 15;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Waste Management'),
        backgroundColor: Colors.red[600],
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(text: 'Overview'),
            Tab(text: 'Recycling'),
            Tab(text: 'Composting'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildWasteOverview(),
          _buildRecyclingTab(),
          _buildCompostingTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red[600],
        child: Icon(Icons.add, color: Colors.white),
        onPressed: () => _showAddWasteDialog(),
      ),
    );
  }

  Widget _buildWasteOverview() {
    double totalWaste =
        wasteData.fold(0, (sum, item) => sum + item.todayAmount);

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Total waste card
          Card(
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                    colors: [Colors.red[300]!, Colors.red[500]!]),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Total Waste Today',
                            style:
                                TextStyle(color: Colors.white, fontSize: 18)),
                        Text('${totalWaste.toStringAsFixed(1)} kg',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold)),
                        Text('Target: <5kg daily',
                            style: TextStyle(color: Colors.white70)),
                      ],
                    ),
                  ),
                  CircularProgressIndicator(
                    value: (totalWaste / 5.0).clamp(0.0, 1.0),
                    backgroundColor: Colors.white30,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 16),

          // Waste breakdown
          Text('Waste Breakdown',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 12),

          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: wasteData.length,
            itemBuilder: (context, index) {
              final category = wasteData[index];
              return Card(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: category.color.withOpacity(0.1),
                        child: Icon(category.icon, color: category.color),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(category.name,
                                style: TextStyle(fontWeight: FontWeight.w500)),
                            Text(
                                'Today: ${category.todayAmount}kg | Month: ${category.monthlyAmount}kg',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey[600])),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          Text(
                              '${(category.todayAmount / totalWaste * 100).toInt()}%',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Container(
                            width: 40,
                            height: 6,
                            decoration: BoxDecoration(
                              color: category.color,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          SizedBox(height: 16),

          // Waste reduction tips
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.tips_and_updates, color: Colors.green),
                      SizedBox(width: 8),
                      Text('Waste Reduction Tips',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SizedBox(height: 12),
                  _buildWasteTip('Use reusable bags for shopping'),
                  _buildWasteTip('Choose products with minimal packaging'),
                  _buildWasteTip('Repair instead of replacing items'),
                  _buildWasteTip('Donate items you no longer need'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecyclingTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recycling rate card
          Card(
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                    colors: [Colors.green[300]!, Colors.green[500]!]),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Recycling Rate',
                            style:
                                TextStyle(color: Colors.white, fontSize: 18)),
                        Text('${recyclingRate.toStringAsFixed(1)}%',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold)),
                        Text('This month',
                            style: TextStyle(color: Colors.white70)),
                      ],
                    ),
                  ),
                  Icon(Icons.recycling, color: Colors.white, size: 40),
                ],
              ),
            ),
          ),

          SizedBox(height: 16),

          // Recycling centers nearby
          Text('Nearby Recycling Centers',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 12),

          _buildRecyclingCenter('EcoCycle Center', '0.8 km away',
              'Plastic, Paper, Glass', Icons.location_on),
          _buildRecyclingCenter('Green Earth Facility', '1.2 km away',
              'Electronics, Metal', Icons.location_on),
          _buildRecyclingCenter('Community Recycling', '1.8 km away',
              'All materials', Icons.location_on),

          SizedBox(height: 16),

          // Recycling rewards
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Recycling Rewards',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildRewardCard(
                            'Points Earned', '245', Icons.star, Colors.amber),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _buildRewardCard('Items Recycled', '87',
                            Icons.recycling, Colors.green),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      minimumSize: Size(double.infinity, 45),
                    ),
                    child: Text('Redeem Rewards',
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 16),

          // Recycling guide
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Recycling Guide',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 12),
                  _buildRecyclingGuide('Plastic Bottles',
                      'Clean and remove caps', Icons.local_drink, Colors.red),
                  _buildRecyclingGuide(
                      'Paper & Cardboard',
                      'Keep dry and flatten boxes',
                      Icons.description,
                      Colors.brown),
                  _buildRecyclingGuide('Glass Containers',
                      'Remove lids and rinse', Icons.wine_bar, Colors.blue),
                  _buildRecyclingGuide(
                      'Electronics',
                      'Take to special e-waste centers',
                      Icons.computer,
                      Colors.purple),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompostingTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Composting streak
          Card(
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                    colors: [Colors.brown[300]!, Colors.brown[500]!]),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Composting Streak',
                            style:
                                TextStyle(color: Colors.white, fontSize: 18)),
                        Text('$compostDays days',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold)),
                        Text('Keep it going!',
                            style: TextStyle(color: Colors.white70)),
                      ],
                    ),
                  ),
                  Icon(Icons.compost, color: Colors.white, size: 40),
                ],
              ),
            ),
          ),

          SizedBox(height: 16),

          // Compost bin status
          Text('Compost Bin Status',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Icon(Icons.thermostat, color: Colors.orange, size: 32),
                        SizedBox(height: 8),
                        Text('Temperature',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('65°C',
                            style:
                                TextStyle(fontSize: 20, color: Colors.orange)),
                        Text('Optimal',
                            style:
                                TextStyle(color: Colors.green, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Icon(Icons.water_drop, color: Colors.blue, size: 32),
                        SizedBox(height: 8),
                        Text('Moisture',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('55%',
                            style: TextStyle(fontSize: 20, color: Colors.blue)),
                        Text('Good',
                            style:
                                TextStyle(color: Colors.green, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 16),

          // Compostable items
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('What to Compost',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('✅ Green Materials',
                                style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.w500)),
                            Text(
                                '• Fruit & vegetable scraps\n• Coffee grounds\n• Fresh grass clippings\n• Plant trimmings'),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('✅ Brown Materials',
                                style: TextStyle(
                                    color: Colors.brown,
                                    fontWeight: FontWeight.w500)),
                            Text(
                                '• Dry leaves\n• Paper towels\n• Cardboard\n• Wood chips'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(
                      '❌ Never Compost: Meat, dairy, oils, pet waste, diseased plants',
                      style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ),

          SizedBox(height: 16),

          // Compost progress
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Compost Progress',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: 0.75,
                    backgroundColor: Colors.grey[200],
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.brown[600]!),
                  ),
                  SizedBox(height: 8),
                  Text('Ready in 2-3 weeks',
                      style: TextStyle(color: Colors.brown[600])),
                  SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown[600],
                      minimumSize: Size(double.infinity, 45),
                    ),
                    child: Text('Add Organic Waste',
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWasteTip(String tip) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.eco, size: 16, color: Colors.green),
          SizedBox(width: 8),
          Expanded(child: Text(tip, style: TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  Widget _buildRecyclingCenter(
      String name, String distance, String accepts, IconData icon) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Colors.green[600]),
        title: Text(name),
        subtitle: Text('$distance • $accepts'),
        trailing: TextButton(
          onPressed: () {},
          child: Text('Directions'),
        ),
      ),
    );
  }

  Widget _buildRewardCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color),
          SizedBox(height: 4),
          Text(value,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildRecyclingGuide(
      String item, String instruction, IconData icon, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item, style: TextStyle(fontWeight: FontWeight.w500)),
                Text(instruction,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddWasteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Log Waste'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: 'Waste Type'),
              items: wasteData
                  .map((category) => DropdownMenuItem(
                      value: category.name, child: Text(category.name)))
                  .toList(),
              onChanged: (value) {},
            ),
            SizedBox(height: 16),
            TextFormField(
              decoration:
                  InputDecoration(labelText: 'Amount (kg)', hintText: '0.0'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context), child: Text('Add')),
        ],
      ),
    );
  }
}

// Enhanced Habits Screen
class HabitsScreen extends StatefulWidget {
  @override
  _HabitsScreenState createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {
  List<EnhancedHabit> habits = [
    EnhancedHabit('Use reusable water bottle', false, 'Water',
        Icons.local_drink, 15, Colors.blue),
    EnhancedHabit('Take public transport', false, 'Transport',
        Icons.directions_bus, 28, Colors.green),
    EnhancedHabit('Turn off lights when leaving', true, 'Energy',
        Icons.lightbulb_outline, 42, Colors.orange),
    EnhancedHabit('Eat plant-based meal', true, 'Diet', Icons.restaurant, 8,
        Colors.green[700]!),
    EnhancedHabit('Recycle waste properly', true, 'Waste', Icons.recycling, 22,
        Colors.teal),
    EnhancedHabit('Use reusable shopping bags', false, 'Shopping',
        Icons.shopping_bag, 35, Colors.purple),
    EnhancedHabit('Compost organic waste', false, 'Composting', Icons.compost,
        12, Colors.brown),
  ];

  @override
  Widget build(BuildContext context) {
    int completedToday = habits.where((h) => h.isCompletedToday).length;

    return Scaffold(
      appBar: AppBar(
        title: Text('Eco Habits'),
        backgroundColor: Colors.green[600],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress summary
            Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Today\'s Progress',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          SizedBox(height: 8),
                          Text(
                              '$completedToday/${habits.length} habits completed',
                              style: TextStyle(color: Colors.grey[600])),
                          SizedBox(height: 12),
                          LinearProgressIndicator(
                            value: completedToday / habits.length,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.green[600]!),
                          ),
                        ],
                      ),
                    ),
                    CircularProgressIndicator(
                      value: completedToday / habits.length,
                      backgroundColor: Colors.grey[200],
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.green[600]!),
                      strokeWidth: 6,
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16),

            Text('Your Habits',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),

            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: habits.length,
              itemBuilder: (context, index) {
                final habit = habits[index];
                return Card(
                  margin: EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: GestureDetector(
                      onTap: () {
                        setState(() {
                          habit.isCompletedToday = !habit.isCompletedToday;
                          if (habit.isCompletedToday) habit.currentStreak++;
                        });
                      },
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: habit.isCompletedToday
                              ? habit.color
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Icon(
                          habit.isCompletedToday ? Icons.check : habit.icon,
                          color: habit.isCompletedToday
                              ? Colors.white
                              : habit.color,
                        ),
                      ),
                    ),
                    title: Text(
                      habit.name,
                      style: TextStyle(
                        decoration: habit.isCompletedToday
                            ? TextDecoration.lineThrough
                            : null,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                        '${habit.category} • ${habit.currentStreak} day streak'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (habit.currentStreak >= 7)
                          Icon(Icons.local_fire_department,
                              color: Colors.orange, size: 20),
                        if (habit.currentStreak >= 30)
                          Icon(Icons.star, color: Colors.amber, size: 20),
                        Icon(Icons.more_vert, color: Colors.grey),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green[600],
        child: Icon(Icons.add, color: Colors.white),
        onPressed: () => _showAddHabitDialog(),
      ),
    );
  }

  void _showAddHabitDialog() {
    final nameController = TextEditingController();
    String selectedCategory = 'General';
    final categories = [
      'General',
      'Water',
      'Transport',
      'Energy',
      'Diet',
      'Waste',
      'Shopping'
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add New Habit'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Habit Name'),
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedCategory,
              decoration: InputDecoration(labelText: 'Category'),
              items: categories
                  .map((category) =>
                      DropdownMenuItem(value: category, child: Text(category)))
                  .toList(),
              onChanged: (value) => selectedCategory = value!,
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          TextButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                setState(() {
                  habits.add(EnhancedHabit(
                    nameController.text,
                    false,
                    selectedCategory,
                    Icons.eco,
                    0,
                    Colors.green,
                  ));
                });
                Navigator.pop(context);
              }
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }
}

// Enhanced Trackers Screen with comprehensive tracking
class TrackersScreen extends StatefulWidget {
  @override
  _TrackersScreenState createState() => _TrackersScreenState();
}

class _TrackersScreenState extends State<TrackersScreen> {
  int waterCount = 6;
  double carbonFootprint = 12.5;
  int plantMeals = 2;
  List<TransportLog> transportHistory = [
    TransportLog('Walking', 2.5, DateTime.now().subtract(Duration(hours: 2))),
    TransportLog('Bus', 8.0, DateTime.now().subtract(Duration(hours: 5))),
    TransportLog('Bicycle', 5.2, DateTime.now().subtract(Duration(days: 1))),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lifestyle Trackers'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Daily Trackers',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            _buildWaterTracker(),
            SizedBox(height: 16),
            _buildCarbonFootprintTracker(),
            SizedBox(height: 16),
            _buildDietTracker(),
            SizedBox(height: 16),
            _buildTransportTracker(),
            SizedBox(height: 16),
            _buildSleepTracker(),
            SizedBox(height: 16),
            _buildShoppingTracker(),
          ],
        ),
      ),
    );
  }

  Widget _buildWaterTracker() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.water_drop, color: Colors.blue, size: 28),
                    SizedBox(width: 8),
                    Text('Water Intake',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                Text('${waterCount}/8',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                8,
                (index) => GestureDetector(
                  onTap: () => setState(() => waterCount = index + 1),
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      Icons.water_drop,
                      color:
                          index < waterCount ? Colors.blue : Colors.grey[300],
                      size: 30,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 12),
            LinearProgressIndicator(
              value: waterCount / 8,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${waterCount * 250}ml consumed'),
                Text('Goal: 2000ml'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCarbonFootprintTracker() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.co2, color: Colors.grey[700], size: 28),
                SizedBox(width: 8),
                Text('Carbon Footprint',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text('Today', style: TextStyle(color: Colors.grey[600])),
                      Text('${carbonFootprint.toStringAsFixed(1)} kg CO2',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text('Weekly Avg',
                          style: TextStyle(color: Colors.grey[600])),
                      Text('15.2 kg CO2',
                          style: TextStyle(fontSize: 16, color: Colors.red)),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text('Target', style: TextStyle(color: Colors.grey[600])),
                      Text('10.0 kg CO2',
                          style: TextStyle(fontSize: 16, color: Colors.green)),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            LinearProgressIndicator(
              value: (carbonFootprint / 20.0).clamp(0.0, 1.0),
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(carbonFootprint <= 10
                  ? Colors.green
                  : (carbonFootprint <= 15 ? Colors.orange : Colors.red)),
            ),
            SizedBox(height: 12),
            Text('Breakdown: Transport 60% • Energy 25% • Food 15%',
                style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  Widget _buildDietTracker() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.restaurant_menu, color: Colors.green[700], size: 28),
                SizedBox(width: 8),
                Text('Sustainable Diet',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildDietMetric('Plant-based', '$plantMeals/3',
                      plantMeals / 3, Colors.green),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildDietMetric(
                      'Local Food', '2/3', 2 / 3, Colors.orange),
                ),
                SizedBox(width: 12),
                Expanded(
                  child:
                      _buildDietMetric('Zero Waste', '1/3', 1 / 3, Colors.blue),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () =>
                      setState(() => plantMeals = (plantMeals + 1).clamp(0, 3)),
                  icon: Icon(Icons.add, size: 16),
                  label: Text('Plant Meal'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700]),
                ),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.location_on, size: 16),
                  label: Text('Local Food'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange[700]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDietMetric(
      String title, String value, double progress, Color color) {
    return Column(
      children: [
        Text(title,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        SizedBox(height: 4),
        CircularProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(color),
          strokeWidth: 4,
        ),
        SizedBox(height: 4),
        Text(value,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildTransportTracker() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.directions, color: Colors.teal, size: 28),
                SizedBox(width: 8),
                Text('Transportation',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 16),
            Text('Recent Trips', style: TextStyle(fontWeight: FontWeight.w500)),
            SizedBox(height: 8),
            ...transportHistory
                .take(3)
                .map(
                  (trip) => Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Icon(_getTransportIcon(trip.mode),
                            color: _getTransportColor(trip.mode), size: 20),
                        SizedBox(width: 8),
                        Expanded(child: Text(trip.mode)),
                        Text('${trip.distance.toStringAsFixed(1)} km'),
                      ],
                    ),
                  ),
                )
                .toList(),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showTransportDialog(),
                    icon: Icon(Icons.add, size: 16),
                    label: Text('Log Trip'),
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSleepTracker() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bedtime, color: Colors.indigo, size: 28),
                SizedBox(width: 8),
                Text('Sleep Quality',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text('Last Night',
                          style: TextStyle(color: Colors.grey[600])),
                      Text('7h 45m',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          5,
                          (index) => Icon(Icons.star,
                              color:
                                  index < 4 ? Colors.amber : Colors.grey[300],
                              size: 16),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text('Weekly Avg',
                          style: TextStyle(color: Colors.grey[600])),
                      Text('7h 20m', style: TextStyle(fontSize: 16)),
                      Text('Good',
                          style: TextStyle(color: Colors.green, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text('Good sleep improves decision-making for sustainable choices!',
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic)),
          ],
        ),
      ),
    );
  }

  Widget _buildShoppingTracker() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.shopping_cart, color: Colors.purple, size: 28),
                SizedBox(width: 8),
                Text('Sustainable Shopping',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildShoppingMetric(
                      'Eco Products', '12/15', 12 / 15, Colors.green),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildShoppingMetric(
                      'Local Brands', '8/15', 8 / 15, Colors.orange),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildShoppingMetric(
                      'Minimal Package', '10/15', 10 / 15, Colors.blue),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text('Recent Sustainable Purchases',
                style: TextStyle(fontWeight: FontWeight.w500)),
            SizedBox(height: 8),
            _buildShoppingItem('Bamboo Toothbrush', 'Eco-friendly', Icons.eco),
            _buildShoppingItem(
                'Reusable Food Wraps', 'Zero waste', Icons.kitchen),
            _buildShoppingItem(
                'Organic Cotton Bag', 'Local brand', Icons.shopping_bag),
          ],
        ),
      ),
    );
  }

  Widget _buildShoppingMetric(
      String title, String value, double progress, Color color) {
    return Column(
      children: [
        Text(title,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
        SizedBox(height: 4),
        CircularProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(color),
          strokeWidth: 4,
        ),
        SizedBox(height: 4),
        Text(value,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildShoppingItem(String item, String category, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: Colors.green[600], size: 20),
          SizedBox(width: 8),
          Expanded(child: Text(item, style: TextStyle(fontSize: 14))),
          Text(category,
              style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }

  IconData _getTransportIcon(String mode) {
    switch (mode.toLowerCase()) {
      case 'walking':
        return Icons.directions_walk;
      case 'bicycle':
        return Icons.directions_bike;
      case 'bus':
        return Icons.directions_bus;
      case 'car':
        return Icons.directions_car;
      default:
        return Icons.directions;
    }
  }

  Color _getTransportColor(String mode) {
    switch (mode.toLowerCase()) {
      case 'walking':
        return Colors.green;
      case 'bicycle':
        return Colors.teal;
      case 'bus':
        return Colors.blue;
      case 'car':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showTransportDialog() {
    String selectedMode = 'Walking';
    final distanceController = TextEditingController();
    final modes = ['Walking', 'Bicycle', 'Bus', 'Train', 'Car', 'Motorcycle'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Log Transportation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: selectedMode,
              decoration: InputDecoration(labelText: 'Mode of Transport'),
              items: modes
                  .map((mode) =>
                      DropdownMenuItem(value: mode, child: Text(mode)))
                  .toList(),
              onChanged: (value) => selectedMode = value!,
            ),
            SizedBox(height: 16),
            TextField(
              controller: distanceController,
              decoration:
                  InputDecoration(labelText: 'Distance (km)', hintText: '0.0'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          TextButton(
            onPressed: () {
              if (distanceController.text.isNotEmpty) {
                setState(() {
                  transportHistory.insert(
                      0,
                      TransportLog(
                        selectedMode,
                        double.parse(distanceController.text),
                        DateTime.now(),
                      ));
                });
                Navigator.pop(context);
              }
            },
            child: Text('Log'),
          ),
        ],
      ),
    );
  }
}

// New Challenges Screen
class ChallengesScreen extends StatefulWidget {
  @override
  _ChallengesScreenState createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen> {
  List<Challenge> activeChallenges = [
    Challenge('Zero Waste Week', 'Produce no waste for 7 days', 5, 7,
        Colors.green, Icons.delete_outline),
    Challenge('Plant-Based Month', 'Eat only plant-based meals', 18, 30,
        Colors.green[700]!, Icons.restaurant),
    Challenge('Car-Free Challenge', 'No car usage for 2 weeks', 8, 14,
        Colors.blue, Icons.directions_walk),
    Challenge('Energy Saver', 'Reduce energy usage by 30%', 12, 21,
        Colors.orange, Icons.bolt),
  ];

  List<Challenge> completedChallenges = [
    Challenge('Plastic-Free July', 'Avoid single-use plastic', 31, 31,
        Colors.red, Icons.no_drinks),
    Challenge('Bike to Work', 'Cycle to work daily', 22, 22, Colors.teal,
        Icons.directions_bike),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Eco Challenges'),
        backgroundColor: Colors.amber[600],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Challenge stats
            Row(
              children: [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Icon(Icons.emoji_events,
                              color: Colors.amber, size: 32),
                          SizedBox(height: 8),
                          Text('Active',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('${activeChallenges.length}',
                              style: TextStyle(fontSize: 20)),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Icon(Icons.check_circle,
                              color: Colors.green, size: 32),
                          SizedBox(height: 8),
                          Text('Completed',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('${completedChallenges.length}',
                              style: TextStyle(fontSize: 20)),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 32),
                          SizedBox(height: 8),
                          Text('Points',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('1,250', style: TextStyle(fontSize: 20)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 24),
            Text('Active Challenges',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),

            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: activeChallenges.length,
              itemBuilder: (context, index) {
                final challenge = activeChallenges[index];
                return _buildChallengeCard(challenge, false);
              },
            ),

            SizedBox(height: 24),
            Text('Completed Challenges',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),

            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: completedChallenges.length,
              itemBuilder: (context, index) {
                final challenge = completedChallenges[index];
                return _buildChallengeCard(challenge, true);
              },
            ),

            SizedBox(height: 24),
            Text('Discover New Challenges',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),

            _buildNewChallengeCard('Meatless Monday', 'Skip meat every Monday',
                Icons.restaurant, Colors.green),
            _buildNewChallengeCard('5-Minute Shower',
                'Limit showers to 5 minutes', Icons.shower, Colors.blue),
            _buildNewChallengeCard(
                'Digital Detox Weekend',
                'Reduce screen time on weekends',
                Icons.phone_android,
                Colors.purple),
          ],
        ),
      ),
    );
  }

  Widget _buildChallengeCard(Challenge challenge, bool isCompleted) {
    double progress = challenge.currentDay / challenge.totalDays;

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: challenge.color.withOpacity(0.1),
                  child: Icon(challenge.icon, color: challenge.color),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(challenge.title,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(challenge.description,
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 14)),
                    ],
                  ),
                ),
                if (isCompleted)
                  Icon(Icons.check_circle, color: Colors.green, size: 32)
                else
                  Text('${challenge.currentDay}/${challenge.totalDays}',
                      style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            if (!isCompleted) ...[
              SizedBox(height: 12),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(challenge.color),
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${(progress * 100).toInt()}% complete'),
                  Text(
                      '${challenge.totalDays - challenge.currentDay} days left'),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNewChallengeCard(
      String title, String description, IconData icon, Color color) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(description),
        trailing: ElevatedButton(
          onPressed: () {
            setState(() {
              activeChallenges
                  .add(Challenge(title, description, 0, 30, color, icon));
            });
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Challenge started! Good luck!')));
          },
          style: ElevatedButton.styleFrom(backgroundColor: color),
          child: Text('Start', style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}

// Enhanced Profile Screen
class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Colors.green[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: Icon(Icons.edit), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile header
            Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.green[100],
                      child: Icon(Icons.person,
                          size: 50, color: Colors.green[600]),
                    ),
                    SizedBox(height: 16),
                    Text('Eco Warrior',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold)),
                    Text('Level 5 Sustainability Champion',
                        style: TextStyle(color: Colors.green[600])),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildProfileStat('Streak', '42 days',
                            Icons.local_fire_department, Colors.orange),
                        _buildProfileStat(
                            'Points', '1,250', Icons.star, Colors.amber),
                        _buildProfileStat(
                            'Rank', '#127', Icons.leaderboard, Colors.purple),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            // Achievements
            Text('Recent Achievements',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                    child: _buildAchievement('Water Saver', '30 days tracking',
                        Icons.water_drop, Colors.blue)),
                SizedBox(width: 12),
                Expanded(
                    child: _buildAchievement(
                        'Green Commuter',
                        'Used eco transport',
                        Icons.directions_bike,
                        Colors.green)),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                    child: _buildAchievement('Waste Warrior',
                        'Reduced waste 50%', Icons.recycling, Colors.teal)),
                SizedBox(width: 12),
                Expanded(
                    child: _buildAchievement('Plant Pioneer', '100 plant meals',
                        Icons.restaurant, Colors.green[700]!)),
              ],
            ),

            SizedBox(height: 20),

            // Impact summary
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Your Environmental Impact',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 16),
                    _buildImpactRow(
                        'CO2 Prevented', '285 kg', Icons.co2, Colors.green),
                    _buildImpactRow('Water Saved', '1,250 liters',
                        Icons.water_drop, Colors.blue),
                    _buildImpactRow('Waste Reduced', '45 kg',
                        Icons.delete_outline, Colors.orange),
                    _buildImpactRow('Trees Equivalent', '12 trees', Icons.park,
                        Colors.green[700]!),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            // Menu options
            _buildMenuTile('Settings', Icons.settings, () {}),
            _buildMenuTile('Friends & Community', Icons.people, () {}),
            _buildMenuTile('Export Data', Icons.download, () {}),
            _buildMenuTile('Help & Support', Icons.help, () {}),
            _buildMenuTile('About', Icons.info, () {}),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileStat(
      String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        SizedBox(height: 4),
        Text(value,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildAchievement(
      String title, String description, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            SizedBox(height: 8),
            Text(title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            Text(description,
                style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildImpactRow(
      String title, String value, IconData icon, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(width: 12),
          Expanded(child: Text(title)),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildMenuTile(String title, IconData icon, VoidCallback onTap) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Colors.green[600]),
        title: Text(title),
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}

// Data Models
class Habit {
  String name;
  bool isCompleted;
  Habit(this.name, this.isCompleted);
}

class EnhancedHabit {
  String name;
  bool isCompletedToday;
  String category;
  IconData icon;
  int currentStreak;
  Color color;

  EnhancedHabit(this.name, this.isCompletedToday, this.category, this.icon,
      this.currentStreak, this.color);
}

class Goal {
  String title;
  double progress;
  Goal(this.title, this.progress);
}

class ApplianceUsage {
  String name;
  double usage;
  IconData icon;
  bool isOn;

  ApplianceUsage(this.name, this.usage, this.icon, this.isOn);
}

class WasteCategory {
  String name;
  double todayAmount;
  double monthlyAmount;
  Color color;
  IconData icon;

  WasteCategory(
      this.name, this.todayAmount, this.monthlyAmount, this.color, this.icon);
}

class TransportLog {
  String mode;
  double distance;
  DateTime timestamp;

  TransportLog(this.mode, this.distance, this.timestamp);
}

class Challenge {
  String title;
  String description;
  int currentDay;
  int totalDays;
  Color color;
  IconData icon;

  Challenge(this.title, this.description, this.currentDay, this.totalDays,
      this.color, this.icon);
}

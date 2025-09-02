import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'girl.dart';
import 'boy.dart';
import 'payments.dart';
import 'widrawal.dart';
import 'package:intl/intl.dart';
import 'models/ad_insights.dart';
import 'services/facebook_ad_service.dart';
import 'package:fl_chart/fl_chart.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'User List App',
      theme: ThemeData(
        fontFamily: 'Montserrat', // Modern font
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[100],
        appBarTheme: AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.transparent,
          centerTitle: true,
          titleTextStyle: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: Colors.black87,
          ),
        ),
      ),
      home: const NavigationContainer(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class NavigationContainer extends StatefulWidget {
  const NavigationContainer({Key? key}) : super(key: key);

  @override
  State<NavigationContainer> createState() => _NavigationContainerState();
}

class _NavigationContainerState extends State<NavigationContainer> {
  int _selectedIndex = 0;
  
  static final List<Widget> _screens = [
    const HomePage(),
    const UserListScreen(), // Female profiles
    const BoyUserListScreen(), // Male profiles
    const PaymentsScreen(),
    const WithdrawalPage(),
  ];
  
  static final List<String> _titles = [
    'Dashboard',
    'Female Profiles',
    'Male Profiles',
    'Payments',
    'Withdrawals'
  ];
  
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      // appBar: PreferredSize(
      //   preferredSize: const Size.fromHeight(70),
      //   child: Container(
      //     decoration: BoxDecoration(
      //       gradient: LinearGradient(
      //         colors: [Colors.blue[700]!, Colors.purple[400]!],
      //         begin: Alignment.topLeft,
      //         end: Alignment.bottomRight,
      //       ),
      //       borderRadius: const BorderRadius.only(
      //         bottomLeft: Radius.circular(32),
      //         bottomRight: Radius.circular(32),
      //       ),
      //       boxShadow: [
      //         BoxShadow(
      //           color: Colors.blue.withOpacity(0.2),
      //           blurRadius: 16,
      //           offset: const Offset(0, 8),
      //         ),
      //       ],
      //     ),
      //     child: AppBar(
      //       backgroundColor: Colors.transparent,
      //       elevation: 0,
      //       title: Row(
      //         mainAxisAlignment: MainAxisAlignment.center,
      //         children: [
      //           Icon(Icons.chat_bubble, color: Colors.white, size: 28),
      //           const SizedBox(width: 8),
      //           Text(
      //             _titles[_selectedIndex],
      //             style: const TextStyle(
      //               color: Colors.white,
      //               fontWeight: FontWeight.bold,
      //               fontSize: 22,
      //             ),
      //           ),
      //         ],
      //       ),
      //       centerTitle: true,
      //     ),
      //   ),
      // ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        child: _screens[_selectedIndex],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[700]!, Colors.purple[400]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            elevation: 0,
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white70,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.female),
                label: 'Female',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.male),
                label: 'Male',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.payment),
                label: 'Payments',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.account_balance_wallet),
                label: 'Withdrawals',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoading = true;
  String errorMessage = '';
  
  // Dashboard statistics
  int totalGirlUsers = 0;
  int totalBoyUsers = 0;
  int activeGirlUsers = 0;
  int activeBoyUsers = 0;
  double totalPaymentsAmount = 0;
  int totalPaymentsCount = 0;
  double todayPaymentsAmount = 0;
  int todayPaymentsCount = 0;
  double yesterdayPaymentsAmount = 0;
  int yesterdayPaymentsCount = 0;
  double totalWithdrawalsAmount = 0;
  int totalWithdrawalsCount = 0;
  double todayWithdrawalsAmount = 0;
  int todayWithdrawalsCount = 0;
  double yesterdayWithdrawalsAmount = 0;
  int yesterdayWithdrawalsCount = 0;
  
  // Facebook Ad statistics
  bool isLoadingAdData = false;
  String adDataErrorMessage = '';
  AdInsights? todayAdInsights;
  AdInsights? yesterdayAdInsights;
  AdInsights? selectedDateAdInsights;
  
  DateTime selectedDate = DateTime.now();
  double selectedDatePaymentsAmount = 0;
  int selectedDatePaymentsCount = 0;
  double selectedDateWithdrawalsAmount = 0;
  int selectedDateWithdrawalsCount = 0;
  
  // Add data for charts
  List<FlSpot> paymentTrend = [];
  List<FlSpot> withdrawalTrend = [];
  List<FlSpot> adSpendTrend = [];
  double maxY = 1000; // Default max Y value for charts
  
  @override
  void initState() {
    super.initState();
    fetchDashboardData();
    // Generate sample data for charts - will be replaced with real data
    _generateChartData();
  }
  
  // Generate sample chart data based on last 7 days
  void _generateChartData() {
    final now = DateTime.now();
    
    // This is temporary - in a real app, you'd fetch historical data from your API
    // We'll generate more meaningful data after API fetch
    paymentTrend = [];
    withdrawalTrend = [];
    adSpendTrend = [];
    
    // Will be populated with real data after API calls complete
  }
  
  // Update chart data after fetching real data
  void _updateChartData() {
    paymentTrend = [];
    withdrawalTrend = [];
    adSpendTrend = [];
    
    maxY = [todayPaymentsAmount, yesterdayPaymentsAmount, 
            todayWithdrawalsAmount, yesterdayWithdrawalsAmount].reduce((a, b) => a > b ? a : b);
    maxY = maxY < 1000 ? 1000 : maxY * 1.2; // Add 20% headroom
    
    // Add today and yesterday data
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));
    
    paymentTrend = [
      FlSpot(yesterday.day.toDouble(), yesterdayPaymentsAmount),
      FlSpot(today.day.toDouble(), todayPaymentsAmount),
    ];
    
    withdrawalTrend = [
      FlSpot(yesterday.day.toDouble(), yesterdayWithdrawalsAmount),
      FlSpot(today.day.toDouble(), todayWithdrawalsAmount),
    ];
    
    // For ad spend, include GST
    final todayAdSpend = (todayAdInsights?.spend ?? 0) * 1.18;
    final yesterdayAdSpend = (yesterdayAdInsights?.spend ?? 0) * 1.18;
    
    adSpendTrend = [
      FlSpot(yesterday.day.toDouble(), yesterdayAdSpend),
      FlSpot(today.day.toDouble(), todayAdSpend),
    ];
  }

  Future<void> fetchDashboardData() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });
    
    try {
      await Future.wait([
        fetchUserStats(),
        fetchPaymentStats(),
        fetchWithdrawalStats(),
        fetchFacebookAdStats(),
      ]);
      
      // Update chart data after fetching all stats
      _updateChartData();
      
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching dashboard data: $e';
        isLoading = false;
      });
    }
  }
  
  Future<void> fetchUserStats() async {
    try {
      // Fetch girl users
      final girlsResponse = await http.get(
        Uri.parse('https://api.ciliega.shop/GetAllAccountsGirls'),
        headers: {'Content-Type': 'application/json'},
      );

      // Fetch boy users
      final boysResponse = await http.get(
        Uri.parse('https://api.ciliega.shop/GetAllAccountsBoy'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (girlsResponse.statusCode == 200 && boysResponse.statusCode == 200) {
        List<dynamic> girlsData = json.decode(girlsResponse.body);
        List<dynamic> boysData = json.decode(boysResponse.body);
        
        setState(() {
          totalGirlUsers = girlsData.length;
          totalBoyUsers = boysData.length;
          
          // Count active users
          activeGirlUsers = girlsData.where((user) => 
            user['Status']?.toString().toLowerCase() == 'active').length;
          activeBoyUsers = boysData.where((user) => 
            user['Status']?.toString().toLowerCase() == 'active').length;
        });
      }
    } catch (e) {
      print('Error fetching user stats: $e');
    }
  }
  
  Future<void> fetchPaymentStats() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.ciliega.shop/GetAllPayments'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        final today = DateTime.now();
        final yesterday = today.subtract(const Duration(days: 1));
        
        // Format dates for comparison
        final todayDate = _formatDateForComparison(today);
        final yesterdayDate = _formatDateForComparison(yesterday);
        final selectedFormattedDate = _formatDateForComparison(selectedDate);
        
        double totalAmount = 0;
        double todayAmount = 0;
        double yesterdayAmount = 0;
        double selectedDayAmount = 0;
        
        int todayCount = 0;
        int yesterdayCount = 0;
        int selectedDayCount = 0;
        
        // Only count successful payments
        final successfulPayments = data.where((payment) => 
          payment['status']?.toString().toLowerCase() == 'success').toList();
        
        for (var payment in successfulPayments) {
          final amount = payment['amount'] is num 
              ? payment['amount'].toDouble() 
              : 0.0;
              
          totalAmount += amount;
          
          // Extract payment date
          String paymentDate = payment['date'] ?? '';
          if (paymentDate.isNotEmpty) {
            try {
              final date = _formatDateForComparison(DateTime.parse(paymentDate));
              
              if (date == todayDate) {
                todayAmount += amount;
                todayCount++;
              }
              
              if (date == yesterdayDate) {
                yesterdayAmount += amount;
                yesterdayCount++;
              }
              
              if (date == selectedFormattedDate) {
                selectedDayAmount += amount;
                selectedDayCount++;
              }
            } catch (e) {
              // Skip invalid dates
            }
          }
        }
        
        setState(() {
          totalPaymentsAmount = totalAmount;
          totalPaymentsCount = successfulPayments.length;
          todayPaymentsAmount = todayAmount;
          todayPaymentsCount = todayCount;
          yesterdayPaymentsAmount = yesterdayAmount;
          yesterdayPaymentsCount = yesterdayCount;
          selectedDatePaymentsAmount = selectedDayAmount;
          selectedDatePaymentsCount = selectedDayCount;
        });
      }
    } catch (e) {
      print('Error fetching payment stats: $e');
    }
  }
  
  Future<void> fetchWithdrawalStats() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.ciliega.shop/getAllWidrawals'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        final today = DateTime.now();
        final yesterday = today.subtract(const Duration(days: 1));
        
        // Format dates for comparison
        final todayDate = _formatDateForComparison(today);
        final yesterdayDate = _formatDateForComparison(yesterday);
        final selectedFormattedDate = _formatDateForComparison(selectedDate);
        
        double totalAmount = 0;
        double todayAmount = 0;
        double yesterdayAmount = 0;
        double selectedDayAmount = 0;
        
        int todayCount = 0;
        int yesterdayCount = 0;
        int selectedDayCount = 0;
        
        // Count all withdrawals, not just successful ones
        for (var withdrawal in data) {
          final amount = withdrawal['amount'] is num 
              ? withdrawal['amount'].toDouble() 
              : 0.0;
              
          totalAmount += amount;
          
          // Extract withdrawal date
          String withdrawalDate = withdrawal['date'] ?? '';
          if (withdrawalDate.isNotEmpty) {
            try {
              final date = _formatDateForComparison(DateTime.parse(withdrawalDate));
              
              if (date == todayDate) {
                todayAmount += amount;
                todayCount++;
              }
              
              if (date == yesterdayDate) {
                yesterdayAmount += amount;
                yesterdayCount++;
              }
              
              if (date == selectedFormattedDate) {
                selectedDayAmount += amount;
                selectedDayCount++;
              }
            } catch (e) {
              // Skip invalid dates
            }
          }
        }
        
        setState(() {
          totalWithdrawalsAmount = totalAmount;
          totalWithdrawalsCount = data.length;  // Count all withdrawals
          todayWithdrawalsAmount = todayAmount;
          todayWithdrawalsCount = todayCount;
          yesterdayWithdrawalsAmount = yesterdayAmount;
          yesterdayWithdrawalsCount = yesterdayCount;
          selectedDateWithdrawalsAmount = selectedDayAmount;
          selectedDateWithdrawalsCount = selectedDayCount;
        });
      }
    } catch (e) {
      print('Error fetching withdrawal stats: $e');
    }
  }
  
  Future<void> fetchFacebookAdStats() async {
    setState(() {
      isLoadingAdData = true;
      adDataErrorMessage = '';
    });
    
    try {
      // Get today's ad insights
      final today = DateTime.now();
      todayAdInsights = await FacebookAdService.getTodayAdSpend(today);
      
      // Get yesterday's ad insights
      final yesterday = today.subtract(const Duration(days: 1));
      yesterdayAdInsights = await FacebookAdService.getTodayAdSpend(yesterday);
      
      // Get selected date ad insights
      selectedDateAdInsights = await FacebookAdService.getTodayAdSpend(selectedDate);
      
      setState(() {
        isLoadingAdData = false;
      });
    } catch (e) {
      setState(() {
        adDataErrorMessage = 'Error fetching ad data: $e';
        isLoadingAdData = false;
      });
      print('Error fetching Facebook ad stats: $e');
    }
  }
  
  String _formatDateForComparison(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
  
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      // Refetch stats with new selected date
      fetchPaymentStats();
      fetchWithdrawalStats();
      fetchFacebookAdStats(); // Also fetch ad stats for the selected date
    }
  }

  @override
  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
  }) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      shadowColor: iconColor.withOpacity(0.3),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              iconColor.withOpacity(0.08),
              Colors.white,
              iconColor.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: const [0.0, 0.5, 1.0],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: iconColor.withOpacity(0.1),
            width: 1,
          ),
        ),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [iconColor.withOpacity(0.2), iconColor.withOpacity(0.3)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: iconColor.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(2, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Icon(icon, color: iconColor, size: 26),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF424242),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: iconColor.withOpacity(0.9),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Dashboard Overview',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchDashboardData,
            tooltip: 'Refresh Data',
          ),
        ],
      ),
    );
  }

  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.blue[50]!, Colors.white],
        ),
      ),
      child: RefreshIndicator(
        onRefresh: fetchDashboardData,
        child: isLoading 
          ? Center(
              child: SizedBox(
                width: 48,
                height: 48,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
                  strokeWidth: 5,
                ),
              ),
            )
          : errorMessage.isNotEmpty 
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      errorMessage,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: fetchDashboardData,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
            : LayoutBuilder(
                builder: (context, constraints) {
                  // Use LayoutBuilder to get available width
                  final isNarrow = constraints.maxWidth < 600;
                  
                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 16),
                        _buildNetEarningsCard(
                          title: 'Net Earnings',
                          value: '₹${(todayPaymentsAmount - (todayAdInsights?.spend ?? 0) * 1.18 - todayWithdrawalsAmount).toStringAsFixed(2)}',
                          income: '₹${todayPaymentsAmount.toStringAsFixed(2)}',
                          adSpend: '₹${((todayAdInsights?.spend ?? 0) * 1.18).toStringAsFixed(2)}',
                          withdrawals: '₹${todayWithdrawalsAmount.toStringAsFixed(2)}',
                          icon: Icons.account_balance,
                          iconColor: Colors.green[700]!,
                        ),
                        const SizedBox(height: 24),
                        _buildPerformanceChart(isNarrow), // New chart section
                        const SizedBox(height: 24),
                        _buildUserStatistics(),
                        const SizedBox(height: 24),
                        _buildPaymentStatistics(),
                        const SizedBox(height: 24),
                        _buildWithdrawalStatistics(),
                        const SizedBox(height: 24),
                        _buildFacebookAdStatistics(),
                        const SizedBox(height: 24),
                        _buildDateSpecificStats(),
                        const SizedBox(height: 16),
                      ],
                    ),
                  );
                }
              ),
      ),
    );
  }
  
  // Add a new method for the performance chart
  // Performance chart implementation moved to the first declaration

  @override
  Widget _buildNetEarningsCard({
    required String title,
    required String value,
    required String income,
    required String adSpend,
    required String withdrawals,
    required IconData icon,
    required Color iconColor,
  }) {
    final isPositive = !value.contains('-');
    final primaryColor = isPositive ? Colors.green : Colors.red;
    
    return Card(
      elevation: 12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      shadowColor: primaryColor.withOpacity(0.3),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              primaryColor.withOpacity(0.05),
              Colors.white,
              primaryColor.withOpacity(0.08),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: const [0.0, 0.6, 1.0],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: primaryColor.withOpacity(0.2),
            width: 1.5,
          ),
        ),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [iconColor.withOpacity(0.3), iconColor.withOpacity(0.5)],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: iconColor.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(14),
                  child: Icon(icon, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF424242), // equivalent to Colors.grey[800]
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    primaryColor.withOpacity(0.1),
                    primaryColor.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: primaryColor.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: primaryColor[700],
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                children: [
                  _buildNetEarningsRow('Income', income, Icons.trending_up, Colors.green),
                  const SizedBox(height: 4),
                  _buildNetEarningsRow('Ad Spend', adSpend, Icons.shopping_cart, Colors.blue),
                  const SizedBox(height: 4),
                  _buildNetEarningsRow('Withdrawals', withdrawals, Icons.account_balance_wallet, Colors.orange),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNetEarningsRow(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 14, color: color),
          ),
          const SizedBox(width: 8),
          Text(
            '$label:',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ...existing code...

  Widget _buildPerformanceChart(bool isNarrow) {
    return Card(
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      shadowColor: Colors.blue.withOpacity(0.2),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blue.withOpacity(0.03),
              Colors.white,
              Colors.purple.withOpacity(0.02),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.blue.withOpacity(0.1),
            width: 1,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue[600]!, Colors.purple[400]!],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(Icons.insert_chart, size: 24, color: Colors.white),
                  const SizedBox(width: 10),
                  Text(
                    'Performance Overview',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // Enhanced Chart legend
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Wrap(
                spacing: 20,
                children: [
                  _buildEnhancedLegendItem('Payments', Colors.green, Icons.arrow_upward),
                  _buildEnhancedLegendItem('Withdrawals', Colors.orange, Icons.arrow_downward),
                  _buildEnhancedLegendItem('Ad Spend', Colors.blue, Icons.trending_up),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Enhanced chart container
            Container(
              height: 280,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              width: double.infinity,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawHorizontalLine: true,
                    drawVerticalLine: false,
                    horizontalInterval: maxY / 5,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey[300]!,
                        strokeWidth: 1,
                        dashArray: [5, 5],
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          // This is a simplified approach. In a real app, you'd use date formatting
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              value == DateTime.now().day ? 'Today' : 'Yest',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 10,
                              ),
                            ),
                          );
                        },
                        reservedSize: 30,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value == 0) return const SizedBox();
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Text(
                              value >= 1000 
                                ? '₹${(value/1000).toStringAsFixed(0)}K'
                                : '₹${value.toInt()}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 10,
                              ),
                            ),
                          );
                        },
                        reservedSize: 40,
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(
                      color: Colors.grey[300]!,
                      width: 1,
                    ),
                  ),
                  minX: DateTime.now().day - 1.5,
                  maxX: DateTime.now().day + 0.5,
                  minY: 0,
                  maxY: maxY,
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      tooltipBgColor: Colors.black87,
                      tooltipRoundedRadius: 12,
                      tooltipPadding: const EdgeInsets.all(12),
                      getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                        return touchedBarSpots.map((barSpot) {
                          final flSpot = barSpot;
                          String label = '';
                          Color color = Colors.white;
                          
                          switch (barSpot.barIndex) {
                            case 0:
                              label = 'Payments: ₹${flSpot.y.toStringAsFixed(2)}';
                              color = Colors.green;
                              break;
                            case 1:
                              label = 'Withdrawals: ₹${flSpot.y.toStringAsFixed(2)}';
                              color = Colors.orange;
                              break;
                            case 2:
                              label = 'Ad Spend: ₹${flSpot.y.toStringAsFixed(2)}';
                              color = Colors.blue;
                              break;
                          }
                          
                          return LineTooltipItem(
                            label,
                            TextStyle(
                              color: color,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          );
                        }).toList();
                      }
                    ),
                  ),
                  lineBarsData: [
                    _createEnhancedLineData(paymentTrend, Colors.green),
                    _createEnhancedLineData(withdrawalTrend, Colors.orange),
                    _createEnhancedLineData(adSpendTrend, Colors.blue),
                  ],
                  // ...existing chart properties...
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Enhanced summary
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue[50]!, Colors.purple[50]!],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[100]!),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[700], size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Showing data for yesterday and today',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.blue[700],
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Enhanced legend item
  Widget _buildEnhancedLegendItem(String label, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Container(
            width: 10,
            height: 10,
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
              color: color.withOpacity(0.8),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // Enhanced line chart data
  LineChartBarData _createEnhancedLineData(List<FlSpot> spots, Color color) {
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      color: color,
      barWidth: 4,
      isStrokeCapRound: true,
      gradient: LinearGradient(
        colors: [color.withOpacity(0.8), color],
      ),
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, barData, index) {
          return FlDotCirclePainter(
            radius: 6,
            color: Colors.white,
            strokeWidth: 3,
            strokeColor: color,
          );
        },
      ),
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.3),
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }

  Widget _buildDateStatCard({
    required String title,
    required double amount,
    int? count,
    String? detail,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: 200,
      child: Card(
        elevation: 8,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        shadowColor: color.withOpacity(0.3),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.05),
                Colors.white,
                color.withOpacity(0.08),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: color.withOpacity(0.2),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color.withOpacity(0.2), color.withOpacity(0.3)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: color, size: 22),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '₹${amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: color.withOpacity(0.7),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (count != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$count Transactions',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              if (detail != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    detail,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdSpendCard({
    required String title,
    required double spend,
    required int clicks,
    required IconData icon,
    required Color iconColor,
  }) {
    final double gst = spend * 0.18;
    final double totalWithGst = spend + gst;
    
    return Card(
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      shadowColor: iconColor.withOpacity(0.3),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              iconColor.withOpacity(0.05),
              Colors.white,
              iconColor.withOpacity(0.08),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: iconColor.withOpacity(0.2),
            width: 1,
          ),
        ),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [iconColor.withOpacity(0.3), iconColor.withOpacity(0.5)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: iconColor.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(2, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Icon(icon, color: Colors.white, size: 26),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [iconColor.withOpacity(0.1), iconColor.withOpacity(0.05)],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: iconColor.withOpacity(0.2)),
              ),
              child: Text(
                '₹${totalWithGst.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: iconColor.withOpacity(0.7),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Base: ₹${spend.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'GST: ₹${gst.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.mouse, size: 14, color: iconColor),
                        const SizedBox(width: 4),
                        Text(
                          '$clicks Clicks',
                          style: TextStyle(
                            fontSize: 12,
                            color: iconColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdMetricsCard() {
    final insights = todayAdInsights;
    
    if (insights == null) {
      return _buildStatCard(
        title: 'Ad Metrics',
        value: 'N/A',
        subtitle: 'No data available',
        icon: Icons.bar_chart,
        iconColor: Colors.orange[700]!
      );
    }
    
    final ctrPercentage = (insights.ctr * 100).toStringAsFixed(2);
    
    return Card(
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      shadowColor: Colors.orange.withOpacity(0.3),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.orange.withOpacity(0.05),
              Colors.white,
              Colors.orange.withOpacity(0.08),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.orange.withOpacity(0.2),
            width: 1,
          ),
        ),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.orange.withOpacity(0.3), Colors.orange.withOpacity(0.5)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(2, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Icon(Icons.bar_chart, color: Colors.white, size: 26),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Ad Metrics',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF424242),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange.withOpacity(0.1), Colors.orange.withOpacity(0.05)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.touch_app, size: 14, color: Colors.orange[700]),
                          const SizedBox(width: 4),
                          Text(
                            'CTR',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$ctrPercentage%',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[700],
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.monetization_on, size: 14, color: Colors.orange[700]),
                          const SizedBox(width: 4),
                          Text(
                            'CPC',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₹${insights.cpc.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[700],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.visibility, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 6),
                  Text(
                    '${NumberFormat.compact().format(insights.impressions)} Impressions',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserStatistics() {
    return Card(
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      shadowColor: Colors.purple.withOpacity(0.3),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.purple.withOpacity(0.05),
              Colors.white,
              Colors.purple.withOpacity(0.08),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.purple.withOpacity(0.2),
            width: 1,
          ),
        ),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'User Statistics',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.purple[700],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatBox(
                  title: 'Total Girl Users',
                  value: totalGirlUsers.toString(),
                  active: activeGirlUsers.toString(),
                  icon: Icons.female,
                  color: Colors.pink,
                ),
                _buildStatBox(
                  title: 'Total Boy Users',
                  value: totalBoyUsers.toString(),
                  active: activeBoyUsers.toString(),
                  icon: Icons.male,
                  color: Colors.blue,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBox({
    required String title,
    required String value,
    required String active,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$active Active',
            style: TextStyle(
              fontSize: 12,
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentStatistics() {
    return Card(
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      shadowColor: Colors.green.withOpacity(0.3),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.green.withOpacity(0.05),
              Colors.white,
              Colors.green.withOpacity(0.08),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.green.withOpacity(0.2),
            width: 1,
          ),
        ),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment Statistics',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatBox(
                  title: 'Today\'s Payments',
                  value: '₹${todayPaymentsAmount.toStringAsFixed(2)}',
                  active: '$todayPaymentsCount Transactions',
                  icon: Icons.today,
                  color: Colors.green,
                ),
                _buildStatBox(
                  title: 'Yesterday\'s Payments',
                  value: '₹${yesterdayPaymentsAmount.toStringAsFixed(2)}',
                  active: '$yesterdayPaymentsCount Transactions',
                  icon: Icons.history,
                  color: Colors.teal,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Payments',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.green[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₹${totalPaymentsAmount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$totalPaymentsCount Total Transactions',
                      style: TextStyle(
                        color: Colors.green[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSpecificStats() {
    // Calculate GST for selected date ad insights
    final double adSpend = selectedDateAdInsights?.spend ?? 0.0;
    final double gst = adSpend * 0.18;
    final double totalWithGst = adSpend + gst;
    
    // Calculate net earnings for selected date
    final double selectedDateNetEarnings = selectedDatePaymentsAmount - totalWithGst - selectedDateWithdrawalsAmount;
    
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Custom Date Statistics',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.calendar_month),
                  label: Text(
                    DateFormat('dd MMM yyyy').format(selectedDate),
                  ),
                  onPressed: () => _selectDate(context),
                ),
              ],
            ),
            
            // Add net earnings summary for selected date
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: selectedDateNetEarnings >= 0 ? Colors.green[50] : Colors.red[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selectedDateNetEarnings >= 0 ? Colors.green[200]! : Colors.red[200]!
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.account_balance,
                    color: selectedDateNetEarnings >= 0 ? Colors.green[700] : Colors.red[700],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Net Earnings for ${DateFormat('dd MMM yyyy').format(selectedDate)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '₹${selectedDateNetEarnings.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: selectedDateNetEarnings >= 0 ? Colors.green[700] : Colors.red[700],
                          ),
                        ),
                        Text(
                          'Income: ₹${selectedDatePaymentsAmount.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 11),
                        ),
                        Text(
                          'Ad Spend: ₹${totalWithGst.toStringAsFixed(2)} • Withdrawals: ₹${selectedDateWithdrawalsAmount.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Use a more responsive layout for detailed stats
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildDateStatCard(
                  title: 'Payments',
                  amount: selectedDatePaymentsAmount,
                  count: selectedDatePaymentsCount,
                  icon: Icons.payment,
                  color: Colors.green[600]!
                ),
                _buildDateStatCard(
                  title: 'Withdrawals',
                  amount: selectedDateWithdrawalsAmount,
                  count: selectedDateWithdrawalsCount,
                  icon: Icons.account_balance_wallet,
                  color: Colors.orange[600]!
                ),
                _buildDateStatCard(
                  title: 'Ad Spend (with GST)',
                  amount: totalWithGst,
                  detail: 'Base: ₹${adSpend.toStringAsFixed(2)} + GST: ₹${gst.toStringAsFixed(2)}',
                  icon: Icons.facebook,
                  color: Colors.blue[900]!
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            if (selectedDateAdInsights != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[100]!),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildMetricItem(
                      label: 'Impressions', 
                      value: NumberFormat.compact().format(selectedDateAdInsights!.impressions)
                    ),
                    _buildMetricItem(
                      label: 'CTR', 
                      value: '${(selectedDateAdInsights!.ctr * 100).toStringAsFixed(2)}%'
                    ),
                    _buildMetricItem(
                      label: 'CPC', 
                      value: '₹${selectedDateAdInsights!.cpc.toStringAsFixed(2)}'
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMetricItem({required String label, required String value}) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.blue[700],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: Colors.blue[900],
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildFacebookAdStatistics() {
    return Column(
      children: [
        _buildAdSpendCard(
          title: 'Today\'s Ad Spend',
          spend: todayAdInsights?.spend ?? 0,
          clicks: todayAdInsights?.clicks ?? 0,
          icon: Icons.facebook,
          iconColor: Colors.blue[900]!,
        ),
        const SizedBox(height: 16),
        _buildAdMetricsCard(),
      ],
    );
  }

  Widget _buildWithdrawalStatistics() {
    return Card(
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      shadowColor: Colors.orange.withOpacity(0.3),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.orange.withOpacity(0.05),
              Colors.white,
              Colors.orange.withOpacity(0.08),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.orange.withOpacity(0.2),
            width: 1,
          ),
        ),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Withdrawal Statistics',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.orange[700],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatBox(
                  title: 'Today\'s Withdrawals',
                  value: '₹${todayWithdrawalsAmount.toStringAsFixed(2)}',
                  active: '$todayWithdrawalsCount Transactions',
                  icon: Icons.today,
                  color: Colors.orange,
                ),
                _buildStatBox(
                  title: 'Yesterday\'s Withdrawals',
                  value: '₹${yesterdayWithdrawalsAmount.toStringAsFixed(2)}',
                  active: '$yesterdayWithdrawalsCount Transactions',
                  icon: Icons.history,
                  color: Colors.deepOrange,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Withdrawals',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.orange[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₹${totalWithdrawalsAmount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[700],
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.orange[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$totalWithdrawalsCount Total Transactions',
                      style: TextStyle(
                        color: Colors.orange[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ...existing code...
}

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  List<User> users = [];
  List<User> filteredUsers = [];
  bool isLoading = false;
  String errorMessage = '';
  
  // Filtering variables
  final TextEditingController _searchController = TextEditingController();
  String _statusFilter = 'All'; // All, Active, Inactive
  bool _showVerifiedOnly = false;
  double _minRating = 0.0;

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> fetchUsers() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });
    
    try {
      final response = await http.get(
        Uri.parse('https://api.ciliega.shop/GetAllAccountsGirls'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonData = json.decode(response.body);
        List<User> fetchedUsers =
            jsonData.map((json) => User.fromJson(json)).toList();
            
        setState(() {
          users = fetchedUsers;
          applyFilters();
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to fetch users. Status code: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching users: $e';
        isLoading = false;
      });
    }
  }
  
  void applyFilters() {
    setState(() {
      filteredUsers = users.where((user) {
        // Apply search filter
        bool matchesSearch = true;
        if (_searchController.text.isNotEmpty) {
          final searchTerm = _searchController.text.toLowerCase();
          matchesSearch = user.name.toLowerCase().contains(searchTerm) || 
                         user.email.toLowerCase().contains(searchTerm);
        }
        
        // Apply status filter
        bool matchesStatus = true;
        if (_statusFilter == 'Active') {
          matchesStatus = user.status.toLowerCase() == 'active';
        } else if (_statusFilter == 'Inactive') {
          matchesStatus = user.status.toLowerCase() != 'active';
        }
        
        // Apply verified filter
        bool matchesVerified = true;
        if (_showVerifiedOnly) {
          matchesVerified = user.isVerified;
        }
        
        // Apply rating filter
        bool matchesRating = user.rating >= _minRating;
        
        return matchesSearch && matchesStatus && matchesVerified && matchesRating;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profiles'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('User Management Application')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.blue[50]!, Colors.white],
                ),
              ),
              child: isLoading 
                ? Center(
                    child: SizedBox(
                      width: 48,
                      height: 48,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
                        strokeWidth: 5,
                      ),
                    ),
                  )
                : errorMessage.isNotEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.error_outline, color: Colors.red, size: 48),
                          SizedBox(height: 16),
                          Text(
                            errorMessage, 
                            style: TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: fetchUsers,
                            child: const Text('Try Again'),
                          ),
                        ],
                      ),
                    )
                  : filteredUsers.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.person_off, size: 48, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              users.isEmpty 
                                ? 'No users found' 
                                : 'No users match your filters',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[700],
                              ),
                            ),
                            if (users.isNotEmpty)
                              TextButton(
                                onPressed: () {
                                  _searchController.clear();
                                  _statusFilter = 'All';
                                  _showVerifiedOnly = false;
                                  _minRating = 0.0;
                                  applyFilters();
                                },
                                child: const Text('Clear Filters'),
                              ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: fetchUsers,
                        child: ListView.builder(
                          padding: const EdgeInsets.only(top: 12, bottom: 80),
                          itemCount: filteredUsers.length,
                          itemBuilder: (context, index) {
                            final user = filteredUsers[index];
                            return UserCard(
                              user: user,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProfileDetailScreen(user: user),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: fetchUsers,
        icon: const Icon(Icons.refresh),
        label: const Text('Refresh'),
        elevation: 4,
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        // Glassmorphism effect
        backgroundBlendMode: BlendMode.overlay,
      ),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        children: [
          // Search field
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search by name or email...',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
              prefixIcon: const Icon(Icons.search, color: Colors.white),
              filled: true,
              fillColor: Colors.white.withOpacity(0.2),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
            style: const TextStyle(color: Colors.white),
            onChanged: (value) {
              applyFilters();
            },
          ),
          const SizedBox(height: 10),
          
          // Filter options
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Status filter
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _statusFilter,
                      icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                      style: const TextStyle(color: Colors.white),
                      dropdownColor: Colors.blue[600],
                      items: ['All', 'Active', 'Inactive']
                          .map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _statusFilter = newValue;
                            applyFilters();
                          });
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                
                // Verified filter
                FilterChip(
                  label: const Text(
                    'Verified Only',
                    style: TextStyle(color: Colors.white),
                  ),
                  selected: _showVerifiedOnly,
                  checkmarkColor: Colors.white,
                  selectedColor: Colors.blue[500],
                  backgroundColor: Colors.white.withOpacity(0.2),
                  onSelected: (bool selected) {
                    setState(() {
                      _showVerifiedOnly = selected;
                      applyFilters();
                    });
                  },
                ),
                const SizedBox(width: 10),
                
                // Rating filter
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<double>(
                      value: _minRating,
                      icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                      style: const TextStyle(color: Colors.white),
                      dropdownColor: Colors.blue[600],
                      items: [0.0, 3.0, 4.0, 4.5]
                          .map((double value) {
                        return DropdownMenuItem<double>(
                          value: value,
                          child: Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                value == 0.0 ? 'Any Rating' : '≥ ${value.toString()}',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (double? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _minRating = newValue;
                            applyFilters();
                          });
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                
                // Clear filters button
                if (_searchController.text.isNotEmpty || 
                    _statusFilter != 'All' || 
                    _showVerifiedOnly || 
                    _minRating > 0.0)
                  ActionChip(
                    label: Row(
                       children: const [
                        Icon(Icons.clear, size: 16, color: Colors.white),
                        SizedBox(width: 4),
                        Text('Clear', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                    backgroundColor: Colors.red[400],
                    onPressed: () {
                      setState(() {
                        _searchController.clear();
                        _statusFilter = 'All';
                        _showVerifiedOnly = false;
                        _minRating = 0.0;
                        applyFilters();
                      });
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ...existing code...
}

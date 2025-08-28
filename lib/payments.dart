import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class Payment {
  final String updatedAt;
  final String app;
  final String date;
  final String paymentId;
  final String statusPay;
  final String createdAt;
  final String refId;
  final double amount;
  final String status;
  final String email;
  final String phone;
  final String upi;
  final String? utr;
  final String? payerName;
  final String? payeeUPI;
  final double? successDate;
  
  Payment({
    required this.updatedAt,
    required this.app,
    required this.date,
    required this.paymentId,
    required this.statusPay,
    required this.createdAt,
    required this.refId,
    required this.amount,
    required this.status,
    required this.email,
    required this.phone,
    required this.upi,
    this.utr,
    this.payerName,
    this.payeeUPI,
    this.successDate,
  });
  
  factory Payment.fromJson(Map<String, dynamic> json) {
    // Handle both lower-case and upper-case/snake_case keys
    String getKey(Map<String, dynamic> json, List<String> keys, [String defaultValue = '']) {
      for (var key in keys) {
      if (json.containsKey(key)) return json[key] ?? defaultValue;
      }
      return defaultValue;
    }

    double? getDouble(Map<String, dynamic> json, List<String> keys) {
      for (var key in keys) {
      if (json.containsKey(key)) {
        final val = json[key];
        if (val is num) return val.toDouble();
        if (val is String) return double.tryParse(val);
      }
      }
      return null;
    }

    return Payment(
      updatedAt: getKey(json, ['updated_at', 'updatedAt']),
      app: getKey(json, ['app']),
      date: getKey(json, ['Date', 'date']),
      paymentId: getKey(json, ['payment_id', 'paymentId']),
      statusPay: getKey(json, ['Statuspay', 'statuspay', 'statusPay']),
      createdAt: getKey(json, ['created_at', 'createdAt']),
      refId: getKey(json, ['refId', 'refid', 'ref_id']),
      amount: getDouble(json, ['amount']) ?? 0.0,
      status: getKey(json, ['Status', 'status']),
      email: getKey(json, ['email']),
      phone: getKey(json, ['phone'], 'N/A'),
      upi: getKey(json, ['upi']),
      utr: getKey(json, ['UTR', 'utr']),
      payerName: getKey(json, ['payerName', 'payername']),
      payeeUPI: getKey(json, ['payeeUPI', 'payee_upi', 'payeeupi']),
      successDate: getDouble(json, ['successDate', 'success_date']),
    );
  }
  
  // Helper getters for filtering and analytics
  bool get isSuccessful => status.toLowerCase() == 'success' || status.toUpperCase() == 'SUCCESS';
  bool get isPending => status.toLowerCase() == 'pending';
  
  DateTime? get dateTime {
    try {
      return DateTime.parse(date);
    } catch (e) {
      return null;
    }
  }
  
  bool isToday() {
    if (dateTime == null) return false;
    final now = DateTime.now();
    return dateTime!.year == now.year && 
           dateTime!.month == now.month && 
           dateTime!.day == now.day;
  }
}

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({Key? key}) : super(key: key);

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  List<Payment> payments = [];
  List<Payment> filteredPayments = [];
  bool isLoading = false;
  String errorMessage = '';
  
  // Filtering variables
  DateTime? _startDate;
  DateTime? _endDate;
  String _statusFilter = 'All'; // All, Success, Pending, Failed
  final TextEditingController _searchController = TextEditingController();
  double _minAmount = 0.0;
  double _maxAmount = 100000.0;
  bool _showFilters = false;

  // Statistics variables
  int totalSuccessCount = 0;
  double totalSuccessAmount = 0.0;
  int todaySuccessCount = 0;
  double todaySuccessAmount = 0.0;
  int todayFailedCount = 0;
  double todayFailedAmount = 0.0;
  int todayPendingCount = 0;
  double todayPendingAmount = 0.0;
  Map<String, double> userPaymentTotals = {};
  
  @override
  void initState() {
    super.initState();
    fetchPayments();
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  Future<void> fetchPayments() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });
    
    try {
      final response = await http.get(
        Uri.parse('https://api.ciliega.shop/GetAllPayments'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonData = json.decode(response.body);
        List<Payment> fetchedPayments =
            jsonData.map((json) => Payment.fromJson(json)).toList();

        // Sort by date descending (latest first)
        fetchedPayments.sort((a, b) {
          final aDate = a.dateTime ?? DateTime.fromMillisecondsSinceEpoch(0);
          final bDate = b.dateTime ?? DateTime.fromMillisecondsSinceEpoch(0);
          return bDate.compareTo(aDate);
        });

        setState(() {
          payments = fetchedPayments;
          _calculateStatistics();
          _applyFilters();
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to fetch payments. Status code: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching payments: $e';
        isLoading = false;
      });
    }
  }
  
  void _calculateStatistics() {
    // Reset statistics
    totalSuccessCount = 0;
    totalSuccessAmount = 0.0;
    todaySuccessCount = 0;
    todaySuccessAmount = 0.0;
    todayFailedCount = 0;
    todayFailedAmount = 0.0;
    todayPendingCount = 0;
    todayPendingAmount = 0.0;
    userPaymentTotals = {};
    
    for (var payment in payments) {
      if (payment.isSuccessful) {
        // Total successful payments
        totalSuccessCount++;
        totalSuccessAmount += payment.amount;
        
        // Today's successful payments
        if (payment.isToday()) {
          todaySuccessCount++;
          todaySuccessAmount += payment.amount;
        }
        
        // Per user payment totals
        if (userPaymentTotals.containsKey(payment.email)) {
          userPaymentTotals[payment.email] = (userPaymentTotals[payment.email] ?? 0) + payment.amount;
        } else {
          userPaymentTotals[payment.email] = payment.amount;
        }
      } else if (payment.isPending) {
        if (payment.isToday()) {
          todayPendingCount++;
          todayPendingAmount += payment.amount;
        }
      } else {
        if (payment.isToday()) {
          todayFailedCount++;
          todayFailedAmount += payment.amount;
        }
      }
    }
  }
  
  void _applyFilters() {
    setState(() {
      filteredPayments = payments.where((payment) {
        // Filter by search (email, payment ID, or UPI)
        bool matchesSearch = true;
        if (_searchController.text.isNotEmpty) {
          final searchTerm = _searchController.text.toLowerCase();
          matchesSearch = payment.email.toLowerCase().contains(searchTerm) ||
                         payment.paymentId.toLowerCase().contains(searchTerm) ||
                         payment.upi.toLowerCase().contains(searchTerm);
        }
        
        // Filter by status
        bool matchesStatus = true;
        if (_statusFilter == 'Success') {
          matchesStatus = payment.isSuccessful;
        } else if (_statusFilter == 'Pending') {
          matchesStatus = payment.isPending;
        } else if (_statusFilter == 'Failed') {
          matchesStatus = !payment.isSuccessful && !payment.isPending;
        }
        
        // Filter by date range
        bool matchesDateRange = true;
        if (_startDate != null || _endDate != null) {
          if (payment.dateTime != null) {
            if (_startDate != null && payment.dateTime!.isBefore(_startDate!)) {
              matchesDateRange = false;
            }
            if (_endDate != null) {
              // Add one day to include end date fully
              final adjustedEndDate = _endDate!.add(const Duration(days: 1));
              if (payment.dateTime!.isAfter(adjustedEndDate)) {
                matchesDateRange = false;
              }
            }
          } else {
            // If date can't be parsed, exclude it when date filtering is active
            matchesDateRange = false;
          }
        }
        
        // Filter by amount range
        bool matchesAmountRange = payment.amount >= _minAmount && payment.amount <= _maxAmount;
        
        return matchesSearch && matchesStatus && matchesDateRange && matchesAmountRange;
      }).toList();
    });
  }
  
  void _resetFilters() {
    setState(() {
      _searchController.clear();
      _statusFilter = 'All';
      _startDate = null;
      _endDate = null;
      _minAmount = 0.0;
      _maxAmount = 100000.0;
      _applyFilters();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Statistics Dashboard
          if (!isLoading && errorMessage.isEmpty && payments.isNotEmpty)
            _buildStatisticsDashboard(),
            
          // Filters Section
          if (_showFilters) _buildFilterSection(),
          
          // Payment List
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
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Loading payment data...'),
                      ],
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
                            onPressed: fetchPayments,
                            child: const Text('Try Again'),
                          ),
                        ],
                      ),
                    )
                  : filteredPayments.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.payment_outlined, size: 48, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              payments.isEmpty 
                                ? 'No payment records found'
                                : 'No payments match your filters',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[700],
                              ),
                            ),
                            if (payments.isNotEmpty)
                              TextButton(
                                onPressed: _resetFilters,
                                child: const Text('Clear Filters'),
                              ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: fetchPayments,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: filteredPayments.length,
                          itemBuilder: (context, index) {
                            final payment = filteredPayments[index];
                            return PaymentCard(payment: payment);
                          },
                        ),
                      ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: fetchPayments,
        icon: const Icon(Icons.refresh),
        label: const Text('Refresh'),
        elevation: 4,
      ),
    );
  }
  
  Widget _buildStatisticsDashboard() {
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 2);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[700],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(15),
          bottomRight: Radius.circular(15),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payment Dashboard',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          // Today's summary row
          Card(
            color: Colors.white,
            elevation: 1,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Success today
                  Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green[700], size: 18),
                          const SizedBox(width: 4),
                          const Text('Success', style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Text(
                        '$todaySuccessCount',
                        style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        currencyFormat.format(todaySuccessAmount),
                        style: TextStyle(color: Colors.green[700], fontSize: 12),
                      ),
                    ],
                  ),
                  // Pending today
                  Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.hourglass_empty, color: Colors.orange[700], size: 18),
                          const SizedBox(width: 4),
                          const Text('Pending', style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Text(
                        '$todayPendingCount',
                        style: TextStyle(color: Colors.orange[700], fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        currencyFormat.format(todayPendingAmount),
                        style: TextStyle(color: Colors.orange[700], fontSize: 12),
                      ),
                    ],
                  ),
                  // Failed today
                  Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.cancel, color: Colors.red[700], size: 18),
                          const SizedBox(width: 4),
                          const Text('Failed', style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Text(
                        '$todayFailedCount',
                        style: TextStyle(color: Colors.red[700], fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        currencyFormat.format(todayFailedAmount),
                        style: TextStyle(color: Colors.red[700], fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Total Successful Payments
                _buildStatisticCard(
                  icon: Icons.check_circle_outline,
                  iconColor: Colors.green,
                  title: 'Total Success',
                  value: '$totalSuccessCount payments',
                  subtitle: currencyFormat.format(totalSuccessAmount),
                ),
                
                // Today's Successful Payments
                _buildStatisticCard(
                  icon: Icons.today,
                  iconColor: Colors.amber,
                  title: 'Today\'s Success',
                  value: '$todaySuccessCount payments',
                  subtitle: currencyFormat.format(todaySuccessAmount),
                ),
                
                // Top User Card
                if (userPaymentTotals.isNotEmpty)
                  _buildStatisticCard(
                    icon: Icons.person,
                    iconColor: Colors.blue,
                    title: 'Top User',
                    value: _getTopUser(),
                    subtitle: currencyFormat.format(_getTopUserAmount()),
                  ),
                  
                // View All Users button
                _buildActionCard(
                  icon: Icons.people,
                  title: 'User Payments',
                  onTap: () {
                    _showUserPaymentsModal(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatisticCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(right: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(right: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 120,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.indigo, size: 28),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'View All',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildFilterSection() {
    return Container(
      color: Colors.blue[50],
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filter Payments',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton.icon(
                icon: const Icon(Icons.clear, size: 16),
                label: const Text('Clear All'),
                onPressed: _resetFilters,
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Search Field
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search by email, payment ID or UPI...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
            onChanged: (value) {
              _applyFilters();
            },
          ),
          const SizedBox(height: 16),
          
          // Filter Options
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Status Filter
                Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _statusFilter,
                      icon: const Icon(Icons.arrow_drop_down),
                      isDense: true,
                      hint: const Text('Status'),
                      items: ['All', 'Success', 'Pending', 'Failed']
                          .map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        if (value != null) {
                          setState(() {
                            _statusFilter = value;
                            _applyFilters();
                          });
                        }
                      },
                    ),
                  ),
                ),
                
                // Date Range Filter
                Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.date_range, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      TextButton(
                        onPressed: () async {
                          final DateTimeRange? picked = await showDateRangePicker(
                            context: context,
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                            initialDateRange: _startDate != null && _endDate != null
                                ? DateTimeRange(start: _startDate!, end: _endDate!)
                                : null,
                          );
                          if (picked != null) {
                            setState(() {
                              _startDate = picked.start;
                              _endDate = picked.end;
                              _applyFilters();
                            });
                          }
                        },
                        child: Text(
                          _getDateRangeText(),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      if (_startDate != null || _endDate != null)
                        IconButton(
                          icon: const Icon(Icons.clear, size: 16),
                          onPressed: () {
                            setState(() {
                              _startDate = null;
                              _endDate = null;
                              _applyFilters();
                            });
                          },
                        ),
                    ],
                  ),
                ),
                
                // Amount Range Filter
                Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.attach_money, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      TextButton(
                        onPressed: () {
                          _showAmountFilterDialog();
                        },
                        child: Text(
                          _getAmountRangeText(),
                          style: const TextStyle(fontSize: 12),
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
    );
  }
  
  void _showAmountFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        double tempMin = _minAmount;
        double tempMax = _maxAmount;
        
        return AlertDialog(
          title: const Text('Filter by Amount'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Text('Min: ₹'),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      initialValue: tempMin.toString(),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          tempMin = double.tryParse(value) ?? 0.0;
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Max: ₹'),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      initialValue: tempMax.toString(),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          tempMax = double.tryParse(value) ?? 100000.0;
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _minAmount = tempMin;
                  _maxAmount = tempMax;
                  _applyFilters();
                });
                Navigator.of(context).pop();
              },
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );
  }
  
  void _showUserPaymentsModal(BuildContext context) {
    // Sort users by payment amount
    final sortedUsers = userPaymentTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
      
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 2);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[700],
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'User Payment Summary',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                      Text(
                        '${sortedUsers.length} users with successful payments',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.all(0),
                    itemCount: sortedUsers.length,
                    itemBuilder: (context, index) {
                      final entry = sortedUsers[index];
                      final userEmail = entry.key;
                      final totalAmount = entry.value;
                      
                      // Count payments for this user
                      final userPayments = payments.where((p) => p.email == userEmail && p.isSuccessful).toList();
                      
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blueGrey,
                          child: Text(
                            userEmail.isNotEmpty ? userEmail[0].toUpperCase() : '?',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(
                          userEmail,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('${userPayments.length} payments'),
                        trailing: Text(
                          currencyFormat.format(totalAmount),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          _filterByEmail(userEmail);
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
  
  void _filterByEmail(String email) {
    setState(() {
      _searchController.text = email;
      _showFilters = true;
      _applyFilters();
    });
  }
  
  String _getTopUser() {
    if (userPaymentTotals.isEmpty) return 'N/A';
    
    final sortedUsers = userPaymentTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
      
    if (sortedUsers.isEmpty) return 'N/A';
    
    final topUserEmail = sortedUsers.first.key;
    // Truncate email if too long
    return topUserEmail.length > 15 
        ? '${topUserEmail.substring(0, 12)}...'
        : topUserEmail;
  }
  
  double _getTopUserAmount() {
    if (userPaymentTotals.isEmpty) return 0.0;
    
    final sortedUsers = userPaymentTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
      
    return sortedUsers.isEmpty ? 0.0 : sortedUsers.first.value;
  }
  
  String _getDateRangeText() {
    if (_startDate == null && _endDate == null) {
      return 'Select Dates';
    } else if (_startDate != null && _endDate == null) {
      return 'From ${_formatDateShort(_startDate!)}';
    } else if (_startDate == null && _endDate != null) {
      return 'Until ${_formatDateShort(_endDate!)}';
    } else {
      return '${_formatDateShort(_startDate!)} - ${_formatDateShort(_endDate!)}';
    }
  }
  
  String _getAmountRangeText() {
    if (_minAmount == 0.0 && _maxAmount == 100000.0) {
      return 'Any Amount';
    } else if (_minAmount > 0 && _maxAmount == 100000.0) {
      return '≥ ₹${_minAmount.toInt()}';
    } else if (_minAmount == 0.0 && _maxAmount < 100000.0) {
      return '≤ ₹${_maxAmount.toInt()}';
    } else {
      return '₹${_minAmount.toInt()} - ₹${_maxAmount.toInt()}';
    }
  }
  
  String _formatDateShort(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class PaymentCard extends StatelessWidget {
  final Payment payment;
  
  const PaymentCard({
    Key? key,
    required this.payment,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    Color statusColor;
    
    // Set color based on payment status
    if (payment.status.toLowerCase() == 'success') {
      statusColor = Colors.green;
    } else if (payment.status.toLowerCase() == 'pending') {
      statusColor = Colors.orange;
    } else {
      statusColor = Colors.red;
    }
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: statusColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: ExpansionTile(
        title: Row(
          children: [
            Icon(
              Icons.payment,
              color: statusColor,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Amount: ₹${payment.amount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  // Show payer name if available
                  if (payment.email != null && payment.email!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2, bottom: 2),
                      child: Text(
                        'Name: ${payment.email!}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blueGrey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    'ID: ${payment.paymentId}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                payment.status,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        subtitle: Text(
          'Date: ${_formatDate(payment.date)}',
          style: TextStyle(color: Colors.grey[600]),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Email', payment.email),
                _buildDetailRow('UPI ID', payment.upi),
                _buildDetailRow('Reference ID', payment.refId),
                _buildDetailRow('App', payment.app),
                if (payment.utr != null) _buildDetailRow('UTR', payment.utr!),
                if (payment.payerName != null) _buildDetailRow('Payer', payment.payerName!),
                if (payment.payeeUPI != null) _buildDetailRow('Payee UPI', payment.payeeUPI!),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Created: ${_formatDate(payment.createdAt)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      'Updated: ${_formatDate(payment.updatedAt)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  String _formatDate(String dateString) {
    try {
      final DateTime dateTime = DateTime.parse(dateString);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}';
    } catch (e) {
      return dateString;
    }
  }
}

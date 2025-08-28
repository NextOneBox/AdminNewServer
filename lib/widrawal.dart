import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart'; // <-- Add for clipboard

class WithdrawalPage extends StatefulWidget {
  const WithdrawalPage({Key? key}) : super(key: key);

  @override
  State<WithdrawalPage> createState() => _WithdrawalPageState();
}

class _WithdrawalPageState extends State<WithdrawalPage> {
  bool isLoading = true;
  List<WithdrawalModel> withdrawals = [];
  String error = '';

  @override
  void initState() {
    super.initState();
    fetchWithdrawals();
  }

  Future<void> fetchWithdrawals() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse('https://api.ciliega.shop/getAllWidrawals'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          withdrawals = data
              .map((json) {
                try {
                  return WithdrawalModel.fromJson(json);
                } catch (_) {
                  return null;
                }
              })
              .whereType<WithdrawalModel>()
              .toList();
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'Failed to load withdrawals: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error: $e';
        isLoading = false;
      });
    }
  }

  Future<bool> updateWithdrawal(String withdrawalId, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('https://api.ciliega.shop/UpdateWithdrawal/$withdrawalId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );
              print('Response: ${response.body}');

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Failed to update withdrawal: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error updating withdrawal: $e');
      return false;
    }
  }

  // Calculate metrics
  double getTotalWithdrawalAmount() {
    return withdrawals.fold(0, (sum, item) => sum + item.amount);
  }

  double getTodayWithdrawalAmount() {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return withdrawals
        .where((w) => w.date != null && w.date!.startsWith(today))
        .fold(0, (sum, item) => sum + item.amount);
  }

  int getTotalWithdrawals() {
    return withdrawals.length;
  }

  int getPendingWithdrawals() {
    return withdrawals.where((w) => (w.status?.toLowerCase() ?? '') == 'pending').length;
  }

  int getSuccessfulWithdrawals() {
    return withdrawals.where((w) => (w.status?.toLowerCase() ?? '') == 'success').length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Withdrawals'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchWithdrawals,
          ),
        ],
      ),
      body: isLoading 
          ? const Center(child: CircularProgressIndicator())
          : error.isNotEmpty 
              ? Center(child: Text(error, style: const TextStyle(color: Colors.red)))
              : Column(
                  children: [
                    _buildMetricsSection(),
                    Expanded(
                      child: _buildWithdrawalsList(),
                    ),
                  ],
                ),
    );
  }

  Widget _buildMetricsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.blue.shade50,
      child: Column(
        children: [
          Text(
            'Withdrawal Summary',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMetricCard(
                title: 'Total Amount',
                value: '₹${getTotalWithdrawalAmount().toStringAsFixed(2)}',
                icon: Icons.account_balance_wallet,
                color: Colors.blue,
              ),
              _buildMetricCard(
                title: 'Today\'s Amount',
                value: '₹${getTodayWithdrawalAmount().toStringAsFixed(2)}',
                icon: Icons.today,
                color: Colors.green,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMetricCard(
                title: 'Total',
                value: '${getTotalWithdrawals()}',
                icon: Icons.summarize,
                color: Colors.orange,
              ),
              _buildMetricCard(
                title: 'Pending',
                value: '${getPendingWithdrawals()}',
                icon: Icons.pending_actions,
                color: Colors.amber,
              ),
              _buildMetricCard(
                title: 'Success',
                value: '${getSuccessfulWithdrawals()}',
                icon: Icons.check_circle,
                color: Colors.green,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWithdrawalsList() {
    // Sort: pending first, then others
    final sortedWithdrawals = [...withdrawals];
    sortedWithdrawals.sort((a, b) {
      final aPending = (a.status?.toLowerCase() ?? '') == 'pending';
      final bPending = (b.status?.toLowerCase() ?? '') == 'pending';
      if (aPending && !bPending) return -1;
      if (!aPending && bPending) return 1;
      return 0;
    });

    return ListView.builder(
      itemCount: sortedWithdrawals.length,
      itemBuilder: (context, index) {
        final withdrawal = sortedWithdrawals[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: withdrawal.image != null
                ? CircleAvatar(
                    backgroundImage: NetworkImage(withdrawal.image!),
                    onBackgroundImageError: (_, __) {},
                    backgroundColor: Colors.grey[200],
                  )
                : const CircleAvatar(child: Icon(Icons.person)),
            title: Text('${withdrawal.name ?? 'N/A'} - ${withdrawal.withdrawalId ?? ''}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Amount: ₹${withdrawal.amount.toStringAsFixed(2)}'),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          if (withdrawal.upi != null && withdrawal.upi!.isNotEmpty) {
                            _showUserWithdrawals(withdrawal.upi!);
                          }
                        },
                        child: Text(
                          'UPI: ${withdrawal.upi ?? 'N/A'}',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            decoration: withdrawal.upi != null ? TextDecoration.underline : null,
                          ),
                        ),
                      ),
                    ),
                    if (withdrawal.upi != null && withdrawal.upi!.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.copy, size: 18),
                        tooltip: 'Copy UPI',
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: withdrawal.upi!));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('UPI copied to clipboard')),
                          );
                        },
                      ),
                  ],
                ),
                Text(
                  'Status: ${withdrawal.status ?? 'N/A'}',
                  style: TextStyle(
                    color: (withdrawal.status?.toLowerCase() == 'success')
                        ? Colors.green
                        : (withdrawal.status?.toLowerCase() == 'pending')
                            ? Colors.orange
                            : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  withdrawal.date != null
                      ? DateFormat('dd/MM/yy').format(DateTime.tryParse(withdrawal.date!) ?? DateTime.now())
                      : '',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                Text(
                  withdrawal.date != null
                      ? DateFormat('hh:mm a').format(DateTime.tryParse(withdrawal.date!) ?? DateTime.now())
                      : '',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            isThreeLine: true,
            onTap: () {
              _showWithdrawalDetails(withdrawal);
            },
          ),
        );
      },
    );
  }

  void _showWithdrawalDetails(WithdrawalModel withdrawal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'Withdrawal Details',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: withdrawal.image != null
                        ? Image.network(
                            withdrawal.image!,
                            height: 80,
                            width: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              height: 80,
                              width: 80,
                              color: Colors.grey[200],
                              child: const Icon(Icons.broken_image),
                            ),
                          )
                        : Container(
                            height: 80,
                            width: 80,
                            color: Colors.grey[200],
                            child: const Icon(Icons.person),
                          ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          withdrawal.name ?? 'N/A',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Text('Email: ${withdrawal.email ?? 'N/A'}'),
                        Text('Phone: ${withdrawal.phone ?? 'N/A'}'),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(),
              _detailRow('ID', withdrawal.withdrawalId ?? 'N/A'),
              _detailRow('Amount', '₹${withdrawal.amount.toStringAsFixed(2)}'),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (withdrawal.upi != null && withdrawal.upi!.isNotEmpty) {
                          _showUserWithdrawals(withdrawal.upi!);
                        }
                      },
                      child: _detailRow('UPI', withdrawal.upi ?? 'N/A'),
                    ),
                  ),
                  if (withdrawal.upi != null && withdrawal.upi!.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.copy, size: 18),
                      tooltip: 'Copy UPI',
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: withdrawal.upi!));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('UPI copied to clipboard')),
                        );
                      },
                    ),
                ],
              ),
              _detailRow('Status', withdrawal.status ?? 'N/A',
                color: (withdrawal.status?.toLowerCase() == 'success')
                    ? Colors.green
                    : (withdrawal.status?.toLowerCase() == 'pending')
                        ? Colors.orange
                        : Colors.red
              ),
              _detailRow(
                'Created',
                withdrawal.createdAt != null
                    ? DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.tryParse(withdrawal.createdAt!) ?? DateTime.now())
                    : 'N/A'
              ),
              _detailRow(
                'Updated',
                withdrawal.updatedAt != null
                    ? DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.tryParse(withdrawal.updatedAt!) ?? DateTime.now())
                    : 'N/A'
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      final success = await updateWithdrawal(
                        withdrawal.withdrawalId ?? '', 
                        {'Status': 'success'}
                      );
                      
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Withdrawal approved successfully')),
                        );
                        fetchWithdrawals(); // Refresh the list
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Failed to approve withdrawal'), 
                            backgroundColor: Colors.red
                          ),
                        );
                      }
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text('Approve'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final success = await updateWithdrawal(
                        withdrawal.withdrawalId ?? '', 
                        {'Status': 'rejected'}
                      );
                      
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Withdrawal rejected')),
                        );
                        fetchWithdrawals(); // Refresh the list
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Failed to reject withdrawal'), 
                            backgroundColor: Colors.red
                          ),
                        );
                      }
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text('Reject'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      await _launchPaytm(withdrawal);
                      // After payment, update status
                      final success = await updateWithdrawal(
                        withdrawal.withdrawalId ?? '', 
                        {'Status': 'success'}
                      );
                      
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Payment completed and status updated')),
                        );
                        fetchWithdrawals(); // Refresh the list
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                    child: const Text('Pay'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showUserWithdrawals(String upi) {
    final userWithdrawals = withdrawals.where((w) => w.upi == upi).toList();
    // Sort: pending first
    userWithdrawals.sort((a, b) {
      final aPending = (a.status?.toLowerCase() ?? '') == 'pending';
      final bPending = (b.status?.toLowerCase() ?? '') == 'pending';
      if (aPending && !bPending) return -1;
      if (!aPending && bPending) return 1;
      return 0;
    });
    // Get email from first withdrawal with this UPI
    final email = userWithdrawals.isNotEmpty ? (userWithdrawals.first.email ?? 'N/A') : 'N/A';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Withdrawals for UPI: $upi\n(Email: $email)',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Divider(),
              SizedBox(
                height: 300,
                child: userWithdrawals.isEmpty
                    ? const Center(child: Text('No withdrawals found for this UPI'))
                    : ListView.builder(
                        itemCount: userWithdrawals.length,
                        itemBuilder: (context, index) {
                          final w = userWithdrawals[index];
                          return ListTile(
                            leading: w.image != null
                                ? CircleAvatar(
                                    backgroundImage: NetworkImage(w.image!),
                                    onBackgroundImageError: (_, __) {},
                                    backgroundColor: Colors.grey[200],
                                  )
                                : const CircleAvatar(child: Icon(Icons.person)),
                            title: Text('${w.name ?? 'N/A'} - ${w.withdrawalId ?? ''}'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Amount: ₹${w.amount.toStringAsFixed(2)}'),
                                Text('Status: ${w.status ?? 'N/A'}'),
                                Text(
                                  w.date != null
                                      ? DateFormat('dd/MM/yy hh:mm a').format(DateTime.tryParse(w.date!) ?? DateTime.now())
                                      : '',
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              _showWithdrawalDetails(w);
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _launchPaytm(WithdrawalModel withdrawal) async {
    final paytm = 'paytmmp://cash_wallet?featuretype=money_transfer&pa=${withdrawal.upi}&am=${withdrawal.amount}&pn=AVENTE%20MATNITECH&tn=1pwk';
    final uri = Uri.parse(paytm);
    
    try {
      if (!await launchUrl(uri)) {
        throw Exception('Could not launch Paytm');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to launch Paytm: $e')),
      );
    }
  }

  Widget _detailRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: color != null ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WithdrawalModel {
  final String? updatedAt;
  final String? date;
  final String? createdAt;
  final String? image;
  final String? withdrawalId;
  final String? status;
  final double amount;
  final String? upi;
  final String? phone;
  final String? name;
  final String? email;

  WithdrawalModel({
    this.updatedAt,
    this.date,
    this.createdAt,
    this.image,
    this.withdrawalId,
    this.status,
    required this.amount,
    this.upi,
    this.phone,
    this.name,
    this.email,
  });

  factory WithdrawalModel.fromJson(Map<String, dynamic> json) {
    double parseAmount(dynamic value) {
      if (value == null) return 0.0;
      if (value is int) return value.toDouble();
      if (value is double) return value;
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return WithdrawalModel(
      updatedAt: json['updated_at']?.toString(),
      date: json['date']?.toString(),
      createdAt: json['created_at']?.toString(),
      image: json['image']?.toString(),
      withdrawalId: json['withdrawal_id']?.toString(),
      status: json['status']?.toString(),
      amount: parseAmount(json['amount']),
      upi: json['upi']?.toString(),
      phone: json['phone']?.toString(),
      name: json['name']?.toString(),
      email: json['email']?.toString(),
    );
  }
}

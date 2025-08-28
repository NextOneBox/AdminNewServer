import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// Add Withdrawal model class
class Withdrawal {
  final String id;
  final String email;
  final double amount;
  final String status;
  final String date;
  final String accountDetails;

  Withdrawal({
    required this.id,
    required this.email,
    required this.amount,
    required this.status,
    required this.date,
    required this.accountDetails,
  });

  factory Withdrawal.fromJson(Map<String, dynamic> json) {
    return Withdrawal(
      id: json['id']?.toString() ?? '',
      email: json['Email'] ?? '',
      amount: _parseDouble(json['Amount']),
      status: json['Status'] ?? 'pending',
      date: json['Date'] ?? '',
      accountDetails: json['AccountDetails'] ?? '',
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) {
      try {
        return double.parse(value);
      } catch (_) {
        return 0.0;
      }
    }
    return 0.0;
  }
}

class User {
  final String email;
  final String status;
  final String token;
  final dynamic lastActive;
  final String name;
  final String avatar;
  final String bio;
  final String phone;
  
  // Additional fields from the JSON data
  final String language;
  final String audioTime;
  final String hobby;
  final String audioUrl;
  final String accountType;
  final double rating;
  final bool isVerified;
  final String date;
  final String totalCalls;
  final double ratingNumber;
  final String accountId;
  final String videoTime;
  final String discCalls;
  final String gender;
  final String extra1;
  final String extra2;
  final String curAmount;
  final double amount;
  
  User({
    required this.email,
    required this.status,
    required this.token,
    required this.lastActive,
    required this.name,
    this.avatar = '',
    this.bio = '',
    this.phone = '',
    this.language = '',
    this.audioTime = '',
    this.hobby = '',
    this.audioUrl = '',
    this.accountType = '',
    this.rating = 0.0,
    this.isVerified = false,
    this.date = '',
    this.totalCalls = '',
    this.ratingNumber = 0.0,
    this.accountId = '',
    this.videoTime = '',
    this.discCalls = '',
    this.gender = '',
    this.extra1 = '',
    this.extra2 = '',
    this.curAmount = '',
    this.amount = 0.0,
  });
  
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      email: json['Email'] ?? '',
      status: json['Status'] ?? '',
      token: json['Token'] ?? '',
      lastActive: json['lastActive'] ?? DateTime.now().toString(),
      name: json['Name'] ?? '',
      avatar: json['Avatar'] ?? 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(json['Name'] ?? 'User')}',
      bio: json['Bio'] ?? 'No bio available',
      phone: _toString(json['Number']),
      language: json['Language'] ?? '',
      audioTime: _toString(json['audiotime']),
      hobby: json['Hobby'] ?? '',
      audioUrl: json['audioUrl'] ?? '',
      accountType: json['account_type'] ?? '',
      rating: _parseDouble(json['Rating']),
      isVerified: json['Isverified'] ?? false,
      date: json['Date'] ?? '',
      totalCalls: _toString(json['Totalcalls']),
      ratingNumber: _parseDouble(json['RatingNumber']),
      accountId: json['account_id'] ?? '',
      videoTime: _toString(json['videotime']),
      discCalls: _toString(json['DiscCalls']),
      gender: json['Gender'] ?? '',
      extra1: json['Extra1'] ?? '',
      extra2: json['Extra2'] ?? '',
      curAmount: _toString(json['CurAmount']),
      amount: _parseDouble(json['Amount']),
    );
  }
  
  // Helper method to convert any value to a string
  static String _toString(dynamic value) {
    if (value == null) return '0';
    if (value is String) return value;
    return value.toString();
  }
  
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) {
      try {
        return double.parse(value);
      } catch (_) {
        return 0.0;
      }
    }
    return 0.0;
  }
}

// Beautiful User Card for the list view
class UserCard extends StatelessWidget {
  final User user;
  final VoidCallback onTap;
  
  const UserCard({Key? key, required this.user, required this.onTap}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  Stack(
                    children: [
                      Hero(
                        tag: 'avatar-${user.email}',
                        child: CircleAvatar(
                          radius: 30,
                          backgroundImage: NetworkImage(user.avatar),
                        ),
                      ),
                      if (user.isVerified)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 1.5),
                            ),
                            child: const Icon(
                              Icons.verified,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name.isEmpty ? 'No Name' : user.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user.email,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        _buildRatingStarsSmall(user.rating),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: user.status == 'active' ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      user.status,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Divider(height: 1, color: Colors.grey[300]),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildCardStat(
                    Icons.call, 
                    'Calls', 
                    user.totalCalls
                  ),
                  _buildCardStat(
                    Icons.access_time, 
                    'Last Active', 
                    _getLastActiveShort(user.lastActive)
                  ),
                  _buildCardStat(
                    Icons.account_balance_wallet, 
                    'Earnings', 
                    '₹${user.amount.toStringAsFixed(0)}'
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardStat(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, size: 18, color: Colors.blue[700]),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildRatingStarsSmall(double rating) {
    return Row(
      children: [
        ...List.generate(
          5,
          (index) => Icon(
            index < rating.floor()
                ? Icons.star
                : (index < rating)
                    ? Icons.star_half
                    : Icons.star_border,
            color: Colors.amber,
            size: 14,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          rating.toString(),
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  String _getLastActiveShort(dynamic lastActive) {
    try {
      final dateTime = DateTime.parse(lastActive.toString());
      final now = DateTime.now();
      final difference = now.difference(dateTime);
      
      if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h ago';
      } else {
        return '${difference.inDays}d ago';
      }
    } catch (e) {
      return 'Unknown';
    }
  }
}

// Profile Detail Screen
class ProfileDetailScreen extends StatefulWidget {
  final User user;
  
  const ProfileDetailScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<ProfileDetailScreen> createState() => _ProfileDetailScreenState();
}

class _ProfileDetailScreenState extends State<ProfileDetailScreen> {
  bool isLoading = false;
  bool isUpdating = false;
  List<Withdrawal> withdrawals = [];
  String errorMessage = '';
  
  @override
  void initState() {
    super.initState();
    fetchWithdrawals();
  }

  Future<void> fetchWithdrawals() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });
    
    try {
      final response = await http.get(
        Uri.parse('https://api.ciliega.shop/GetWithdrawalsByEmail/${widget.user.email}'),
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        setState(() {
          withdrawals = jsonData.map((item) => Withdrawal.fromJson(item)).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to fetch withdrawals';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }
  
  Future<void> updateVerificationStatus(bool isVerified) async {
    setState(() {
      isUpdating = true;
    });
    
    try {
      final body = jsonEncode({
        "Email": widget.user.email,
        "Isverified": isVerified,
      });
      
      final response = await http.put(
        Uri.parse('https://api.ciliega.shop/UpdateAccountGirlsByEmail/${widget.user.email}'),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Verification status updated to ${isVerified ? 'verified' : 'unverified'}'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update status: ${response.statusCode}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating status: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isUpdating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250.0,
            floating: false,
            pinned: true,
            actions: [
              // Add verification toggle button
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: isUpdating
                    ? const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                      )
                    : Switch(
                        value: widget.user.isVerified,
                        activeColor: Colors.green,
                        onChanged: (value) {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(
                                value
                                    ? 'Verify User?'
                                    : 'Remove Verification?'
                              ),
                              content: Text(
                                value
                                    ? 'This will mark the user as verified.'
                                    : 'This will remove verification from the user.'
                              ),
                              actions: [
                                TextButton(
                                  child: const Text('CANCEL'),
                                  onPressed: () => Navigator.pop(context),
                                ),
                                TextButton(
                                  child: const Text('CONFIRM'),
                                  onPressed: () {
                                    updateVerificationStatus(value);
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
            // ...existing code for flexibleSpace...
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.user.name.isEmpty ? 'No Name' : widget.user.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      blurRadius: 4,
                      color: Colors.black45,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    widget.user.avatar,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                            colors: [Colors.blue[400]!, Colors.blue[800]!],
                          ),
                        ),
                        child: const Icon(
                          Icons.person,
                          size: 80,
                          color: Colors.white70,
                        ),
                      );
                    },
                  ),
                  // Gradient overlay for better text visibility
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.6),
                        ],
                      ),
                    ),
                  ),
                  // Verification badge
                  if (widget.user.isVerified)
                    Positioned(
                      top: 40,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.verified,
                              color: Colors.white,
                              size: 16,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Verified',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: _buildProfileDetails(),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBasicInfoCard(),
        _buildStatsCard(),
        _buildAboutCard(),
        _buildPreferencesCard(),
        // _buildStatusCard(),
        _buildFinancialDetails(),
        _buildWithdrawalsCard(),
        _buildAdditionalInfo(),
        const SizedBox(height: 20),
      ],
    );
  }

  // Add a new method to build the withdrawals card
  Widget _buildWithdrawalsCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Withdrawals',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isLoading)
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
          ),
          const Divider(),
          if (errorMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                errorMessage,
                style: const TextStyle(color: Colors.red),
              ),
            )
          else if (withdrawals.isEmpty && !isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('No withdrawal records found.'),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: withdrawals.length,
              itemBuilder: (context, index) {
                final withdrawal = withdrawals[index];
                return ListTile(
                  title: Row(
                    children: [
                      Text(
                        '₹${withdrawal.amount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      _buildWithdrawalStatus(withdrawal.status),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_formatDate(withdrawal.date)),
                      if (withdrawal.accountDetails.isNotEmpty)
                        Text(
                          'Account: ${withdrawal.accountDetails}',
                          style: const TextStyle(fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet,
                      color: Colors.orange,
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildWithdrawalStatus(String status) {
    Color color;
    IconData icon;
    
    switch (status.toLowerCase()) {
      case 'completed':
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case 'pending':
        color = Colors.orange;
        icon = Icons.pending;
        break;
      case 'rejected':
        color = Colors.red;
        icon = Icons.cancel;
        break;
      default:
        color = Colors.grey;
        icon = Icons.info;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            _capitalize(status),
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoCard() {
    return _buildInfoCard(
      title: 'Basic Information',
      content: [
        _buildInfoRow(Icons.email, 'Email', widget.user.email),
        _buildInfoRow(Icons.phone, 'Phone', widget.user.phone),
        _buildInfoRow(Icons.person, 'Gender', _capitalize(widget.user.gender)),
        _buildInfoRow(Icons.tag, 'Account ID', widget.user.accountId),
        _buildInfoRow(Icons.category, 'Account Type', _capitalize(widget.user.accountType)),
        _buildInfoRow(
          Icons.access_time,
          'Last Active',
          _formatLastActive(widget.user.lastActive),
        ),
        _buildInfoRow(
          Icons.calendar_today,
          'Created',
          _formatDate(widget.user.date),
        ),
      ],
    );
  }

  Widget _buildStatsCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Statistics',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildRatingStars(widget.user.rating),
              ],
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildStatRow('Total Calls', widget.user.totalCalls),
                const SizedBox(height: 8),
                _buildStatRow('Disconnected Calls', widget.user.discCalls),
                const SizedBox(height: 8),
                _buildStatRow('Audio Time', '${widget.user.audioTime} minutes'),
                const SizedBox(height: 8),
                _buildStatRow('Video Time', '${widget.user.videoTime} minutes'),
                const SizedBox(height: 8),
                _buildStatRow('Ratings Received', '${widget.user.ratingNumber}'),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAboutCard() {
    return _buildInfoCard(
      title: 'About',
      content: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            widget.user.bio,
            style: const TextStyle(fontSize: 16, height: 1.5),
          ),
        ),
        if (widget.user.audioUrl.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Introduction Audio',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const Icon(Icons.play_circle_fill, color: Colors.blue, size: 32),
                      const SizedBox(width: 12),
                      const Text('Play Audio Introduction'),
                      const Spacer(),
                      Text(
                        '${widget.user.audioTime} min',
                        style: TextStyle(
                          color: Colors.grey[600],
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
  }

  Widget _buildPreferencesCard() {
    return _buildInfoCard(
      title: 'Preferences',
      content: [
        _buildInfoRow(
          Icons.language,
          'Languages',
          widget.user.language.isEmpty ? 'Not specified' : widget.user.language,
        ),
        _buildInfoRow(
          Icons.interests,
          'Hobbies',
          widget.user.hobby.isEmpty ? 'Not specified' : widget.user.hobby,
        ),
      ],
    );
  }

  Widget _buildFinancialDetails() {
    return _buildInfoCard(
      title: 'Financial Details',
      content: [
        _buildInfoRow(
          Icons.account_balance_wallet,
          'Current Amount',
          '₹${widget.user.curAmount}',
        ),
        _buildInfoRow(
          Icons.monetization_on,
          'Total Earnings',
          '₹${widget.user.amount}',
        ),
      ],
    );
  }

  Widget _buildAdditionalInfo() {
    if (widget.user.extra1.isEmpty && widget.user.extra2.isEmpty) return const SizedBox.shrink();
    
    return _buildInfoCard(
      title: 'Additional Information',
      content: [
        if (widget.user.extra1.isNotEmpty)
          _buildInfoRow(Icons.info, 'Extra Info 1', widget.user.extra1),
        if (widget.user.extra2.isNotEmpty)
          _buildInfoRow(Icons.info_outline, 'Extra Info 2', widget.user.extra2),
      ],
    );
  }

  Widget _buildInfoCard({required String title, required List<Widget> content}) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Divider(),
          ...content,
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.blue),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey[700],
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildRatingStars(double rating) {
    return Row(
      children: [
        ...List.generate(
          5,
          (index) => Icon(
            index < rating.floor()
                ? Icons.star
                : (index < rating) 
                    ? Icons.star_half
                    : Icons.star_border,
            color: Colors.amber,
            size: 20,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          rating.toString(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  String _formatLastActive(dynamic lastActive) {
    try {
      final dateTime = DateTime.parse(lastActive.toString());
      final now = DateTime.now();
      final difference = now.difference(dateTime);
      
      if (difference.inMinutes < 60) {
        return '${difference.inMinutes} minutes ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours} hours ago';
      } else {
        return '${difference.inDays} days ago';
      }
    } catch (e) {
      return 'Unknown';
    }
  }
  
  String _formatDate(String dateString) {
    try {
      final dateTime = DateTime.parse(dateString);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } catch (e) {
      return dateString;
    }
  }
  
  String _capitalize(String text) {
    if (text.isEmpty) return '';
    return text[0].toUpperCase() + text.substring(1);
  }
}

// User List Screen
class UserListScreen extends StatelessWidget {
  final List<User> users;
  
  const UserListScreen({Key? key, required this.users}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return UserCard(
            user: user,
            onTap: () {
              // Navigate to profile detail screen
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
    );
  }
}

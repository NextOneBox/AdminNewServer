import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class BoyUser {
  final String email;
  final String status;
  final String token;
  final dynamic lastActive;
  final String name;
  final String avatar;
  final String bio;
  final String phone;
  
  // Additional fields
  final String language;
  final String accountType;
  final double rating;
  final bool isVerified;
  final String date;
  final String totalCalls;
  final double ratingNumber;
  final String accountId;
  final String gender;
  final String extra1;
  final String extra2;
  
  BoyUser({
    required this.email,
    required this.status,
    required this.token,
    required this.lastActive,
    required this.name,
    this.avatar = '',
    this.bio = '',
    this.phone = '',
    this.language = '',
    this.accountType = '',
    this.rating = 0.0,
    this.isVerified = false,
    this.date = '',
    this.totalCalls = '',
    this.ratingNumber = 0.0,
    this.accountId = '',
    this.gender = '',
    this.extra1 = '',
    this.extra2 = '',
  });
  
  factory BoyUser.fromJson(Map<String, dynamic> json) {
    return BoyUser(
      email: json['Email'] ?? '',
      status: json['Status'] ?? '',
      token: json['Token'] ?? '',
      lastActive: json['lastActive'] ?? DateTime.now().toString(),
      name: json['Name'] ?? '',
      avatar: json['Avatar'] ?? 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(json['Name'] ?? 'User')}&gender=male',
      bio: json['Bio'] ?? 'No bio available',
      phone: _toString(json['Number']),
      language: json['Language'] ?? '',
      accountType: json['account_type'] ?? '',
      rating: _parseDouble(json['Rating']),
      isVerified: json['Isverified'] ?? false,
      date: json['Date'] ?? '',
      totalCalls: _toString(json['Totalcalls']),
      ratingNumber: _parseDouble(json['RatingNumber']),
      accountId: json['account_id'] ?? '',
      gender: json['Gender'] ?? 'male',
      extra1: json['Extra1'] ?? '',
      extra2: json['Extra2'] ?? '',
    );
  }
  
  // Helper methods for type conversion
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

// User Card widget for the list view
class BoyUserCard extends StatelessWidget {
  final BoyUser user;
  final VoidCallback onTap;
  
  const BoyUserCard({Key? key, required this.user, required this.onTap}) : super(key: key);
  
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
                        tag: 'avatar-boy-${user.email}',
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
                    Icons.account_circle, 
                    'ID', 
                    user.accountId
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

// Boy Profile Detail Screen
class BoyProfileDetailScreen extends StatefulWidget {
  final BoyUser user;
  
  const BoyProfileDetailScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<BoyProfileDetailScreen> createState() => _BoyProfileDetailScreenState();
}

class _BoyProfileDetailScreenState extends State<BoyProfileDetailScreen> {
  bool isUpdating = false;

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
        Uri.parse('https://api.ciliega.shop/UpdateAccountBoyByEmail/${widget.user.email}'),
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
                            colors: [Colors.indigo[400]!, Colors.indigo[800]!],
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
        _buildStatusCard(),
        const SizedBox(height: 20),
      ],
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
      ],
    );
  }

  Widget _buildStatusCard() {
    bool isActive = widget.user.status == 'active';
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isActive 
            ? [Colors.green[300]!, Colors.green[500]!]
            : [Colors.red[300]!, Colors.red[500]!],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isActive ? Icons.check_circle : Icons.cancel,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isActive ? 'User is Active' : 'User is Inactive',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isActive
                      ? 'This user is currently online and available.'
                      : 'This user is currently offline or unavailable.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
              color: Colors.indigo.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.indigo),
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

// Boy User List Screen
class BoyUserListScreen extends StatefulWidget {
  const BoyUserListScreen({Key? key}) : super(key: key);

  @override
  State<BoyUserListScreen> createState() => _BoyUserListScreenState();
}

class _BoyUserListScreenState extends State<BoyUserListScreen> {
  List<BoyUser> users = [];
  List<BoyUser> filteredUsers = [];
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
    fetchBoyUsers();
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> fetchBoyUsers() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });
    
    try {
      final response = await http.get(
        Uri.parse('https://api.ciliega.shop/GetAllAccountsBoy'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonData = json.decode(response.body);
        List<BoyUser> fetchedUsers =
            jsonData.map((json) => BoyUser.fromJson(json)).toList();
            
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
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.indigo[50]!, Colors.white],
                ),
              ),
              child: isLoading 
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Loading profiles...'),
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
                            onPressed: fetchBoyUsers,
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
                        onRefresh: fetchBoyUsers,
                        child: ListView.builder(
                          padding: const EdgeInsets.only(top: 12, bottom: 80),
                          itemCount: filteredUsers.length,
                          itemBuilder: (context, index) {
                            final user = filteredUsers[index];
                            return BoyUserCard(
                              user: user,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => BoyProfileDetailScreen(user: user),
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
        onPressed: fetchBoyUsers,
        icon: const Icon(Icons.refresh),
        label: const Text('Refresh'),
        elevation: 4,
        backgroundColor: Colors.indigo,
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      color: Colors.indigo[700],
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
                      dropdownColor: Colors.indigo[600],
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
                  selectedColor: Colors.indigo[500],
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
                      dropdownColor: Colors.indigo[600],
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
}
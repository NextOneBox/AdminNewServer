import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/ad_insights.dart';

class FacebookAdService {
  static const String _baseUrl = 'https://graph.facebook.com/v17.0';
  static const String _accessToken = 'EAAOoNVRYZCgoBPNAdYpVDASDsZAuOF47UjunZA372vZAmkVSJgO85Dcj6aYnQ7JHfMKe5xE6ITE5nF4K79QLON2PNS47FZBtDpZBqczcOFbBPlZABBmVE6YZAGym65vLG4QsXr7Rq6i8aFKYc2CtZAKrubfD34pZCm1Uf7Ww0cyigU78nQHUHF5G8yapDgZAb2rB51nbaSw'; 

  // List of all ad account IDs
  static const List<String> _adAccountIds = [
    '1474652509966847',
    '897342495558476',
    '737639555126290'
  ];

  static Future<AdInsights> _getAdSpendForAccount(String accountId, DateTime date) async {
    try {
      final formattedDate = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
      
      // Ad account ID must be prefixed with 'act_'
      final response = await http.get(Uri.parse(
        '$_baseUrl/act_$accountId/insights'
        '?fields=spend,impressions,clicks,cpc,ctr'
        '&time_range={"since":"$formattedDate","until":"$formattedDate"}'
        '&level=account'
        '&access_token=$_accessToken'
      ));

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        if (responseData['data']?.isNotEmpty ?? false) {
          return AdInsights.fromJson(responseData['data'][0]);
        }
        return AdInsights(spend: 0, impressions: 0, clicks: 0, cpc: 0, ctr: 0, roas: 0);
      } else {
        // Parse Facebook API error message
        final error = responseData['error'] ?? {};
        final errorMessage = error['message'] ?? 'Unknown error';
        final errorType = error['type'] ?? '';
        final errorCode = error['code'] ?? '';
        print('Facebook API Error for account $accountId: $errorType ($errorCode) - $errorMessage');
        return AdInsights(spend: 0, impressions: 0, clicks: 0, cpc: 0, ctr: 0, roas: 0);
      }
    } catch (e) {
      print('Error fetching ad spend for account $accountId: ${e.toString()}');
      return AdInsights(spend: 0, impressions: 0, clicks: 0, cpc: 0, ctr: 0, roas: 0);
    }
  }

  static Future<AdInsights> getTodayAdSpend(DateTime date) async {
    try {
      List<AdInsights> allInsights = [];
      
      // Fetch data from all ad accounts
      for (String accountId in _adAccountIds) {
        final insights = await _getAdSpendForAccount(accountId, date);
        allInsights.add(insights);
      }
      
      // Combine all insights
      double totalSpend = 0;
      int totalImpressions = 0;
      int totalClicks = 0;
      double totalCpc = 0;
      double totalCtr = 0;
      
      for (var insights in allInsights) {
        totalSpend += insights.spend;
        totalImpressions += insights.impressions;
        totalClicks += insights.clicks;
        totalCpc += insights.cpc;
        totalCtr += insights.ctr;
      }
      
      // Calculate averages for CPC and CTR
      int validAccounts = allInsights.where((i) => i.spend > 0).length;
      if (validAccounts > 0) {
        totalCpc = totalCpc / validAccounts;
        totalCtr = totalCtr / validAccounts;
      }
      
      return AdInsights(
        spend: totalSpend,
        impressions: totalImpressions,
        clicks: totalClicks,
        cpc: totalCpc,
        ctr: totalCtr,
        roas: 0,
      );
    } catch (e) {
      throw Exception('Error fetching combined ad spend: ${e.toString()}');
    }
  }

  static Future<AdInsights> getDetailedAdInsights(DateTime date) async {
    try {
      List<AdInsights> allInsights = [];
      
      // Fetch detailed data from all ad accounts
      for (String accountId in _adAccountIds) {
        final insights = await _getDetailedAdInsightsForAccount(accountId, date);
        allInsights.add(insights);
      }
      
      // Combine all insights
      double totalSpend = 0;
      int totalImpressions = 0;
      int totalClicks = 0;
      double totalCpc = 0;
      double totalCtr = 0;
      
      for (var insights in allInsights) {
        totalSpend += insights.spend;
        totalImpressions += insights.impressions;
        totalClicks += insights.clicks;
        totalCpc += insights.cpc;
        totalCtr += insights.ctr;
      }
      
      // Calculate averages for CPC and CTR
      int validAccounts = allInsights.where((i) => i.spend > 0).length;
      if (validAccounts > 0) {
        totalCpc = totalCpc / validAccounts;
        totalCtr = totalCtr / validAccounts;
      }
      
      return AdInsights(
        spend: totalSpend,
        impressions: totalImpressions,
        clicks: totalClicks,
        cpc: totalCpc,
        ctr: totalCtr,
        roas: 0,
      );
    } catch (e) {
      throw Exception('Error fetching combined detailed ad insights: ${e.toString()}');
    }
  }

  static Future<AdInsights> _getDetailedAdInsightsForAccount(String accountId, DateTime date) async {
    try {
      final formattedDate = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
      
      // Ad account ID must be prefixed with 'act_'
      final response = await http.get(Uri.parse(
        '$_baseUrl/act_$accountId/insights'
        '?fields=spend,impressions,clicks,cpc,ctr,reach'
        '&time_range={"since":"$formattedDate","until":"$formattedDate"}'
        '&level=account'
        '&access_token=$_accessToken'
      ));

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        if (responseData['data']?.isNotEmpty ?? false) {
          return AdInsights.fromJson(responseData['data'][0]);
        }
        return AdInsights(spend: 0, impressions: 0, clicks: 0, cpc: 0, ctr: 0, roas: 0);
      } else {
        // Parse Facebook API error message
        final error = responseData['error'] ?? {};
        final errorMessage = error['message'] ?? 'Unknown error';
        final errorType = error['type'] ?? '';
        final errorCode = error['code'] ?? '';
        print('Facebook API Error for detailed insights account $accountId: $errorType ($errorCode) - $errorMessage');
        return AdInsights(spend: 0, impressions: 0, clicks: 0, cpc: 0, ctr: 0, roas: 0);
      }
    } catch (e) {
      print('Error fetching detailed ad insights for account $accountId: ${e.toString()}');
      return AdInsights(spend: 0, impressions: 0, clicks: 0, cpc: 0, ctr: 0, roas: 0);
    }
  }

  // Get ad spend breakdown by account for debugging
  static Future<Map<String, AdInsights>> getAdSpendByAccount(DateTime date) async {
    Map<String, AdInsights> accountInsights = {};
    
    for (String accountId in _adAccountIds) {
      try {
        final insights = await _getAdSpendForAccount(accountId, date);
        accountInsights[accountId] = insights;
      } catch (e) {
        print('Error fetching ad spend for account $accountId: $e');
        accountInsights[accountId] = AdInsights(spend: 0, impressions: 0, clicks: 0, cpc: 0, ctr: 0, roas: 0);
      }
    }
    
    return accountInsights;
  }
}

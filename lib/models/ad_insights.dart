class AdInsights {
  final double spend;
  final int impressions;
  final int clicks;
  final double cpc;
  final double ctr;
  final double roas;
  final int? reach;

  AdInsights({
    required this.spend,
    required this.impressions,
    required this.clicks,
    required this.cpc,
    required this.ctr,
    required this.roas,
    this.reach,
  });

  factory AdInsights.fromJson(Map<String, dynamic> json) {
    return AdInsights(
      spend: double.tryParse(json['spend'] ?? '0') ?? 0,
      impressions: int.tryParse(json['impressions'] ?? '0') ?? 0,
      clicks: int.tryParse(json['clicks'] ?? '0') ?? 0,
      cpc: double.tryParse(json['cpc'] ?? '0') ?? 0,
      ctr: double.tryParse(json['ctr'] ?? '0') ?? 0,
      roas: double.tryParse(json['roas'] ?? '0') ?? 0,
      reach: int.tryParse(json['reach'] ?? '0'),
    );
  }
}

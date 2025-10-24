class ThreatAnalysisResponse {
  final String messageType;
  final String contentPreview;
  final List<String> urlsFound;
  final List<UrlAnalysis> urlAnalyses;
  final String overallThreatLevel;
  final String threatSummary;
  final List<String> recommendations;
  final ThreatMetadata metadata;

  ThreatAnalysisResponse({
    required this.messageType,
    required this.contentPreview,
    required this.urlsFound,
    required this.urlAnalyses,
    required this.overallThreatLevel,
    required this.threatSummary,
    required this.recommendations,
    required this.metadata,
  });

  factory ThreatAnalysisResponse.fromJson(Map<String, dynamic> json) {
    return ThreatAnalysisResponse(
      messageType: json['message_type'] ?? '',
      contentPreview: json['content_preview'] ?? '',
      urlsFound: List<String>.from(json['urls_found'] ?? []),
      urlAnalyses: (json['url_analyses'] as List<dynamic>?)
          ?.map((e) => UrlAnalysis.fromJson(e))
          .toList() ?? [],
      overallThreatLevel: json['overall_threat_level'] ?? '',
      threatSummary: json['threat_summary'] ?? '',
      recommendations: List<String>.from(json['recommendations'] ?? []),
      metadata: ThreatMetadata.fromJson(json['metadata'] ?? {}),
    );
  }

  ThreatLevelType get threatLevelType {
    final level = overallThreatLevel.toLowerCase();
    if (level.contains('safe') || level.contains('clean')) {
      return ThreatLevelType.safe;
    } else if (level.contains('suspicious') || level.contains('warning')) {
      return ThreatLevelType.suspicious;
    } else if (level.contains('malicious') || level.contains('dangerous')) {
      return ThreatLevelType.malicious;
    } else {
      return ThreatLevelType.unknown;
    }
  }
}

class UrlAnalysis {
  final String url;
  final int maliciousCount;
  final int suspiciousCount;
  final int cleanCount;
  final int totalEngines;
  final String threatLevel;
  final String scanDate;
  final String permalink;

  UrlAnalysis({
    required this.url,
    required this.maliciousCount,
    required this.suspiciousCount,
    required this.cleanCount,
    required this.totalEngines,
    required this.threatLevel,
    required this.scanDate,
    required this.permalink,
  });

  factory UrlAnalysis.fromJson(Map<String, dynamic> json) {
    return UrlAnalysis(
      url: json['url'] ?? '',
      maliciousCount: json['malicious_count'] ?? 0,
      suspiciousCount: json['suspicious_count'] ?? 0,
      cleanCount: json['clean_count'] ?? 0,
      totalEngines: json['total_engines'] ?? 0,
      threatLevel: json['threat_level'] ?? '',
      scanDate: json['scan_date'] ?? '',
      permalink: json['permalink'] ?? '',
    );
  }
}

class ThreatMetadata {
  final String analysisDate;
  final int urlsAnalyzed;
  final bool virusTotalUsed;

  ThreatMetadata({
    required this.analysisDate,
    required this.urlsAnalyzed,
    required this.virusTotalUsed,
  });

  factory ThreatMetadata.fromJson(Map<String, dynamic> json) {
    return ThreatMetadata(
      analysisDate: json['analysis_date'] ?? '',
      urlsAnalyzed: json['urls_analyzed'] ?? 0,
      virusTotalUsed: json['virustotal_used'] ?? false,
    );
  }
}

enum ThreatLevelType {
  safe,
  suspicious,
  malicious,
  unknown,
}
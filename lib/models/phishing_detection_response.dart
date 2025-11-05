import 'package:flutter/material.dart';

class PhishingDetectionResponse {
  final String contentId;
  final List<String> extractedUrls;
  final List<UrlAnalysis> urlAnalyses;
  final String finalVerdict;
  final String threatLevel;
  final double confidenceScore;
  final String reasoning;
  final List<String> recommendations;
  final ThreatIntelligence threatIntelligence;
  final String timestamp;

  PhishingDetectionResponse({
    required this.contentId,
    required this.extractedUrls,
    required this.urlAnalyses,
    required this.finalVerdict,
    required this.threatLevel,
    required this.confidenceScore,
    required this.reasoning,
    required this.recommendations,
    required this.threatIntelligence,
    required this.timestamp,
  });

  factory PhishingDetectionResponse.fromJson(Map<String, dynamic> json) {
    return PhishingDetectionResponse(
      contentId: json['content_id'] ?? '',
      extractedUrls: List<String>.from(json['extracted_urls'] ?? []),
      urlAnalyses: (json['url_analyses'] as List<dynamic>?)
          ?.map((item) => UrlAnalysis.fromJson(item))
          .toList() ?? [],
      finalVerdict: json['final_verdict'] ?? '',
      threatLevel: json['threat_level'] ?? '',
      confidenceScore: (json['confidence_score'] ?? 0.0).toDouble(),
      reasoning: json['reasoning'] ?? '',
      recommendations: List<String>.from(json['recommendations'] ?? []),
      threatIntelligence: json['threat_intelligence'] != null
          ? ThreatIntelligence.fromJson(json['threat_intelligence'])
          : ThreatIntelligence.empty(),
      timestamp: json['timestamp'] ?? '',
    );
  }

  PhishingVerdictType get verdictType {
    final lowerVerdict = finalVerdict.toLowerCase();
    if (lowerVerdict.contains('safe') || lowerVerdict.contains('clean')) {
      return PhishingVerdictType.safe;
    } else if (lowerVerdict.contains('suspicious') || lowerVerdict.contains('warning')) {
      return PhishingVerdictType.suspicious;
    } else if (lowerVerdict.contains('phishing') || lowerVerdict.contains('malicious')) {
      return PhishingVerdictType.phishing;
    } else {
      return PhishingVerdictType.unknown;
    }
  }

  String get formattedTimestamp {
    try {
      final dateTime = DateTime.parse(timestamp);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return timestamp;
    }
  }
}

class UrlAnalysis {
  final String url;
  final String domain;
  final bool isPhishing;
  final double confidence;
  final double mlProbability;
  final int heuristicScore;
  final List<String> reasons;

  UrlAnalysis({
    required this.url,
    required this.domain,
    required this.isPhishing,
    required this.confidence,
    required this.mlProbability,
    required this.heuristicScore,
    required this.reasons,
  });

  factory UrlAnalysis.fromJson(Map<String, dynamic> json) {
    return UrlAnalysis(
      url: json['url'] ?? '',
      domain: json['domain'] ?? '',
      isPhishing: json['is_phishing'] ?? false,
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      mlProbability: (json['ml_probability'] ?? 0.0).toDouble(),
      heuristicScore: json['heuristic_score'] ?? 0,
      reasons: List<String>.from(json['reasons'] ?? []),
    );
  }

  String get riskLevel {
    if (isPhishing) return 'High Risk';
    if (confidence > 0.7) return 'Medium Risk';
    if (confidence > 0.3) return 'Low Risk';
    return 'Unknown';
  }

  Color get riskColor {
    if (isPhishing) return const Color(0xFFE57373);
    if (confidence > 0.7) return const Color(0xFFFFB74D);
    if (confidence > 0.3) return const Color(0xFF66BB6A);
    return const Color(0xFF9E9E9E);
  }
}

class ThreatIntelligence {
  final bool campaignDetected;
  final String? campaignName;
  final List<String> threatActors;
  final List<String> indicatorsOfCompromise;
  final List<String> relatedMalware;
  final double confidenceScore;
  final List<String> sources;
  final String lastSeen;

  ThreatIntelligence({
    required this.campaignDetected,
    this.campaignName,
    required this.threatActors,
    required this.indicatorsOfCompromise,
    required this.relatedMalware,
    required this.confidenceScore,
    required this.sources,
    required this.lastSeen,
  });

  factory ThreatIntelligence.fromJson(Map<String, dynamic> json) {
    return ThreatIntelligence(
      campaignDetected: json['campaign_detected'] ?? false,
      campaignName: json['campaign_name'],
      threatActors: List<String>.from(json['threat_actors'] ?? []),
      indicatorsOfCompromise: List<String>.from(json['indicators_of_compromise'] ?? []),
      relatedMalware: List<String>.from(json['related_malware'] ?? []),
      confidenceScore: (json['confidence_score'] ?? 0.0).toDouble(),
      sources: List<String>.from(json['sources'] ?? []),
      lastSeen: json['last_seen'] ?? '',
    );
  }

  factory ThreatIntelligence.empty() {
    return ThreatIntelligence(
      campaignDetected: false,
      threatActors: [],
      indicatorsOfCompromise: [],
      relatedMalware: [],
      confidenceScore: 0.0,
      sources: [],
      lastSeen: '',
    );
  }
}

enum PhishingVerdictType {
  safe,
  suspicious,
  phishing,
  unknown,
}
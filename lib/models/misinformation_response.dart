class MisinformationResponse {
  final String verdict;
  final String explanation;
  final List<String> claims;
  final List<String> sources;
  final DebugInfo? debugInfo;

  MisinformationResponse({
    required this.verdict,
    required this.explanation,
    required this.claims,
    required this.sources,
    this.debugInfo,
  });

  factory MisinformationResponse.fromJson(Map<String, dynamic> json) {
    return MisinformationResponse(
      verdict: json['verdict'] ?? '',
      explanation: json['explanation'] ?? '',
      claims: List<String>.from(json['claims'] ?? []),
      sources: List<String>.from(json['sources'] ?? []),
      debugInfo: json['debug_info'] != null 
          ? DebugInfo.fromJson(json['debug_info']) 
          : null,
    );
  }

  VerdictType get verdictType {
    final lowerVerdict = verdict.toLowerCase();
    if (lowerVerdict.contains('true') || lowerVerdict.contains('likely_true')) {
      return VerdictType.likelyTrue;
    } else if (lowerVerdict.contains('false') || lowerVerdict.contains('likely_false')) {
      return VerdictType.likelyFalse;
    } else {
      return VerdictType.uncertain;
    }
  }
}

class DebugInfo {
  final String initialVerdict;
  final List<String> searchQueriesUsed;
  final int searchResultsFound;

  DebugInfo({
    required this.initialVerdict,
    required this.searchQueriesUsed,
    required this.searchResultsFound,
  });

  factory DebugInfo.fromJson(Map<String, dynamic> json) {
    return DebugInfo(
      initialVerdict: json['initial_verdict'] ?? '',
      searchQueriesUsed: List<String>.from(json['search_queries_used'] ?? []),
      searchResultsFound: json['search_results_found'] ?? 0,
    );
  }
}

enum VerdictType {
  likelyTrue,
  likelyFalse,
  uncertain,
}
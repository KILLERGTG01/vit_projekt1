import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/phishing_detection_response.dart';

class PhishingDetectionScreen extends StatelessWidget {
  const PhishingDetectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Phishing Detection'),
        centerTitle: true,
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          if (provider.isPhishingDetectionLoading) {
            return _buildLoadingState(context);
          }

          if (provider.phishingDetectionError != null) {
            return _buildErrorState(context, provider.phishingDetectionError!);
          }

          if (provider.phishingDetectionResponse != null) {
            return _buildResponseState(context, provider.phishingDetectionResponse!);
          }

          return _buildNoDataState(context);
        },
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  strokeWidth: 4,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "Detecting phishing...",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Analyzing URLs and content patterns",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Card(
          color: Theme.of(context).colorScheme.errorContainer,
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.phishing_rounded,
                    color: Theme.of(context).colorScheme.error,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  "Detection Failed",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  error,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onErrorContainer.withValues(alpha: 0.8),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNoDataState(BuildContext context) {
    return Center(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.info_outline,
                color: Theme.of(context).colorScheme.primary,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                "No phishing detection data available",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResponseState(BuildContext context, PhishingDetectionResponse response) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildVerdictCard(context, response),
          const SizedBox(height: 24),
          _buildConfidenceCard(context, response),
          if (response.extractedUrls.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildExtractedUrlsCard(context, response.extractedUrls),
          ],
          if (response.urlAnalyses.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildUrlAnalysisCard(context, response.urlAnalyses),
          ],
          const SizedBox(height: 24),
          _buildReasoningCard(context, response.reasoning),
          const SizedBox(height: 24),
          _buildRecommendationsCard(context, response.recommendations),
          if (response.threatIntelligence.indicatorsOfCompromise.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildThreatIntelligenceCard(context, response.threatIntelligence),
          ],
          const SizedBox(height: 24),
          _buildMetadataCard(context, response),
        ],
      ),
    );
  }

  Widget _buildVerdictCard(BuildContext context, PhishingDetectionResponse response) {
    final verdictConfig = _getVerdictConfig(response.verdictType);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            verdictConfig.color.withValues(alpha: 0.1),
            verdictConfig.color.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: verdictConfig.color.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: verdictConfig.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              verdictConfig.icon,
              color: verdictConfig.color,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            response.finalVerdict.toUpperCase(),
            style: TextStyle(
              color: verdictConfig.color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Threat Level: ${response.threatLevel.toUpperCase()}',
            style: TextStyle(
              color: verdictConfig.color.withValues(alpha: 0.8),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildConfidenceCard(BuildContext context, PhishingDetectionResponse response) {
    final confidencePercentage = (response.confidenceScore * 100).round();
    final confidenceColor = _getConfidenceColor(response.confidenceScore);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: confidenceColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.analytics_outlined,
                    color: confidenceColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Confidence Score',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: response.confidenceScore,
                    backgroundColor: confidenceColor.withValues(alpha: 0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(confidenceColor),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  '$confidencePercentage%',
                  style: TextStyle(
                    color: confidenceColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExtractedUrlsCard(BuildContext context, List<String> urls) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B35).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.link_rounded,
                    color: Color(0xFFFF6B35),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Extracted URLs (${urls.length})',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: urls.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    urls[index],
                    style: const TextStyle(
                      color: Color(0xFFFF6B35),
                      fontSize: 12,
                      fontFamily: 'monospace',
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUrlAnalysisCard(BuildContext context, List<UrlAnalysis> analyses) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF66BB6A).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.security_rounded,
                  color: Color(0xFF66BB6A),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'URL Security Analysis',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: analyses.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              return _buildUrlAnalysisItem(analyses[index], context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildUrlAnalysisItem(UrlAnalysis analysis, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: analysis.riskColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  analysis.url,
                  style: TextStyle(
                    color: analysis.riskColor,
                    fontSize: 12,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: analysis.riskColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  analysis.riskLevel,
                  style: TextStyle(
                    color: analysis.riskColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildAnalysisMetric('Domain', analysis.domain, Colors.blue),
              const SizedBox(width: 16),
              _buildAnalysisMetric('Confidence', '${(analysis.confidence * 100).round()}%', analysis.riskColor),
              const SizedBox(width: 16),
              _buildAnalysisMetric('ML Score', '${(analysis.mlProbability * 100).round()}%', Colors.purple),
            ],
          ),
          if (analysis.reasons.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Analysis Notes:',
              style: TextStyle(
                color: Colors.black,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            ...analysis.reasons.take(3).map((reason) => Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                '• $reason',
                style: TextStyle(
                  color: Colors.black.withValues(alpha: 0.7),
                  fontSize: 11,
                ),
              ),
            )),
          ],
        ],
      ),
    );
  }

  Widget _buildAnalysisMetric(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.black.withValues(alpha: 0.6),
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildReasoningCard(BuildContext context, String reasoning) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2196F3).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.psychology_outlined,
                  color: Color(0xFF2196F3),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Analysis Reasoning',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              reasoning,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsCard(BuildContext context, List<String> recommendations) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF9C27B0).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.lightbulb_outline_rounded,
                  color: Color(0xFF9C27B0),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Security Recommendations',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recommendations.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Color(0xFF9C27B0),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      recommendations[index],
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildThreatIntelligenceCard(BuildContext context, ThreatIntelligence intel) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF5722).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.shield_outlined,
                  color: Color(0xFFFF5722),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Threat Intelligence',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (intel.campaignDetected) ...[
            _buildIntelItem('Campaign Detected', intel.campaignName ?? 'Unknown'),
            const SizedBox(height: 8),
          ],
          _buildIntelItem('Confidence Score', '${(intel.confidenceScore * 100).round()}%'),
          const SizedBox(height: 8),
          _buildIntelItem('Data Sources', intel.sources.join(', ')),
          if (intel.indicatorsOfCompromise.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text(
              'Indicators of Compromise:',
              style: TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ...intel.indicatorsOfCompromise.take(5).map((indicator) => Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '• $indicator',
                style: TextStyle(
                  color: Colors.black.withValues(alpha: 0.8),
                  fontSize: 12,
                ),
              ),
            )),
          ],
        ],
      ),
    );
  }

  Widget _buildIntelItem(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            '$label:',
            style: TextStyle(
              color: Colors.black.withValues(alpha: 0.7),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetadataCard(BuildContext context, PhishingDetectionResponse response) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.info_outline_rounded,
                  color: Colors.grey,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Detection Details',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMetadataItem('Content ID', response.contentId.substring(0, 8) + '...'),
              ),
              Expanded(
                child: _buildMetadataItem('URLs Found', '${response.extractedUrls.length}'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildMetadataItem('Analysis Time', response.formattedTimestamp),
        ],
      ),
    );
  }

  Widget _buildMetadataItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.black.withValues(alpha: 0.7),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  VerdictConfig _getVerdictConfig(PhishingVerdictType type) {
    switch (type) {
      case PhishingVerdictType.safe:
        return VerdictConfig(
          color: const Color(0xFF66BB6A),
          icon: Icons.shield_rounded,
        );
      case PhishingVerdictType.suspicious:
        return VerdictConfig(
          color: const Color(0xFFFFB74D),
          icon: Icons.warning_rounded,
        );
      case PhishingVerdictType.phishing:
        return VerdictConfig(
          color: const Color(0xFFE57373),
          icon: Icons.phishing_rounded,
        );
      case PhishingVerdictType.unknown:
        return VerdictConfig(
          color: const Color(0xFF9E9E9E),
          icon: Icons.help_outline_rounded,
        );
    }
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) return const Color(0xFF66BB6A);
    if (confidence >= 0.6) return const Color(0xFFFFB74D);
    if (confidence >= 0.4) return const Color(0xFFFF9800);
    return const Color(0xFFE57373);
  }
}

class VerdictConfig {
  final Color color;
  final IconData icon;

  VerdictConfig({
    required this.color,
    required this.icon,
  });
}
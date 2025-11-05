import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/threat_analysis_response.dart';
import 'package:url_launcher/url_launcher.dart';

class ThreatAnalysisScreen extends StatelessWidget {
  const ThreatAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Threat Analysis'),
        centerTitle: true,
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          if (provider.isThreatAnalysisLoading) {
            return _buildLoadingState(context);
          }

          if (provider.threatAnalysisError != null) {
            return _buildErrorState(context, provider.threatAnalysisError!);
          }

          if (provider.threatAnalysisResponse != null) {
            return _buildResponseState(context, provider.threatAnalysisResponse!);
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
                "Analyzing threats...",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "This may take a few moments",
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
                    Icons.security_rounded,
                    color: Theme.of(context).colorScheme.error,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  "Analysis Failed",
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
                "No threat analysis data available",
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

  Widget _buildResponseState(BuildContext context, ThreatAnalysisResponse response) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildThreatLevelCard(context, response),
          const SizedBox(height: 24),
          _buildContentPreviewCard(context, response.contentPreview),
          if (response.urlsFound.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildUrlsFoundCard(context, response.urlsFound),
          ],
          if (response.urlAnalyses.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildUrlAnalysisCard(context, response.urlAnalyses),
          ],
          const SizedBox(height: 24),
          _buildRecommendationsCard(context, response.recommendations),
          const SizedBox(height: 24),
          _buildMetadataCard(context, response.metadata),
        ],
      ),
    );
  }

  Widget _buildThreatLevelCard(BuildContext context, ThreatAnalysisResponse response) {
    final threatConfig = _getThreatConfig(response.threatLevelType);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            threatConfig.color.withValues(alpha: 0.1),
            threatConfig.color.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: threatConfig.color.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: threatConfig.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              threatConfig.icon,
              color: threatConfig.color,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            response.overallThreatLevel.toUpperCase(),
            style: TextStyle(
              color: threatConfig.color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            response.threatSummary,
            style: TextStyle(
              color: threatConfig.color.withValues(alpha: 0.8),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildContentPreviewCard(BuildContext context, String contentPreview) {
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
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.preview_outlined,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Content Preview',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
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
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Text(
                contentPreview,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.87),
                  fontSize: 14,
                  height: 1.5,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUrlsFoundCard(BuildContext context, List<String> urls) {
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
                'URLs Found (${urls.length})',
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
                  style: TextStyle(
                    color: const Color(0xFFFF6B35),
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
                'Security Analysis',
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
    final threatColor = _getThreatColorFromLevel(analysis.threatLevel);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: threatColor.withValues(alpha: 0.3),
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
                    color: threatColor,
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
                  color: threatColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  analysis.threatLevel,
                  style: TextStyle(
                    color: threatColor,
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
              _buildAnalysisMetric('Clean', analysis.cleanCount, const Color(0xFF66BB6A)),
              const SizedBox(width: 16),
              _buildAnalysisMetric('Suspicious', analysis.suspiciousCount, const Color(0xFFFFB74D)),
              const SizedBox(width: 16),
              _buildAnalysisMetric('Malicious', analysis.maliciousCount, const Color(0xFFE57373)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Scanned: ${analysis.scanDate}',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 10,
                ),
              ),
              InkWell(
                onTap: () => _launchUrl(analysis.permalink, context),
                child: Text(
                  'View Report',
                  style: TextStyle(
                    color: threatColor,
                    fontSize: 10,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisMetric(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          '$count',
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 10,
          ),
        ),
      ],
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
                'Recommendations',
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
                      style: TextStyle(
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

  Widget _buildMetadataCard(BuildContext context, ThreatMetadata metadata) {
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
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.info_outline_rounded,
                  color: Colors.red,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Analysis Details',
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
                child: _buildMetadataItem('Analysis Date', metadata.analysisDate),
              ),
              Expanded(
                child: _buildMetadataItem('URLs Analyzed', '${metadata.urlsAnalyzed}'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildMetadataItem('VirusTotal Used', metadata.virusTotalUsed ? 'Yes' : 'No'),
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
            color: Colors.black,
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

  ThreatConfig _getThreatConfig(ThreatLevelType type) {
    switch (type) {
      case ThreatLevelType.safe:
        return ThreatConfig(
          color: const Color(0xFF66BB6A),
          icon: Icons.shield_rounded,
        );
      case ThreatLevelType.suspicious:
        return ThreatConfig(
          color: const Color(0xFFFFB74D),
          icon: Icons.warning_rounded,
        );
      case ThreatLevelType.malicious:
        return ThreatConfig(
          color: const Color(0xFFE57373),
          icon: Icons.dangerous_rounded,
        );
      case ThreatLevelType.unknown:
        return ThreatConfig(
          color: const Color(0xFF9E9E9E),
          icon: Icons.help_outline_rounded,
        );
    }
  }

  Color _getThreatColorFromLevel(String level) {
    final lowerLevel = level.toLowerCase();
    if (lowerLevel.contains('safe') || lowerLevel.contains('clean')) {
      return const Color(0xFF66BB6A);
    } else if (lowerLevel.contains('suspicious') || lowerLevel.contains('warning')) {
      return const Color(0xFFFFB74D);
    } else if (lowerLevel.contains('malicious') || lowerLevel.contains('dangerous')) {
      return const Color(0xFFE57373);
    } else {
      return const Color(0xFF9E9E9E);
    }
  }

  Future<void> _launchUrl(String url, BuildContext context) async {
    try {
      final uri = Uri.parse(url);
      
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      
      if (!launched) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      debugPrint('Failed to launch URL: $url, Error: $e');
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open link'),
            backgroundColor: const Color(0xFFE57373),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }
}

class ThreatConfig {
  final Color color;
  final IconData icon;

  ThreatConfig({
    required this.color,
    required this.icon,
  });
}
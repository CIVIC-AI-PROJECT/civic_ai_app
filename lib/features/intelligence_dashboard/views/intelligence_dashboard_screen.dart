import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:civic_ai_app/features/intelligence_dashboard/viewmodels/intelligence_dashboard_viewmodel.dart';
import 'package:civic_ai_app/core/theme/app_theme.dart';
import 'package:civic_ai_app/models/grievance_analytics_models.dart';

class IntelligenceDashboardScreen extends StatefulWidget {
  const IntelligenceDashboardScreen({super.key});

  @override
  State<IntelligenceDashboardScreen> createState() =>
      _IntelligenceDashboardScreenState();
}

class _IntelligenceDashboardScreenState
    extends State<IntelligenceDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<IntelligenceDashboardViewModel>().loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Intelligence Dashboard'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<IntelligenceDashboardViewModel>().refreshAll();
            },
          ),
        ],
      ),
      body: Consumer<IntelligenceDashboardViewModel>(
        builder: (context, viewModel, _) {
          if (viewModel.isLoading && viewModel.dashboard == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading dashboard',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    viewModel.errorMessage!,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => viewModel.loadDashboard(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (viewModel.dashboard == null) {
            return const Center(child: Text('No data available'));
          }

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(
                    context,
                  ).colorScheme.primaryContainer.withOpacity(0.05),
                  Colors.white,
                ],
              ),
            ),
            child: RefreshIndicator(
              onRefresh: () => viewModel.refreshAll(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppTheme.largePadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Statistics Cards
                    _buildStatsGrid(viewModel.dashboard!.stats),
                    const SizedBox(height: 24),

                    // Recent Spikes
                    _buildSectionHeader('Recent Spikes', Icons.trending_up),
                    const SizedBox(height: 12),
                    _buildRecentSpikes(viewModel.dashboard!.recentSpikes),
                    const SizedBox(height: 24),

                    // Top Clusters
                    _buildSectionHeader('Grievance Clusters', Icons.group_work),
                    const SizedBox(height: 12),
                    _buildClusters(viewModel.dashboard!.topClusters),
                    const SizedBox(height: 24),

                    // Anomalies
                    _buildSectionHeader(
                      'Detected Anomalies',
                      Icons.warning_amber,
                    ),
                    const SizedBox(height: 12),
                    _buildAnomalies(viewModel.dashboard!.anomalies),
                    const SizedBox(height: 24),

                    // Category Distribution
                    _buildSectionHeader(
                      'Category Distribution',
                      Icons.pie_chart,
                    ),
                    const SizedBox(height: 12),
                    _buildCategoryDistribution(
                      viewModel.dashboard!.categoryDistribution,
                    ),
                    const SizedBox(height: 24),

                    // Resolution Rates
                    _buildSectionHeader(
                      'Resolution Rates',
                      Icons.check_circle_outline,
                    ),
                    const SizedBox(height: 12),
                    _buildResolutionRates(viewModel.dashboard!.resolutionRates),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(DashboardStats stats) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          'Total Grievances',
          stats.totalGrievances.toString(),
          Icons.description,
          Colors.blue,
        ),
        _buildStatCard(
          'Active',
          stats.activeGrievances.toString(),
          Icons.pending_actions,
          Colors.orange,
        ),
        _buildStatCard(
          'Resolved',
          stats.resolvedGrievances.toString(),
          Icons.check_circle,
          Colors.green,
        ),
        _buildStatCard(
          'Avg Resolution Time',
          '${stats.averageResolutionTime.toStringAsFixed(1)} days',
          Icons.timer,
          Colors.purple,
        ),
        _buildStatCard(
          'Clusters',
          stats.totalClusters.toString(),
          Icons.group_work,
          Colors.teal,
        ),
        _buildStatCard(
          'Anomalies',
          stats.totalAnomalies.toString(),
          Icons.warning,
          Colors.red,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color, size: 28),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentSpikes(List<RecentSpike> spikes) {
    if (spikes.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: Text('No recent spikes detected')),
        ),
      );
    }

    return Column(
      children: spikes.map((spike) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.red[100],
              child: Icon(Icons.trending_up, color: Colors.red[700]),
            ),
            title: Text(
              spike.category,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('${spike.region}\n${spike.description}'),
            isThreeLine: true,
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '+${spike.percentageIncrease.toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: Colors.red[700],
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '${spike.count} cases',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildClusters(List<GrievanceCluster> clusters) {
    if (clusters.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: Text('No clusters available')),
        ),
      );
    }

    return Column(
      children: clusters.map((cluster) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue[100],
              child: Text(
                cluster.count.toString(),
                style: TextStyle(
                  color: Colors.blue[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              cluster.category,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(cluster.region),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Keywords:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: cluster.keywords.map((keyword) {
                        return Chip(
                          label: Text(keyword),
                          backgroundColor: Colors.blue[50],
                          labelStyle: TextStyle(color: Colors.blue[700]),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAnomalies(List<GrievanceAnomaly> anomalies) {
    if (anomalies.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green[700]),
              const SizedBox(width: 12),
              const Expanded(child: Text('No anomalies detected')),
            ],
          ),
        ),
      );
    }

    return Column(
      children: anomalies.map((anomaly) {
        Color severityColor;
        switch (anomaly.severity.toLowerCase()) {
          case 'high':
            severityColor = Colors.red;
            break;
          case 'medium':
            severityColor = Colors.orange;
            break;
          default:
            severityColor = Colors.yellow[700]!;
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: severityColor.withOpacity(0.2),
              child: Icon(Icons.warning, color: severityColor),
            ),
            title: Text(
              anomaly.category,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('${anomaly.region}\n${anomaly.description}'),
            isThreeLine: true,
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: severityColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    anomaly.severity.toUpperCase(),
                    style: TextStyle(
                      color: severityColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Score: ${(anomaly.anomalyScore * 100).toStringAsFixed(0)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCategoryDistribution(Map<String, int> distribution) {
    final total = distribution.values.fold(0, (sum, value) => sum + value);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: distribution.entries.map((entry) {
            final percentage = total > 0 ? (entry.value / total * 100) : 0.0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        entry.key,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Text(
                        '${entry.value} (${percentage.toStringAsFixed(1)}%)',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: percentage / 100,
                    backgroundColor: Colors.grey[200],
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildResolutionRates(Map<String, double> rates) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: rates.entries.map((entry) {
            final percentage = entry.value * 100;
            final color = percentage >= 70
                ? Colors.green
                : percentage >= 40
                ? Colors.orange
                : Colors.red;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        entry.key,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Row(
                        children: [
                          Icon(
                            percentage >= 70
                                ? Icons.check_circle
                                : percentage >= 40
                                ? Icons.access_time
                                : Icons.warning,
                            color: color,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${percentage.toStringAsFixed(1)}%',
                            style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: entry.value,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

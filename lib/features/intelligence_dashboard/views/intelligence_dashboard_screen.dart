import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:civic_ai_app/features/intelligence_dashboard/viewmodels/intelligence_dashboard_viewmodel.dart';
import 'package:civic_ai_app/core/theme/app_theme.dart';
import 'package:civic_ai_app/core/widgets/app_bottom_navigation_bar.dart';
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
    return DefaultTabController(
      length: 3,
      child: Scaffold(
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
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Overview', icon: Icon(Icons.dashboard_outlined)),
              Tab(text: 'Graphs', icon: Icon(Icons.bar_chart_outlined)),
              Tab(text: 'Insights', icon: Icon(Icons.analytics_outlined)),
            ],
          ),
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
                    ).colorScheme.primaryContainer.withValues(alpha: 0.05),
                    Colors.white,
                  ],
                ),
              ),
              child: TabBarView(
                children: [
                  _buildOverviewTab(viewModel),
                  _buildGraphsTab(viewModel),
                  _buildInsightsTab(viewModel),
                ],
              ),
            );
          },
        ),
        bottomNavigationBar: const AppBottomNavigationBar(currentIndex: 3),
      ),
    );
  }

  Widget _buildOverviewTab(IntelligenceDashboardViewModel viewModel) {
    return RefreshIndicator(
      onRefresh: () => viewModel.refreshAll(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppTheme.largePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatsGrid(viewModel.dashboard!),
            const SizedBox(height: 24),
            _buildSectionHeader('Recent Spikes', Icons.trending_up),
            const SizedBox(height: 12),
            _buildRecentSpikes(viewModel.dashboard!.recentSpikes),
            const SizedBox(height: 24),
            _buildSectionHeader('Grievance Clusters', Icons.group_work),
            const SizedBox(height: 12),
            _buildClusters(viewModel.dashboard!.topClusters),
          ],
        ),
      ),
    );
  }

  Widget _buildGraphsTab(IntelligenceDashboardViewModel viewModel) {
    return RefreshIndicator(
      onRefresh: () => viewModel.refreshAll(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppTheme.largePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              'Cluster Distribution Graph',
              Icons.stacked_bar_chart,
            ),
            const SizedBox(height: 12),
            _buildClustersGraph(viewModel.dashboard!.topClusters),
            const SizedBox(height: 24),
            _buildSectionHeader('Spike Trend Graph', Icons.trending_up),
            const SizedBox(height: 12),
            _buildSpikeGraph(viewModel.dashboard!.recentSpikes),
            const SizedBox(height: 24),
            _buildSectionHeader('Issue Distribution', Icons.pie_chart),
            const SizedBox(height: 12),
            _buildIssueDistribution(viewModel.dashboard!.recentSpikes),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightsTab(IntelligenceDashboardViewModel viewModel) {
    return RefreshIndicator(
      onRefresh: () => viewModel.refreshAll(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppTheme.largePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Heatmap Intensity Insights', Icons.map),
            const SizedBox(height: 12),
            _buildStateHeatmapInsights(viewModel.dashboard!.stateHeatmap),
            const SizedBox(height: 24),
            _buildSectionHeader('Recent Spikes Summary', Icons.trending_up),
            const SizedBox(height: 12),
            _buildTopSpikes(viewModel.dashboard!.recentSpikes),
            const SizedBox(height: 24),
            _buildSectionHeader('Cluster Keywords', Icons.hub_outlined),
            const SizedBox(height: 12),
            _buildClusterKeywords(viewModel.dashboard!.topClusters),
          ],
        ),
      ),
    );
  }

  Widget _buildClustersGraph(List<GrievanceCluster> clusters) {
    if (clusters.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: Text('No cluster graph data available')),
        ),
      );
    }

    final maxCount = clusters
        .map((cluster) => cluster.count)
        .fold<int>(0, (max, value) => value > max ? value : max);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: clusters.map((cluster) {
            final ratio = maxCount == 0 ? 0.0 : cluster.count / maxCount;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Cluster ${cluster.clusterId}',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      Text(
                        cluster.count.toString(),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  LinearProgressIndicator(
                    value: ratio,
                    minHeight: 10,
                    borderRadius: BorderRadius.circular(5),
                    backgroundColor: Colors.grey[200],
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSpikeGraph(List<RecentSpike> spikes) {
    if (spikes.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: Text('No spike graph data available')),
        ),
      );
    }

    final maxGrowth = spikes
        .map((spike) => spike.growth)
        .fold<int>(0, (max, value) => value > max ? value : max);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: spikes.take(8).map((spike) {
            final ratio = maxGrowth == 0 ? 0.0 : spike.growth / maxGrowth;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${spike.state} • ${spike.issue}',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                          maxLines: 1,
                        ),
                      ),
                      Text(
                        '+${spike.growth}',
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  LinearProgressIndicator(
                    value: ratio,
                    minHeight: 10,
                    borderRadius: BorderRadius.circular(5),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
                    backgroundColor: Colors.red.shade50,
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildStateHeatmapInsights(Map<String, int> stateHeatmap) {
    if (stateHeatmap.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: Text('No heatmap insights available')),
        ),
      );
    }

    final sortedStates = stateHeatmap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topStates = sortedStates.take(10).toList();

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: topStates.map((entry) {
            final percentage =
                (entry.value / stateHeatmap.values.reduce((a, b) => a + b)) *
                100;
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
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${entry.value} cases',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  LinearProgressIndicator(
                    value: percentage / 100,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(5),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.deepOrange.withValues(alpha: 0.7),
                    ),
                    backgroundColor: Colors.deepOrange.withValues(alpha: 0.1),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
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

  Widget _buildStatsGrid(IntelligenceDashboard dashboard) {
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
          dashboard.totalRecords.toString(),
          Icons.description,
          Colors.blue,
        ),
        _buildStatCard(
          'Total Clusters',
          dashboard.topClusters.length.toString(),
          Icons.group_work,
          Colors.teal,
        ),
        _buildStatCard(
          'States Affected',
          dashboard.stateHeatmap.length.toString(),
          Icons.location_on,
          Colors.purple,
        ),
        _buildStatCard(
          'Recent Spikes',
          dashboard.recentSpikes.length.toString(),
          Icons.trending_up,
          Colors.orange,
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
      children: spikes.take(5).map((spike) {
        final growthPercentage =
            spike.previousCount == 0 && spike.recentCount > 0
            ? 100.0
            : spike.previousCount == 0
            ? 0.0
            : (spike.growth / spike.previousCount) * 100;

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
              spike.state,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('${spike.issue}\nRecent: ${spike.recentCount}'),
            isThreeLine: true,
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '+${spike.growth}',
                  style: TextStyle(
                    color: Colors.red[700],
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Growth: ${growthPercentage.toStringAsFixed(0)}%',
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
              'Cluster ${cluster.clusterId}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('${cluster.keywords.length} keywords'),
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
      children: anomalies.take(10).map((anomaly) {
        // Determine severity based on count
        late Color severityColor;
        late String severity;
        if (anomaly.count > 100) {
          severityColor = Colors.red;
          severity = 'HIGH';
        } else if (anomaly.count > 50) {
          severityColor = Colors.orange;
          severity = 'MEDIUM';
        } else if (anomaly.count > 20) {
          severityColor = Colors.amber;
          severity = 'LOW';
        } else {
          severityColor = Colors.blue;
          severity = 'INFO';
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: severityColor.withValues(alpha: 0.2),
              child: Icon(Icons.warning, color: severityColor),
            ),
            title: Text(
              anomaly.state,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              anomaly.issue,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
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
                    color: severityColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    severity,
                    style: TextStyle(
                      color: severityColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${anomaly.count} cases',
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

  Widget _buildIssueDistribution(List<RecentSpike> spikes) {
    if (spikes.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: Text('No issue distribution data')),
        ),
      );
    }

    // Group spikes by issue and sum counts
    final issueMap = <String, int>{};
    for (final spike in spikes) {
      issueMap[spike.issue] = (issueMap[spike.issue] ?? 0) + spike.recentCount;
    }

    final sortedIssues = issueMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topIssues = sortedIssues.take(6).toList();
    final maxCount = topIssues.isNotEmpty ? topIssues[0].value : 1;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: topIssues.map((entry) {
            final ratio = maxCount == 0 ? 0.0 : entry.value / maxCount;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          entry.key,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      Text(
                        '${entry.value}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  LinearProgressIndicator(
                    value: ratio,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.teal,
                    ),
                    backgroundColor: Colors.teal.withValues(alpha: 0.1),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTopSpikes(List<RecentSpike> spikes) {
    if (spikes.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: Text('No spikes to show')),
        ),
      );
    }

    final sortedSpikes = spikes.toList()
      ..sort((a, b) => b.growth.compareTo(a.growth));
    final topSpikes = sortedSpikes.take(5).toList();

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: topSpikes.asMap().entries.map((entry) {
            final index = entry.key + 1;
            final spike = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.red[100],
                    radius: 20,
                    child: Text(
                      index.toString(),
                      style: TextStyle(
                        color: Colors.red[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          spike.state,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          spike.issue,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '+${spike.growth}',
                        style: TextStyle(
                          color: Colors.red[700],
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '${spike.recentCount} now',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildClusterKeywords(List<GrievanceCluster> clusters) {
    if (clusters.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: Text('No cluster keywords available')),
        ),
      );
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: clusters.map((cluster) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Chip(
                        label: Text('Cluster ${cluster.clusterId}'),
                        backgroundColor: Colors.blue[100],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${cluster.count} grievances',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: cluster.keywords.take(5).map((keyword) {
                      return Chip(
                        label: Text(keyword),
                        backgroundColor: Colors.blue[50],
                        labelStyle: TextStyle(color: Colors.blue[700]),
                      );
                    }).toList(),
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

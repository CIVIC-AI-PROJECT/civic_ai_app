import 'dart:math' as math;

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

class _SparklinePainter extends CustomPainter {
  final List<double> values;
  final Color lineColor;
  final Color fillColor;

  _SparklinePainter({
    required this.values,
    required this.lineColor,
    required this.fillColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final minValue = values.reduce(math.min);
    final maxValue = values.reduce(math.max);
    final range = (maxValue - minValue).abs() < 0.0001
        ? 1.0
        : maxValue - minValue;

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    final points = <Offset>[];
    for (var index = 0; index < values.length; index++) {
      final x = values.length == 1
          ? size.width / 2
          : (index / (values.length - 1)) * size.width;
      final normalized = (values[index] - minValue) / range;
      final y = size.height - (normalized * (size.height - 14)) - 8;
      points.add(Offset(x, y));
    }

    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (var index = 1; index < points.length; index++) {
      final midX = (points[index - 1].dx + points[index].dx) / 2;
      linePath.quadraticBezierTo(
        midX,
        points[index - 1].dy,
        points[index].dx,
        points[index].dy,
      );
    }

    final areaPath = Path.from(linePath)
      ..lineTo(points.last.dx, size.height)
      ..lineTo(points.first.dx, size.height)
      ..close();

    final gridPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.15)
      ..strokeWidth = 1;
    for (var row = 1; row <= 3; row++) {
      final y = size.height * (row / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    canvas.drawPath(areaPath, fillPaint);
    canvas.drawPath(linePath, linePaint);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) {
    return oldDelegate.values != values ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.fillColor != fillColor;
  }
}

class _DonutChartPainter extends CustomPainter {
  final List<double> values;
  final List<Color> colors;

  _DonutChartPainter({required this.values, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final total = values.fold<double>(0, (sum, value) => sum + value);
    if (total <= 0) return;

    final stroke = size.shortestSide * 0.18;
    final rect = Rect.fromCircle(
      center: size.center(Offset.zero),
      radius: (size.shortestSide - stroke) / 2,
    );

    var start = -math.pi / 2;
    for (var index = 0; index < values.length; index++) {
      final sweep = (values[index] / total) * math.pi * 2;
      final paint = Paint()
        ..color = colors[index % colors.length]
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.butt;
      canvas.drawArc(rect, start, sweep, false, paint);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) {
    return oldDelegate.values != values || oldDelegate.colors != colors;
  }
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
              'Cluster Distribution (Bar Chart)',
              Icons.bar_chart,
            ),
            const SizedBox(height: 12),
            _buildClustersGraph(viewModel.dashboard!.topClusters),
            const SizedBox(height: 24),
            _buildSectionHeader('Spike Trend (Line Chart)', Icons.show_chart),
            const SizedBox(height: 12),
            _buildSpikeGraph(viewModel.dashboard!.recentSpikes),
            const SizedBox(height: 24),
            _buildSectionHeader(
              'Issue Distribution (Donut Chart)',
              Icons.pie_chart,
            ),
            const SizedBox(height: 12),
            _buildIssueDistribution(viewModel.dashboard!.recentSpikes),
            const SizedBox(height: 24),
            _buildSectionHeader('State Intensity Heatmap', Icons.grid_view),
            const SizedBox(height: 12),
            _buildStateHeatmapInsights(viewModel.dashboard!.stateHeatmap),
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
            _buildSectionHeader('Top Spikes (Ranked Bars)', Icons.trending_up),
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

    final chartData = clusters.take(6).toList();
    final maxCount = chartData
        .map((cluster) => cluster.count)
        .fold<int>(0, (max, value) => value > max ? value : max);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 180,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: chartData.map((cluster) {
                  final ratio = maxCount == 0 ? 0.0 : cluster.count / maxCount;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            '${cluster.count}',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.primaryTeal,
                                ),
                          ),
                          const SizedBox(height: 6),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 450),
                            curve: Curves.easeOut,
                            height: math.max(12, ratio * 120),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  AppTheme.primaryTeal,
                                  AppTheme.primaryTeal.withValues(alpha: 0.55),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'C${cluster.clusterId}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
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

    final trendData = spikes.take(10).toList();
    final points = trendData.map((spike) => spike.growth.toDouble()).toList();

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 180,
              width: double.infinity,
              child: CustomPaint(
                painter: _SparklinePainter(
                  values: points,
                  lineColor: Colors.red,
                  fillColor: Colors.red.withValues(alpha: 0.12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: trendData.take(4).map((spike) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${spike.state}: +${spike.growth}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.red[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
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
    final topStates = sortedStates.take(12).toList();
    final minValue = topStates
        .map((entry) => entry.value)
        .reduce(math.min)
        .toDouble();
    final maxValue = topStates
        .map((entry) => entry.value)
        .reduce(math.max)
        .toDouble();
    final range = (maxValue - minValue).abs() < 0.0001
        ? 1.0
        : (maxValue - minValue);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final crossAxisCount = width < 360
                    ? 2
                    : width < 520
                    ? 3
                    : 4;
                final tileWidth =
                    (width - ((crossAxisCount - 1) * 10)) / crossAxisCount;
                final childAspectRatio = tileWidth / 72;

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: topStates.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: childAspectRatio,
                  ),
                  itemBuilder: (context, index) {
                    final entry = topStates[index];
                    final normalized = ((entry.value - minValue) / range).clamp(
                      0.0,
                      1.0,
                    );
                    final cellColor = Color.lerp(
                      AppTheme.primaryTeal.withValues(alpha: 0.15),
                      AppTheme.primaryTeal,
                      normalized,
                    )!;

                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: cellColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppTheme.primaryTeal.withValues(alpha: 0.20),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            entry.key,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: normalized > 0.55
                                      ? Colors.white
                                      : AppTheme.darkText,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          Text(
                            '${entry.value}',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: normalized > 0.55
                                      ? Colors.white
                                      : AppTheme.darkText,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text('Low', style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryTeal.withValues(alpha: 0.15),
                          AppTheme.primaryTeal,
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text('High', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ],
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
    final topIssues = sortedIssues.take(5).toList();
    final total = topIssues.fold<int>(0, (sum, issue) => sum + issue.value);
    const palette = [
      Color(0xFF0F766E),
      Color(0xFF14B8A6),
      Color(0xFF2DD4BF),
      Color(0xFF5EEAD4),
      Color(0xFF99F6E4),
    ];

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            SizedBox(
              height: 140,
              width: 140,
              child: CustomPaint(
                painter: _DonutChartPainter(
                  values: topIssues.map((e) => e.value.toDouble()).toList(),
                  colors: palette,
                ),
                child: Center(
                  child: Text(
                    '$total\nTotal',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                children: topIssues.asMap().entries.map((entry) {
                  final color = palette[entry.key % palette.length];
                  final percentage = total == 0
                      ? 0
                      : (entry.value.value * 100 / total);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            entry.value.key,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                        Text(
                          '${percentage.toStringAsFixed(0)}%',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
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
    final maxGrowth = topSpikes
        .map((spike) => spike.growth)
        .fold<int>(0, (max, value) => value > max ? value : max);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: topSpikes.map((spike) {
            final ratio = maxGrowth == 0 ? 0.0 : spike.growth / maxGrowth;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${spike.state} • ${spike.issue}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '+${spike.growth}',
                        style: TextStyle(
                          color: Colors.red[700],
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: ratio,
                      minHeight: 10,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.red,
                      ),
                      backgroundColor: Colors.red.withValues(alpha: 0.12),
                    ),
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

// lib/widgets/mood_graph_widget.dart
// Mood visualization widget using fl_chart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:samvaad/data/models/mood_check_in.dart';
import 'package:samvaad/utils/app_colors.dart';

class MoodGraphWidget extends StatelessWidget {
  final List<MoodCheckIn> moodHistory;
  final Function(DateTime)? onDateTap;
  
  const MoodGraphWidget({
    super.key,
    required this.moodHistory,
    this.onDateTap,
  });
  
  @override
  Widget build(BuildContext context) {
    if (moodHistory.isEmpty) {
      return _buildEmptyState();
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '30-Day Mood History',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: LineChart(_buildLineChartData()),
          ),
          const SizedBox(height: 16),
          _buildLegend(),
        ],
      ),
    );
  }
  
  LineChartData _buildLineChartData() {
    final spots = <FlSpot>[];
    final moodValues = {
      'Happy': 4.0,
      'Calm': 3.0,
      'Anxious': 2.0,
      'Sad': 1.0,
    };
    
    // Sort by date
    final sortedHistory = List<MoodCheckIn>.from(moodHistory)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    
    for (int i = 0; i < sortedHistory.length; i++) {
      final mood = sortedHistory[i].mood;
      final value = moodValues[mood] ?? 2.5;
      spots.add(FlSpot(i.toDouble(), value));
    }
    
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: AppColors.lightGrey,
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: spots.length > 10 ? (spots.length / 5).ceilToDouble() : 1,
            getTitlesWidget: (value, meta) {
              if (value.toInt() >= sortedHistory.length) return const Text('');
              final date = sortedHistory[value.toInt()].timestamp;
              return Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  '${date.day}/${date.month}',
                  style: const TextStyle(
                    color: AppColors.greyText,
                    fontSize: 10,
                  ),
                ),
              );
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            reservedSize: 40,
            getTitlesWidget: (value, meta) {
              final moodLabels = {
                1.0: 'Sad',
                2.0: 'Anxious',
                3.0: 'Calm',
                4.0: 'Happy',
              };
              return Text(
                moodLabels[value] ?? '',
                style: const TextStyle(
                  color: AppColors.greyText,
                  fontSize: 10,
                ),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      minX: 0,
      maxX: spots.length > 1 ? spots.length.toDouble() - 1 : 1,
      minY: 0.5,
      maxY: 4.5,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.secondary],
          ),
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 4,
                color: Colors.white,
                strokeWidth: 2,
                strokeColor: AppColors.primary,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withOpacity(0.2),
                AppColors.secondary.withOpacity(0.1),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
      lineTouchData: LineTouchData(
        enabled: true,
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) {
              if (spot.spotIndex >= sortedHistory.length) return null;
              final checkIn = sortedHistory[spot.spotIndex];
              return LineTooltipItem(
                '${checkIn.mood}\n${checkIn.timestamp.day}/${checkIn.timestamp.month}',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              );
            }).toList();
          },
        ),
      ),
    );
  }
  
  Widget _buildLegend() {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        _buildLegendItem('Happy', AppColors.happy),
        _buildLegendItem('Calm', AppColors.calm),
        _buildLegendItem('Anxious', AppColors.anxious),
        _buildLegendItem('Sad', AppColors.sad),
      ],
    );
  }
  
  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.greyText,
          ),
        ),
      ],
    );
  }
  
  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightGrey),
      ),
      child: Column(
        children: [
          Icon(
            Icons.mood_outlined,
            size: 48,
            color: AppColors.greyText.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'No mood data yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Start tracking your mood to see patterns',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.greyText,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart' as charts;

class StatisticsView extends StatelessWidget {
  StatisticsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Statistics();
  }
}

class _StatisticsState extends State<Statistics> {
  @override
  Widget build(BuildContext context) {
    return Icon(Icons.auto_graph);
  }
}

class Statistics extends StatefulWidget {
  const Statistics({super.key});
  @override
  State<Statistics> createState() => _StatisticsState();
}

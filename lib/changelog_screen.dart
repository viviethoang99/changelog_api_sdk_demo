import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:changelog_api_sdk_demo/timelines.dart';

class TimeLineModel {
  final String name;
  final String version;
  final List<String> changelog;

  const TimeLineModel({
    required this.name,
    required this.version,
    required this.changelog,
  });

  factory TimeLineModel.fromJson(Map<String, dynamic> json) {
    return TimeLineModel(
      name: json['name'],
      version: json['version'],
      changelog: List<String>.from(json['changelog']),
    );
  }
}

class ChangeLogScreen extends StatefulWidget {
  const ChangeLogScreen({super.key});

  @override
  State<ChangeLogScreen> createState() => _ChangeLogScreenState();
}

class _ChangeLogScreenState extends State<ChangeLogScreen> {
  late Future<List<TimeLineModel>> _futureChangelog;

  @override
  void initState() {
    super.initState();
    _futureChangelog = _loadChangelog();
  }

  Future<List<TimeLineModel>> _loadChangelog() async {
    final String response = await rootBundle.loadString('assets/changelog.json');
    final List<dynamic> data = json.decode(response);
    return data.map((json) => TimeLineModel.fromJson(json)).toList().reversed.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: FutureBuilder<List<TimeLineModel>>(
        future: _futureChangelog,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading changelog'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No changelog available'));
          }

          final changelog = snapshot.data!;

          return SingleChildScrollView(
            child: Center(
              child: Container(
                alignment: Alignment.center,
                constraints: const BoxConstraints(
                  maxWidth: 600.0,
                ),
                padding: const EdgeInsets.all(20.0),
                child: FixedTimeline.tileBuilder(
                  theme: TimelineThemeData(
                    nodePosition: 0,
                    color: const Color(0xff989898),
                    indicatorTheme: const IndicatorThemeData(
                      position: 0,
                      size: 20.0,
                    ),
                    connectorTheme: const ConnectorThemeData(
                      thickness: 2.5,
                    ),
                  ),
                  builder: TimelineTileBuilder.connected(
                    connectionDirection: ConnectionDirection.before,
                    itemCount: changelog.length,
                    contentsBuilder: (_, index) {
                      final item = changelog[index];
                      return Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              item.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(vertical: 8.0),
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              width: double.infinity,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Align(
                                    alignment: Alignment.topRight,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 2.0,
                                        horizontal: 8.0,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(8.0),
                                      ),
                                      child: Text(item.version),
                                    ),
                                  ),
                                  ...item.changelog.map((log) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 4.0,
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            height: 12.0,
                                            width: 12.0,
                                            decoration: BoxDecoration(
                                              color: Colors.grey[400],
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 8.0),
                                          Expanded(
                                            child: Text(log),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    indicatorBuilder: (_, index) {
                      return const DotIndicator(
                        color: Color(0xff66c97f),
                        child: Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 12.0,
                        ),
                      );
                    },
                    connectorBuilder: (_, index, ___) => const SolidLineConnector(
                      color: Color(0xff66c97f),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

import 'dart:convert';
import 'package:flutter/services.dart';

class AppInfo {
  final String version;
  final String buildNumber;
  final String buildDate;
  final String author;
  final String website;
  final String license;
  final String support;

  const AppInfo({
    required this.version,
    required this.buildNumber,
    required this.buildDate,
    required this.author,
    required this.website,
    required this.license,
    required this.support,
  });

  factory AppInfo.fromJson(Map<String, dynamic> json) => AppInfo(
        version: json['version'] ?? '—',
        buildNumber: json['build_number'] ?? '—',
        buildDate: json['build_date'] ?? '—',
        author: json['author'] ?? '—',
        website: json['website'] ?? '',
        license: json['license'] ?? '—',
        support: json['support'] ?? '',
      );

  String get fullVersion => '$version+$buildNumber';
}

class AppInfoService {
  static AppInfo? _cached;

  static Future<AppInfo> load() async {
    if (_cached != null) return _cached!;
    final raw = await rootBundle.loadString('assets/data/app_info.json');
    _cached = AppInfo.fromJson(json.decode(raw));
    return _cached!;
  }

  /// Call once at app startup to warm the cache.
  static Future<void> init() async => await load();
}

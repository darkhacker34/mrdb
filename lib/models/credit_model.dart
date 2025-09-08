import 'package:cupertino_icons/cupertino_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
class InfoModel {
  final IconData icon;
  final String? topTxt;
  final String centreTxt;
  final String? subTxt;
  final String? lastTxt;
  final String? onTap;

  InfoModel({
    required this.icon,
    this.topTxt,
    this.lastTxt,
    this.onTap,
    required this.centreTxt,
    this.subTxt,
  });

  // Convert from map
  factory InfoModel.fromMap(Map<String, dynamic> map) {
    return InfoModel(
      icon: map['icon'] ?? '',
      topTxt: map['topTxt'] ?? '',
      centreTxt: map['centreTxt'] ?? '',
      lastTxt: map['lastTxt'] ?? '',
      onTap: map['onTap'] ?? '',
      subTxt: map['subTxt'] ?? '',
    );
  }

  // Convert to map
  Map<String, dynamic> toMap() {
    return {
      'icon': icon,
      'topTxt': topTxt,
      'centreTxt': centreTxt,
      'onTap': onTap,
      'subTxt': subTxt,
      'lastTxt': lastTxt,
    };
  }
}
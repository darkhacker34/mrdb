
import 'dart:io';

import 'package:amicons/amicons.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:mrdb/home/navs/about.dart';
import 'package:mrdb/home/navs/fav.dart';
import 'package:mrdb/home/navs/first_page/home_page.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import '../constens/keys.dart';
import '../provider/client.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

List pages=[
  HomePage(),
  Favorite(),
  About()
];
int currentIndex=0;

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        extendBody: true,
        bottomNavigationBar: GNav(
          backgroundColor: Colors.grey.shade900,
          onTabChange: (value) {
            setState(() {
              currentIndex=value;
            });
          },
            rippleColor: Colors.transparent,
            hoverColor: Colors.transparent,
            tabBorderRadius: wt*0.02,
            color: Colors.grey.shade600,
            activeColor: Colors.white,
            iconSize: wt*0.08,
            style: GnavStyle.oldSchool,
            tabBackgroundColor: Colors.transparent,
            padding: EdgeInsets.symmetric(horizontal: wt*0.09, vertical: wt*0.02),
            tabs: [
              GButton(
                icon: Amicons.iconly_home,
                text: 'Home',
              ),
              GButton(
                icon: Amicons.flaticon_comment_heart_rounded,
                text: 'Favorite',
              ),
              GButton(
                icon: Amicons.lucide_badge_info,
                text: 'Info',
              ),
            ]
        ),
        body: Padding(
          padding: EdgeInsets.only(bottom: ht*0.06),
        child: pages[currentIndex],
        ),
      ),
    );
  }
}

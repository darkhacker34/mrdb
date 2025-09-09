import 'dart:convert';
import 'dart:io';

import 'package:amicons/amicons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:mrdb/home/bottom_nav.dart';
import 'package:mrdb/provider/client.dart';
import 'package:pretty_animated_text/pretty_animated_text.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'main.dart';
import 'constens/keys.dart';
List<dynamic> all = [];
class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}
int pageNum = DateTime.now().second;


class _SplashState extends State<Splash> {
  Future<void> shClear() async {
    SharedPreferences preferences= await SharedPreferences.getInstance();
    preferences.clear();
  }
  Future<void> getDeviceDetails() async {
    await getMovie();
    final deviceInfo = DeviceInfoPlugin();
      SharedPreferences preferences = await SharedPreferences.getInstance();
      final oldSavedDev = preferences.getStringList('phone')??[];
      final androidInfo = await deviceInfo.androidInfo;
      bool isAlreadySaved=oldSavedDev.isNotEmpty;

      if(isAlreadySaved) {
        if(mounted) {
          Provider.of<ClientProvider>(
            context,
            listen: false,
          ).setClientId(androidInfo.id);
        }
        await preferences.setStringList('phone', [
          androidInfo.brand,
          androidInfo.model,
          androidInfo.version.release,
          androidInfo.id
        ]);
        if(mounted)Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainScreen(),));

      }else{
        FirebaseFirestore.instance.collection(AppConstants.phone).doc(androidInfo.id.toString())
            .set({
          "brand": androidInfo.brand,
          "model": androidInfo.model,
          "version": androidInfo.version.release,
          "id": androidInfo.id,
        }, SetOptions(merge: true));
        await preferences.setStringList('phone', [
          androidInfo.brand,
          androidInfo.model,
          androidInfo.version.release,
          androidInfo.id
        ]);
        if(mounted) {
          Provider.of<ClientProvider>(
          context,
          listen: false,
        ).setClientId(androidInfo.id);
        }
        if(mounted) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainScreen(),));
        }
      }

  }
  Future<void> getMovie({bool refresh = false}) async {

    Uri url = Uri.parse(
      'https://api.themoviedb.org/3/movie/popular'
          '?api_key=${AppConstants.apiKey}'
          '&sort_by=popularity.desc'
          '&page=$pageNum',
    );
    int attempts = 0;

    while (attempts < 10) {
      try {
        final res = await http.get(url);
          final data = jsonDecode(res.body);
          setState(() {
            all.addAll(data['results']);
          });
          return;
      } catch (e) {
        attempts++;
        if (attempts < 10) {
          await Future.delayed(const Duration(seconds: 1));
        } else {
          if(!mounted) return;
        }
      }
    }
  }


  @override
  void initState() {
    // shClear();
    getDeviceDetails();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(),
              Container(
                width: wt*0.45,
                height: ht*0.2,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(wt*0.03),
                  border: Border.all(
                    color: Colors.green.withOpacity(0.6),
                    width: 2
                  )
                ),
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Icon(Amicons.iconly_video,color: Colors.green,size: wt*0.15,),
                      Text('MRDB',
                        style: TextStyle(
                          fontSize: wt * 0.1,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              LoadingAnimationWidget.newtonCradle(color: Colors.green, size: wt*0.25)
            ],
          ),
        ),
      ),
    );
  }
}

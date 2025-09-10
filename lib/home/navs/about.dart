import 'package:amicons/amicons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cupertino_icons/cupertino_icons.dart';
import 'package:flutter/services.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:mrdb/constens/keys.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../main.dart';
import '../../models/credit_model.dart';
import '../../models/movie_model.dart';

class About extends StatefulWidget {
  const About({super.key});

  @override
  State<About> createState() => _AboutState();
}

class _AboutState extends State<About> {
  bool isLoding=true;
  List device=[];
  List reDirecting=[];
  Future<void> getPhoneDetails() async {
   try{
     SharedPreferences preferences = await SharedPreferences.getInstance();
     List<String>? phoneData = preferences.getStringList('phone');
     setState(() {
       device = phoneData??['Unknown', 'Unknown Model', 'Unknown Version', 'Unknown ID'];
       isLoding=false;
     });
   }catch(e){
     setState(() {
       device = ['Unknown', 'Unknown Model', 'Unknown Version', 'Unknown ID'];
       isLoding = false;
     });
   }
  }
  Future<void> nav({required String url}) async {
    Uri ur;
    if(url.contains('@')){
      ur=Uri(
        scheme: 'mailto',
        path: url,
        queryParameters: {
          'subject': 'Hello!,Nihal',
          'body': 'MRDb ...'
        },
      );
    }else{
      ur = Uri.parse(url);
    }
    if(await canLaunchUrl(ur)){
      await launchUrl(ur);
    }
  }


  @override
  void initState() {
    getPhoneDetails();
    super.initState();
  }
  @override
  build(BuildContext context) {
    List<InfoModel> getCredits() {
      return [
        InfoModel(
          icon: Amicons.remix_admin,
          topTxt: 'Developer',
          centreTxt: 'Nihal M',
          subTxt: 'Mobile App Developer',
        ),
        InfoModel(
          icon: Amicons.flaticon_chart_network_rounded,
          topTxt: 'API Provider',
          centreTxt: 'The Movie Database (TMDB)',
          subTxt: 'Movie Details Scrap',
        ),
        InfoModel(
          icon: Amicons.remix_flutter,
          topTxt: 'Design Inspiration',
          centreTxt: 'Material Design',
          subTxt: 'UI/UX Guideline',
        ),
      ];
    }
    List<InfoModel> getSupportOptions(){
      return [
        InfoModel(
            icon: Amicons.lucide_mail,
            centreTxt: 'Contact Mail',
            lastTxt: 'Redirecting to Mail Box...',
            subTxt: 'nihalthoppil16@gmail.com',
            onTap: 'nihalthoppil16@gmail.com'
        ),
        InfoModel(
            icon: Amicons.lucide_instagram,
            centreTxt: 'Instagram',
            lastTxt: 'Redirecting to Instagram...',
            subTxt: 'nihh____al',
            onTap: 'https://www.instagram.com/nihh____al'
        ),
        InfoModel(
            icon: Amicons.remix_whatsapp,
            centreTxt: 'WhatsApp',
            lastTxt: 'Redirecting to WhatsApp...',
            subTxt: '+91 9605945341',
            onTap: 'https://wa.me/919605945341'
        ),
      ];
    }
    List<InfoModel> getDeviceInfo(){
      while (device.length < 4) {
        device.add('Unknown');
      }
      return [
        InfoModel(
          icon: Amicons.vuesax_device_message,
          centreTxt: 'Brand',
          lastTxt: device[0].toString().toUpperCase(),
        ),
        InfoModel(
          icon: Amicons.remix_android,
          centreTxt: 'Model',
          lastTxt: device[1]
      ),
        InfoModel(
          icon: Amicons.flaticon_apps_sharp,
          centreTxt: 'Android Version',
          lastTxt:  device[2]
      ),
        InfoModel(
          icon: Amicons.iconly_danger_circle,
          centreTxt: 'Device Id',
          lastTxt:  device[3]
      ),
      ];
    }
    List<InfoModel> credits = getCredits();
    List<InfoModel> support = getSupportOptions();
    List<InfoModel> deviceInfo = getDeviceInfo();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('About'),
        titleTextStyle: TextStyle(
          color: Colors.grey.shade400,
          fontSize: wt * 0.05,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(wt * 0.04),
        child: Center(
          child: SingleChildScrollView(
            child: isLoding?LoadingAnimationWidget.threeArchedCircle(color: Colors.green, size: wt*0.2):SizedBox(
              width: wt * 1,
              height: ht * 2.1,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: wt * 0.9,
                    height: ht * 0.4,
                    decoration: BoxDecoration(
                      color: Colors.pink.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(wt * 0.05),
                      border: Border.all(
                        color: Colors.pink.withOpacity(0.5),
                        width: 2
                      )
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: wt * 0.05,
                        vertical: wt * 0.06,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadiusGeometry.circular(
                              wt * 0.025,
                            ),
                            child: Image.asset(
                              'assets/images/logo.jpg',
                              width: wt * 0.3,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Text(
                            'Version 1.0.0',
                            style: TextStyle(
                              color: Colors.white30,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            'A Movie Research Database App, Find All Movies and Get Detailed information Via this App',
                            maxLines: 3,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white38,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: wt * 0.9,
                    height: ht * 0.47,
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(wt * 0.05),
                      border: Border.all(
                        color: Colors.green.withOpacity(0.5),
                        width: 1.4
                      )
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(wt * 0.05),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(
                                    Amicons.remix_android,
                                    color: Colors.green.shade800.withOpacity(0.7),
                                  ),
                                  SizedBox(width: wt * 0.05),
                                  Text(
                                    'Device Information',
                                    style: TextStyle(
                                      color: Colors.green.withOpacity(0.7),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              InkWell(
                                  onTap: () {
                                    Clipboard.setData(ClipboardData(text: device.join(', ')));
                                    showScaffoldMsg(context, txt: 'Copied to clipboard');
                                  },
                                  child: Icon(Amicons.lucide_copy,color: Colors.green.shade400,))
                            ],
                          ),
                          SizedBox(height: ht*0.04,),
                          Expanded(
                            child: ListView.builder(
                              itemCount: deviceInfo.length,
                              itemBuilder: (context, index) {
                                InfoModel data = deviceInfo[index];
                                return Column(
                                  children: [
                                    Container(
                                      width: wt*1,
                                      height: ht*0.07,
                                      decoration: BoxDecoration(
                                          color: Colors.green.withOpacity(0.03),
                                          border: Border.all(
                                              color: Colors.green.withOpacity(0.2),
                                              width: 1
                                          ),
                                          borderRadius: BorderRadius.circular(wt*0.03)
                                      ),
                                      child: ListTile(
                                        title: Text(
                                          data.centreTxt,
                                          maxLines: 2,
                                          style: TextStyle(
                                              color: Colors.green,
                                              fontSize: wt*0.035,
                                              fontWeight: FontWeight.bold
                                          ),
                                        ),
                                        leading: Icon(data.icon,size: wt*0.06,color: Colors.green.shade400,),
                                        trailing: Text(
                                          data.lastTxt.toString(),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              color: Colors.lightGreen.shade600,
                                              fontSize: wt*0.034
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: ht*0.02,)
                                  ],
                                );
                              },
                              physics: NeverScrollableScrollPhysics(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: wt * 0.9,
                    height: ht * 0.59,
                    decoration: BoxDecoration(
                      color: Colors.orangeAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(wt * 0.05),
                      border: Border.all(
                        color: Colors.orangeAccent.withOpacity(0.5),
                        width: 1.5
                      )
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(wt * 0.04),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(
                                Amicons.vuesax_personalcard,
                                color: Colors.orange.shade800.withOpacity(0.7),
                              ),
                              SizedBox(width: wt * 0.05),
                              Text(
                                'Credits',
                                style: TextStyle(
                                  color: Colors.orangeAccent.shade400,
                                  fontWeight: FontWeight.bold,
                                  fontSize: wt*0.045
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: ht*0.045,),
                          Expanded(
                            child: ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                                itemCount: credits.length,
                                itemBuilder: (context, index) {
                                InfoModel data=credits[index];
                                  return Column(
                                    children: [
                                      Container(
                                        width: wt*1,
                                        height: ht*0.14,
                                        decoration: BoxDecoration(
                                            color: Colors.orangeAccent.withOpacity(0.03),
                                            border: Border.all(
                                                color: Colors.orangeAccent.withOpacity(0.2),
                                                width: 2
                                            ),
                                            borderRadius: BorderRadius.circular(wt*0.03)
                                        ),
                                        child: ListTile(
                                          titleAlignment: ListTileTitleAlignment.center,
                                          leading: Icon(data.icon),
                                          title: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(data.topTxt.toString(),
                                                style: TextStyle(
                                                    color: Colors.orangeAccent.shade700.withOpacity(0.4),
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: wt*0.045
                                                ),
                                              ),
                                              SizedBox(height: ht*0.01,),
                                              Text(data.centreTxt,maxLines:1,overflow: TextOverflow.ellipsis, style: TextStyle(
                                                  color: Colors.orangeAccent.withOpacity(0.7),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: wt*0.04
                                              ),),
                                              Text(data.subTxt.toString(),
                                                style: TextStyle(
                                                    color: Colors.orange.withOpacity(0.5),
                                                    fontSize: wt*0.03
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: ht*0.02,)
                                    ],
                                  );
                                },
                            ),
                          ),

                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: wt * 0.9,
                    height: ht * 0.45,
                    decoration: BoxDecoration(
                      color: Colors.tealAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(wt * 0.05),
                      border: Border.all(
                        color: Colors.tealAccent.withOpacity(0.4),
                        width: 1.5
                      )
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(wt*0.04),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(
                                Amicons.lucide_message_square_more,
                                color: Colors.teal,
                              ),
                              SizedBox(width: wt * 0.05),
                              Text(
                                'Support Us',
                                style: TextStyle(
                                  color: Colors.teal.shade700,
                                  fontSize: wt*0.045,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: ht*0.03,),
                          Expanded(
                            child: ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: support.length,
                                itemBuilder: (context, index) {
                                InfoModel data = support[index];
                                  return Column(
                                    children: [
                                      Container(
                                        width: wt*1,
                                        height: ht*0.1,
                                        decoration: BoxDecoration(
                                          color: Colors.teal.withOpacity(0.1),
                                          border: Border.all(
                                            color: Colors.teal.withOpacity(0.2),
                                            width: 2
                                          ),
                                          borderRadius: BorderRadius.circular(wt*0.03)
                                        ),
                                        child: InkWell(
                                          splashColor: Colors.green.withOpacity(0.1),
                                          highlightColor: Colors.green.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(wt*0.02),
                                          onTap: () async {
                                            setState(() {
                                              reDirecting.add(index);
                                              showScaffoldMsg(context, txt: data.lastTxt.toString());
                                            });
                                            await Future.delayed(Duration(seconds: 2));
                                            await nav(url: data.onTap.toString());
                                            setState(() {
                                              reDirecting.remove(index);
                                            });
                                          },
                                          child: ListTile(
                                            trailing: reDirecting.contains(index)?LoadingAnimationWidget.dotsTriangle(color: Colors.teal, size: wt*0.05):Icon(Amicons.vuesax_arrow_right,size: wt*0.08,color: Colors.teal,),
                                            titleAlignment: ListTileTitleAlignment.center,
                                            title: Text(data.centreTxt,style: TextStyle(
                                              color: Colors.tealAccent,
                                              fontWeight: FontWeight.bold
                                            ),),
                                            subtitle: Text(data.subTxt.toString(),overflow: TextOverflow.ellipsis, style: TextStyle(
                                              color: Colors.teal.withOpacity(0.7)
                                            ),),
                                            leading: Icon(data.icon,color: Colors.teal.shade400,),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: ht*0.02,),

                                    ],
                                  );
                                },
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  TextButton(
                      onPressed: () async {
                        SharedPreferences pref= await SharedPreferences.getInstance();
                        pref.clear();
                        await FirebaseFirestore.instance.collection(AppConstants.phone).doc(device[3]).delete();
                        Navigator.pop(context);
                      },
                      child: Text('Delete Account',style: TextStyle(
                          color: Colors.red.withOpacity(0.6),
                        fontWeight: FontWeight.bold
                      ),)
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

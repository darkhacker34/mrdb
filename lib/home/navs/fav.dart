import 'package:amicons/amicons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:lottie/lottie.dart';
import 'package:mrdb/home/bottom_nav.dart';
import 'package:mrdb/home/navs/first_page/preview_page.dart';
import 'package:mrdb/constens/keys.dart';
import 'package:mrdb/models/movie_model.dart';
import 'package:mrdb/provider/client.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../main.dart';

class Favorite extends StatefulWidget {
  const Favorite({super.key});

  @override
  State<Favorite> createState() => _FavoriteState();
}
class _FavoriteState extends State<Favorite> {
  List favorites=[];
  String clientId='';
  List isDeleting=[];
  List searched=[];
  bool isClearing=false;
  bool notFound=false;
  bool load=false;
  TextEditingController favoritesSearch=TextEditingController();

  // void searchGet({required String query}) {
  //   favorites.;
  // }
  Future<void> getLiked({bool isCleared=false}) async {
    if(!isCleared)setState(() =>load=true);
    clientId = Provider.of<ClientProvider>(context, listen: false).clientId!;
    var client = FirebaseFirestore.instance.collection(AppConstants.phone).doc(clientId);
    var liks = await client.collection('liked').orderBy('timeStamp',descending: true).get();
    setState(() {
      favorites= liks.docs;
      load=false;
    });
  }
  Future<void> removeFav({required String id, required String title }) async {
    setState(() {
      isDeleting.add(id);
    });
    int attempt=0;
    while(attempt<3){
      try{
        await FirebaseFirestore.instance.collection(AppConstants.phone).doc(clientId).collection('liked').doc(id).delete();
          await getLiked();
          setState(() {
            isDeleting.remove(id);
          });
        if(mounted)showScaffoldMsg(context, txt: '"$title" removed from Favorites!');
        return;
      }catch(e){
        attempt++;
          if(attempt<3){
            await Future.delayed(Duration(seconds: 2));
          }else{
            if(mounted)showScaffoldMsg(context, txt: 'try Again...');
            setState(() {
              isDeleting.remove(id);
            });
          }
      }

    }
  }
  @override
  void initState() {
    getLiked();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Favorites'),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: wt * 0.06,
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: EdgeInsets.only(
              right: wt*0.05
            ),
            child: load?Shimmer(
                direction: ShimmerDirection.ltr,
                period: Duration(milliseconds: 1000),
                gradient:LinearGradient(
                  colors: [
                    Colors.grey.shade800,
                    Colors.grey.shade600,
                    Colors.grey.shade800,
                  ],
                  stops: [0.0, 0.5, 1.0],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                child: CircleAvatar(
                  radius: wt*0.06,
                  backgroundColor: Colors.black54,
                )
            )
                :CircleAvatar(
                radius: wt*0.06,
                backgroundColor: Colors.grey.withOpacity(0.5),
                child: Text(favorites.length.toString(),style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: wt*0.04,
                    color: Colors.white
                )
                )
            )
          )
        ],
      ),
      body: load?
      Shimmer(
        direction: ShimmerDirection.ltr,
        period: Duration(milliseconds: 1000),
        gradient: LinearGradient(
          colors: [
            Colors.grey.shade800,
            Colors.grey.shade600,
            Colors.grey.shade800,
          ],
          stops: [0.0, 0.5, 1.0],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        child: Padding(
          padding: EdgeInsets.all(wt * 0.05),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 7,
                    child: Container(
                      height: ht * 0.06,
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(wt * 0.04),
                      ),
                    ),
                  ),
                  SizedBox(width: wt * 0.02),
                  Expanded(
                    flex: 3,
                    child: Container(
                      height: ht * 0.06,
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(wt * 0.04),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: ht * 0.03),
              Expanded(
                child: ListView.separated(
                  physics: NeverScrollableScrollPhysics(),
                  separatorBuilder: (context, index) => SizedBox(height: ht * 0.03),
                  itemCount: 3,
                  itemBuilder: (context, index) {
                    return Container(
                      width: wt * 1,
                      height: ht * 0.2,
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(wt * 0.04),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      )
          :favorites.isNotEmpty?
      Padding(
        padding: EdgeInsets.all(wt*0.05),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 7,
                  child: TextFormField(
                    textInputAction: TextInputAction.search,
                    onChanged: (value) {
                      setState(() {
                        searched.clear();
                      });
                      for(var fav in favorites){
                        if(fav['title'].toLowerCase().contains(value.toLowerCase().trim())){
                          setState(() {
                            searched.add(fav);
                          });
                        }
                      }
                      setState(() {
                        if(value.isNotEmpty&&searched.isEmpty){
                          notFound=true;
                        }else{
                          notFound=false;
                        }
                      });
                    },
                    textCapitalization: TextCapitalization.words,
                    controller: favoritesSearch,
                    cursorColor: Colors.white,
                    cursorHeight: ht * 0.025,
                    style: TextStyle(
                      color: Colors.grey.shade300,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      fillColor: Colors.grey.shade700,
                      filled: true,
                      hintText: 'search favorites...',
                      hintStyle: TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(wt * 0.04),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(wt * 0.04),
                        borderSide: BorderSide(
                          color: Colors.white,
                          width: wt * 0.006,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(wt * 0.04),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: wt*0.02,),
                Expanded(
                    flex: 3,
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.1),
                          border: Border.all(
                              color: Colors.teal.withOpacity(0.5)
                          ),
                          borderRadius: BorderRadius.circular(wt*0.04)
                      ),
                      child: TextButton(
                          onPressed: () async {
                            setState(() {
                              isClearing=true;
                            });
                            for(var fav in favorites){
                              await FirebaseFirestore.instance.collection(AppConstants.phone).doc(clientId).collection('liked').doc(fav['id'].toString()).delete();
                            }
                            await getLiked(isCleared: true);
                            setState(() {
                              isClearing=false;
                            });
                          },
                          child: FittedBox(
                            child: isClearing?LoadingAnimationWidget.horizontalRotatingDots(color: Colors.teal, size: wt*0.08):Text('Clear Favorites',style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.teal,
                                fontSize: wt*0.038
                            ),),
                          )
                      ),
                    )
                )
              ],
            ),
            SizedBox(height: ht*0.02,),
            Expanded(
              child: notFound?Center(
                child: LottieBuilder.asset('assets/lottie/no_item_found.json'),
              ):ListView.separated(
                separatorBuilder: (context, index) => SizedBox(height: ht*0.03,),
                physics: BouncingScrollPhysics(),
                itemCount: searched.isNotEmpty?searched.length:favorites.length,
                itemBuilder: (context, index) {
                  var currentData=searched.isNotEmpty?searched:favorites;
                  return Container(
                    width: wt * 1,
                    height: ht * 0.22,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade800,
                      borderRadius: BorderRadius.circular(wt * 0.04),
                    ),
                    child: Row(
                      children: [
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(wt * 0.04),
                                bottomLeft: Radius.circular(wt * 0.04),
                              ),
                              child: SizedBox(
                                width: wt * 0.3,
                                height: ht * 0.22,
                                child: CachedNetworkImage(
                                  errorWidget: (context, url, error) => Icon(Amicons.iconly_image_2_fill,size: wt*0.2,color: Colors.white30),
                                  imageUrl: currentData[index]['img']??'',
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => LoadingAnimationWidget.fourRotatingDots(color: Colors.green, size: wt*0.08),
                                ),
                              ),
                            ),
                            Align(
                              alignment: AlignmentGeometry.topLeft,
                              child: Container(
                                  width: wt*0.15,
                                  height: ht*0.05,
                                  decoration: BoxDecoration(
                                    color: isDeleting.contains(currentData[index]['id'].toString())?Colors.black.withOpacity(0.7):Colors.red.shade900.withOpacity(0.8),
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(wt*0.04),
                                      bottomRight: Radius.circular(wt*0.04),
                                    ),
                                  ),
                                  child: isDeleting.contains(currentData[index]['id'].toString())?LoadingAnimationWidget.fallingDot(color: Colors.grey, size: wt*0.08):IconButton(
                                      onPressed: () {
                                        removeFav(id: currentData[index]['id'].toString(),title: currentData[index]['title']);
                                      },
                                      icon: Icon(Amicons.iconly_delete,color: Colors.black,size: wt*0.07,))
                              ),
                            )
                          ],
                        ),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: wt * 0.03,
                              vertical: wt*0.04,
                            ),
                            color: Colors.transparent,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  flex: 4,
                                  child: Text(
                                    currentData[index]['title'],
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: wt * 0.05,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: wt * 0.02,
                                            vertical: wt * 0.01,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.yellow.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(wt * 0.02),
                                            border: Border.all(
                                              color: Colors.yellow.withOpacity(0.3),
                                              width: 2,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                                            children: [
                                              Icon(
                                                Amicons.vuesax_star_1,
                                                color: Colors.yellow,
                                                size: wt * 0.045,
                                              ),
                                              Text(
                                                (currentData[index]['rating']/2).toStringAsFixed(1).toString(),
                                                style: TextStyle(
                                                  color: Colors.yellow,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: wt * 0.035,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: wt * 0.01),
                                      Flexible(
                                        flex: 4,
                                        child: Container(
                                          padding: EdgeInsets.symmetric(horizontal: wt * 0.02, vertical: wt * 0.01),
                                          decoration: BoxDecoration(
                                            color: Colors.yellow.withOpacity(0.1),
                                            border: Border.all(
                                              color: Colors.yellow.withOpacity(0.3),
                                              width: 2,
                                            ),
                                            borderRadius: BorderRadius.circular(wt * 0.1),
                                          ),
                                          child: Center(
                                            child: Text(
                                              currentData[index]['year'],
                                              style: TextStyle(
                                                color: Colors.white54,
                                                fontWeight: FontWeight.bold,
                                                fontSize: wt * 0.034,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Spacer(),
                                Expanded(
                                  flex: 2,
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.push(context, MaterialPageRoute(builder: (context) =>  MoviePreview(movieId: currentData[index]['id'],),));
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: Colors.yellow.withOpacity(0.1),
                                          border: Border.all(
                                              color: Colors.yellow.withOpacity(0.3),
                                              width: 2
                                          ),
                                          borderRadius: BorderRadius.circular(wt*0.02)
                                      ),
                                      child: Center(
                                        child: Text('Details',style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: wt*0.045
                                        ),),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              )
            ),
          ],
        ),
      )
          :Center(child: LottieBuilder.asset('assets/lottie/not_found.json',alignment: Alignment.center,width: wt*0.8,)),
    );
  }
}

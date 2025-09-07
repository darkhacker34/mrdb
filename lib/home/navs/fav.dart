import 'package:amicons/amicons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:lottie/lottie.dart';
import 'package:mrdb/home/bottom_nav.dart';
import 'package:mrdb/home/navs/first_page/preview_page.dart';
import 'package:mrdb/models/keys.dart';
import 'package:mrdb/models/movie_model.dart';
import 'package:mrdb/provider/client.dart';
import 'package:provider/provider.dart';

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

  Future<void> getLiked() async {
    clientId = Provider.of<ClientProvider>(context, listen: false).clientId!;
    var client = FirebaseFirestore.instance.collection(Keys.phone).doc(clientId);
    var liks = await client.collection('liked').orderBy('timeStamp',descending: true).get();
    setState(() {
      favorites= liks.docs;
    });
  }
  Future<void> removeFav({required String id, required String title }) async {
    setState(() {
      isDeleting.add(id);
    });
    int attempt=0;
    while(attempt<3){
      try{
        await FirebaseFirestore.instance.collection(Keys.phone).doc(clientId).collection('liked').doc(id).delete();
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
        leading: Icon(
          Amicons.vuesax_document_favorite_fill,
          color: Colors.white,
        ),
        backgroundColor: Colors.black,
        title: Text('Favorites'),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: wt * 0.06,
        ),
        centerTitle: true,
      ),
      body: favorites.isNotEmpty?RefreshIndicator(
        onRefresh: () async {
          await getLiked();
          setState(() {
            
          });
        },
        child: ListView.builder(
          itemCount: favorites.length,
          itemBuilder: (context, index) {
            return Container(
              margin: EdgeInsets.symmetric(
                horizontal: wt * 0.04,
                vertical: wt * 0.02,
              ),
              width: wt * 1,
              height: wt * 0.5,
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
                          height: wt * 0.5,
                          child: CachedNetworkImage(
                            errorWidget: (context, url, error) => Icon(Amicons.iconly_image_2_fill,size: wt*0.2,color: Colors.white30),
                            imageUrl: favorites[index]['img']??'',
                            fit: BoxFit.cover,
                            placeholder: (context, url) => LoadingAnimationWidget.fourRotatingDots(color: Colors.green, size: wt*0.08),
                          ),
                        ),
                      ),
                      Align(
                        alignment: AlignmentGeometry.topLeft,
                        child: Container(
                          width: wt*0.15,
                          height: wt*0.12,
                            decoration: BoxDecoration(
                              color: isDeleting.contains(favorites[index]['id'].toString())?Colors.black.withOpacity(0.7):Colors.red.shade900.withOpacity(0.8),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(wt*0.04),
                                bottomRight: Radius.circular(wt*0.04),
                              ),
                            ),
                            child: isDeleting.contains(favorites[index]['id'].toString())?LoadingAnimationWidget.fallingDot(color: Colors.grey, size: wt*0.08):IconButton(
                                onPressed: () {
                                  removeFav(id: favorites[index]['id'].toString(),title: favorites[index]['title']);
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
                              favorites[index]['title'],
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: wt * 0.05,
                              ),
                            ),
                          ),
                          SizedBox(height: wt * 0.02),
                          Expanded(
                            flex: 2,
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 2,
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
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Icon(
                                          Amicons.vuesax_star_1,
                                          color: Colors.yellow,
                                          size: wt * 0.05,
                                        ),
                                        SizedBox(width: wt * 0.01),
                                        Text(
                                          (favorites[index]['rating']/2).toStringAsFixed(1).toString(),
                                          style: TextStyle(
                                            color: Colors.yellow,
                                            fontWeight: FontWeight.bold,
                                            fontSize: wt * 0.04,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(width: wt * 0.02),
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
                                        favorites[index]['year'],
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
                               Navigator.push(context, MaterialPageRoute(builder: (context) =>  MoviePreview(movieId: favorites[index]['id'],),));
                              },
                              child: Container(
                                width: double.infinity,
                                height: wt*0.1,
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
        ),
      ):Center(
        child: LottieBuilder.asset('assets/lottie/not_found.json',alignment: Alignment.center,width: wt*0.8,),
      ),
    );
  }
}

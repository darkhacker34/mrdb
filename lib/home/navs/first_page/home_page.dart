import 'dart:convert';
import 'dart:io';
import 'package:amicons/amicons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating/flutter_rating.dart';
import 'package:flutter_rating_stars/flutter_rating_stars.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:mrdb/home/navs/first_page/preview_page.dart';
import 'package:mrdb/models/keys.dart';
import 'package:mrdb/models/movie_model.dart';
import 'package:provider/provider.dart';
import '../../../main.dart';
import '../../../provider/client.dart';

class MRDb extends StatefulWidget {
  final String lang;
  const MRDb({super.key, this.lang = 'en'});

  @override
  State<MRDb> createState() => _MRDbState();
}

class _MRDbState extends State<MRDb> {
  List<dynamic> all = [];
  int pageNum = DateTime.now().second;
  bool refresh = false;
  List likList = [];
  bool lod = false;
  List isLiking = [];
  bool forReFresh = false;
  double pixel = 0;
  bool isSearch = false;
  bool showSearch = false;
  TextEditingController search = TextEditingController();
  ScrollController moveTo = ScrollController();
  String deviceId = '';
  Future<void> getMovie({bool refresh = false}) async {
    deviceId = Provider.of<ClientProvider>(context, listen: false).clientId!;
    if (refresh) {
      setState(() {
        all.clear();
        forReFresh = false;
        pageNum = DateTime.now().second;
      });
    }

    setState(() {
      lod = true;
      if (pageNum > 2700 && moveTo.hasClients) {
        moveTo.jumpTo(pixel);
      }
    });

    Uri url = Uri.parse(
      'https://api.themoviedb.org/3/discover/movie'
      '?api_key=38ed19dab876e12b797aaa54db51b633'
      '&with_original_language=${widget.lang}'
      '&sort_by=popularity.desc'
      '&page=$pageNum',
    );

    int attempts = 0;
    bool success = false;

    while (!success && attempts < 3) {
      try {
        final res = await http.get(url);

        if (res.statusCode == 200) {
          final data = jsonDecode(res.body);
          setState(() {
            all.addAll(data['results']);
            lod = false;
          });
          success = true;
        } else {
          throw Exception('Failed with status: ${res.statusCode}');
        }
      } catch (e) {
        attempts++;
        if (attempts < 3) {
          await Future.delayed(const Duration(seconds: 1));
        } else {
          if(!mounted) return;
          setState(() {
            lod = false;
            forReFresh = true;
          });
          showScaffoldMsg(context, txt: "ReFresh the page...");
        }
      }
    }
  }

  Future<void> searchMovie(String query) async {
    if (query.isEmpty) {
      all.clear();
      await getMovie();
      return;
    }

    if (!mounted) return;

    setState(() {
      lod = true;
      isSearch = true;
    });

    try {
      Uri url = Uri.parse(
        'https://api.themoviedb.org/3/search/movie?api_key=38ed19dab876e12b797aaa54db51b633&query=$query',
      );

      final res = await http.get(url);
      if (!mounted) return;

      final data = jsonDecode(res.body);

      setState(() {
        all = data['results'];
        search.clear();
        lod = false;
        isSearch = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        lod = false;
        isSearch = false;
      });
      print('Error searching movie: $e');
    }
  }

  Future<void> getLiked() async {
    var doc = await FirebaseFirestore.instance
        .collection(Keys.phone)
        .doc(deviceId).collection('liked')
        .get();
    var data = doc.docs;
    List likes = data;
    setState(() {
      likList = likes.map((e) => e['id']).toList();
    });
  }

  Future<void> addFav({
    required int movieId,
    required String title,
    required String image,
    required String year,
    required double rating,
  }) async {

    Movie movie = Movie(
      movId: movieId,
      title: title,
      img: image,
      year: year,
      rating: rating,
      timeStamp: DateTime.now().toString()
    );

    if(!likList.contains(movieId)){
      setState(() {
        isLiking.add(movieId);
      });
      likList.add(movieId);
      await FirebaseFirestore.instance
          .collection(Keys.phone)
          .doc(deviceId)
          .collection('liked')
          .doc(movie.movId.toString())
          .set(movie.toMap());

      setState(() {
        isLiking.remove(movieId);
      });
    }else{
      return showScaffoldMsg(context, txt: 'Go To Favorite Page To Remove');
    }

  }

  @override
  void initState() {
    getMovie();
    getLiked();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: pixel > 1000
          ? InkWell(
              onTap: () {
                moveTo.animateTo(
                  0,
                  duration: Duration(milliseconds: 500),
                  curve: Curves.fastEaseInToSlowEaseOut,
                );
              },
              child: CircleAvatar(
                backgroundColor: Colors.white70,
                radius: wt * 0.06,
                child: Center(
                  child: Icon(Icons.arrow_upward, color: Colors.black),
                ),
              ),
            )
          : SizedBox(),
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('MRDb'),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: wt * 0.06,
        ),
        backgroundColor: Colors.black,
        leading: Icon(Icons.menu, color: Colors.white, size: wt * 0.08),
        actions: [
          Icon(
            Icons.movie_creation_outlined,
            color: Colors.white,
            size: wt * 0.08,
          ),
          SizedBox(width: wt * 0.03),
        ],
      ),
      body: forReFresh
          ? Center(
              child: InkWell(
                borderRadius: BorderRadius.circular(wt * 0.1),
                onTap: () => getMovie(refresh: true),

                child: Container(
                  width: wt * 0.27,
                  height: wt * 0.1,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade700,
                    borderRadius: BorderRadius.circular(wt * 0.1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Icon(
                        Amicons.vuesax_refresh_circle_fill,
                        size: wt * 0.09,
                        color: Colors.white54,
                      ),
                      Text(
                        'Refresh',
                        style: TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : Padding(
              padding: EdgeInsets.all(wt * 0.04),
              child: SingleChildScrollView(
                physics: NeverScrollableScrollPhysics(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextFormField(
                      controller: search,
                      cursorColor: Colors.white,
                      cursorHeight: wt * 0.05,
                      onChanged: (value) {
                        setState(() {
                          if (value.isNotEmpty) {
                            showSearch = true;
                          } else {
                            showSearch = false;
                          }
                        });
                      },
                      style: TextStyle(
                        color: Colors.grey.shade300,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: InputDecoration(
                        fillColor: Colors.grey.shade700,
                        filled: true,
                        hintText: 'Movies, shows, celebrities...',
                        hintStyle: TextStyle(color: Colors.grey),
                        suffixIcon: showSearch
                            ? isSearch
                                  ? Padding(
                                      padding: EdgeInsets.all(wt * 0.015),
                                      child:
                                          LoadingAnimationWidget.dotsTriangle(
                                            color: Colors.white,
                                            size: wt * 0.06,
                                          ),
                                    )
                                  : InkWell(
                                      borderRadius: BorderRadius.circular(
                                        wt * 1,
                                      ),
                                      onTap: () {
                                        searchMovie(search.text);
                                        FocusManager.instance.primaryFocus!
                                            .unfocus();
                                      },
                                      child: Icon(
                                        Icons.search,
                                        color: Colors.white54,
                                      ),
                                    )
                            : null,
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
                    SizedBox(height: wt * 0.03),
                    NotificationListener(
                      onNotification: (ScrollNotification notification) {
                        pixel = notification.metrics.pixels;
                        setState(() {});
                        if (pixel > (pageNum * 2700 - 500)) {
                          pageNum++;
                          getMovie();
                        }
                        return true;
                      },
                      child: SizedBox(
                        height: wt * 1.6,
                        child: RefreshIndicator(
                          onRefresh: () => getMovie(refresh: true),

                          child: Stack(
                            children: [
                              GridView.builder(
                                controller: moveTo,
                                itemCount: all.length,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      mainAxisSpacing: wt * 0.02,
                                      crossAxisSpacing: wt * 0.02,
                                      mainAxisExtent: wt * 0.9,
                                    ),
                                itemBuilder: (context, index) {
                                  final currentItem = all[index];
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => MoviePreview(
                                            movieId: currentItem['id'],
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius: BorderRadius.circular(
                                          wt * 0.04,
                                        ),
                                        border: Border.all(color: Colors.grey),
                                      ),
                                      child: Column(
                                        children: [
                                          Expanded(
                                            flex: 9,
                                            child: Stack(
                                              children: [
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.only(
                                                        topLeft:
                                                            Radius.circular(
                                                              wt * 0.04,
                                                            ),
                                                        topRight:
                                                            Radius.circular(
                                                              wt * 0.04,
                                                            ),
                                                      ),
                                                  child:
                                                      all[index]['poster_path'] !=
                                                          null
                                                      ? CachedNetworkImage(
                                                          imageUrl:
                                                              'https://image.tmdb.org/t/p/w500${all[index]['poster_path']}',
                                                          width: wt * 0.5,
                                                          placeholder:
                                                              (
                                                                context,
                                                                url,
                                                              ) => Center(
                                                                child: LoadingAnimationWidget.fallingDot(
                                                                  color: Colors
                                                                      .green,
                                                                  size: wt * 0.1,
                                                                ),
                                                              ),
                                                          errorWidget:
                                                              (
                                                                context,
                                                                url,
                                                                error,
                                                              ) => Image.asset(
                                                                'assets/images/image_error.png',
                                                                color:
                                                                    Colors.grey,
                                                                width:
                                                                    wt * 0.05,
                                                              ),
                                                          fit: BoxFit.cover,
                                                        )
                                                      : Image.asset(
                                                          'assets/images/image_error.png',
                                                          color: Colors.grey,
                                                          width: wt * 0.5,
                                                          fit: BoxFit.cover,
                                                        ),
                                                ),
                                                Align(
                                                  alignment: Alignment.topRight,
                                                  child: Padding(
                                                    padding: EdgeInsets.all(
                                                      wt * 0.015,
                                                    ),
                                                    child: Container(
                                                      width: wt * 0.1,
                                                      height: wt * 0.1,
                                                      decoration: BoxDecoration(
                                                        color: Colors.black
                                                            .withOpacity(0.1)
                                                            .withOpacity(0.6),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              wt * 0.03,
                                                            ),
                                                        border: Border.all(
                                                          color: Colors.white
                                                              .withOpacity(0.6),
                                                          width: 2,
                                                        ),
                                                      ),
                                                      child: InkWell(
                                                        onTap: () async {
                                                          addFav(
                                                            movieId:
                                                                currentItem['id'],
                                                            title:
                                                                currentItem['title'],
                                                            image:
                                                                "https://image.tmdb.org/t/p/w500${currentItem['poster_path']}",
                                                            year:
                                                                currentItem['release_date'],
                                                            rating:
                                                                currentItem['vote_average'],
                                                          );
                                                        },
                                                        child:
                                                            isLiking.contains(
                                                              currentItem['id'],
                                                            )
                                                            ? LoadingAnimationWidget.fallingDot(
                                                                color:
                                                                    Colors.red,
                                                                size: wt * 0.08,
                                                              )
                                                            : Icon(
                                                                likList.contains(
                                                                      currentItem['id'],
                                                                    )
                                                                    ? Amicons
                                                                          .iconly_heart_fill
                                                                    : Amicons
                                                                          .iconly_heart,
                                                                color:
                                                                    likList.contains(
                                                                      currentItem['id'],
                                                                    )
                                                                    ? Colors.red
                                                                    : Colors
                                                                          .white,
                                                                size: wt * 0.05,
                                                              ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: ListTile(
                                              title: Text(
                                                all[index]['title'].toString(),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              titleTextStyle: TextStyle(
                                                color: Colors.white54,
                                                fontSize: wt * 0.04,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              subtitle: Text(
                                                'Release: ${all[index]['release_date']}',
                                              ),
                                              subtitleTextStyle: TextStyle(
                                                color: Colors.white38,
                                                fontWeight: FontWeight.bold,
                                                fontSize: wt * 0.03,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Container(
                                                  width: wt * 0.14,
                                                  height: wt * 0.05,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white24,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          wt * 0.04,
                                                        ),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      ('${(all[index]['vote_average'] / 2).toString().split('.').first}.${(all[index]['vote_average'] / 2).toString().split('.').last[0]}/5.0')
                                                          .toString(),
                                                      style: TextStyle(
                                                        color: Colors.white38,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: wt * 0.03,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                StarRating(
                                                  starCount: 5,
                                                  size: wt * 0.04,
                                                  rating:
                                                      (all[index]['vote_average'] /
                                                      2),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                              if (lod)
                                Align(
                                  alignment: Alignment.center,
                                  child: Container(
                                    width: wt,
                                    height: wt * 0.15,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.transparent,
                                          Colors.black.withOpacity(0.28),
                                          Colors.black.withOpacity(0.7),
                                        ],
                                        stops: [0.0, 0.4, 1.0],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                    ),
                                    child: Center(
                                      child:
                                          LoadingAnimationWidget.progressiveDots(
                                            color: Colors.white70,
                                            size: wt * 0.1,
                                          ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

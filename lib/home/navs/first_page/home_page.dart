import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:amicons/amicons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating/flutter_rating.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:lottie/lottie.dart';
import 'package:mrdb/home/navs/first_page/preview_page.dart';
import 'package:mrdb/constens/keys.dart';
import 'package:mrdb/models/movie_model.dart';
import 'package:provider/provider.dart';
import '../../../main.dart';
import '../../../provider/client.dart';
import '../../../splash.dart';

class MRDb extends StatefulWidget {
  final String lang;
  const MRDb({super.key, this.lang = 'en'});

  @override
  State<MRDb> createState() => _MRDbState();
}

class _MRDbState extends State<MRDb> {
  bool _showFAB = false;
  int pageNum = DateTime.now().second;
  bool refresh = false;
  List likList = [];
  bool lod = false;
  bool bottomLod = false;
  List isLiking = [];
  bool forReFresh = false;
  double pixel = 0;
  TextEditingController search = TextEditingController();
  ScrollController moveTo = ScrollController();
  String deviceId = '';

  Future<void> getMovie({
    bool refresh = false,
    bool loadMore = false,
    bool forRe = false,
  }) async {
    deviceId = Provider.of<ClientProvider>(context, listen: false).clientId!;
    setState(() {
      if (forRe) {
        lod = true;
        forReFresh = false;
      }

      if (refresh) {
        forReFresh = false;
        pageNum = DateTime.now().second;
      }

      if (loadMore) {
        bottomLod = true;
        lod = false;
      }
    });

    Uri url = Uri.parse(
      'https://api.themoviedb.org/3/discover/movie'
      '?api_key=${AppConstants.apiKey}'
      '&with_original_language=${widget.lang}'
      '&sort_by=popularity.desc'
      '&page=$pageNum',
    );

    int attempts = 0;

    while (attempts < 3) {
      try {
        final res = await http.get(url);
        if (res.statusCode == 200) {
          final data = jsonDecode(res.body);
          setState(() {
            if (bottomLod) {
              all.addAll(data['results']);
            } else {
              all = data['results'];
            }
            bottomLod = false;
            lod = false;
          });
          return;
        } else {
          throw Exception('Failed with status: ${res.statusCode}');
        }
      } catch (e) {
        attempts++;
        if (attempts < 3) {
          await Future.delayed(const Duration(seconds: 1));
        } else {
          if (!mounted) return;
          setState(() {
            lod = false;
            pixel = 0;
            forReFresh = true;
            bottomLod ? _showFAB = true : _showFAB = false;
            bottomLod = false;
          });
          showScaffoldMsg(context, txt: "ReFresh the page...");
        }
      }
    }
  }

  Future<void> searchMovie(String query) async {
    if (query.isEmpty && query == '') {
      showScaffoldMsg(context, txt: "Search Can't Be Empty");
      return;
    }

    if (!mounted) return;
    setState(() {
      _showFAB = false;
      lod = true;
    });

    int attempt = 0;
    while (attempt < 3) {
      try {
        Uri url = Uri.parse(
          'https://api.themoviedb.org/3/search/movie?api_key=${AppConstants.apiKey}&query=$query',
        );
        final res = await http.get(url);
        if (!mounted) return;
        final data = jsonDecode(res.body);
        setState(() {
          if (moveTo.hasClients) {
            moveTo.jumpTo(0);
          }
          all = data['results'];
          search.clear();
          lod = false;
        });
        return;
      } catch (e) {
        if (!mounted) return;
        attempt++;
        if (attempt < 3) {
          await Future.delayed(Duration(seconds: 2));
        } else {
          if (!mounted) return;
          setState(() {
            lod = false;
            forReFresh = true;
            search.clear();
          });
          showScaffoldMsg(context, txt: 'refresh and try again...');
        }
      }
    }
  }

  Future<void> getLiked() async {
    deviceId = Provider.of<ClientProvider>(context, listen: false).clientId!;
    setState(() {
      _showFAB = false;
      lod = true;
    });
    int attempts = 0;

    while (attempts < 3) {
      try {
        var doc = await FirebaseFirestore.instance
            .collection(AppConstants.phone)
            .doc(deviceId)
            .collection('liked')
            .get();
        var data = doc.docs;
        List likes = data;
        setState(() {
          likList = likes.map((e) => e['id']).toList();
          lod = false;
        });
        break;
      } catch (e) {
        attempts++;
        print('dfdik');
        if (attempts < 3) {
          await Future.delayed(const Duration(seconds: 1));
        } else {
          setState(() {
            lod = false;
            forReFresh = true;
          });
        }
      }
    }
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
      timeStamp: DateTime.now(),
    );
    if (likList.contains(movieId)) {
      showScaffoldMsg(context, txt: 'Go To Favorite Page to Remove!!');
    }
    int attempt = 0;
    while (!likList.contains(movieId) && attempt < 3) {
      setState(() {
        isLiking.add(movieId);
      });
      try {
        await FirebaseFirestore.instance
            .collection(AppConstants.phone)
            .doc(deviceId)
            .collection('liked')
            .doc(movie.movId.toString())
            .set(movie.toMap());

        setState(() {
          likList.add(movieId);
          isLiking.remove(movieId);
        });

        if (mounted)
          showScaffoldMsg(context, txt: '"$title" added to favorites ✅');
        return;
      } catch (e) {
        attempt++;
        if (attempt < 3) {
          await Future.delayed(const Duration(seconds: 1));
        } else {
          setState(() {
            isLiking.remove(movieId);
          });
          showScaffoldMsg(context, txt: 'Tried 3 times... please try again ❌');
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
      floatingActionButton: _showFAB
          ? InkWell(
              onTap: () {
                moveTo.animateTo(
                  0,
                  duration: Duration(milliseconds: 500),
                  curve: Curves.fastEaseInToSlowEaseOut,
                );
              },
              child: Padding(
                padding: EdgeInsets.all(wt * 0.04),
                child: CircleAvatar(
                  backgroundColor: Colors.white70,
                  radius: wt * 0.06,
                  child: Center(
                    child: Icon(Icons.arrow_upward, color: Colors.black),
                  ),
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
                onTap: () => getMovie(forRe: true),
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
              padding: EdgeInsets.only(right: wt * 0.04, left: wt * 0.04),
              child: SingleChildScrollView(
                physics: NeverScrollableScrollPhysics(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextFormField(
                      textInputAction: TextInputAction.search,
                      onFieldSubmitted: (value) {
                        searchMovie(value);
                      },
                      controller: search,
                      cursorColor: Colors.white,
                      cursorHeight: ht * 0.025,
                      style: TextStyle(
                        color: Colors.grey.shade300,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: InputDecoration(
                        fillColor: Colors.grey.shade700,
                        filled: true,
                        hintText: 'Movies, shows, celebrities...',
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
                    SizedBox(height: ht * 0.02),
                    NotificationListener(
                      onNotification: (ScrollNotification notification) {
                        pixel = notification.metrics.pixels;
                        final shouldShowFAB = pixel > 1000;
                        if (shouldShowFAB != _showFAB) {
                          setState(() {
                            _showFAB = shouldShowFAB;
                          });
                        }

                        if (pixel >=
                                notification.metrics.maxScrollExtent - 100 &&
                            !bottomLod) {
                          pageNum++;
                          bottomLod = true;
                          getMovie(loadMore: true);
                        }
                        return true;
                      },
                      child: SizedBox(
                        height: ht * 0.74,
                        child: Stack(
                          children: [
                            RefreshIndicator(
                              onRefresh: () => getMovie(refresh: true),
                              child: lod
                                  ? Center(
                                      child:
                                          LoadingAnimationWidget.dotsTriangle(
                                            color: Colors.green,
                                            size: wt * 0.1,
                                          ),
                                    )
                                  :all.isEmpty? Center(
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(
                                    wt * 0.1,
                                  ),
                                  onTap: () => getMovie(forRe: true),
                                  child: Container(
                                    width: wt * 0.27,
                                    height: wt * 0.1,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade700,
                                      borderRadius: BorderRadius.circular(
                                        wt * 0.1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                      children: [
                                        Icon(
                                          Amicons
                                              .vuesax_refresh_circle_fill,
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
                              ):GridView.builder(
                                      controller: moveTo,
                                      itemCount: all.length,
                                      physics: BouncingScrollPhysics(),
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 2,
                                            mainAxisSpacing: ht * 0.02,
                                            crossAxisSpacing: wt * 0.04,
                                            mainAxisExtent: wt * 0.9,
                                          ),
                                      itemBuilder: (context, index) {
                                        final currentItem = all[index];
                                        return GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    MoviePreview(
                                                      movieId:
                                                          currentItem['id'],
                                                    ),
                                              ),
                                            );
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.black,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    wt * 0.04,
                                                  ),
                                              border: Border.all(
                                                color: Colors.grey,
                                              ),
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
                                                                        size:
                                                                            wt *
                                                                            0.1,
                                                                      ),
                                                                    ),
                                                                errorWidget:
                                                                    (
                                                                      context,
                                                                      url,
                                                                      error,
                                                                    ) => Image.asset(
                                                                      'assets/images/image_error.png',
                                                                      color: Colors
                                                                          .grey,
                                                                      width:
                                                                          wt *
                                                                          0.05,
                                                                    ),
                                                                fit: BoxFit
                                                                    .cover,
                                                              )
                                                            : Image.asset(
                                                                'assets/images/image_error.png',
                                                                color:
                                                                    Colors.grey,
                                                                width: wt * 0.5,
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                      ),
                                                      Align(
                                                        alignment:
                                                            Alignment.topRight,
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                wt * 0.015,
                                                              ),
                                                          child: Container(
                                                            width: wt * 0.11,
                                                            height: ht * 0.05,
                                                            decoration: BoxDecoration(
                                                              color: Colors
                                                                  .black
                                                                  .withOpacity(
                                                                    0.1,
                                                                  )
                                                                  .withOpacity(
                                                                    0.6,
                                                                  ),
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    wt * 0.03,
                                                                  ),
                                                              border: Border.all(
                                                                color: Colors
                                                                    .white
                                                                    .withOpacity(
                                                                      0.6,
                                                                    ),
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
                                                                      "${AppConstants.baseImageUrl}${currentItem['poster_path']}",
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
                                                                      color: Colors
                                                                          .red,
                                                                      size:
                                                                          wt *
                                                                          0.08,
                                                                    )
                                                                  : Icon(
                                                                      likList.contains(
                                                                            currentItem['id'],
                                                                          )
                                                                          ? Amicons.iconly_heart_fill
                                                                          : Amicons.iconly_heart,
                                                                      color:
                                                                          likList.contains(
                                                                            currentItem['id'],
                                                                          )
                                                                          ? Colors.red
                                                                          : Colors.white,
                                                                      size:
                                                                          wt *
                                                                          0.05,
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
                                                      all[index]['title']
                                                          .toString(),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                    titleTextStyle: TextStyle(
                                                      color: Colors.white54,
                                                      fontSize: wt * 0.04,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                    subtitle: Text(
                                                      'Release: ${all[index]['release_date']}',
                                                    ),
                                                    subtitleTextStyle:
                                                        TextStyle(
                                                          color: Colors.white38,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: wt * 0.03,
                                                        ),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 2,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    children: [
                                                      Container(
                                                        width: wt * 0.14,
                                                        height: ht * 0.028,
                                                        decoration: BoxDecoration(
                                                          color: Colors.white24,
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                wt * 0.04,
                                                              ),
                                                        ),
                                                        child: Center(
                                                          child: Text(
                                                            ('${(all[index]['vote_average'] / 2).toStringAsFixed(1).toString()}/5.0'),
                                                            style: TextStyle(
                                                              color: Colors
                                                                  .white38,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize:
                                                                  wt * 0.03,
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
                            ),
                            if (all.isNotEmpty && bottomLod)
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: SizedBox(
                                  width: wt,
                                  height: ht * 0.13,
                                  child: Center(
                                    child:
                                        LoadingAnimationWidget.progressiveDots(
                                          color: Colors.green,
                                          size: wt * 0.1,
                                        ),
                                  ),
                                ),
                              ),
                          ],
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

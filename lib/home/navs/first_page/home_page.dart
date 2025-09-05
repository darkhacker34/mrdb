import 'dart:convert';
import 'package:amicons/amicons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating/flutter_rating.dart';
import 'package:flutter_rating_stars/flutter_rating_stars.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:mrdb/home/navs/first_page/preview_page.dart';
import '../../../main.dart';

class MRDb extends StatefulWidget {
  final String lang;
  const MRDb({super.key, this.lang='en'});

  @override
  State<MRDb> createState() => _MRDbState();
}

class _MRDbState extends State<MRDb> {

  List<dynamic> all = [];
  int pageNum = DateTime.now().second;
  bool refresh=false;
  bool lod = false;
  bool forReFresh=false;
  double pixel = 0;
  bool isSearch=false;
  bool showSearch=false;
  TextEditingController search = TextEditingController();
  ScrollController moveTo = ScrollController();
  Future<void> getMovie({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        all.clear();
        forReFresh=false;
        pageNum=DateTime.now().second;
      });
    }

    setState(() {
      lod = true;
      if (pageNum > 1 && moveTo.hasClients) {
        moveTo.jumpTo(pixel);
      }
    });

    Uri url = Uri.parse(
      'https://api.themoviedb.org/3/discover/movie'
          '?api_key=38ed19dab876e12b797aaa54db51b633'
          '&with_original_language=${widget.lang}'
          '&sort_by=popularity.desc'
          '&page=$pageNum'
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
          setState(() {
            lod=false;
            forReFresh=true;
          });
          showScaffoldMsg(context, txt: "ReFresh the page...");
        }
      }
    }
  }


  searchMovie(String query) async {
    if (query.isEmpty) {
      all.clear();
      getMovie();
      return;
    }
    setState(() {
      lod = true;
      isSearch=true;
    });

    Uri url = Uri.parse(
      'https://api.themoviedb.org/3/search/movie?api_key=38ed19dab876e12b797aaa54db51b633&query=$query',
    );

    http.Response res = await http.get(url);
    setState(() {
      var a = jsonDecode(res.body);
      all = a['results'];
      search.clear();
      lod = false;
      isSearch=false;
    });
  }

  @override
  void initState() {
    getMovie();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: pixel>1000?InkWell(
        onTap: () {
          moveTo.animateTo(0, duration: Duration(milliseconds: 500), curve: Curves.fastEaseInToSlowEaseOut);
        },
        child: CircleAvatar(
          backgroundColor: Colors.white70,
          radius: wt*0.06,
          child: Center(
            child: Icon(Icons.arrow_upward,color: Colors.black,),
          ),
        ),
      ):SizedBox(),
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
      body: forReFresh? Center(
        child: InkWell(
            borderRadius: BorderRadius.circular(wt*0.1),
          onTap: () =>getMovie(refresh: true),

          child: Container(
            width: wt*0.27,
            height: wt*0.1,
            decoration: BoxDecoration(
              color: Colors.grey.shade700,
              borderRadius: BorderRadius.circular(wt*0.1)
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Icon(Amicons.vuesax_refresh_circle_fill,size: wt*0.09,color: Colors.white54,),
                Text('Refresh',style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.bold
                ),)
              ],
            ),
          ),
        ),
      ):Padding(
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
                    if(value.isNotEmpty){
                      showSearch=true;
                    }else{
                      showSearch=false;
                    }
                  });
                },
                style: TextStyle(
                  color: Colors.grey.shade300,
                  fontWeight: FontWeight.w600
                ),
                decoration: InputDecoration(
                  fillColor: Colors.grey.shade700,
                  filled: true,
                  hintText: 'Movies, shows, celebrities...',
                  hintStyle: TextStyle(
                    color: Colors.grey
                  ),
                  suffixIcon: showSearch?isSearch?Padding(
                    padding: EdgeInsets.all(wt*0.015),
                    child: LoadingAnimationWidget.dotsTriangle(color: Colors.white, size: wt*0.06),
                  ):InkWell(
                    borderRadius: BorderRadius.circular(wt * 1),
                    onTap: () {
                      searchMovie(search.text);
                      FocusManager.instance.primaryFocus!.unfocus();
                    },
                    child: Icon(Icons.search, color: Colors.white54),
                  ):null,
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
                  setState(() {

                  });
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
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: wt * 0.02,
                            crossAxisSpacing: wt * 0.02,
                            mainAxisExtent: wt * 0.9,
                          ),
                          itemBuilder: (context, index) {
                            final currentItem=all[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MoviePreview(movieId: currentItem['id'],),
                                  ),
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(wt * 0.04),
                                  border: Border.all(color: Colors.grey),
                                ),
                                child: Column(
                                  children: [
                                    Expanded(
                                      flex: 9,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(wt * 0.04),
                                          topRight: Radius.circular(wt * 0.04),
                                        ),
                                        child: all[index]['poster_path'] != null
                                            ? CachedNetworkImage(
                                          imageUrl:
                                          'https://image.tmdb.org/t/p/w500${all[index]['poster_path']}',
                                          width: wt * 0.5,
                                          placeholder: (context, url) =>
                                              LoadingAnimationWidget.fallingDot(color: Colors.green, size: wt * 0.1),
                                          errorWidget: (context, url, error) =>
                                              Image.asset('assets/images/image_error.png',
                                                  color: Colors.grey, width: wt * 0.05),
                                          fit: BoxFit.cover,
                                        )
                                            : Image.asset(
                                          'assets/images/image_error.png',
                                          color: Colors.grey,
                                          width: wt * 0.5,
                                          fit: BoxFit.cover,
                                        ),
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
                                              borderRadius: BorderRadius.circular(
                                                wt * 0.04,
                                              ),
                                            ),
                                            child: Center(
                                              child: Text(
                                                ('${(all[index]['vote_average'] / 2).toString().split('.').first}.${(all[index]['vote_average'] / 2).toString().split('.').last[0]}/5.0')
                                                    .toString(),
                                                style: TextStyle(
                                                  color: Colors.white38,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: wt * 0.03,
                                                ),
                                              ),
                                            ),
                                          ),
                                          StarRating(
                                            starCount: 5,
                                            size: wt * 0.04,
                                            rating: (all[index]['vote_average'] / 2),
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
                        if(lod)
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
                                child: LoadingAnimationWidget.progressiveDots(
                                  color: Colors.white70,
                                  size: wt * 0.1,
                                ),
                              ),
                            ),
                          )
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

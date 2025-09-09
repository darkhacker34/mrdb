import 'dart:convert';
import 'package:amicons/amicons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating/flutter_rating.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:lottie/lottie.dart';
import 'package:marquee/marquee.dart';
import 'package:mrdb/constens/all_color.dart';
import 'package:mrdb/constens/keys.dart';
import 'package:mrdb/home/bottom_nav.dart';
import 'package:mrdb/home/navs/about.dart';
import 'package:pretty_animated_text/pretty_animated_text.dart';
import 'package:provider/provider.dart';
import 'package:readmore/readmore.dart';
import '../../../main.dart';
import '../../../models/movie_model.dart';
import '../../../provider/client.dart';

class MoviePreview extends StatefulWidget {
  final int movieId;
  const MoviePreview({super.key, required this.movieId});

  @override
  State<MoviePreview> createState() => _MoviePreviewState();
}

class _MoviePreviewState extends State<MoviePreview> {

  bool islod = false;
  Map<String, dynamic> movi = {};
  var cast = [];
  var genre = [];
  var actors = [];
  List favAdding = [];
  List liked = [];
  List reviews = [];

  Future<void> addFav({
    required int movieId,
    required String title,
    required String image,
    required String year,
    required double rating,
  }) async {
    var deviceId = Provider.of<ClientProvider>(
      context,
      listen: false,
    ).clientId!;
    Movie movie = Movie(
      movId: movieId,
      title: title,
      img: image,
      year: year,
      rating: rating,
      timeStamp: DateTime.now(),
    );
    if (liked.contains(movieId)) {
      showScaffoldMsg(context, txt: 'Go To Favorite Page to Remove!!');
    }
    int attempt = 0;
    while (!liked.contains(movieId) && attempt < 3) {
      setState(() {
        favAdding.add(movieId);
      });
      try {
        await FirebaseFirestore.instance
            .collection(AppConstants.phone)
            .doc(deviceId)
            .collection('liked')
            .doc(movie.movId.toString())
            .set(movie.toMap());

        setState(() {
          liked.add(movieId);
          favAdding.remove(movieId);
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
            favAdding.remove(movieId);
          });
          if (mounted)
            showScaffoldMsg(
              context,
              txt: 'Tried 3 times... please try again ❌',
            );
        }
      }
    }
  }
  Future<void> getMovieDetails() async {
    Uri? url = Uri.parse(
      'https://api.themoviedb.org/3/movie/${widget.movieId}?api_key=${AppConstants.apiKey}&language=en',
    );
    Uri? castUri = Uri.parse(
      'https://api.themoviedb.org/3/movie/${widget.movieId}/credits?api_key=${AppConstants.apiKey}&language=en',
    );

    setState(() {
      islod = true;
    });
    int attempt = 0;
    while (attempt <= 3) {
      try {
        http.Response res = await http.get(url);
        http.Response castRes = await http.get(castUri);
        final response = jsonDecode(res.body);
        final castResponse = jsonDecode(castRes.body);
        List allCast = castResponse['cast'];

        actors = allCast
            .where((element) => element['known_for_department'] == 'Acting')
            .toList();

        movi = response;
        var ff = response['genres'];
        genre = ff.map((item) => item['name'].toString()).toList();
        await getReviews();
        setState(() {

          islod = false;
        });
        return;
      } catch (c) {
        attempt++;
        if (attempt <= 3) {
          await Future.delayed(Duration(seconds: 1));
        } else {
          if (mounted) {
            Navigator.pop(context);
            showScaffoldMsg(context, txt: 'Please Try Again...');
          }
        }
      }
    }

  }
  Future<void> getReviews() async {
    Uri uri = Uri.parse('https://api.themoviedb.org/3/movie/${widget.movieId}/reviews?api_key=${AppConstants.apiKey}');

    int attempt=0;
    while(attempt<5){
      try{
        http.Response response = await http.get(uri);
        var data=jsonDecode(response.body);
        setState(() {
          reviews=data['results'];
        });
        return;
      }catch(e){
        attempt++;
        if(attempt<5){
          await Future.delayed(Duration(seconds: 1));
        }else{
          if(mounted)showScaffoldMsg(context, txt: e.toString());
        }
      }
    }
  }
  
  @override
  void initState() {
    getMovieDetails();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String imgUrl(dynamic path) {
      if (path == null || path.isEmpty) {
        return 'https://bioapdps.com.my/malayamedicalcentre/images/no-image/No-Image-Found-400x264.png';
      }
      if (path.startsWith('http')) return path;
      return '${AppConstants.baseImageUrl}$path';
    }

    final img = imgUrl(movi['backdrop_path'] ?? movi['poster_path']);
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: islod
            ? Center(
                child: LoadingAnimationWidget.discreteCircle(
                  color: Colors.lightGreenAccent,
                  secondRingColor: Colors.pink,
                  thirdRingColor: Colors.indigoAccent,
                  size: wt * 0.15,
                ),
              )
            : CustomScrollView(
                slivers: [
                  SliverAppBar(
                    backgroundColor: Colors.black,
                    leading: IconButton(
                      icon: Icon(
                        Amicons.remix_arrow_go_back,
                        color: Colors.grey.shade300,
                      ),
                      onPressed: () {
                        if (mounted) Navigator.pop(context);
                      },
                      tooltip: 'Go back',
                    ),
                    pinned: true,
                    expandedHeight: ht * 0.3,
                    flexibleSpace: LayoutBuilder(
                      builder: (context, constraints) {
                        var top = constraints.biggest.height;
                        bool isCollapsed = top <= 150;
                        return FlexibleSpaceBar(
                          titlePadding: EdgeInsets.all(wt * 0.03),
                          title: !isCollapsed
                              ? Padding(
                                  padding: EdgeInsets.all(wt * 0.02),
                                  child: SizedBox(
                                    width: wt * 1,
                                    height: ht * 0.057,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(
                                          height: ht * 0.034,
                                          child:
                                              (movi['title'] ?? 'Unknown Title')
                                                      .length >
                                                  20
                                              ? Marquee(
                                                  text:
                                                      movi['title'] ??
                                                      'Unknown Title',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: wt * 0.05,
                                                    fontWeight: FontWeight.bold,
                                                    shadows: [
                                                      Shadow(
                                                        offset: Offset(1, 1),
                                                        blurRadius: 3,
                                                        color: Colors.black54,
                                                      ),
                                                    ],
                                                  ),
                                                  scrollAxis: Axis.horizontal,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  blankSpace: wt * 0.5,
                                                  startAfter: Duration(
                                                    seconds: 2,
                                                  ),
                                                  pauseAfterRound: Duration(
                                                    seconds: 2,
                                                  ),
                                                )
                                              : Text(
                                                  movi['title'] ??
                                                      'Unknown Title',
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: wt * 0.05,
                                                    fontWeight: FontWeight.bold,
                                                    shadows: [
                                                      Shadow(
                                                        offset: Offset(1, 1),
                                                        blurRadius: 3,
                                                        color: Colors.black54,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                        ),
                                        Expanded(
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Amicons.vuesax_star,
                                                    color: Colors.yellow,
                                                    size: wt * 0.04,
                                                  ),
                                                  SizedBox(width: wt * 0.02),
                                                  Text(
                                                    (movi['vote_average'] ??
                                                            0.0)
                                                        .toStringAsFixed(1),
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: wt * 0.03,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      shadows: [
                                                        Shadow(
                                                          offset: Offset(1, 1),
                                                          blurRadius: 2,
                                                          color: Colors.black54,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(width: wt * 0.05),
                                              Expanded(
                                                flex: 4,
                                                child: (genre.length) > 2
                                                    ? SizedBox(
                                                        height: ht * 0.05,
                                                        width: double.infinity,
                                                        child: Marquee(
                                                          text: genre.join(
                                                            ',  ',
                                                          ),
                                                          style: TextStyle(
                                                            color:
                                                                Colors.white70,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: wt * 0.03,
                                                          ),
                                                          scrollAxis:
                                                              Axis.horizontal,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          blankSpace: wt * 0.5,
                                                          startAfter: Duration(
                                                            seconds: 2,
                                                          ),
                                                          pauseAfterRound:
                                                              Duration(
                                                                seconds: 2,
                                                              ),
                                                        ),
                                                      )
                                                    : Text(
                                                        genre
                                                            .join(',  ')
                                                            .toString(),
                                                        style: TextStyle(
                                                          color: Colors.white70,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: wt * 0.03,
                                                        ),
                                                      ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: wt * 0.12,
                                  ),
                                  child: Align(
                                    alignment: Alignment.bottomLeft,
                                    child: Text(
                                      movi['title'] ?? 'Unknown Title',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: wt * 0.06,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                          background: SizedBox(
                            width: wt,
                            child: Stack(
                              children: [
                                CachedNetworkImage(
                                  imageUrl: img,
                                  fit: BoxFit.cover,
                                  width: wt,
                                  height: ht * 0.34,
                                  placeholder: (context, url) => Container(
                                    color: Colors.grey.shade800,
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          CircularProgressIndicator(
                                            color: Colors.grey.shade400,
                                          ),
                                          SizedBox(height: ht * 0.02),
                                          Text(
                                            'Loading...',
                                            style: TextStyle(
                                              color: Colors.grey.shade400,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Container(
                                        color: Colors.grey.shade800,
                                        child: Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.movie,
                                                size: wt * 0.2,
                                                color: Colors.grey.shade600,
                                              ),
                                              SizedBox(height: ht * 0.01),
                                              Text(
                                                'Image not available',
                                                style: TextStyle(
                                                  color: Colors.grey.shade500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                ),
                                Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Container(
                                    width: wt,
                                    height: ht * 0.15,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.transparent,
                                          Colors.black38,
                                          Colors.black87,
                                        ],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        stops: [0, 0.4, 1],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildListDelegate([
                      Padding(
                        padding: EdgeInsets.all(wt * 0.07),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(wt * 0.05),
                          onTap: () {},
                          child: Container(
                            width: wt * 0.9,
                            height: ht * 0.075,
                            decoration: BoxDecoration(
                              color: Colors.teal.withOpacity(0.1),
                              border: Border.all(
                                color: Colors.teal.withOpacity(0.3),
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(wt * 0.05),
                            ),
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Amicons.lucide_play,
                                  color: Colors.teal,
                                  size: wt * 0.07,
                                ),
                                SizedBox(width: wt * 0.04),
                                Text(
                                  'Watch Now',
                                  style: TextStyle(
                                    color: Colors.teal,
                                    fontWeight: FontWeight.bold,
                                    fontSize: wt * 0.055,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: ht * 0.1,

                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              InkWell(
                                splashColor: Colors.teal.withOpacity(0.1),
                                highlightColor: Colors.teal.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(wt * 0.02),
                                onTap: () {},
                                child: Padding(
                                  padding: EdgeInsets.all(wt * 0.02),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Icon(
                                        Amicons.remix_heart_add,
                                        color: Colors.white,
                                        size: wt * 0.1,
                                      ),
                                      Text(
                                        'My List',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              InkWell(
                                splashColor: Colors.teal.withOpacity(0.1),
                                highlightColor: Colors.teal.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(wt * 0.02),
                                onTap: () {},
                                child: Padding(
                                  padding: EdgeInsets.all(wt * 0.02),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Icon(
                                        Amicons.iconly_star,
                                        color: Colors.white,
                                        size: wt * 0.1,
                                      ),
                                      Text(
                                        'Rate',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              InkWell(
                                splashColor: Colors.teal.withOpacity(0.1),
                                highlightColor: Colors.teal.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(wt * 0.02),
                                onTap: () {},
                                child: Padding(
                                  padding: EdgeInsets.all(wt * 0.02),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Icon(
                                        Amicons.remix_share,
                                        color: Colors.white,
                                        size: wt * 0.1,
                                      ),
                                      Text(
                                        'Share',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontWeight: FontWeight.bold,
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
                      if ((movi['overview'].toString()).isNotEmpty)Padding(
                          padding: EdgeInsets.all(wt * 0.04),
                          child: ListTile(
                            title: Padding(
                              padding: EdgeInsets.only(bottom: ht * 0.015),
                              child: Text('Synopsis'),
                            ),
                            subtitle: Text(movi['overview']),
                            subtitleTextStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: wt * 0.04,
                              fontWeight: FontWeight.w500,
                            ),
                            titleTextStyle: TextStyle(
                              color: Colors.white,
                              fontSize: wt * 0.05,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      if (actors.isNotEmpty)Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: wt * 0.08,
                            vertical: 0,
                          ),
                          child: Text(
                            'Cast',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: wt * 0.05,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      if (actors.isNotEmpty)Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: wt * 0.03,
                            vertical: ht * 0.01,
                          ),
                          child: SizedBox(
                            height: ht * 0.24,
                            width: wt * 1,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              padding: EdgeInsets.symmetric(
                                horizontal: wt * 0.02,
                              ),
                              itemCount: actors.length,
                              itemBuilder: (context, index) {
                                String image =
                                    'https://image.tmdb.org/t/p/w500${actors[index]['profile_path']}';
                                return SizedBox(
                                  width: wt * 0.35,
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      ClipOval(
                                        child: CachedNetworkImage(
                                          imageUrl: image,
                                          width: wt * 0.3,
                                          height: ht * 0.14,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) =>
                                              LottieBuilder.asset(
                                                'assets/lottie/image_loading.json',
                                                fit: BoxFit.cover,
                                              ),
                                          errorWidget: (context, url, error) =>
                                              Icon(
                                                CupertinoIcons.person,
                                                size: wt * 0.2,
                                                color: Colors.grey.withOpacity(
                                                  0.5,
                                                ),
                                              ),
                                        ),
                                      ),
                                      Text(
                                        actors[index]['name'],
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.8),
                                          fontSize: wt * 0.04,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        softWrap: true,
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                );
                              },
                              separatorBuilder: (context, index) {
                                return SizedBox(width: wt * 0.02);
                              },
                            ),
                          ),
                        ),
                      if(reviews.isNotEmpty)Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: wt * 0.08,
                          vertical: 0,
                        ),
                        child: Row(
                          children: [
                            Text(
                              'Reviews',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: wt * 0.05,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      reviews.isNotEmpty?Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: wt * 0.08,
                          vertical: ht * 0.024,
                        ),
                        child: ListView.separated(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: reviews.length,
                          itemBuilder: (context, index) {
                            var review =reviews[index];
                            var profile =review['author_details']['avatar_path'];
                            String name=review['author'];
                            Map<String, Color>? circleColor=AllLettersColors.colorsAZ[name[0].toUpperCase()];
                            return Container(
                              width: wt * 0.9,
                              padding: EdgeInsets.only(
                                bottom: ht*0.03,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade900.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(wt * 0.05)
                              ),
                              child: Column(
                                children: [
                                  ListTile(
                                    title: Text(name,overflow: TextOverflow.ellipsis,maxLines: 1,),
                                    titleTextStyle: TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold,
                                      fontSize: wt * 0.035,
                                    ),
                                    subtitle: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        StarRating(
                                          size: wt*0.05,
                                          rating: (review['author_details']['rating']??0)/2,
                                          allowHalfRating: true,
                                        ),
                                        Text(review['updated_at'].split("T").first,style: TextStyle(
                                          color: Colors.grey
                                        ),)
                                      ],
                                    ),
                                    leading: CircleAvatar(
                                      radius: wt * 0.07,
                                      backgroundColor: circleColor?['color'],
                                      child: profile!=null? CircleAvatar(
                                        radius: wt * 0.065,
                                        backgroundImage: CachedNetworkImageProvider(
                                          '${AppConstants.baseImageUrl}$profile',
                                        ),
                                      ):
                                          Center(
                                            child: Text(name[0].toUpperCase(),style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: wt*0.05,
                                              color: circleColor?['combo']
                                            ),),
                                          ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: ht*0.01 ,
                                  ),
                                  SizedBox(
                                    width: wt*0.7,
                                    child: ReadMoreText(
                                      review['content'],
                                      trimLines: 6,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.6)
                                      ),
                                      colorClickableText: Colors.green,
                                      isExpandable: true,
                                      trimMode: TrimMode.Line,
                                      textAlign: TextAlign.start,
                                    ),
                                  )
                                ],
                              ),
                            );
                          },
                          separatorBuilder: (context, index) =>
                              SizedBox(height: ht * 0.03),
                        ),
                      ):Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.reviews_outlined,
                              color: Colors.white70,
                              size: wt*0.1,
                            ),
                            SizedBox(height: ht*0.015),
                            Text(
                              'No Reviews Found',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: wt*0.04,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(wt * 0.07),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(wt * 0.05),
                          onTap: () {
                            currentIndex = 2;
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MainScreen(),
                              ),
                              (route) => false,
                            );
                          },
                          child: Container(
                            width: wt * 0.9,
                            height: ht * 0.075,
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              border: Border.all(
                                color: Colors.green.withOpacity(0.4),
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(wt * 0.05),
                            ),
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Amicons.lucide_badge_info,
                                  color: Colors.green,
                                  size: wt * 0.07,
                                ),
                                SizedBox(width: wt * 0.04),
                                Text(
                                  'More Info',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                    fontSize: wt * 0.055,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ]),
                  ),
                ],
              ),
      ),
    );
  }
}

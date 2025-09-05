import 'dart:convert';
import 'package:amicons/amicons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pretty_animated_text/pretty_animated_text.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../../main.dart';

class MoviePreview extends StatefulWidget {
  final int movieId;
  const MoviePreview({
    super.key,
    required this.movieId,
  });

  @override
  State<MoviePreview> createState() => _MoviePreviewState();
}

YoutubePlayerController? yt;

bool islod = false;
Map<String, dynamic> movi={};
class _MoviePreviewState extends State<MoviePreview> {
  Future<void> getMovieDetails() async {
    Uri? url=Uri.parse('https://api.themoviedb.org/3/movie/${widget.movieId}?api_key=38ed19dab876e12b797aaa54db51b633&language=en');
    setState(() {
      islod=true;
    });
    try{
      http.Response res = await http.get(url);
      final response = jsonDecode(res.body);
      movi=response;
      setState(() {
        islod=false;
      });

    }catch(c){
      if(Navigator.canPop(context)){
        Navigator.pop(context);
        showScaffoldMsg(context, txt: 'Please Try Again...');
      }else{
        showScaffoldMsg(context, txt: 'Press Back And Try Again...');
      }
    }
  }
  String imgUrl(dynamic path) {
    if (path == null || path.isEmpty) return 'https://bioapps.com.my/malayamedicalcentre/images/no-image/No-Image-Found-400x264.png';
    if (path.startsWith('http')) return path;
    return 'https://image.tmdb.org/t/p/w500$path';
  }
@override
  void initState() {
    getMovieDetails();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {

    final img = imgUrl(movi['backdrop_path']??movi['poster_path']);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(CupertinoIcons.back),
          color: Colors.white,
        ),
        backgroundColor: Colors.black,
        title: islod?LoadingAnimationWidget.progressiveDots(color: Colors.green, size: wt*0.07):
        FittedBox(
          fit: BoxFit.scaleDown,
          child: OffsetText(
            text: movi['original_title'],
            textAlignment: TextAlignment.center,
            duration: Duration(milliseconds: 400),
            type: AnimationType.word,
            slideType: SlideAnimationType.alternateLR,
            textStyle: TextStyle(fontSize: wt * 0.05),
          ),
        ),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: wt * 0.06,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
      ),
      body: islod
          ? Center(
              child: LoadingAnimationWidget.inkDrop(
                color: Colors.green,
                size: wt * 0.1,
              ),
            )
          : Column(
            children: [
              SizedBox(
                width: wt*1,
                height: wt*0.5,
                child: CachedNetworkImage(
                  imageUrl: img,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Center(
                    child: LoadingAnimationWidget.fallingDot(
                      color: Colors
                          .green,
                      size: wt * 0.1,
                    ),
                  ),
                  errorWidget: (context, url, error) => Icon(Amicons.iconly_image_2_fill,size: wt*0.2,color: Colors.white30),
                ),
              ),
            ],
          ),
    );
  }
}

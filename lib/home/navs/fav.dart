import 'package:amicons/amicons.dart';
import 'package:flutter/material.dart';

import '../../main.dart';

class Favorite extends StatefulWidget {
  const Favorite({super.key});

  @override
  State<Favorite> createState() => _FavoriteState();
}

class _FavoriteState extends State<Favorite> {
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
      body: ListView.builder(
        itemCount: 5,
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
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(wt * 0.04),
                    bottomLeft: Radius.circular(wt * 0.04),
                  ),
                  child: SizedBox(
                    width: wt * 0.3,
                    height: wt * 0.5,
                    child: Image.network(
                      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRK4R7Pg7cz4BjrSWjLeuzcHBTrTuDJBXLBGQ&s',
                      fit: BoxFit.cover,
                    ),
                  ),
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
                        Text(
                          'Venom: Let There Be Carnage',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: wt * 0.05,
                          ),
                        ),
                        SizedBox(height: wt * 0.02),
                        Row(
                          children: [
                            Expanded(
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
                                  children: [
                                    Icon(
                                      Amicons.vuesax_star_1,
                                      color: Colors.yellow,
                                      size: wt * 0.05,
                                    ),
                                    SizedBox(width: wt * 0.01),
                                    Text(
                                      '3.4',
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
                                    '2025-07-29',
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
                        Spacer(),
                        InkWell(
                          onTap: () {

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
    );
  }
}

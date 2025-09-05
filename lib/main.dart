import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mrdb/home/bottom_nav.dart';
import 'package:mrdb/home/navs/fav.dart';
import 'package:mrdb/test.dart';

import 'home/navs/first_page/home_page.dart';

void main() async {
  runApp(Crud());
}

var wt;
var ht;
showScaffoldMsg(context, {required String txt}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.circular(wt*0.1)
      ),
      width: wt*0.95,
      showCloseIcon: true,
      closeIconColor: Colors.black.withOpacity(0.5),
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.white.withOpacity(0.8),
      content: Center(
        child: Text(
          txt,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: Colors.black.withOpacity(0.8), fontWeight: FontWeight.bold),
        ),
      ),
    ),
  );
}

class Crud extends StatelessWidget {
  const Crud({super.key});

  @override
  Widget build(BuildContext context) {
    wt = MediaQuery.of(context).size.width;
    ht = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus!.unfocus();
      },

      child: MaterialApp(
        theme: ThemeData(
          bottomSheetTheme: BottomSheetThemeData(
            backgroundColor: Colors.transparent,
          ),
          appBarTheme: AppBarTheme(
            color: Colors.white,
            surfaceTintColor: Colors.white,
          ),
          scaffoldBackgroundColor: Colors.white,
          textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
        ),
        debugShowCheckedModeBanner: false,
        home: Favorite(),
      ),
    );
  }
}

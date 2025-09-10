import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:mrdb/firebase_options.dart';
import 'package:mrdb/home/bottom_nav.dart';
import 'package:mrdb/home/navs/fav.dart';
import 'package:mrdb/home/navs/first_page/preview_page.dart';
import 'package:mrdb/provider/client.dart';
import 'package:mrdb/splash.dart';
import 'package:provider/provider.dart';

import 'home/navs/first_page/home_page.dart';
List all=[];
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(ChangeNotifierProvider(
    create: (_) => ClientProvider(),
      child: Crud()
  )
  );
}

var wt;
var ht;
void showScaffoldMsg(context, {required String txt}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      duration: Duration(seconds: 1),
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
            surfaceTintColor: Colors.black,
          ),
          scaffoldBackgroundColor: Colors.white,
        ),
        debugShowCheckedModeBanner: false,
        home: Splash(),
      ),
    );
  }
}

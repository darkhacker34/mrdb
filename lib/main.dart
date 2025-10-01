import 'package:device_preview_plus/device_preview_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mrdb/firebase_options.dart';
import 'package:mrdb/provider/client.dart';
import 'package:mrdb/splash.dart';
import 'package:provider/provider.dart';
List all=[];
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(ChangeNotifierProvider(
    create: (_) => ClientProvider(),
      child: DevicePreview(
        builder: (context) => MRDb(),
        enabled: false,
      )
  )
  );
}

var wt;
var ht;
void showScaffoldMsg(BuildContext context, {required String txt}) {
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

class MRDb extends StatelessWidget {
  const MRDb({super.key});

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
            backgroundColor: Colors.white,
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

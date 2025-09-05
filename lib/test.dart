import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:torch_light/torch_light.dart';

class Test extends StatefulWidget {
  const Test({super.key});

  @override
  State<Test> createState() => _TestState();
}
bool on =false;
class _TestState extends State<Test> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(title: Text('Test Flash'),),
      body: Center(
        child: IconButton(
            onPressed: () async {
              var stat = await Permission.camera.status;
              if(stat.isDenied){
                stat = await Permission.camera.request();
              }
              if(stat.isGranted){
                final hasTorch = await TorchLight.isTorchAvailable();
                if(hasTorch){
                  try{
                    if(on){
                      await TorchLight.enableTorch();
                    }else{
                      await TorchLight.disableTorch();
                    }
                    setState(() {
                      on=!on;
                    });
                  }catch(e){
                    print('error Flash: $e');
                  }
                }
              }
            },
            icon: Icon(Icons.ondemand_video_outlined)),
      ),
    );
  }
}

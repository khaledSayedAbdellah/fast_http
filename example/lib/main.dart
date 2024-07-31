import 'dart:developer';
import 'dart:typed_data';
import 'package:easy_http/fast_http.dart';
import 'package:flutter/material.dart';

import 'api_method.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  Uint8List? imageData;

  Future getImage()async{
    setState(() {imageData = null;});
   final result = await APIMethod.getImageData(imagePath: "https://picsum.photos/id/237/200/300");
   result.fold((l)=> log(l.errorModel.statusMessage), (r)=> setState(() {imageData = r;}));

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: getImage,
              child: const Text("execute simple request"),
            ),
            const SizedBox(height: 16,),
            if(imageData != null) Image.memory(imageData!),
            if(imageData == null) const CircularProgressIndicator(),

          ],
        ),
      ),
      floatingActionButton: StreamBuilder<RequestProgressModel>(
        stream: FastHttp.requestProgressStream.stream,
        builder: (context, snapshot) {
          if(!snapshot.hasData) return const SizedBox();
          return FloatingActionButton(
            onPressed: (){},
            child: Text("${snapshot.data?.bytes??0} / ${snapshot.data?.totalBytes??0}"),
          );
        }
      ),
    );
  }
}

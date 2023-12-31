import 'dart:async';

import 'package:bugheist/src/pages/welcome.dart';
import 'package:bugheist/src/routes/routing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

/// ### The BugHeist app's root widget
class BugHeist extends StatefulWidget {
  const BugHeist({Key? key}) : super(key: key);

  @override
  BugHeistState createState() => BugHeistState();
}

class BugHeistState extends State<BugHeist> {
  late StreamSubscription _intentDataStreamSubscription;
  late List<SharedMediaFile> _sharedFiles;
  //late String _sharedText;
  final _messengerKey = GlobalKey<ScaffoldMessengerState>();
  @override
  void initState() {
    super.initState();
    // For sharing images coming from outside the app while the app is in the memory
    _intentDataStreamSubscription = ReceiveSharingIntent.getMediaStream()
        .listen((List<SharedMediaFile> value) {
      setState(() {
        print(_sharedFiles);
        _sharedFiles = value;
      });
    }, onError: (err) {
      print("getIntentDataStream error: $err");
    });

    // For sharing images coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialMedia().then((List<SharedMediaFile> value) {
      setState(() {
        _sharedFiles = value;
      });
    });

    // For sharing or opening urls/text coming from outside the app while the app is in the memory
    _intentDataStreamSubscription =
        ReceiveSharingIntent.getTextStream().listen((String value) {
      setState(() {
        print('detected a link here 1');
        print(value);
        //_sharedText = value;
      });
    }, onError: (err) {
      print("getLinkStream error: $err");
    });

    // For sharing or opening urls/text coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialText().then((value) {
      setState(() {
        print('detected text here:');
        print(value);
        //_sharedText = value;
      });
    });
  }

  @override
  void dispose() {
    _intentDataStreamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Intializing riverpod for state management
    return ProviderScope(
      child: GestureDetector(
        onTap: () {
          // This enables focusing out of text field, by touching anywhere
          // outside them
          FocusScopeNode currentScope = FocusScope.of(context);
          if (!currentScope.hasPrimaryFocus && currentScope.hasFocus) {
            FocusManager.instance.primaryFocus!.unfocus();
          }
        },
        child: MaterialApp(
          scaffoldMessengerKey: _messengerKey,
          debugShowCheckedModeBanner: false,
          onGenerateRoute: RouteManager.generateRoute,
          title: 'BugHeist',
          theme: ThemeData(
            primarySwatch: Colors.red,
            primaryColor: Colors.white,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          home: WelcomePage(),
        ),
      ),
    );
  }
}

// The config app layout variable
// or this value can load online https://json-inspire-ui.inspire.now.sh/config.json - see document
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';


const kEmptyColor = 0XFFF2F2F2;


Widget kLoadingWidget(context) => Center(
      child: SpinKitFadingCube(
        color: Colors.deepOrange,
        size: 30.0,
      ),
    );


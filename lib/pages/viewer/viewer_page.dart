// This source code is a part of Project Violet.
// Copyright (C) 2020. violet-team. Licensed under the Apache-2.0 License.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:violet/pages/viewer/vertical_viewer/vertical_viewer_widget.dart';

int currentPage = 0;

class ViewerPage extends StatelessWidget {
  final List<String> images;
  final Map<String, String> headers;
  final String id;

  ViewerPage({this.images, this.headers, this.id});

  bool canResizeToAvoidBottomInset(BuildContext context) {
    if (context == null) return false;
    var viewInsets = MediaQuery.of(context).viewInsets;
    var insetsBottom = viewInsets.bottom;
    var screenHeight = MediaQuery.of(context).size.height;
    return (screenHeight * 0.18) < insetsBottom;
  }

  @override
  Widget build(BuildContext context) {
    return
        //  WillPopScope(
        //   onWillPop: () {
        //     Navigator.pop(context, currentPage);
        //     return new Future(() => false);
        //   },
        //   child:
        AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
      ),
      sized: false,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        resizeToAvoidBottomPadding: false,
        body: ViewerWidget(
          id: id,
          headers: headers,
          urls: images,
          // ),
        ),
      ),
    );
  }
}

// This source code is a part of Project Violet.
// Copyright (C) 2020. violet-team. Licensed under the Apache-2.0 License.

import 'package:flutter/material.dart';
import 'package:html_unescape/html_unescape_small.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';
import 'package:uuid/uuid.dart';
import 'package:violet/algorithm/distance.dart';
import 'package:violet/component/hitomi/hitomi.dart';
import 'package:violet/database/query.dart';
import 'package:violet/locale/locale.dart';
import 'package:violet/model/article_list_item.dart';
import 'package:violet/pages/artist_info/artist_info_page.dart';
import 'package:violet/settings/settings.dart';
import 'package:violet/widgets/article_item/article_list_item_widget.dart';

class ArtistListPage extends StatelessWidget {
  final List<String> aritsts;
  ArtistListPage({this.aritsts});

  Future<List<QueryResult>> _future(String e) async {
    var unescape = new HtmlUnescape();
    var postfix = e.toLowerCase().replaceAll(' ', '_');
    var queryString = HitomiManager.translate2query('artist:' +
        postfix +
        ' ' +
        Settings.includeTags +
        ' ' +
        Settings.excludeTags
            .where((e) => e.trim() != '')
            .map((e) => '-$e')
            .join(' '));
    final qm = QueryManager.queryPagination(queryString);
    qm.itemsPerPage = 10;

    var x = await qm.next();
    var y = [x[0]];

    var titles = [unescape.convert((x[0].title() as String).trim())];
    if (titles[0].contains('Ch.'))
      titles[0] = titles[0].split('Ch.')[0];
    else if (titles[0].contains('ch.')) titles[0] = titles[0].split('ch.')[0];

    for (int i = 1; i < x.length; i++) {
      var skip = false;
      var ff = unescape.convert((x[i].title() as String).trim());
      if (ff.contains('Ch.'))
        ff = ff.split('Ch.')[0];
      else if (ff.contains('ch.')) ff = ff.split('ch.')[0];
      for (int j = 0; j < titles.length; j++) {
        var tt = titles[j];
        if (Distance.levenshteinDistanceComparable(
                tt.runes.map((e) => e.toString()).toList(),
                ff.runes.map((e) => e.toString()).toList()) <
            3) {
          skip = true;
          break;
        }
      }
      if (skip) continue;
      y.add(x[i]);
      titles.add(ff.trim());
    }

    return y;
  }

  @override
  Widget build(BuildContext context) {
    var windowWidth = MediaQuery.of(context).size.width;
    final width = MediaQuery.of(context).size.width;
    final height =
        MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top;
    final mediaQuery = MediaQuery.of(context);
    return Padding(
      padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top,
          bottom: (mediaQuery.padding + mediaQuery.viewInsets).bottom),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Card(
              elevation: 5,
              color:
                  Settings.themeWhat ? Color(0xFF353535) : Colors.grey.shade100,
              child: SizedBox(
                width: width - 16,
                height: height -
                    16 -
                    (mediaQuery.padding + mediaQuery.viewInsets).bottom,
                child: Container(
                    child: ListView.builder(
                        padding: EdgeInsets.fromLTRB(0, 4, 0, 0),
                        physics: ClampingScrollPhysics(),
                        itemCount: aritsts.length,
                        itemBuilder: (BuildContext ctxt, int index) {
                          var e = aritsts[index];
                          return FutureBuilder<List<QueryResult>>(
                              future: _future(e),
                              builder: (BuildContext context,
                                  AsyncSnapshot<List<QueryResult>> snapshot) {
                                var qq = snapshot.data;
                                if (!snapshot.hasData)
                                  return Container(
                                    height: 195,
                                  );
                                return InkWell(
                                  onTap: () async {
                                    Navigator.of(context).push(PageRouteBuilder(
                                      // opaque: false,
                                      transitionDuration:
                                          Duration(milliseconds: 500),
                                      transitionsBuilder: (context, animation,
                                          secondaryAnimation, child) {
                                        var begin = Offset(0.0, 1.0);
                                        var end = Offset.zero;
                                        var curve = Curves.ease;

                                        var tween = Tween(
                                                begin: begin, end: end)
                                            .chain(CurveTween(curve: curve));

                                        return SlideTransition(
                                          position: animation.drive(tween),
                                          child: child,
                                        );
                                      },
                                      pageBuilder: (_, __, ___) =>
                                          ArtistInfoPage(
                                        isGroup: false,
                                        isUploader: false,
                                        artist: e,
                                      ),
                                    ));
                                  },
                                  child: SizedBox(
                                    height: 195,
                                    child: Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(12, 8, 12, 0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: <Widget>[
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: <Widget>[
                                                Text(
                                                    ' ' +
                                                        e +
                                                        ' (' +
                                                        HitomiManager
                                                                .getArticleCount(
                                                                    'artist', e)
                                                            .toString() +
                                                        ')',
                                                    style: TextStyle(
                                                        fontSize: 17)),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 162,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: <Widget>[
                                                  _image(qq, 0, windowWidth),
                                                  _image(qq, 1, windowWidth),
                                                  _image(qq, 2, windowWidth),
                                                ],
                                              ),
                                            ),
                                          ],
                                        )),
                                  ),
                                );
                              });
                        })),
              ),
            ),
          ]),
    );
  }

  Widget _image(List<QueryResult> qq, int index, double windowWidth) {
    return Expanded(
        flex: 1,
        child: qq.length > index
            ? Padding(
                padding: EdgeInsets.all(4),
                child: Provider<ArticleListItem>.value(
                  value: ArticleListItem.fromArticleListItem(
                    queryResult: qq[index],
                    showDetail: false,
                    addBottomPadding: false,
                    width: (windowWidth - 16 - 4.0 - 16.0) / 3,
                    thumbnailTag: Uuid().v4(),
                  ),
                  child: ArticleListItemVerySimpleWidget(),
                ),
              )
            : Container());
  }
}

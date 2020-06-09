import 'package:flutter/material.dart';
import 'package:flutter_moment/api/cloud_music_api.dart';
import 'dart:math';

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _HomeState();
}

class _HomeState extends State<Home> {
  CloudMusicApi cloudMusicApi = new CloudMusicApi();
  Map<String, String> currentMusic;

  @override
  void initState() {
    super.initState();
    _getRandMusic();
  }

  void _getRandMusic() async {
    List playList = await cloudMusicApi.getPlayList();
    int len = playList.length;
    if (len > 0) {
      Random rand = new Random();
      int i = rand.nextInt(len);
      var current = playList[i];
      String url = await cloudMusicApi.getMusicUrl(current['id']);
      var comment = await cloudMusicApi.getMusicComment(current['id']);
      setState(() {
        currentMusic = {
          'url': url,
          'name': current['name'],
          'pic': current['al']['picUrl'],
          'comment': comment['content'],
          'commentUser': comment['user']['nickname'],
        };
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: _appBar(),
      body: _body(currentMusic),
    );
  }
}

Widget _appBar() => AppBar(
      title: Text('辛巳'),
    );

Widget _body(Map currentMusic) {
  if (currentMusic == null) {
    return Container();
  }

  return Card(
      margin: EdgeInsets.fromLTRB(15, 15, 15, 90),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(0))),
      elevation: 3,
      child: Column(
        children: <Widget>[
          Image(
            image: NetworkImage(currentMusic['pic']),
            fit: BoxFit.fill,
          ),
          Container(
              padding: EdgeInsets.all(30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    currentMusic['comment'].toString(),
                    softWrap: true,
                    textAlign: TextAlign.justify,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 5,
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    "「 ${currentMusic['commentUser'].toString()} 」",
                    textAlign: TextAlign.right,
                  )
                ],
              )
          )
        ],
      )
  );
}

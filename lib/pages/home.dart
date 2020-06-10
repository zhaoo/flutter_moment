import 'package:flutter/material.dart';
import 'package:flutter_moment/api/cloud_music_api.dart';
import 'dart:math';
import 'package:transparent_image/transparent_image.dart';
import 'package:audioplayers/audioplayers.dart';

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _HomeState();
}

class _HomeState extends State<Home> {
  CloudMusicApi cloudMusicApi = new CloudMusicApi();
  AudioPlayer audioPlayer = AudioPlayer();
  Map<String, String> currentMusic;
  String playStatus = 'stop';

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

  void _playMusic() async {
    int res = await audioPlayer.play(currentMusic['url']);
    if (res == 1) {
      setState(() {
        playStatus = 'play';
      });
    }
  }

  void _stopMusic() async {
    int res = await audioPlayer.stop();
    if (res == 1) {
      setState(() {
        playStatus = 'stop';
      });
    }
  }

  void _pauseMusic() async {
    int res = await audioPlayer.pause();
    if (res == 1) {
      setState(() {
        playStatus = 'pause';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: _appBar(),
      body: _body(),
    );
  }

  Widget _appBar() {
    if (currentMusic == null) {
      return AppBar();
    }
    return AppBar(title: Text(currentMusic['name']));
  }

  Widget _body() {
    if (currentMusic == null) {
      return Container();
    }
    return Card(
        margin: EdgeInsets.fromLTRB(15, 15, 15, 90),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(0))),
        elevation: 2,
        child: Column(
          children: <Widget>[
            FadeInImage.memoryNetwork(
              image: currentMusic['pic'],
              placeholder: kTransparentImage,
              width: MediaQuery.of(context).size.width - 30,
              height: MediaQuery.of(context).size.width - 30,
              fit: BoxFit.cover,
            ),
            Container(
                padding: EdgeInsets.all(30),
                child: Column(
                  children: <Widget>[
                    Text(
                      currentMusic['comment'].toString(),
                      softWrap: true,
                      textAlign: TextAlign.justify,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 5,
                      style: TextStyle(fontSize: 16),
                    ),
                    Container(
                      alignment: Alignment.centerRight,
                      margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                      child: Text(
                        "「 ${currentMusic['commentUser'].toString()} 」",
                      ),
                    ),
                    FlatButton(
                      onPressed: () {
                        _showPlayControl();
                      },
                      child: playStatus == 'play' ? Text('暂停') : Text('播放'),
                    )
                  ],
                ))
          ],
        ));
  }

  void _showPlayControl() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
            return Container(
              height: 100,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    IconButton(
                      iconSize: 36,
                      icon: Icon(Icons.skip_previous),
                      onPressed: () {},
                    ),
                    IconButton(
                      iconSize: 48,
                      icon: playStatus == 'play'
                          ? Icon(Icons.pause)
                          : Icon(Icons.play_arrow),
                      onPressed: () {
                        // print(playStatus);
                        if (playStatus == 'play') {
                          _pauseMusic();
                        } else {
                          _playMusic();
                        }
                      },
                    ),
                    IconButton(
                      iconSize: 36,
                      icon: Icon(Icons.skip_next),
                      onPressed: () {},
                    ),
                    playStatus == 'play' ? Text('暂停') : Text('播放')
                  ],
                ),
              ),
            );
          });
        });
  }
}

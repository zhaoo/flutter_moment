import 'package:flutter/material.dart';
import 'package:flutter_moment/api/cloud_music_api.dart';
import 'package:flutter_moment/api/weather_api.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:amap_location/amap_location.dart';
import 'package:location_permissions/location_permissions.dart';

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _HomeState();
}

class _HomeState extends State<Home> {
  WeatherApi weatherApi = new WeatherApi();
  CloudMusicApi cloudMusicApi = new CloudMusicApi();
  AudioPlayer audioPlayer = AudioPlayer();
  AudioPlayerState playerState;
  Duration position = new Duration(hours: 0, minutes: 0, seconds: 0);
  Duration duration = new Duration(hours: 0, minutes: 0, seconds: 0);

  Map<String, String> currentMusic;
  Map<String, String> weather;
  String playStatus = 'stop';

  @override
  void initState() {
    super.initState();
    _getWeather();
    _getRandMusic();
  }

  @override
  void deactivate() async {
    await audioPlayer.release();
    super.deactivate();
  }

  void _getWeather() async {
    PermissionStatus permission =
        await LocationPermissions().requestPermissions();
    if (!(permission == PermissionStatus.granted)) {
      return;
    }
    await AMapLocationClient.startup(new AMapLocationOption(
        desiredAccuracy: CLLocationAccuracy.kCLLocationAccuracyHundredMeters));
    AMapLocation loc = await AMapLocationClient.getLocation(true);
    String city = loc.city;
    print(city);
    Set filterCity = {'市', '区', '县', '省'};
    filterCity.forEach((e) {
      if (city.contains(e)) {
        city = city.replaceAll(e, '');
      }
    });
    Map res = await weatherApi.getWeatherByCity(city);
    setState(() {
      weather = {
        'city': city,
        'temperature': res['temperature'],
        'info': res['info'],
      };
    });
  }

  void _getRandMusic() async {
    int id = await cloudMusicApi.getRandPlayList();
    var current = await cloudMusicApi.getRandPlay(id);
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

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: _appBar(),
      body: _body(),
      floatingActionButton: _floatingActionButton(),
    );
  }

  Widget _floatingActionButton() {
    return Container(
        margin: EdgeInsets.fromLTRB(0, 0, 15, 15),
        child: FloatingActionButton(
          onPressed: () {
            _showPlayControl();
          },
          child: Icon(Icons.album),
          backgroundColor: Colors.black,
        ));
  }

  Widget _appBar() {
    return AppBar(
      title: currentMusic == null ? Text('片刻') : Text(currentMusic['name']),
      actions: <Widget>[
        Container(
            padding: EdgeInsets.all(15),
            alignment: Alignment.bottomCenter,
            child: weather == null
                ? Text('正在定位')
                : Text(
                    '${weather['city']} · ${weather['info']}  ${weather['temperature']}°C'))
      ],
    );
  }

  Widget _body() {
    if (currentMusic == null) {
      return Container();
    }
    return Card(
        margin: EdgeInsets.fromLTRB(15, 15, 15, 15),
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
            Expanded(
                child: Container(
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
                        )
                      ],
                    )))
          ],
        ));
  }

  void _showPlayControl() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter state) {
            audioPlayer.onPlayerStateChanged.listen((AudioPlayerState s) {
              state(() => playerState = s);
            });

            audioPlayer.onAudioPositionChanged.listen((Duration p) {
              state(() => position = p);
            });

            audioPlayer.onDurationChanged.listen((Duration d) {
              state(() => duration = d);
            });

            void _playMusic() async {
              await audioPlayer.play(currentMusic['url']);
            }

            void _stopMusic() async {
              await audioPlayer.stop();
            }

            void _pauseMusic() async {
              await audioPlayer.pause();
            }

            return Container(
                height: 200,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        IconButton(
                          iconSize: 40,
                          icon: Icon(Icons.skip_previous),
                          onPressed: () {
                            _pauseMusic();
                            _getRandMusic();
                          },
                        ),
                        IconButton(
                          iconSize: 60,
                          icon: playerState == AudioPlayerState.PLAYING
                              ? Icon(Icons.pause)
                              : Icon(Icons.play_arrow),
                          onPressed: () {
                            if (playerState == AudioPlayerState.PLAYING) {
                              _pauseMusic();
                            } else {
                              _playMusic();
                            }
                          },
                        ),
                        IconButton(
                          iconSize: 40,
                          icon: Icon(Icons.skip_next),
                          onPressed: () {
                            _pauseMusic();
                            _getRandMusic();
                          },
                        ),
                      ],
                    ),
                    Slider(
                      value: position.inSeconds.toDouble(),
                      max: duration.inSeconds.toDouble(),
                      min: 0.0,
                      activeColor: Colors.black,
                      inactiveColor:Colors.black12,
                      onChanged: (double val) async {
                        await audioPlayer.seek(Duration(seconds: val.toInt()));
                      },
                    ),
                  ],
                ));
          });
        });
  }
}

import 'package:flutter_moment/api/http.dart';
import 'dart:math';

class CloudMusicApi {
  static const BASE_URL = 'https://musicapi.leanapp.cn';

  getRandPlayList() async {
    Map<String, String> params = new Map();
    Random rand = new Random();
    int i = rand.nextInt(100);
    params['cat'] = '民谣';
    params['offset'] = i.toString();
    var res = await Http.get(BASE_URL + '/top/playlist', params: params);
    if (res['code'] == 200) {
      List playList = res['playlists'];
      int len = playList.length;
      if (len > 0) {
        Random rand = new Random();
        int i = rand.nextInt(len);
        return playList[i]['id'];
      }
    }
  }

  getRandPlay(int id) async {
    Map<String, String> params = new Map();
    params['id'] = id.toString();
    var res = await Http.get(BASE_URL + '/playlist/detail', params: params);
    if (res['code'] == 200) {
      List playList = res['playlist']['tracks'];
      int len = playList.length;
      if (len > 0) {
        Random rand = new Random();
        int i = rand.nextInt(len);
        return playList[i];
      }
    }
  }

  getMusicUrl(int id) async {
    Map<String, String> params = new Map();
    params['id'] = id.toString();
    var res = await Http.get(BASE_URL + '/music/url', params: params);
    if (res['code'] == 200) {
      return res['data'][0]['url'];
    }
  }

  getMusicComment(int id) async {
    Map<String, String> params = new Map();
    params['id'] = id.toString();
    var res = await Http.get(BASE_URL + '/comment/music', params: params);
    if (res['code'] == 200) {
      if (!res['hotComments'].isEmpty) {
        return res['hotComments'][0];
      } else {
        return res['comments'][0];
      }
    }
  }
}

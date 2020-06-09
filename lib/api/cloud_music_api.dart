import 'package:flutter_moment/api/http.dart';

class CloudMusicApi {
  static const BASE_URL = 'http://musicapi.leanapp.cn';

  getPlayList() async {
    var res = await Http.get(BASE_URL+'/playlist/detail?id=879463910');
    if(res['code'] == 200) {
      return res['playlist']['tracks'];
    }
  }

  getMusicUrl(int id) async {
    Map<String, String> params = new Map();
    params['id'] = id.toString();
    var res = await Http.get(BASE_URL+'/music/url', params: params);
    if(res['code'] == 200) {
      return res['data'][0]['url'];
    }
  }

  getMusicComment(int id) async {
    Map<String, String> params = new Map();
    params['id'] = id.toString();
    var res = await Http.get(BASE_URL+'/comment/music', params: params);
    if(res['code'] == 200) {
      return res['hotComments'][0];
    }
  }
}
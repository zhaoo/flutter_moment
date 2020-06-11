import 'package:flutter_moment/api/http.dart';

class WeatherApi {
  getWeatherByCity(String city) async {
    Map<String, String> params = new Map();
    Map<String, String> weather = new Map();
    params['city'] = city;
    params['key'] = 'bbedbc7b06bc5e0cf93b030b0f91f4fe';
    var res = await Http.get('http://apis.juhe.cn/simpleWeather/query',
        params: params);
    if (res['error_code'] == 0) {
      weather['temperature'] = res['result']['realtime']['temperature'];
      weather['info'] = res['result']['realtime']['info'];
      return weather;
    }
  }
}

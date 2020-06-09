import 'package:http/http.dart' as http;
import 'dart:convert';

class Http {
  static get(String url, {Map<String, String> params}) async {
    if (params != null && params.isNotEmpty) {
      StringBuffer sb = new StringBuffer("?");
      params.forEach((key, value) {
        sb.write("$key" + "=" + "$value" + "&");
      });
      String paramStr = sb.toString();
      paramStr = paramStr.substring(0, paramStr.length - 1);
      url += paramStr;
    }
    try {
      http.Response res = await http.get(url);
      return json.decode(res.body);
    } catch (e) {
      print(e);
    }
  }

  static post(String url, {Map<String, String> params}) async {
    try {
      http.Response res = await http.post(url, body: params);
      return json.decode(res.body);
    } catch (e) {
      print(e);
    }
  }
}

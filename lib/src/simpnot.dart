import 'dart:convert';
import 'package:http/http.dart';

const String appID = 'chalk-bump-f49';
final String apiKey =
    utf8.decode(base64.decode('YzhjMmI4NjMzNzE1NGNkYWJjOTg5YjIzZTMwYzZiZjQ='));
const String bucket = 'note';
const String authURL = "https://auth.simperium.com/1/$appID/authorize/";
const String dataURL = "https://api.simperium.com/1/$appID/$bucket";
const int noteFetchLength = 1000;
const String authHeader = 'X-Simperium-API-Key';
const String dataHeader = 'X-Simperium-Token';

///Class for interacting with simplenote web service
class Simplenote {
  String username;
  String password;
  String? token;
  String current = '';

  ///Constructs a Simplenote object by provided username and password
  Simplenote(this.username, this.password);

  ///Returns Simplenote API token using provided username and password
  Future<String?> authenticate(String username, String password) async {
    var tokenReceived = '';
    try {
      var r = await post(Uri.parse(authURL),
          headers: {authHeader: apiKey},
          body: {"username": username, "password": password});
      tokenReceived = jsonDecode(r.body)["access_token"];
    } catch (e) {}
    if (tokenReceived == '') {
      return null;
    } else {
      return tokenReceived;
    }
  }

  ///Returns token, either by getting a new one or giving out the cached one
  Future<String?> getToken() async {
    if (token == null) {
      token = await authenticate(username, password);
      return token;
    } else {
      return token;
    }
  }

  Future<Map<String, dynamic>?> getNote(String noteid,
      [String? version]) async {
    String paramsVersion = "";
    var tokenCurrent = await getToken();
    if (tokenCurrent == null) {
      return null;
    } else {
      if (!(version == null)) {
        paramsVersion = '/v' + version;
      }
      String params = '/i/' + noteid + paramsVersion;
      var r = await get(Uri.parse(dataURL + params),
          headers: {dataHeader: tokenCurrent});
      if (r.statusCode == 404) {
        return null;
      }
      var q = jsonDecode(r.body);
      q['id'] = noteid;
      q['version'] = version;
      return q;
    }
  }
}

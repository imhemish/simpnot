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

class Note {
  List<dynamic>? tags;
  bool? deleted;
  String? shareURL;
  String? publishURL;
  String? content;
  List<dynamic>? systemTags;
  double? modificationDate;
  double? creationDate;
  String? id;
  int? version;
  Note(Map<String, dynamic>? noteDict) {
    tags = noteDict?['tags'];
    deleted = noteDict?['deleted'];
    shareURL = noteDict?['shareURL'];
    publishURL = noteDict?['publishURL'];
    content = noteDict?['content'];
    systemTags = noteDict?['systemTags'];
    modificationDate = noteDict?['modificationDate'];
    creationDate = noteDict?['creationDate'];

    // Id and Version arent part of note object returned by api in form of json
    id = noteDict?['id'];
    version = noteDict?['version'];
  }

  // Excluding id and version
  Map<String, dynamic>? encodeForAPI() {
    return {
      "tags": tags,
      "deleted": deleted,
      "shareURL": shareURL,
      "publishURL": publishURL,
      "content": content,
      "systemTags": systemTags,
      "modificationDate": modificationDate,
      "creationDate": creationDate
    };
  }

  Map<String, dynamic>? encodeAsDict() {
    return {
      "tags": tags,
      "deleted": deleted,
      "shareURL": shareURL,
      "publishURL": publishURL,
      "content": content,
      "systemTags": systemTags,
      "modificationDate": modificationDate,
      "creationDate": creationDate,
      "version": version,
      "id": id
    };
  }
}

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
    try {
      var r = await post(Uri.parse(authURL),
          headers: {authHeader: apiKey},
          body: {"username": username, "password": password});
      return jsonDecode(r.body)["access_token"];
    } catch (e) {
      return null;
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

  Future<Note?> getNote(String noteid, [String? version]) async {
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
      if (version != null) {
        q['version'] = version;
      }
      return Note(q);
    }
  }

  //Future<Note?> updateNote(Note note) async {
  //var q = note.encodeAsDict();
  //if (q == null) {
  //return null;
  //} else {
  //var copyNote = Note(q);
  //}
  //if (copyNote.id != null) {
  //var isNew = true;
  //} else {
  //var isNew = false;
  //}
  //if (copyNote.version != null) {}
  //}
}

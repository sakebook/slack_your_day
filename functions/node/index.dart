import 'dart:convert';
import 'dart:math';
import 'package:node_http/node_http.dart' as http;

import 'package:firebase_functions_interop/firebase_functions_interop.dart';

const EMOJIS = [":one:", ":two:", ":three:"];

void main() {
  functions['yourDay'] = functions.https.onRequest(yourDay);
}

void yourDay(ExpressHttpRequest request) async {
  print("yourDay request: ${request.body}");
  final config = functions.config;
  final token = config.get("secret.token");
  if (token == null) {
    _responseComplete(request, 400, "Not set Token");
    return;
  }
  final Map<String, dynamic> jsonBody = request.body;
  final text = jsonBody["text"] as String;
  final userGroupId = _parseGroupId(text);
  if (userGroupId == null) {
    _responseComplete(request, 400, "Group not found");
    return;
  }
  final users = await _getUsers(token, userGroupId);
  print("userGroupId: $userGroupId");
  print("users: $users");
  final postText = _postTextFromUsers(users, EMOJIS.length);
  _responseComplete(request, 200, postText);
}


void _responseComplete(ExpressHttpRequest request, int statusCode, String text) {
  request.response.statusCode = statusCode;
  request.response.headers.add("Content-type", "application/json");
  request.response.writeln(_createJSON(text));
  request.response.close();
}

String _parseGroupId(String text) {
  RegExp exp = RegExp("(?<=\\^)([^|]*|)");
  if (!exp.hasMatch(text)) {
    return null;
  }
  final match = exp.firstMatch(text);
  final userGroupId = match.group(0);
  return userGroupId;
}


dynamic _createJSON(String text) {
  final json = {"\"text\"": "\"$text\""};
  return json;
}

Future<List<dynamic>> _getUsers(String token, String usergroupId) async {
  final url = "https://slack.com/api/usergroups.users.list?token=$token&usergroup=$usergroupId&pretty=1";
  final response = await http.get(url);
  final Map<String, dynamic> jsonBody = json.decode(response.body);
  return jsonBody["users"] as List<dynamic>;
}

String _postTextFromUsers(List<dynamic> users, int limit) {
  users.shuffle(Random());
  String text = "本日の主役 ";
  final length = (users.length < limit) ? users.length : limit;
  for (int i = 0; i < length; i++) {
    text += "${EMOJIS[i]} <@${users[i]}> ";
  }
  return text;
}


import 'dart:convert';
import 'dart:math';
import 'package:node_http/node_http.dart' as http;

import 'package:firebase_functions_interop/firebase_functions_interop.dart';

void main() {
  functions['yourDay'] = functions.https.onRequest(yourDay);
}

void yourDay(ExpressHttpRequest request) async {
  print("yourDay request: ${request.body}");
  final config = functions.config;
  final token = config.get("secret.token");
  if (token == null) {
    request.response.statusCode = 400;
    request.response.headers.add("Content-type", "application/json");
    request.response.writeln(_createJSON("Not set Token"));
    request.response.close();
    return;
  }
  final Map<String, dynamic> jsonBody = request.body;
  final text = jsonBody["text"] as String;
  RegExp exp = RegExp("(?<=\\^)([^|]*|)");
  if (!exp.hasMatch(text)) {
    request.response.statusCode = 400;
    request.response.headers.add("Content-type", "application/json");
    request.response.writeln(_createJSON("Group not found"));
    request.response.close();
    return;
  }
  final match = exp.firstMatch(text);
  final userGroupId = match.group(0);
  final users = await _getUsers(token, userGroupId);
  print("userGroupId: $userGroupId");
  print("users: $users");
  final user = _choiceUser(users);
  print("choiceUser: $user");

  request.response.statusCode = 200;
  request.response.headers.add("Content-type", "application/json");
  request.response.writeln(_createJSON("本日の主役 <@$user>"));
  request.response.close();
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

dynamic _choiceUser(List<dynamic> users) {
  users.shuffle(Random());
  return users.first;
}
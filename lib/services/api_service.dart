import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pratice_flutter/common/common_widget.dart';
import 'package:provider/provider.dart';

import '../viewmodels/auth_viewmodel.dart';
import '../views/login_view.dart';

class ApiService {
  static const String baseUrl = 'https://dev.gigagates.com/qq-delivery-backend';
  static const String loginUrl='/v3/user/';
  static const String listUrl='/v4/pickup/list';
  static const String refreshUrl='/v3/user/refresh_token';
  static const String logoutUrl='/v3/user/revoke_access_token_by_username';

  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl$loginUrl'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'username':username, 'password': password}),
    );
    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> fetchData(int first, int max, String token,BuildContext context) async {
    print("Token loadData: $token");
    print("Token body: ${json.encode({'first': first, 'max': max})}");
    final response = await http.post(
      Uri.parse('$baseUrl$listUrl'),
      headers: {
        "charset": "utf-8", "Accept-Charset": "utf-8",
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({'first': first, 'max': max}),
    );
      return json.decode(utf8.decode(response.bodyBytes));


  }

  Future<Map<String, dynamic>> fetchRefreshToken(String? token) async {
    print("Token Refresh: $token");
    CommonWidget.showToast('Refresh token:$token');
  final response= await http.post(
      Uri.parse('$baseUrl$refreshUrl'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({'accessToken':token}),
    );
  return json.decode(response.body);
  }

  Future<void> logout(String token) async {
    await http.post(
      Uri.parse('$baseUrl$logoutUrl'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({}),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:pratice_flutter/viewmodels/auth_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import 'dart:async';

import '../views/login_view.dart';

class DataViewModel with ChangeNotifier {
  List<Map<String, dynamic>> _data = [];
  int _currentPage = 0;
  int _totalRecord = 0;
  bool _isLoading = false;
  bool _hasMore = true;
  User? _user;
  Timer? _refreshTimer;



  User? get user => _user;
  List<Map<String, dynamic>> get data => _data;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  int get currentPage => _currentPage;


  Future<void> setCurrentPage(int page)async{
    _currentPage=0;
    _hasMore=true;
    _data.clear();
    notifyListeners();
  }

  Future<void> loadData(String? token,BuildContext context) async {
    print('LoadData $token');
    if (_isLoading) return;
    _isLoading = true;

    final response = await ApiService().fetchData(_currentPage * 10, 10, token!,context);
    if (response!=null && response['success']) {
      List<Map<String, dynamic>> newData = List<Map<String, dynamic>>.from(response['data']['items']);
      _data.addAll(newData);
      _currentPage++;
      _hasMore = newData.length ==9; // api response is 9
      print("TotalRecord: ${newData.length} $_totalRecord");
      _isLoading = false;

    } else {
      // Handle error
      _isLoading = false;
    }
    notifyListeners();
  }
  Future<void> checkExpireTime(BuildContext context)async{
    SharedPreferences pref=await SharedPreferences.getInstance();
    String? refreshToken = pref.getString('refresh_token');

    _loadRefreshToken(refreshToken,context);
    notifyListeners();
  }

  Future<void> refreshData(BuildContext context) async {
    SharedPreferences prefs=await SharedPreferences.getInstance();
    String? refreshToken=prefs.getString('refresh_token');
    _data.clear();
    _currentPage = 0;
    _hasMore = true;
    _isLoading=false;
    await _loadRefreshToken(refreshToken,context);
    notifyListeners();
  }

  Future<void> _loadRefreshToken(String? refreshToken,BuildContext context) async {
   _isLoading=true;
    final response = await ApiService().fetchRefreshToken(refreshToken);
    _isLoading=false;
    _hasMore=true;
    if (response['success']) {
      _user = User.fromJson(response['data']);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', _user!.accessToken);
      await prefs.setString('refresh_token', _user!.refreshToken);
      await prefs.setInt('expires_in', _user!.expiresIn);
      await loadData(_user!.accessToken,context);

    }
    notifyListeners();
  }

  void _cancelRefreshTimer() {
    _refreshTimer?.cancel();
  }

  @override
  void dispose() {
    _cancelRefreshTimer();
    super.dispose();
  }

  Future<void> loadMoreData(BuildContext context) async {
    SharedPreferences prefs=await SharedPreferences.getInstance();
    String? token=prefs.getString('access_token');
    print('loadMore: $_isLoading $hasMore');
    if (_isLoading || !hasMore) return;

    _isLoading = true;

    final response = await ApiService().fetchData(_currentPage * 10, 10, token!,context);
    if (response!=null && response['success']) {
      _totalRecord=response['data']['totalRecords']??0;
      List<Map<String, dynamic>> newData = List<Map<String, dynamic>>.from(response['data']['items']);
      _data.addAll(newData);
      _currentPage++;
      _hasMore = newData.length ==10;
      // Assuming page size is 10, adjust as needed
      print("HasMore: $_hasMore ${newData.length} $_totalRecord");
      _isLoading = false;

    } else {
      // Handle error
      _isLoading = false;
    }
    notifyListeners();
  }
}

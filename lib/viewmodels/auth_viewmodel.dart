
import 'package:flutter/material.dart';
import 'package:pratice_flutter/common/common_widget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import 'data_viewmodel.dart';
class AuthViewModel with ChangeNotifier {
  User? _user;

  User? get user => _user;

  bool? _isCheck = false;

  bool? get isCheck => _isCheck;

    bool? _isUserName=false;

  bool? get isUserName => _isUserName;

  bool? _isPassword=false;

  bool? get isPassword => _isPassword;

  bool? _isLoginClick=false;

  bool? get isLoginClick=> _isLoginClick;

  bool? _isLoginDataCall=false;

  bool? get isLoginDataCall => _isLoginDataCall;


  Future<void> clickCheckBox(bool? value)async{
    _isCheck=value;
    notifyListeners();
  }

  Future<void> clickLoginButton(bool? value)async{
    _isLoginClick=value;
    notifyListeners();
  }
  Future<void> enterUserName(String value)async{
    if(value.isNotEmpty){
      _isUserName=true;
    }else{
      _isUserName=false;
    }
    notifyListeners();
  }
  Future<void> enterPassword(String value)async{
    if(value.isNotEmpty){
      _isPassword=true;
    }else{
      _isPassword=false;
    }
    notifyListeners();
  }

  Future<void> login(String username, String password) async {
    _isLoginDataCall=true;
    final response = await ApiService().login(username, password);
    if(response['message']=='Login success'){
      if (response['success']) {
        _user = User.fromJson(response['data']);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', _user!.accessToken);
        await prefs.setString('refresh_token', _user!.refreshToken);
        await prefs.setInt('expires_in', _user!.expiresIn);
      }
    }else{
      CommonWidget.showToast('UserName and Password are incorrect');
    }
    _isLoginDataCall=false;
    notifyListeners();
  }

  Future<void> logout(BuildContext context) async {
    final dataViewModel = Provider.of<DataViewModel>(context, listen: false);
    await dataViewModel.setCurrentPage(0);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token') ?? '';
    await ApiService().logout(token);
    await prefs.clear();
    _user = null;
    notifyListeners();
  }

  Future<void> loadUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('access_token')) {
      _user = User(
        accessToken: prefs.getString('access_token')!,
        refreshToken: prefs.getString('refresh_token')!,
        expiresIn: prefs.getInt('expires_in')!,
      );
      notifyListeners();
    }
  }
}

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop_app/module/httpException.dart';

class Auth with ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  String _userId;

  Timer authTimer;

  bool get isAuth {
    print('token on iaAuth $token');
    return token != null;
  }

  String get userId {
    return _userId;
  }

  String get token {
    if (_expiryDate != null &&
        _expiryDate.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  Future<void> authentication(
      String email, String password, String urlSegment) async {
    final url =
        'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyBYa0punUveUrcmZ7A1ks64puwmzmN6grY';
    try {
      final response = await http.post(url,
          body: json.encode({
            'email': email,
            'password': password,
            'returnSecureToken': true,
          }));
      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(
            responseData['expiresIn'],
          ),
        ),
      );
      autoLogOut();
      notifyListeners();
      final pref = await SharedPreferences.getInstance();
      final dataRes = jsonEncode({
        'token': _token,
        'userId': _userId,
        'expiryDate': _expiryDate.toIso8601String()
      });
      pref.setString('userData', dataRes);
    } catch (error) {
      throw error;
    }
  }

  Future<void> signUp(String email, String password) async {
    return authentication(email, password, 'signUp');
  }

  Future<void> logIn(String email, String password) async {
    return authentication(email, password, 'signInWithPassword');
  }

  Future<void> logOut() async {
    _token = null;
    _userId = null;
    _expiryDate = null;
    if (authTimer != null) {
      authTimer.cancel();
      authTimer = null;
    }
    notifyListeners();
    final pref = await SharedPreferences.getInstance();
    // pref.remove('userData');
    pref.clear();
  }

  void autoLogOut() {
    if (authTimer != null) {
      authTimer.cancel();
    }
    final timeToExpiry = _expiryDate.difference(DateTime.now()).inSeconds;
    authTimer = Timer(Duration(seconds: timeToExpiry), logOut);
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }
    final extractedUserData =
        jsonDecode(prefs.getString('userData')) as Map<String, Object>;
    final expireDate = DateTime.parse(extractedUserData['expiryDate']);
    if (expireDate.isBefore(DateTime.now())) {
      return false;
    }
    _token = extractedUserData['token'];
    _userId = extractedUserData['userId'];
    _expiryDate = expireDate;
    notifyListeners();
    autoLogOut();
    return true;
  }
}

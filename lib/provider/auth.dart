import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart'as http;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop/model/http_exception.dart';

class Auth extends ChangeNotifier{
  String? token;
  DateTime? expiryDate;
  String? userId;
  Timer? authTimer;
  bool get Token1{
    return token!=null;
  }
  bool get isAuth{
    return token!=null;
  }
  String? get Token{
    if(expiryDate!=null&&expiryDate!.isAfter(DateTime.now())&&token!=null){
      return token;

    }
    return null;
  }
  String? get UserId{
    return userId;
  }
  Future<void>authenticate(String email,String password,String urlSegment)async{
   final url='https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyDxo3ciNHulf7mAPNZPfDaxKw5QcJi1-0U';
    try{
      final respond=await http.post(Uri.parse(url),body: jsonEncode({
        'email':email,
        'password':password,
        'returnSecureToken':true

        
      }));
      final responseData=jsonDecode(respond.body);
      if(responseData['error']!=null){
        httpExcptions(responseData['error']['message']);
      }
      token=responseData['idToken'];
      userId=responseData['localId'];
      expiryDate=DateTime.now().add(Duration(seconds: int.parse(responseData['expiresIn'])));
      AutoLigout();
      notifyListeners();
      final prefs= await SharedPreferences.getInstance();
      String userData=json.encode({
        'token':token,
        'userId':userId,
        'expiryDate':expiryDate!.toIso8601String()
      });
      prefs.setString('userData', userData);

    }catch(ERROR){
      throw ERROR;

    }
  }
  Future<void>signup(String email,String password)async{
    return authenticate(email, password, 'signUp');

  }
  Future<void>login(String email,String password,)async{

    return authenticate(email, password, 'signInWithPassword');
  }
  Future<bool?>tryAutoLogin()async{
    final prefs= await SharedPreferences.getInstance();
    if(prefs.containsKey('userData'))return false;
    final extractedData=json.decode(prefs.getString('userData')!)as Map<String,Object>;
    final ExpiryData=DateTime.parse(extractedData['expiryDate'].toString());
    if(expiryDate!.isBefore(DateTime.now()))return false;
    token= extractedData['token'].toString();
    userId=extractedData['userId'].toString();
   expiryDate=ExpiryData;
   notifyListeners();
    AutoLigout();
   return true;
  }
  Future<void>Logout()async{
    token=null;
    userId=null;
    expiryDate=null;
    if(authTimer!=null){
      authTimer!.cancel();
      authTimer=null;

    }
    notifyListeners();
    final prfes=await SharedPreferences.getInstance();
    prfes.clear();
  }
  void AutoLigout(){
    if(authTimer!=null){
      authTimer!.cancel();
    }
    final timetoex=expiryDate!.difference(DateTime.now()).inSeconds;
    authTimer=Timer(Duration(seconds: timetoex ),Logout);
  }
}
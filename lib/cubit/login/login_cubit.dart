
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:transport_app/common/globs.dart';

import 'package:transport_app/common/common_extension.dart';

import '../../common/service_call.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {

  LoginCubit() : super(LoginInitialState());

  void submitLogin(String mobileCode, String mobile, String userType){
    try{
      emit(LoginHUDState());
      ServiceCall.post({
        "user_type":userType,
        "mobile_code": mobileCode,
        "mobile": mobile,
        "os_type": Platform.isIOS ? "i" : Platform.isAndroid ? "a" : "w",
        "push_token": "",
        "socket_id": "",
      },SVKey.svLogin,
      withSuccess:(responseObj)async{
        if((responseObj[KKey.status] as String? ?? "")=="1"){
          ServiceCall.userObj = responseObj[KKey.payload] as Map? ?? {};
          ServiceCall.userType = ServiceCall.userObj["user_type"] as int? ?? 1;

          Globs.udSet(ServiceCall.userObj, Globs.userPayload);
          Globs.udBoolSet(false,"is_online");
          Globs.udBoolSet(true, Globs.userLogin);
          emit(LoginApiResultState());
          emit(TokenState(ServiceCall.userObj["auth_token"]));
          emit(LoginInitialState());
        }else{
          emit(LoginErrortState(responseObj[KKey.message] ?? MSG.fail));
        }
      },
      failure: (err) async{
        emit(LoginErrortState(err));
      });
    }catch(e){
      emit(LoginErrortState(e.toString()));
    }
  }

}

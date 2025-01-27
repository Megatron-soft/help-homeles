import 'package:flutter_bloc/flutter_bloc.dart';

class LanguageBloc extends Cubit<String> {
  LanguageBloc() : super("en");

  void changeLang(){
    String newState = "en";
    if(state == "en"){
      newState = "ar";
    }
    else{
      newState = "en";
    }
    emit(newState);
  }
}
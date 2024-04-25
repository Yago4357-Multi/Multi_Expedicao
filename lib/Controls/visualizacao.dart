import 'dart:io';


///Classe para descobrir o tipo de sistema que está acessando
String visualizacao(){
  if (Platform.isAndroid){
    return '/Login';
  }
  else{
    return '/Login';
  }
}
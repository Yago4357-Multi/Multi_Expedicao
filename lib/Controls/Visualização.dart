import 'package:flutter/foundation.dart';

String Visualizacao(){
  if (kIsWeb){
    return '/Romaneio';
  }
  else{
    return '/Contagem';
  }
}
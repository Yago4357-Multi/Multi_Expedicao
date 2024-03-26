class Contagem {
  String Codigo;
  late String Cod_Arrumado, Ped;
  late int Vol, Cx, Soma, Palete;

  Contagem(this.Codigo, this.Palete){
    Cod_Arrumado = Codigo.substring(14,33);
    Ped = Cod_Arrumado.substring(0,10);
    Vol = int.parse(Cod_Arrumado.substring(17,19));
    Cx = int.parse(Cod_Arrumado.substring(14,16));
  }

}

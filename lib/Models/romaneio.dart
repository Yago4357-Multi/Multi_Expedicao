
///Objeto para manter padrão do Romaneio
class Romaneio{

  ///Variáveis inicials do Romaneio
  late int? romaneio, vol, codTrans;
  ///Variáveis inicials do Romaneio
  late String? usurCriacao, palete, transportadora;

  ///Variáveis inicias do Romaneio
  late DateTime? dtFechamento, dtRomaneio;


  ///Construtor para a classe do Romaneio
  Romaneio(this.romaneio, this.vol, this.dtFechamento, this.dtRomaneio,
      this.usurCriacao, this.palete, this.codTrans, this.transportadora);
}
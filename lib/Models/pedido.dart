
///Objeto para manter padrão do Pedido
class Pedido{

  ///Variáveis inicials do Pedido
  late String palete, status;
  ///Variáveis inicials do Pedido
  late int ped, vol, caixas;

  ///Construtor para a classe de Pedido
  Pedido(this.ped, this.palete, this.caixas, this.vol, this.status);
}
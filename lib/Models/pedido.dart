
///Objeto para manter padrão do Pedido
class Pedido{

  ///Variáveis inicials do Pedido
  late String palete, status;

  late String?  situacao, cnpj, cidade;

  late int? nota, volfat;

  late double? valor;
  ///Variáveis inicials do Pedido
  late int ped, vol, caixas;

  ///Construtor para a classe de Pedido
  Pedido(this.ped, this.palete, this.caixas, this.vol, this.status, {this.situacao, this.cnpj , this.cidade, this.nota, this.valor, this.volfat});
}
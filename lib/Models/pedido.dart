
///Objeto para manter padrão do Pedido
class Pedido{

  ///Variáveis inicials do Pedido
  late String palete, status;

  ///Variáveis inicials do Pedido
  late String?  situacao, cnpj, cidade, cliente;

  ///Variáveis inicials do Pedido
  late int? nota, volfat, codCli, codVenda, romaneio;

  ///Variáveis inicials do Pedido
  late DateTime? dtPedido, dtCancelPed, dtFat, dtCancelNf;

  ///Variáveis inicials do Pedido
  late double? valor;

  ///Variáveis inicials do Pedido
  late int ped, vol, caixas;

  ///Construtor para a classe de Pedido
  Pedido(this.ped, this.palete, this.caixas, this.vol, this.status, {this.situacao, this.cnpj , this.cidade, this.nota, this.valor, this.volfat, this.codCli, this.cliente, this.codVenda, this.dtPedido, this.dtFat, this.dtCancelPed, this.dtCancelNf, this.romaneio});
}
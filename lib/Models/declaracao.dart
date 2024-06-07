
///Objeto para manter padrão do Pedido
class Declaracao{

  ///Variáveis inicials do Pedido
  late String palete, status;

  ///Variáveis inicials do Pedido
  late String?  situacao, cnpj, cidade, cliente, endereco;

  ///Variáveis inicials do Pedido
  late int? nota, volfat, codCli, codVenda, romaneio;

  ///Variáveis inicials do Pedido
  late DateTime? dtPedido, dtCancelPed, dtFat, dtCancelNf;

  ///Variáveis inicials do Pedido
  late double? valor;

  ///Variáveis inicials do Pedido
  late int ped, vol, caixas;

  late String? motivo;

  late bool? ignorar;

  String? cep, telefone;

  ///Construtor para a classe de Pedido
  Declaracao(this.ped, this.palete, this.caixas, this.vol, this.status, {this.situacao, this.cnpj , this.cidade, this.nota, this.valor, this.volfat, this.codCli, this.cliente, this.codVenda, this.dtPedido, this.dtFat, this.dtCancelPed, this.dtCancelNf, this.romaneio, this.ignorar, this.endereco, this.motivo, this.cep, this.telefone});
}
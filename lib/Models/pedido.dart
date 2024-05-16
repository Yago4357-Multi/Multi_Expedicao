
///Objeto para manter padrão do Pedido
class Pedido{

  ///Variáveis inicials do Pedido
  late String palete, status;

  late String?  situacao, cnpj, cidade, cliente;

  late int? nota, volfat, cod_cli, cod_venda, romaneio;

  late DateTime? dt_pedido, dt_cancel_ped, dt_fat, dt_cancel_nf;

  late double? valor;
  ///Variáveis inicials do Pedido
  late int ped, vol, caixas;

  ///Construtor para a classe de Pedido
  Pedido(this.ped, this.palete, this.caixas, this.vol, this.status, {this.situacao, this.cnpj , this.cidade, this.nota, this.valor, this.volfat, this.cod_cli, this.cliente, this.cod_venda, this.dt_pedido, this.dt_fat, this.dt_cancel_ped, this.dt_cancel_nf, this.romaneio});
}
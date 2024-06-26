
///Objeto para manter padrão do Pedido
class Pedido{
  ///Variáveis iniciais do Pedido
  late String palete, status;

  ///Variáveis iniciais do Pedido
  late String?  situacao, cnpj, cidade, cliente;

  ///Variáveis iniciais do Pedido
  late int? nota, volfat, codCli, codVenda, romaneio, codTrans;

  ///Variáveis iniciais do Pedido
  late DateTime? dtPedido, dtCancelPed, dtFat, dtCancelNf;

  ///Variáveis iniciais do Pedido
  late double? valor;

  ///Variáveis iniciais do Pedido
  late int ped, vol, caixas;

  ///Variável para verificar se o pedido é ignorado ou não
  late bool? ignorar;

  ///Construtor para a classe de Pedido
  Pedido(this.ped, this.palete, this.caixas, this.vol, this.status,
      {this.situacao,
      this.cnpj,
      this.cidade,
      this.nota,
      this.valor,
      this.volfat,
      this.codCli,
      this.cliente,
      this.codVenda,
      this.dtPedido,
      this.dtFat,
      this.dtCancelPed,
      this.dtCancelNf,
      this.romaneio,
      this.ignorar,
      this.codTrans});
}
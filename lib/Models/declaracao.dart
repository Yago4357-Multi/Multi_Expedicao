
///Objeto para manter padrão do Pedido
class Declaracao{
  ///Variáveis iniciais do Pedido
  late String palete, status;

  ///Variáveis iniciais do Pedido
  late String?  situacao, cnpj, cidade, cliente, endereco;

  ///Variáveis iniciais do Pedido
  late int? nota, volfat, codCli, codVenda, romaneio;

  ///Variáveis iniciais do Pedido
  late DateTime? dtPedido, dtCancelPed, dtFat, dtCancelNf;

  ///Variáveis iniciais do Pedido
  late double? valor;

  ///Variáveis iniciais do Pedido
  late int ped, vol, caixas;

  ///Variável para guardar o motivo da declaração
  late String? motivo;

  ///Variável para guardar se o pedido vai ser ignorado ou não
  late bool? ignorar;

  ///Dados do cliente
  String? cep, telefone;

  ///Construtor para a classe de Pedido
  Declaracao(this.ped, this.palete, this.caixas, this.vol, this.status, {this.situacao, this.cnpj , this.cidade, this.nota, this.valor, this.volfat, this.codCli, this.cliente, this.codVenda, this.dtPedido, this.dtFat, this.dtCancelPed, this.dtCancelNf, this.romaneio, this.ignorar, this.endereco, this.motivo, this.cep, this.telefone});
}
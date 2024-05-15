
///Objeto para manter padrão da Bipagem
class Contagem {

  ///Variáveis inicias da Bipagem
  late int? ped, vol, caixa, palete;

  late String? cidade, cliente, status;

  ///Construtor da classe para a Bipagem
  Contagem(this.ped, this.palete, this.caixa, this.vol,{this.cliente, this.cidade, this.status});

}

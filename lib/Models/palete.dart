///Objeto para manter padrão do Palete
class Paletes{

  ///Variáveis do Palete não finalizado
  int? pallet, volumetria;
  ///Variáveis de Data do Palete não finalizado
  DateTime? dtInclusao;

  String? UsurInclusao;

  ///Variáveis adicionais do Palete finalizado
  String? UsurFechamento;
  ///Variáveis de Data adicionais do Palete finalizado
  DateTime? dtFechamento;

  ///Variáveis de Data adicionais do Palete carregado
  String? UsurCarregamento;
  ///Variáveis de Data adicionais do Palete carregado
  DateTime? dtCarregamento;

  ///Construtor para criar um objeto Palete
  Paletes(this.pallet, this.UsurInclusao, this.dtInclusao, this.volumetria,{this.UsurFechamento,
    this.dtFechamento, this.UsurCarregamento, this.dtCarregamento});
}
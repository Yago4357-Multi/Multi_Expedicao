///Objeto para manter padrão do Palete
class Paletes{

  ///Variáveis do Palete não finalizado
  int? pallet, idUsurInclusao, volumetria;
  ///Variáveis de Data do Palete não finalizado
  DateTime? dtInclusao;

  ///Variáveis adicionais do Palete finalizado
  int? idUsurFechamento;
  ///Variáveis de Data adicionais do Palete finalizado
  DateTime? dtFechamento;

  ///Variáveis de Data adicionais do Palete carregado
  int? idUsurCarregamento;
  ///Variáveis de Data adicionais do Palete carregado
  DateTime? dtCarregamento;

  ///Construtor para criar um objeto Palete
  Paletes(this.pallet, this.idUsurInclusao, this.dtInclusao, this.volumetria,{this.idUsurFechamento,
       this.dtFechamento, this.idUsurCarregamento, this.dtCarregamento});
}
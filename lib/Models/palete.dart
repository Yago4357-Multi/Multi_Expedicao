///Objeto para manter padrão do Palete
class Paletes{

  ///Variáveis do Palete não finalizado
  int? pallet, volumetria, romaneio;

  ///Usuário que criou o Palete
  String? usurInclusao;

  ///Data de criação do palete
  DateTime? dtInclusao;

  ///Usuário que fechou o Palete
  String? usurFechamento;

  ///Data de fechamento do palete
  DateTime? dtFechamento;

  ///Usuário que carregou o Palete
  String? usurCarregamento;

  ///Data de carregamento do palete
  DateTime? dtCarregamento;

  ///Construtor para criar um objeto Palete
  Paletes(this.pallet, this.usurInclusao, this.dtInclusao, this.volumetria,
      {this.usurFechamento,
      this.dtFechamento,
      this.usurCarregamento,
      this.dtCarregamento,
      this.romaneio});
}
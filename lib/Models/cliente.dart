///Classe para definir o padrão do Cliente
class Cliente{
  ///Variáveis iniciais do Cliente
  int? codCli, codCid;

  ///Variáveis iniciais do Cliente
  String? cliente,
      nomeFantasia,
      cnpj,
      tipo,
      bairro,
      cep,
      telefoneCelular,
      endereco;

  ///Variáveis iniciais do Cliente
  String? cidade;

  ///Construtor do objeto "Cliente"
  Cliente(this.codCli, this.codCid, this.cliente, this.nomeFantasia, this.cnpj,
      this.tipo,
      {this.cidade,
      this.bairro,
      this.cep,
      this.telefoneCelular,
      this.endereco});
}
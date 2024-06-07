class Cliente{

  int? cod_cli,cod_cid;

  String? cliente, nome_fantasia, cnpj, tipo, bairro, cep, telefone_celular,endereco;

  String? cidade;

  Cliente(this.cod_cli, this.cod_cid, this.cliente, this.nome_fantasia,
      this.cnpj, this.tipo, {this.cidade, this.bairro, this.cep, this.telefone_celular, this.endereco});

}
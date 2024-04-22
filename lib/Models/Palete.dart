class palete{
  int? pallet, id_usur_inclusao, volumetria;
  DateTime? dt_inclusao;
  int? id_usur_fechamento;
  DateTime? dt_fechamento;

  palete(this.pallet, this.id_usur_inclusao, this.dt_inclusao, this.volumetria,{this.id_usur_fechamento,
       this.dt_fechamento});
}
import 'base/entity_base.dart';

class Tarefa extends EntityBase {
  String titulo;
  String descricao;
  String prioridade; 
  String? tagidentificacao; 
  DateTime dataInicio;
  DateTime? dataFinalizacao;
  String responsavel;

  Tarefa({
    super.id,
    required this.titulo,
    required this.descricao,
    required this.prioridade,
    required this.dataInicio,       
    this.dataFinalizacao,           
    required this.responsavel,     
    super.criadoEm,
    super.editadoEm,
    this.tagidentificacao,
  });

  // Helpers para conversão de data
  String get dataInicioString => dataInicio.toIso8601String();
  String? get dataFinalizacaoString => dataFinalizacao?.toIso8601String();

  factory Tarefa.fromMap(Map<String, dynamic> map) {
    return Tarefa(
      id: map['id'] as int?,
      titulo: map['titulo'] as String,
      descricao: map['descricao'] as String,
      prioridade: map['prioridade'] as String,
      dataInicio: DateTime.parse(map['dataInicio'] as String),             
      dataFinalizacao: map['dataFinalizacao'] != null                  
          ? DateTime.parse(map['dataFinalizacao'] as String)
          : null,
      responsavel: map['responsavel'] as String,                       
      criadoEm: DateTime.parse(map['criadoEm'] as String),
      editadoEm: map['editadoEm'] != null 
          ? DateTime.parse(map['editadoEm'] as String)
          : null,
      tagidentificacao: map['tagidentificacao'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'descricao': descricao,
      'prioridade': prioridade,
      'dataInicio': dataInicioString,                 
      'dataFinalizacao': dataFinalizacaoString,       
      'responsavel': responsavel,                       
      'criadoEm': criadoEmString,
      'editadoEm': editadoEmString,
      'tagidentificacao': tagidentificacao,
    };
  }

  Map<String, dynamic> toJson() => toMap();

  @override
  String toString() {
    return 'Tarefa{id: $id, titulo: $titulo, responsavel: $responsavel, '
           'prioridade: $prioridade, dataInicio: $dataInicio}';
  }

  // Método útil para verificar se está finalizada
  bool get isFinalizada => dataFinalizacao != null;
}
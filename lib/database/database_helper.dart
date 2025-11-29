import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../models/tarefa.dart';
import 'dart:io';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  static const String _databaseName = '202310130.db';
  static const int _databaseVersion = 1;

  static const String tableTarefas = 'tarefas';

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(_databaseName);
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, filePath);

    print('📂 Caminho do banco: $path');

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const textTypeNull = 'TEXT';

    await db.execute('''
      CREATE TABLE $tableTarefas (
        id $idType,
        titulo $textType,
        descricao $textType,
        prioridade $textType,
        dataInicio $textType,
        dataFinalizacao $textTypeNull,
        responsavel $textType,
        tagidentificacao $textTypeNull,
        criadoEm $textType,
        editadoEm $textTypeNull
      )
    ''');

    print('✅ Banco de dados criado com sucesso!');
    print('📋 Tabela "$tableTarefas" criada com 10 campos');
    print('📄 Nome do arquivo: $_databaseName');
  }

  // Método COMPLETO para testar o banco
  Future<void> testDatabase() async {
    final db = await database;
    print('✅ Banco de dados está funcionando!');
    print('📊 Verificando estrutura da tabela...\n');

    // Verificar estrutura da tabela
    final columns = await db.rawQuery('PRAGMA table_info($tableTarefas)');
    print('📋 Campos da tabela "$tableTarefas":');
    for (var column in columns) {
      final nome = column['name'];
      final tipo = column['type'];
      final notNull = column['notnull'] == 1 ? 'NOT NULL' : 'NULLABLE';
      final pk = column['pk'] == 1 ? '(PRIMARY KEY)' : '';
      print('   • $nome: $tipo $notNull $pk');
    }
    print('\n✨ Total de campos: ${columns.length}');
    print('✨ Caminho completo: ${db.path}');
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
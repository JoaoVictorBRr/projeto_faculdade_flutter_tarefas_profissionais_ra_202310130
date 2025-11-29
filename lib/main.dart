import 'package:flutter/material.dart';
import './database/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Testar criação do banco
  await DatabaseHelper.instance.testDatabase();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mini Cadastro de Tarefas',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: Scaffold(
        appBar: AppBar(title: const Text('Tarefas Profissionais')),
        body: const Center(
          child: Text(
            'Banco criado com sucesso!\nVerifique o console.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}

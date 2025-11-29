import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/tarefa.dart';
import 'tarefa_form_screen.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Tarefa> _tarefas = [];
  bool _isLoading = true;
  String _filtro = 'Todas'; // Todas, Pendentes, Finalizadas

  @override
  void initState() {
    super.initState();
    _carregarTarefas();
  }

  Future<void> _carregarTarefas() async {
    setState(() => _isLoading = true);

    try {
      List<Tarefa> tarefas;

      if (_filtro == 'Pendentes') {
        tarefas = await DatabaseHelper.instance.buscarPendentes();
      } else if (_filtro == 'Finalizadas') {
        tarefas = await DatabaseHelper.instance.buscarFinalizadas();
      } else {
        tarefas = await DatabaseHelper.instance.listarTarefas();
      }

      setState(() {
        _tarefas = tarefas;
        _isLoading = false;
      });
    } catch (e) {
      print('Erro ao carregar tarefas: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _excluirTarefa(int id, String titulo) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: Text('Deseja realmente excluir a tarefa "$titulo"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await DatabaseHelper.instance.excluirTarefa(id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tarefa excluída com sucesso!')),
      );
      _carregarTarefas();
    }
  }

  void _abrirFormulario([Tarefa? tarefa]) async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TarefaFormScreen(tarefa: tarefa),
      ),
    );

    if (resultado == true) {
      _carregarTarefas();
    }
  }

  Color _getCorPrioridade(String prioridade) {
    switch (prioridade.toLowerCase()) {
      case 'alta':
        return Colors.red;
      case 'média':
      case 'media':
        return Colors.orange;
      case 'baixa':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tarefas Profissionais'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (valor) {
              setState(() => _filtro = valor);
              _carregarTarefas();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'Todas', child: Text('Todas')),
              const PopupMenuItem(value: 'Pendentes', child: Text('Pendentes')),
              const PopupMenuItem(value: 'Finalizadas', child: Text('Finalizadas')),
            ],
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _tarefas.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 100, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'Nenhuma tarefa encontrada',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Toque no + para adicionar',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      )
          : Column(
        children: [
          // Resumo
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildContador('Total', _tarefas.length, Theme.of(context).primaryColor),
                _buildContador(
                  'Pendentes',
                  _tarefas.where((t) => !t.isFinalizada).length,
                  Colors.orange,
                ),
                _buildContador(
                  'Finalizadas',
                  _tarefas.where((t) => t.isFinalizada).length,
                  Colors.green,
                ),
              ],
            ),
          ),
          // Lista
          Expanded(
            child: ListView.builder(
              itemCount: _tarefas.length,
              padding: const EdgeInsets.all(8),
              itemBuilder: (context, index) {
                final tarefa = _tarefas[index];
                return _buildTarefaCard(tarefa);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirFormulario(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildContador(String label, int valor, Color cor) {
    return Column(
      children: [
        Text(
          valor.toString(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: cor,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[700]),
        ),
      ],
    );
  }

  Widget _buildTarefaCard(Tarefa tarefa) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getCorPrioridade(tarefa.prioridade),
          child: Text(
            tarefa.prioridade[0].toUpperCase(),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          tarefa.titulo,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            decoration: tarefa.isFinalizada ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Responsável: ${tarefa.responsavel}'),
            Text('Início: ${dateFormat.format(tarefa.dataInicio)}'),
            if (tarefa.isFinalizada)
              Text(
                'Finalizada: ${dateFormat.format(tarefa.dataFinalizacao!)}',
                style: const TextStyle(color: Colors.green),
              ),
            if (tarefa.tagidentificacao != null)
              Text('Tag: ${tarefa.tagidentificacao}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: Theme.of(context).primaryColor),
              onPressed: () => _abrirFormulario(tarefa),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _excluirTarefa(tarefa.id!, tarefa.titulo),
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }
}
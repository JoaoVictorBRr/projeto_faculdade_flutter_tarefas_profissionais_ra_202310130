import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/tarefa.dart';
import 'package:intl/intl.dart';

class TarefaFormScreen extends StatefulWidget {
  final Tarefa? tarefa;

  const TarefaFormScreen({super.key, this.tarefa});

  @override
  State<TarefaFormScreen> createState() => _TarefaFormScreenState();
}

class _TarefaFormScreenState extends State<TarefaFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _tituloController;
  late TextEditingController _descricaoController;
  late TextEditingController _responsavelController;
  late TextEditingController _tagController;

  String _prioridade = 'Média';
  DateTime _dataInicio = DateTime.now();
  DateTime? _dataFinalizacao;

  bool get _isEdicao => widget.tarefa != null;

  @override
  void initState() {
    super.initState();

    if (_isEdicao) {
      final t = widget.tarefa!;
      _tituloController = TextEditingController(text: t.titulo);
      _descricaoController = TextEditingController(text: t.descricao);
      _responsavelController = TextEditingController(text: t.responsavel);
      _tagController = TextEditingController(text: t.tagidentificacao ?? '');
      _prioridade = t.prioridade;
      _dataInicio = t.dataInicio;
      _dataFinalizacao = t.dataFinalizacao;
    } else {
      _tituloController = TextEditingController();
      _descricaoController = TextEditingController();
      _responsavelController = TextEditingController();
      _tagController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();
    _responsavelController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  Future<void> _selecionarData(BuildContext context, bool isInicio) async {
    final dataAtual = isInicio ? _dataInicio : _dataFinalizacao;

    final dataSelecionada = await showDatePicker(
      context: context,
      initialDate: dataAtual ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      locale: const Locale('pt', 'BR'),
    );

    if (dataSelecionada != null) {
      setState(() {
        if (isInicio) {
          _dataInicio = dataSelecionada;
        } else {
          _dataFinalizacao = dataSelecionada;
        }
      });
    }
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final tarefa = Tarefa(
        id: _isEdicao ? widget.tarefa!.id : null,
        titulo: _tituloController.text.trim(),
        descricao: _descricaoController.text.trim(),
        prioridade: _prioridade,
        dataInicio: _dataInicio,
        dataFinalizacao: _dataFinalizacao,
        responsavel: _responsavelController.text.trim(),
        tagidentificacao: _tagController.text.trim().isEmpty
            ? null
            : _tagController.text.trim(),
        criadoEm: _isEdicao ? widget.tarefa!.criadoEm : null,
      );

      if (_isEdicao) {
        await DatabaseHelper.instance.atualizarTarefa(tarefa);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tarefa atualizada com sucesso!')),
          );
        }
      } else {
        await DatabaseHelper.instance.inserirTarefa(tarefa);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tarefa criada com sucesso!')),
          );
        }
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdicao ? 'Editar Tarefa' : 'Nova Tarefa'),
        backgroundColor: Colors.blue,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Título
            TextFormField(
              controller: _tituloController,
              decoration: const InputDecoration(
                labelText: 'Título *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Campo obrigatório';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Descrição
            TextFormField(
              controller: _descricaoController,
              decoration: const InputDecoration(
                labelText: 'Descrição *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Campo obrigatório';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Responsável
            TextFormField(
              controller: _responsavelController,
              decoration: const InputDecoration(
                labelText: 'Responsável *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Campo obrigatório';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Prioridade
            DropdownButtonFormField<String>(
              value: _prioridade,
              decoration: const InputDecoration(
                labelText: 'Prioridade *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.priority_high),
              ),
              items: ['Baixa', 'Média', 'Alta']
                  .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                  .toList(),
              onChanged: (value) => setState(() => _prioridade = value!),
            ),
            const SizedBox(height: 16),

            // Data Início
            ListTile(
              title: const Text('Data de Início *'),
              subtitle: Text(dateFormat.format(_dataInicio)),
              leading: const Icon(Icons.calendar_today),
              trailing: const Icon(Icons.edit),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.grey.shade400),
              ),
              onTap: () => _selecionarData(context, true),
            ),
            const SizedBox(height: 16),

            // Data Finalização
            ListTile(
              title: const Text('Data de Finalização'),
              subtitle: Text(
                _dataFinalizacao != null
                    ? dateFormat.format(_dataFinalizacao!)
                    : 'Não finalizada',
              ),
              leading: const Icon(Icons.event_available),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_dataFinalizacao != null)
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() => _dataFinalizacao = null),
                    ),
                  const Icon(Icons.edit),
                ],
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.grey.shade400),
              ),
              onTap: () => _selecionarData(context, false),
            ),
            const SizedBox(height: 16),

            // Tag Identificação (campo personalizado)
            TextFormField(
              controller: _tagController,
              decoration: const InputDecoration(
                labelText: 'Tag de Identificação',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.label),
                helperText: 'Campo opcional',
              ),
            ),
            const SizedBox(height: 32),

            // Botão Salvar
            ElevatedButton.icon(
              onPressed: _salvar,
              icon: const Icon(Icons.save),
              label: Text(_isEdicao ? 'Atualizar' : 'Salvar'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
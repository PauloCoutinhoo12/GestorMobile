import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:appestacio/controllers/app_controller.dart';

class EstoqueScreen extends StatefulWidget {
  const EstoqueScreen({super.key});

  @override
  State<EstoqueScreen> createState() => _EstoqueScreenState();
}

class _EstoqueScreenState extends State<EstoqueScreen> {
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, TextEditingController> _addControllers = {};

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    final appController = Provider.of<AppController>(context, listen: false);
    appController.dadosEstoque.forEach((key, value) {
      _controllers[key] = TextEditingController(text: _formatarDecimal(value));
      _addControllers[key] = TextEditingController();
    });
  }

  @override
  void dispose() {
    _controllers.forEach((_, c) => c.dispose());
    _addControllers.forEach((_, c) => c.dispose());
    super.dispose();
  }

  String _formatarNomeMaterial(String nome) {
    final correcoes = {
      'Sai': 'Sal',
      'Óleo GorduRandeja&scoEfiquet&flagre': 'Óleo',
    };
    return correcoes[nome] ?? nome;
  }

  String _formatarDecimal(double valor) {
    return valor.toStringAsFixed(2).replaceAll(RegExp(r'\.?0*$'), '');
  }

  double _getDiasRestantes(String item, Map<String, double> estoque) {
    final consumoDiario = {
      'Trigo (kg)': 40.0,
      'Sal (kg)': 0.36,
      'Óleo (L)': 0.4,
      'Vinagre (L)': 0.28,
      'Gordura (kg)': 15.0,
      'Bandejas B2 (un)': 240.0,
      'Sacos (un)': 240.0,
      'Etiquetas (un)': 240.0,
    };

    final estoqueAtual = estoque[item] ?? 0;
    final consumo = consumoDiario[item] ?? 1.0;
    return (consumo > 0 && estoqueAtual > 0)
        ? (estoqueAtual / consumo).clamp(0, 365)
        : 0;
  }

  Color _getColorByDias(double dias) {
    if (dias <= 3) return const Color(0xFFFF5252);
    if (dias <= 7) return const Color(0xFFFFA726);
    return const Color(0xFF00E676);
  }

  Future<void> _adicionarEstoque(String key) async {
    final appController = Provider.of<AppController>(context, listen: false);
    final valorAtual = appController.dadosEstoque[key] ?? 0;
    final valorAdicionado = double.tryParse(
        _addControllers[key]!.text.replaceAll(',', '.')) ?? 0;

    if (valorAdicionado > 0) {
      final novoValor = valorAtual + valorAdicionado;
      await appController.atualizarEstoque({key: novoValor});

      setState(() {
        _controllers[key]!.text = _formatarDecimal(novoValor);
        _addControllers[key]!.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$key atualizado para ${_formatarDecimal(novoValor)}'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Widget _buildResumoDiasEstoque(Map<String, double> estoque) {
    return Card(
      color: const Color(0xFF1E1E1E),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dias Restantes de Estoque',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            ...estoque.entries.map((entry) {
              final key = entry.key;
              final dias = _getDiasRestantes(key, estoque);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        key.split(' ')[0],
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: LinearProgressIndicator(
                        value: dias / 30,
                        minHeight: 20,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getColorByDias(dias),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${dias.toStringAsFixed(1)} dias',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: _getColorByDias(dias),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            const SizedBox(height: 10),
            const Text(
              'Legenda:',
              style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
            ),
            Row(
              children: [
                _buildLegendaItem(Colors.red, 'Crítico (<3 dias)'),
                const SizedBox(width: 10),
                _buildLegendaItem(Colors.orange, 'Atenção (<7 dias)'),
                const SizedBox(width: 10),
                _buildLegendaItem(Colors.green, 'Normal'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendaItem(Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(fontSize: 10),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppController>(
      builder: (context, appController, child) {
        final estoque = appController.dadosEstoque;

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Gestão de Estoque',
              style: TextStyle(color: Color(0xFFE0E0E0)),
            ),
            backgroundColor: const Color(0xFF1E1E1E),
            actions: [
              IconButton(
                icon: const Icon(Icons.save, color: Color(0xFF00E676)),
                onPressed: () async {
                  final novosValores = <String, double>{};
                  estoque.forEach((key, _) {
                    novosValores[key] = double.tryParse(
                        _controllers[key]!.text.replaceAll(',', '.')) ?? 0;
                  });
                  await appController.atualizarEstoque(novosValores);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Estoque salvo com sucesso!'),
                      backgroundColor: Color(0xFF00E676),
                    ),
                  );
                },
              ),
            ],
          ),
          backgroundColor: const Color(0xFF121212),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Card(
                  color: const Color(0xFF1E1E1E),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Text(
                          'Visão Geral do Estoque',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFFFFFF)),
                        ),
                        const SizedBox(height: 10),
                        _buildResumoDiasEstoque(estoque),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Níveis de Estoque',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFFFFFF)),
                ),
                const SizedBox(height: 10),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: estoque.length,
                  separatorBuilder: (_, __) => Divider(
                    height: 1,
                    color: Colors.grey.shade800,
                  ),
                  itemBuilder: (context, index) {
                    final key = estoque.keys.elementAt(index);
                    final valor = estoque[key] ?? 0;
                    final dias = _getDiasRestantes(key, estoque);

                    return Card(
                      color: const Color(0xFF1E1E1E),
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  key,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFFFFFFFF),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Chip(
                                  label: Text(
                                    '${_formatarDecimal(dias)} dias',
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                  backgroundColor: _getColorByDias(dias),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: LinearProgressIndicator(
                                    value: dias / 30,
                                    backgroundColor: Colors.grey[800],
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        _getColorByDias(dias)),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Estoque: ${_formatarDecimal(valor)} ${key.split(' ').last}',
                              style: TextStyle(
                                  fontSize: 14,
                                  color: valor <= 0
                                      ? const Color(0xFFFF5252)
                                      : const Color(0xFFCFD8DC)),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _addControllers[key],
                                    style: const TextStyle(color: Color(0xFFFFFFFF)),
                                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                                    decoration: InputDecoration(
                                      labelText: 'Quantidade a adicionar',
                                      labelStyle: const TextStyle(color: Color(0xFF90CAF9)),
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.grey.shade700),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.grey.shade700),
                                      ),
                                      focusedBorder: const OutlineInputBorder(
                                        borderSide: BorderSide(color: Color(0xFF00E676)),
                                      ),
                                      suffixText: key.split(' ').last,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF00E676),
                                    foregroundColor: Colors.black,
                                  ),
                                  onPressed: () => _adicionarEstoque(key),
                                  child: const Text('Adicionar'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
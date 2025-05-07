import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:appestacio/controllers/app_controller.dart';
import 'package:appestacio/models/lancamento.dart';
import 'package:appestacio/models/producao_data.dart';

class RelatoriosScreen extends StatefulWidget {
  const RelatoriosScreen({super.key});

  @override
  State<RelatoriosScreen> createState() => _RelatoriosScreenState();
}

class _RelatoriosScreenState extends State<RelatoriosScreen> {
  final TextEditingController _descricaoController = TextEditingController();
  final TextEditingController _valorController = TextEditingController();
  final TextEditingController _dataController = TextEditingController();
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _dataController.text = DateTime.now().toString().substring(0, 10);
    _selectedDay = DateTime.now();
  }

  @override
  void dispose() {
    _descricaoController.dispose();
    _valorController.dispose();
    _dataController.dispose();
    super.dispose();
  }

  Widget _buildFaltasWidget(BuildContext context, AppController appController) {
    final now = DateTime.now();
    final faltas = appController.getFaltasPorFuncionario(now.month, now.year);
    final diasUteis = _calcularDiasUteisNoMes(now.month, now.year);

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Faltas do Mês (${DateFormat('MM/yyyy').format(now)})",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              "Dias úteis no mês: $diasUteis",
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 10),
            Table(
              border: TableBorder.all(color: Colors.grey.shade700),
              children: [
                const TableRow(
                  decoration: BoxDecoration(color: Color(0xFF1E1E1E)),
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Funcionário',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF90CAF9),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Faltas',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF90CAF9),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        '%',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF90CAF9),
                        ),
                      ),
                    ),
                  ],
                ),
                ...faltas.entries.map((entry) {
                  final porcentagem = (entry.value / diasUteis * 100).clamp(0, 100);
                  return TableRow(
                    decoration: const BoxDecoration(color: Color(0xFF121212)),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          entry.key,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Color(0xFFE0E0E0)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          entry.value.toString(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Color(0xFFE0E0E0)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          '${porcentagem.toStringAsFixed(1)}%',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: porcentagem > 20
                                ? const Color(0xFFFF5252)
                                : const Color(0xFF00E676),
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  int _calcularDiasUteisNoMes(int mes, int ano) {
    final primeiroDia = DateTime(ano, mes, 1);
    final ultimoDia = DateTime(ano, mes + 1, 0);
    int diasUteis = 0;

    for (var dia = primeiroDia;
    dia.isBefore(ultimoDia.add(const Duration(days: 1)));
    dia = dia.add(const Duration(days: 1))) {
      if (dia.weekday != DateTime.saturday && dia.weekday != DateTime.sunday) {
        diasUteis++;
      }
    }

    return diasUteis;
  }

  Map<String, double> _calcularUltimoMes(List<Lancamento> receitas, List<Lancamento> gastos) {
    final now = DateTime.now();
    final primeiroDiaMesAtual = DateTime(now.year, now.month, 1);
    final ultimoDiaMesPassado = primeiroDiaMesAtual.subtract(const Duration(days: 1));
    final primeiroDiaMesPassado = DateTime(ultimoDiaMesPassado.year, ultimoDiaMesPassado.month, 1);

    double receitasMesPassado = 0.0;
    double gastosMesPassado = 0.0;

    for (var receita in receitas) {
      final dataReceita = DateTime.parse(receita.data);
      if (dataReceita.isAfter(primeiroDiaMesPassado.subtract(const Duration(days: 1))) &&
          dataReceita.isBefore(primeiroDiaMesAtual)) {
        receitasMesPassado += receita.valor;
      }
    }

    for (var gasto in gastos) {
      final dataGasto = DateTime.parse(gasto.data);
      if (dataGasto.isAfter(primeiroDiaMesPassado.subtract(const Duration(days: 1))) &&
          dataGasto.isBefore(primeiroDiaMesAtual)) {
        gastosMesPassado += gasto.valor;
      }
    }

    final lucroMesPassado = receitasMesPassado - gastosMesPassado;
    final margemMesPassado = receitasMesPassado > 0 ? (lucroMesPassado / receitasMesPassado) * 100 : 0.0;

    return {
      'receitas': receitasMesPassado,
      'gastos': gastosMesPassado,
      'lucro': lucroMesPassado,
      'margem': margemMesPassado,
    };
  }

  void _adicionarLancamento(BuildContext context, bool isReceita) {
    _descricaoController.clear();
    _valorController.clear();
    _dataController.text = DateTime.now().toString().substring(0, 10);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isReceita ? "Adicionar Receita" : "Adicionar Gasto"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _descricaoController,
                decoration: const InputDecoration(labelText: "Descrição"),
              ),
              TextField(
                controller: _valorController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                    labelText: "Valor (R\$)",
                    prefixText: "R\$ "),
              ),
              TextField(
                controller: _dataController,
                decoration: const InputDecoration(
                    labelText: "Data",
                    suffixIcon: Icon(Icons.calendar_today)),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (date != null) {
                    _dataController.text = date.toString().substring(0, 10);
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () {
              final valor = double.tryParse(_valorController.text) ?? 0;
              if (valor > 0 && _descricaoController.text.isNotEmpty) {
                final lancamento = Lancamento(
                  descricao: _descricaoController.text,
                  valor: valor,
                  data: _dataController.text,
                );

                final appController = Provider.of<AppController>(context, listen: false);
                if (isReceita) {
                  appController.receitasBox.add(lancamento);
                } else {
                  appController.gastosBox.add(lancamento);
                }

                setState(() {});
                Navigator.pop(context);
              }
            },
            child: const Text("Adicionar"),
          ),
        ],
      ),
    );
  }

  void _mostrarDetalhes(BuildContext context, List<Lancamento> lancamentos, String titulo) {
    final appController = Provider.of<AppController>(context, listen: false);
    final bool isReceitaList = titulo.toLowerCase().contains('receita');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(titulo),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: lancamentos.length,
            itemBuilder: (context, index) {
              final item = lancamentos[index];
              return ListTile(
                title: Text(item.descricao),
                subtitle: Text("${item.data} - R\$ ${item.valor.toStringAsFixed(2)}"),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    final box = isReceitaList ? appController.receitasBox : appController.gastosBox;
                    final key = isReceitaList
                        ? appController.receitasBox.keyAt(index)
                        : appController.gastosBox.keyAt(index);
                    await box.delete(key);

                    setState(() {
                      lancamentos.removeAt(index);
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Lançamento removido com sucesso!"),
                        duration: Duration(seconds: 2),
                      ),
                    );

                    Navigator.pop(context);
                  },
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Fechar"),
          ),
        ],
      ),
    );
  }

  Widget _buildDetalhesDia(DateTime dia, AppController appController) {
    final dateStr = DateFormat('yyyy-MM-dd').format(dia);
    final producao = appController.getProducaoPorData(dateStr);

    if (producao == null || producao.manha == 0 && producao.tarde == 0) {
      return const Text(
        "Nenhum dado de produção para este dia",
        style: TextStyle(color: Color(0xFFE0E0E0)),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Detalhes da Produção - ${DateFormat('dd/MM/yyyy').format(dia)}",
          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFE0E0E0)),
        ),
        const SizedBox(height: 10),
        Table(
          border: TableBorder.all(color: Colors.grey.shade700),
          children: [
            TableRow(
              decoration: const BoxDecoration(color: Color(0xFF1E1E1E)),
              children: [
                _buildTableCell('Turno', isHeader: true),
                _buildTableCell('Bandejas', isHeader: true),
              ],
            ),
            TableRow(
              decoration: const BoxDecoration(color: Color(0xFF121212)),
              children: [
                _buildTableCell('Manhã'),
                _buildTableCell(producao.manha.toString()),
              ],
            ),
            TableRow(
              decoration: const BoxDecoration(color: Color(0xFF121212)),
              children: [
                _buildTableCell('Tarde'),
                _buildTableCell(producao.tarde.toString()),
              ],
            ),
            TableRow(
              decoration: const BoxDecoration(color: Color(0xFF1E1E1E)),
              children: [
                _buildTableCell('Total', isTotal: true),
                _buildTableCell('${producao.manha + producao.tarde}', isTotal: true),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
        const Text(
          "Equipe Presente:",
          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFE0E0E0)),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: producao.equipePresente.map((membro) => Chip(
            label: Text(
              membro,
              style: const TextStyle(color: Colors.black),
            ),
            backgroundColor: const Color(0xFF00E676).withOpacity(0.7),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildTableCell(String text, {bool isHeader = false, bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: isHeader || isTotal ? FontWeight.bold : FontWeight.normal,
          color: isTotal
              ? const Color(0xFF00E676)
              : (isHeader
              ? const Color(0xFF90CAF9)
              : const Color(0xFFE0E0E0)),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, double value, Color color, IconData icon, {required VoidCallback onAdd, required VoidCallback onView}) {
    return Card(
      color: const Color(0xFF1E1E1E),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE0E0E0)),
            ),
            const SizedBox(height: 8),
            Text(
              "R\$ ${value.toStringAsFixed(2)}",
              style: TextStyle(fontSize: 18, color: color),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: Icon(Icons.add, color: color),
                  onPressed: onAdd,
                  tooltip: "Adicionar $title",
                ),
                IconButton(
                  icon: Icon(Icons.list, color: color),
                  onPressed: onView,
                  tooltip: "Ver Detalhes",
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, double value, Color color, IconData icon, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                  color: const Color(0xFFE0E0E0),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                "R\$ ${value.toStringAsFixed(2)}",
                style: TextStyle(
                  fontSize: 16,
                  color: color,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPercentageInfo(String label, double percentage) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
                fontSize: 16,
                color: Color(0xFFE0E0E0)),
          ),
          Text(
            "${percentage.toStringAsFixed(2)}%",
            style: TextStyle(
              fontSize: 16,
              color: percentage >= 0 ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppController>(
      builder: (context, appController, child) {
        final receitas = appController.receitasBox.values.toList();
        final gastos = appController.gastosBox.values.toList();
        final resumo = appController.resumoFinanceiro;
        final producoes = appController.todasProducoes;
        final ultimoMes = _calcularUltimoMes(receitas, gastos);

        return Scaffold(
          appBar: AppBar(
            title: const Text("Dashboard Financeiro"),
            backgroundColor: const Color(0xFF1E1E1E),
          ),
          backgroundColor: const Color(0xFF121212),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  color: const Color(0xFF1E1E1E),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      const Text(
                      "Resumo Financeiro",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE0E0E0)),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoCard(
                            "Receitas",
                            resumo['receitas'] ?? 0.0,
                            Colors.green,
                            Icons.arrow_upward,
                            onAdd: () => _adicionarLancamento(context, true),
                            onView: () => _mostrarDetalhes(context, receitas, "Receitas"),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildInfoCard(
                            "Gastos",
                            resumo['gastos'] ?? 0.0,
                            Colors.red,
                            Icons.arrow_downward,
                            onAdd: () => _adicionarLancamento(context, false),
                            onView: () => _mostrarDetalhes(context, gastos, "Gastos"),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24, color: Colors.grey),
                    _buildInfoRow(
                      "Lucro:",
                      resumo['lucro'] ?? 0.0,
                      (resumo['lucro'] ?? 0) >= 0 ? Colors.blue : Colors.orange,
                      Icons.attach_money,
                      isBold: true,
                    ),
                    const SizedBox(height: 8),
                    _buildPercentageInfo(
                      "Margem de Lucro:",
                      resumo['margem'] ?? 0.0,
                    ),
                    const Divider(height: 24, color: Colors.grey),
                    Text(
                      "Último Mês (${DateFormat('MM/yyyy').format(DateTime.now().subtract(const Duration(days: 30)))})",
                      style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFE0E0E0)),
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        "Receitas:",
                        ultimoMes['receitas'] ?? 0.0,
                        Colors.green,
                        Icons.arrow_upward,
                      ),
                      _buildInfoRow(
                        "Gastos:",
                        ultimoMes['gastos'] ?? 0.0,
                        Colors.red,
                        Icons.arrow_downward,
                      ),
                      _buildInfoRow(
                        "Lucro:",
                        ultimoMes['lucro'] ?? 0.0,
                        (ultimoMes['lucro'] ?? 0) >= 0 ? Colors.blue : Colors.orange,
                        Icons.attach_money,
                        isBold: true,
                      ),
                      _buildPercentageInfo(
                        "Margem:",
                        ultimoMes['margem'] ?? 0.0,
                      ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildFaltasWidget(context, appController),
                const SizedBox(height: 20),
                Card(
                  color: const Color(0xFF1E1E1E),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Produção Diária",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFE0E0E0)),
                        ),
                        const SizedBox(height: 16),
                        TableCalendar(
                          locale: 'pt_BR',
                          firstDay: DateTime.now().subtract(const Duration(days: 365)),
                          lastDay: DateTime.now().add(const Duration(days: 365)),
                          focusedDay: _focusedDay,
                          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                          onDaySelected: (selectedDay, focusedDay) {
                            setState(() {
                              _selectedDay = selectedDay;
                              _focusedDay = focusedDay;
                            });
                          },
                          calendarFormat: CalendarFormat.month,
                          headerStyle: const HeaderStyle(
                            formatButtonVisible: false,
                            titleCentered: true,
                            titleTextStyle: TextStyle(color: Color(0xFFE0E0E0)),
                            leftChevronIcon: Icon(Icons.chevron_left, color: Color(0xFF90CAF9)),
                            rightChevronIcon: Icon(Icons.chevron_right, color: Color(0xFF90CAF9)),
                          ),
                          calendarStyle: const CalendarStyle(
                            defaultTextStyle: TextStyle(color: Color(0xFFE0E0E0)),
                            weekendTextStyle: TextStyle(color: Color(0xFFE0E0E0)),
                            outsideTextStyle: TextStyle(color: Colors.grey),
                          ),
                          daysOfWeekStyle: const DaysOfWeekStyle(
                            weekdayStyle: TextStyle(color: Color(0xFF90CAF9)),
                            weekendStyle: TextStyle(color: Color(0xFF90CAF9)),
                          ),
                          calendarBuilders: CalendarBuilders(
                            markerBuilder: (context, day, events) {
                              final dateStr = DateFormat('yyyy-MM-dd').format(day);
                              final producao = producoes.firstWhere(
                                    (p) => p.dia == dateStr,
                                orElse: () => ProducaoData('', 0, 0),
                              );

                              if (producao.manha > 0 || producao.tarde > 0) {
                                return Positioned(
                                  right: 1,
                                  bottom: 1,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF00E676),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      '${producao.manha + producao.tarde}',
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                );
                              }
                              return const SizedBox();
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (_selectedDay != null) _buildDetalhesDia(_selectedDay!, appController),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
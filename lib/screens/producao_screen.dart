import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../widgets/info_dia_equipe.dart';
import '../widgets/turno_card.dart';
import '../widgets/totais_section.dart';
import '../widgets/materiais_section.dart';
import 'package:appestacio/controllers/app_controller.dart';

class ProducaoScreen extends StatefulWidget {
  const ProducaoScreen({super.key});

  @override
  State<ProducaoScreen> createState() => _ProducaoScreenState();
}

class _ProducaoScreenState extends State<ProducaoScreen> {
  late TextEditingController _manhaBandejasController;
  late TextEditingController _tardeBandejasController;
  late TextEditingController _gorduraManhaController;
  late TextEditingController _gorduraTardeController;

  int _bandejasManha = 120;
  int _bandejasTarde = 120;
  double _gorduraManha = 7.5;
  double _gorduraTarde = 7.5;
  bool _frituraManha = true;
  bool _frituraTarde = true;

  final List<String> _equipe = [
    'Rayssa', 'Fábio', 'Francisca', 'Leide',
    'Danielma', 'João', 'Julha', 'Raimundo'
  ];

  List<bool> _equipePresente = List.filled(8, true);

  @override
  void initState() {
    super.initState();
    _manhaBandejasController = TextEditingController();
    _tardeBandejasController = TextEditingController();
    _gorduraManhaController = TextEditingController();
    _gorduraTardeController = TextEditingController();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    final appController = Provider.of<AppController>(context, listen: false);
    final dados = appController.dadosProducao;

    setState(() {
      _bandejasManha = dados['bandejasManha'] ?? 120;
      _bandejasTarde = dados['bandejasTarde'] ?? 120;
      _gorduraManha = dados['gorduraManha'] ?? 7.5;
      _gorduraTarde = dados['gorduraTarde'] ?? 7.5;
      _frituraManha = dados['frituraManha'] ?? true;
      _frituraTarde = dados['frituraTarde'] ?? true;

      _manhaBandejasController.text = _bandejasManha.toString();
      _tardeBandejasController.text = _bandejasTarde.toString();
      _gorduraManhaController.text = _gorduraManha.toStringAsFixed(1);
      _gorduraTardeController.text = _gorduraTarde.toStringAsFixed(1);
    });
  }

  Future<void> _salvarDados() async {
    final appController = Provider.of<AppController>(context, listen: false);

    await appController.atualizarProducao(
      _bandejasManha,
      _bandejasTarde,
      _gorduraManha,
      _gorduraTarde,
    );

    final List<String> equipePresente = [];
    for (int i = 0; i < _equipe.length; i++) {
      if (_equipePresente[i]) {
        equipePresente.add(_equipe[i]);
      }
    }

    await appController.salvarProducaoDiaria(
      _bandejasManha,
      _bandejasTarde,
      equipePresente,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Produção salva com sucesso!"),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _manhaBandejasController.dispose();
    _tardeBandejasController.dispose();
    _gorduraManhaController.dispose();
    _gorduraTardeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalBandejas = _bandejasManha + _bandejasTarde;
    final totalGordura = _gorduraManha + _gorduraTarde;

    final trigoKg = (totalBandejas / 60) * 10;
    final salKg = (totalBandejas / 60) * 0.09;
    final oleoL = (totalBandejas / 60) * 0.1;
    final vinagreL = (totalBandejas / 60) * 0.07;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Controle de Produção"),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _salvarDados,
            tooltip: "Salvar produção",
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            InfoDiaEquipe(
              equipe: _equipe,
              equipePresente: _equipePresente,
              onChanged: (index, value) {
                setState(() => _equipePresente[index] = value);
              },
            ),
            const SizedBox(height: 20),
            TurnoCard(
              turno: "Manhã",
              bandejasController: _manhaBandejasController,
              gorduraController: _gorduraManhaController,
              frituraRealizada: _frituraManha,
              onBandejasChanged: (value) {
                setState(() => _bandejasManha = int.tryParse(value) ?? 0);
              },
              onGorduraChanged: (value) {
                setState(() => _gorduraManha = double.tryParse(value) ?? 0);
              },
              onFrituraChanged: (value) {
                setState(() => _frituraManha = value ?? false);
              },
            ),
            const SizedBox(height: 16),
            TurnoCard(
              turno: "Tarde",
              bandejasController: _tardeBandejasController,
              gorduraController: _gorduraTardeController,
              frituraRealizada: _frituraTarde,
              onBandejasChanged: (value) {
                setState(() => _bandejasTarde = int.tryParse(value) ?? 0);
              },
              onGorduraChanged: (value) {
                setState(() => _gorduraTarde = double.tryParse(value) ?? 0);
              },
              onFrituraChanged: (value) {
                setState(() => _frituraTarde = value ?? false);
              },
            ),
            TotaisSection(
              totalBandejas: totalBandejas,
              totalGordura: totalGordura,
            ),
            MateriaisSection(
              trigoKg: trigoKg,
              salKg: salKg,
              oleoL: oleoL,
              vinagreL: vinagreL,
              gorduraKg: totalGordura,
              bandejasB2: totalBandejas,
              sacos: totalBandejas,
              etiquetas: totalBandejas,
            ),
          ],
        ),
      ),
    );
  }
}
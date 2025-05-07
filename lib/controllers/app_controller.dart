import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/producao_data.dart';
import '../models/lancamento.dart';
import 'package:intl/intl.dart';

class AppController extends ChangeNotifier {
  final Box<dynamic> producaoBox;
  final Box<dynamic> estoqueBox;
  final Box<Lancamento> receitasBox;
  final Box<Lancamento> gastosBox;
  final Box<ProducaoData> producaoDiariaBox;

  AppController({
    required this.producaoBox,
    required this.estoqueBox,
    required this.receitasBox,
    required this.gastosBox,
    required this.producaoDiariaBox,
  });

  Map<String, int> getFaltasPorFuncionario(int mes, int ano) {
    final faltas = <String, int>{};
    final equipeCompleta = [
      'Rayssa', 'Fábio', 'Francisca', 'Leide',
      'Danielma', 'João', 'Julha', 'Raimundo'
    ];

    for (var funcionario in equipeCompleta) {
      faltas[funcionario] = 0;
    }

    for (var producao in producaoDiariaBox.values) {
      final dataProducao = DateTime.parse(producao.dia);
      if (dataProducao.month == mes && dataProducao.year == ano) {
        for (var funcionario in equipeCompleta) {
          if (!producao.equipePresente.contains(funcionario)) {
            faltas[funcionario] = faltas[funcionario]! + 1;
          }
        }
      }
    }

    return faltas;
  }
Future<void> atualizarProducao(int bandejasManha, int bandejasTarde, double gorduraManha, double gorduraTarde) async {
  if (bandejasManha <= 0 || bandejasTarde <= 0) {
    throw Exception("Produção deve ser maior que zero");
  }

  final totalBandejas = bandejasManha + bandejasTarde;
  final totalGordura = gorduraManha + gorduraTarde;
  final estoqueAtual = estoqueBox.toMap();

  final novosValores = {
    'Trigo (kg)': _calcularNovoEstoque(estoqueAtual['Trigo (kg)'], totalBandejas, 10, isPer60: true),
    'Sal (kg)': _calcularNovoEstoque(estoqueAtual['Sal (kg)'], totalBandejas, 0.09, isPer60: true),
    'Óleo (L)': _calcularNovoEstoque(estoqueAtual['Óleo (L)'], totalBandejas, 0.1, isPer60: true),
    'Vinagre (L)': _calcularNovoEstoque(estoqueAtual['Vinagre (L)'], totalBandejas, 0.07, isPer60: true),
    'Gordura (kg)': (estoqueAtual['Gordura (kg)'] ?? 0).toDouble() - totalGordura,
    'Bandejas B2 (un)': _calcularNovoEstoque(estoqueAtual['Bandejas B2 (un)'], totalBandejas, 1, isPer60: false),
    'Sacos (un)': _calcularNovoEstoque(estoqueAtual['Sacos (un)'], totalBandejas, 1, isPer60: false),
    'Etiquetas (un)': _calcularNovoEstoque(estoqueAtual['Etiquetas (un)'], totalBandejas, 1, isPer60: false),
  };

  novosValores.forEach((key, value) {
    if (value < 0) novosValores[key] = 0.0;
  });

  await estoqueBox.putAll(novosValores);
  notifyListeners();
}

double _calcularNovoEstoque(dynamic estoqueAtual, int totalBandejas, double consumoPorUnidade, {required bool isPer60}) {
  final valorAtual = (estoqueAtual ?? 0).toDouble();
  final consumo = isPer60
      ? (totalBandejas * consumoPorUnidade / 60)
      : (totalBandejas * consumoPorUnidade);

  return (valorAtual - consumo) >= 0 ? (valorAtual - consumo) : 0;
}

Future<void> salvarProducaoDiaria(int bandejasManha, int bandejasTarde, List<String> equipePresente) async {
  final hoje = DateFormat('yyyy-MM-dd').format(DateTime.now());
  final producao = ProducaoData(hoje, bandejasManha, bandejasTarde, equipePresente);
  await producaoDiariaBox.put(hoje, producao);
  notifyListeners();
}

ProducaoData? getProducaoPorData(String data) {
  return producaoDiariaBox.get(data);
}

List<ProducaoData> get todasProducoes {
  return producaoDiariaBox.values.toList();
}

Map<String, dynamic> get dadosProducao {
  return {
    'bandejasManha': producaoBox.get('bandejasManha', defaultValue: 120),
    'bandejasTarde': producaoBox.get('bandejasTarde', defaultValue: 120),
    'gorduraManha': producaoBox.get('gorduraManha', defaultValue: 7.5),
    'gorduraTarde': producaoBox.get('gorduraTarde', defaultValue: 7.5),
    'frituraManha': producaoBox.get('frituraManha', defaultValue: true),
    'frituraTarde': producaoBox.get('frituraTarde', defaultValue: true),
  };
}

Map<String, double> get dadosEstoque {
  return {
    'Trigo (kg)': (estoqueBox.get('Trigo (kg)', defaultValue: 100.0) as num).toDouble(),
    'Sal (kg)': (estoqueBox.get('Sal (kg)', defaultValue: 5.0) as num).toDouble(),
    'Óleo (L)': (estoqueBox.get('Óleo (L)', defaultValue: 10.0) as num).toDouble(),
    'Gordura (kg)': (estoqueBox.get('Gordura (kg)', defaultValue: 30.0) as num).toDouble(),
    'Bandejas B2 (un)': (estoqueBox.get('Bandejas B2 (un)', defaultValue: 500.0) as num).toDouble(),
    'Sacos (un)': (estoqueBox.get('Sacos (un)', defaultValue: 500.0) as num).toDouble(),
    'Etiquetas (un)': (estoqueBox.get('Etiquetas (un)', defaultValue: 500.0) as num).toDouble(),
    'Vinagre (L)': (estoqueBox.get('Vinagre (L)', defaultValue: 5.0) as num).toDouble(),
  };
}

Map<String, double> get resumoFinanceiro {
  try {
    final receitas = receitasBox.values.fold<double>(0.0, (sum, item) => sum + item.valor);
    final gastos = gastosBox.values.fold<double>(0.0, (sum, item) => sum + item.valor);
    final lucro = receitas - gastos;
    final margem = receitas > 0 ? (lucro / receitas) * 100 : 0.0;

    return {
      'receitas': receitas,
      'gastos': gastos,
      'lucro': lucro,
      'margem': margem,
    };
  } catch (e) {
    print('Erro ao calcular resumo financeiro: $e');
    return {
      'receitas': 0.0,
      'gastos': 0.0,
      'lucro': 0.0,
      'margem': 0.0,
    };
  }
}

Future<void> atualizarEstoque(Map<String, dynamic> novosValores) async {
  final valoresConvertidos = <String, double>{};

  novosValores.forEach((key, value) {
    if (value is int) {
      valoresConvertidos[key] = value.toDouble();
    } else if (value is double) {
      valoresConvertidos[key] = value;
    } else if (value is String) {
      valoresConvertidos[key] = double.tryParse(value) ?? estoqueBox.get(key, defaultValue: 0.0) as double;
    } else if (value is num) {
      valoresConvertidos[key] = value.toDouble();
    }
  });

  await estoqueBox.putAll(valoresConvertidos);
  notifyListeners();
}
}
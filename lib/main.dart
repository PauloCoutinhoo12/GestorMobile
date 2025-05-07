import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'controllers/app_controller.dart';
import 'models/producao_data.dart';
import 'models/lancamento.dart';
import 'adapters/producao_adapter.dart';
import 'adapters/lancamento_adapter.dart';
import 'screens/home_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Hive.initFlutter();
    Hive.registerAdapter(ProducaoDataAdapter());
    Hive.registerAdapter(LancamentoAdapter());

    final producaoBox = await Hive.openBox<dynamic>('producao_box');
    await Hive.openBox<Lancamento>('financeiro_box');
    final estoqueBox = await Hive.openBox<dynamic>('estoque_box');
    final receitasBox = await Hive.openBox<Lancamento>('receitas_box');
    final gastosBox = await Hive.openBox<Lancamento>('gastos_box');
    final producaoDiariaBox = await Hive.openBox<ProducaoData>('producao_diaria_box');

    final appController = AppController(
      producaoBox: producaoBox,
      estoqueBox: estoqueBox,
      receitasBox: receitasBox,
      gastosBox: gastosBox,
      producaoDiariaBox: producaoDiariaBox,
    );

    runApp(
      ChangeNotifierProvider(
        create: (context) => appController,
        child: const CanudoControlApp(),
      ),
    );
  } catch (e) {
    print('Erro ao inicializar Hive: $e');
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(child: Text('Erro ao carregar o aplicativo. Reinicie o app.')),
        ),
      ),
    );
  }
}

class CanudoControlApp extends StatelessWidget {
  const CanudoControlApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CanudoControl',
      theme: ThemeData.dark().copyWith(
        primaryColor: const Color(0xFF90CAF9),
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF90CAF9),
          secondary: const Color(0xFF00E676),
          surface: const Color(0xFF1E1E1E),
        ),
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardColor: const Color(0xFF1E1E1E),
        textTheme: ThemeData.dark().textTheme.copyWith(
          bodyLarge: const TextStyle(color: Color(0xFFE0E0E0)),
          bodyMedium: const TextStyle(color: Color(0xFFE0E0E0)),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pt', 'BR'),
      ],
      locale: const Locale('pt', 'BR'),
    );
  }
}
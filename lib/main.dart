import 'package:flutter/material.dart';

import 'screens/equipo_screen.dart';
import 'screens/pokedex_screen.dart';
import 'screens/quiz_screen.dart';
import 'screens/tu_pokemon_screen.dart';
import 'services/equipo_storage.dart';
import 'theme/pixel.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Equipo.cargar(); // carga el equipo guardado en el celular
  runApp(const PokeRegionApp());
}

class PokeRegionApp extends StatelessWidget {
  const PokeRegionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PokéRegión',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: PixelColors.rojo,
        colorScheme: ColorScheme.fromSeed(seedColor: PixelColors.rojo),
      ),
      home: const Inicio(),
    );
  }
}

/// Pantalla principal: AppBar + 4 pestañas en la barra inferior.
class Inicio extends StatefulWidget {
  const Inicio({super.key});

  @override
  State<Inicio> createState() => _InicioState();
}

class _InicioState extends State<Inicio> {
  int _pestana = 0;

  static const _titulos = ['POKÉDEX', '¿QUÉ POKÉMON ERES?', 'QUIZ', 'MI EQUIPO'];

  @override
  Widget build(BuildContext context) {
    final paginas = [
      const PokedexScreen(),
      const TuPokemonScreen(),
      const QuizScreen(),
      EquipoScreen(onIrADex: () => setState(() => _pestana = 0)),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: PixelColors.carbon,
        toolbarHeight: 60,
        // Imagen desde Assets (requisito): pon tu logo en assets/images/logo.png
        leading: Padding(
          padding: const EdgeInsets.all(12),
          child: Image.asset('assets/images/logo.png', filterQuality: FilterQuality.none),
        ),
        title: Text(_titulos[_pestana], style: pixelTitle(12, color: PixelColors.neon)),
        shape: const Border(bottom: BorderSide(color: PixelColors.carbonBorde, width: 4)),
      ),
      body: FondoPuntos(
        child: IndexedStack(index: _pestana, children: paginas),
      ),
      bottomNavigationBar: PixelNavBar(
        actual: _pestana,
        onTap: (i) => setState(() => _pestana = i),
      ),
    );
  }
}

/// Barra inferior pixel con 4 botones.
class PixelNavBar extends StatelessWidget {
  final int actual;
  final ValueChanged<int> onTap;
  const PixelNavBar({super.key, required this.actual, required this.onTap});

  static const _items = [
    (Icons.grid_view_sharp, 'DEX'),
    (Icons.person_pin_circle_sharp, 'TÚ'),
    (Icons.quiz_sharp, 'QUIZ'),
    (Icons.star_sharp, 'EQUIPO'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: PixelColors.carbon,
        border: Border(top: BorderSide(color: PixelColors.carbonBorde, width: 4)),
      ),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            for (var i = 0; i < _items.length; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () => onTap(i),
                  child: Container(
                    height: 58,
                    decoration: BoxDecoration(
                      color: i == actual ? PixelColors.neon : PixelColors.lcdBorde,
                      border: Border.all(color: PixelColors.carbonBorde, width: 3),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(_items[i].$1,
                            size: 20,
                            color: i == actual ? PixelColors.carbon : const Color(0xFFD6DAE1)),
                        Text(_items[i].$2,
                            style: pixelBody(19,
                                color: i == actual ? PixelColors.carbon : const Color(0xFFD6DAE1))),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Pestaña 4 — Mi Equipo: hasta 6 Pokémon guardados en el celular.
import 'package:flutter/material.dart';

import '../services/equipo_storage.dart';
import '../services/poke_api.dart';
import '../theme/pixel.dart';
import '../widgets/pokemon_card.dart';
import 'detalle_screen.dart';

class EquipoScreen extends StatelessWidget {
  final VoidCallback onIrADex;
  const EquipoScreen({super.key, required this.onIrADex});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<int>>(
      valueListenable: Equipo.ids,
      builder: (context, ids, _) {
        return FutureBuilder<List<Pokemon>>(
          future: Future.wait(ids.map(PokeApi.pokemon)),
          builder: (context, snap) {
            final equipo = snap.data ?? const <Pokemon>[];
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 20, 32),
              children: [
                Text('${ids.length}/${Equipo.maximo} POKÉMON', style: pixelTitle(10, color: Colors.white)),
                const SizedBox(height: 10),
                // Barra de 6 segmentos
                Row(
                  children: [
                    for (var i = 0; i < Equipo.maximo; i++) ...[
                      if (i > 0) const SizedBox(width: 6),
                      Expanded(
                        child: Container(
                          height: 14,
                          decoration: BoxDecoration(
                            color: i < ids.length ? PixelColors.neon : Colors.white,
                            border: Border.all(color: PixelColors.carbon, width: 3),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 16),
                if (ids.isEmpty) ...[
                  // Imagen desde Assets (requisito): assets/images/equipo_vacio.png
                  Center(
                    child: Image.asset('assets/images/equipo_vacio.png',
                        width: 120, filterQuality: FilterQuality.none),
                  ),
                  const SizedBox(height: 16),
                ],
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 220,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 0.72,
                  ),
                  itemCount: Equipo.maximo,
                  itemBuilder: (_, i) {
                    if (i < equipo.length) {
                      final p = equipo[i];
                      return PokemonCard(
                        pokemon: p,
                        heroTag: 'equipo-${p.id}',
                        onQuitar: () => Equipo.quitar(p.id),
                        onTap: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => DetalleScreen(pokemon: p, heroTag: 'equipo-${p.id}'),
                        )),
                      );
                    }
                    return GestureDetector(
                      onTap: onIrADex,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0x1FFFFFFF),
                          border: Border.all(color: Colors.white, width: 4),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('+', style: pixelTitle(24, color: Colors.white)),
                            const SizedBox(height: 8),
                            Text('AGREGAR', style: pixelTitle(10, color: Colors.white)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                const DialogBox('Agrega Pokémon desde la DEX o desde TÚ. Tu equipo se guarda en el celular.'),
              ],
            );
          },
        );
      },
    );
  }
}

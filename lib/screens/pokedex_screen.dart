// Pestaña 1 — Pokédex: lista de los 151, buscador, filtros y dado al azar.
import 'package:flutter/material.dart';

import '../services/poke_api.dart';
import '../theme/pixel.dart';
import '../widgets/pokemon_card.dart';
import 'detalle_screen.dart';

class PokedexScreen extends StatefulWidget {
  const PokedexScreen({super.key});

  @override
  State<PokedexScreen> createState() => _PokedexScreenState();
}

class _PokedexScreenState extends State<PokedexScreen> {
  late Future<List<Pokemon>> _futuro = PokeApi.kanto();
  String _filtro = 'todos';
  String _busqueda = '';

  static const _filtros = ['todos', 'fire', 'water', 'grass', 'electric', 'poison', 'flying'];

  void _abrir(Pokemon p) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => DetalleScreen(pokemon: p, heroTag: 'dex-${p.id}'),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Pokemon>>(
      future: _futuro,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const CargandoPixel(texto: 'CARGANDO POKÉDEX');
        }
        if (snap.hasError) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const DialogBox('No pude conectar con PokéAPI. Revisa tu internet.'),
                const SizedBox(height: 16),
                PixelButton(
                  label: '↺ REINTENTAR',
                  onTap: () => setState(() => _futuro = PokeApi.kanto()),
                ),
              ],
            ),
          );
        }

        final todos = snap.data!;
        final lista = todos.where((p) {
          final pasaFiltro = _filtro == 'todos' || p.tipos.contains(_filtro);
          final q = _busqueda.trim().toUpperCase();
          final pasaBusqueda = q.isEmpty || p.nombre.contains(q) || p.numero.contains(q);
          return pasaFiltro && pasaBusqueda;
        }).toList();

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  Expanded(
                    child: PixelBox(
                      sombra: 4,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        children: [
                          Text('>', style: pixelTitle(12)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              onChanged: (v) => setState(() => _busqueda = v),
                              style: pixelBody(22),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'BUSCAR NOMBRE O N.º',
                                hintStyle: pixelBody(22, color: PixelColors.texto2),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Dado: abre un Pokémon al azar
                  SizedBox(
                    width: 56,
                    child: PixelButton(
                      label: '',
                      icon: Icons.casino_sharp,
                      onTap: () => _abrir(todos[PokeApi.idAleatorio() - 1]),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 56,
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                scrollDirection: Axis.horizontal,
                itemCount: _filtros.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final f = _filtros[i];
                  final activo = f == _filtro;
                  return GestureDetector(
                    onTap: () => setState(() => _filtro = f),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: activo ? PixelColors.neon : Colors.white,
                        border: Border.all(color: PixelColors.carbon, width: 3),
                      ),
                      child: Text(f == 'todos' ? 'TODOS' : tipoNombres[f]!, style: pixelBody(20)),
                    ),
                  );
                },
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 20, 24),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 220,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.72,
                ),
                itemCount: lista.length,
                itemBuilder: (_, i) => PokemonCard(
                  pokemon: lista[i],
                  heroTag: 'dex-${lista[i].id}',
                  onTap: () => _abrir(lista[i]),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

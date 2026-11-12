// Detalle de un Pokémon: grito, shiny, pestañas INFO / STATS / EVO y agregar al equipo.
import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/equipo_storage.dart';
import '../services/poke_api.dart';
import '../theme/pixel.dart';

class DetalleScreen extends StatefulWidget {
  final Pokemon pokemon;
  final String heroTag;
  const DetalleScreen({super.key, required this.pokemon, required this.heroTag});

  @override
  State<DetalleScreen> createState() => _DetalleScreenState();
}

class _DetalleScreenState extends State<DetalleScreen> with SingleTickerProviderStateMixin {
  final _player = AudioPlayer();
  late final AnimationController _salto =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 700));

  bool _shiny = false;
  bool _sonando = false;
  int _tab = 1; // 0 INFO, 1 STATS, 2 EVO

  late final Future<String> _descripcion = PokeApi.descripcion(widget.pokemon.id);
  late final Future<List<String>> _evos = PokeApi.evoluciones(widget.pokemon.id);

  Pokemon get p => widget.pokemon;

  @override
  void dispose() {
    _player.dispose();
    _salto.dispose();
    super.dispose();
  }

  void _saltar() {
    HapticFeedback.mediumImpact();
    _salto.forward(from: 0);
  }

  Future<void> _gritar() async {
    _saltar();
    final url = p.grito;
    if (url == null) return;
    setState(() => _sonando = true);
    try {
      await _player.play(UrlSource(url));
    } catch (_) {
      // Algunos teléfonos (iOS) no reproducen .ogg; no rompemos la app por eso.
    }
    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) setState(() => _sonando = false);
  }

  Future<void> _agregar() async {
    final ok = await Equipo.agregar(p.id);
    if (!mounted) return;
    final msg = ok
        ? '¡${p.nombre} se unió a tu equipo!'
        : Equipo.lleno
            ? 'Tu equipo ya tiene 6 Pokémon.'
            : '${p.nombre} ya está en tu equipo.';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: PixelColors.carbon,
      content: Text(msg, style: pixelBody(22, color: PixelColors.neon)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: PixelColors.carbon,
        iconTheme: const IconThemeData(color: PixelColors.textoClaro),
        title: Text('N.º ${p.numero}', style: pixelTitle(12, color: PixelColors.neon)),
        shape: const Border(bottom: BorderSide(color: PixelColors.carbonBorde, width: 4)),
      ),
      body: FondoPuntos(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 20, 32),
          children: [
            // ── Pantalla LCD con el Pokémon ──
            LcdScreen(
              marco: _shiny ? PixelColors.neon : PixelColors.lcdBorde,
              child: SizedBox(
                height: 200,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: _saltar,
                      child: AnimatedBuilder(
                        animation: _salto,
                        builder: (_, child) {
                          // Dos saltitos a bloques, estilo 8 bits.
                          final t = _salto.value;
                          final y = -20 * (math.sin(t * math.pi * 2).abs());
                          return Transform.translate(offset: Offset(0, (y / 4).round() * 4), child: child);
                        },
                        child: Bobbing(
                          child: Hero(
                            tag: widget.heroTag,
                            child: SpriteImage(_shiny ? p.spriteShiny : p.sprite, size: 120),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(p.nombre,
                              overflow: TextOverflow.ellipsis,
                              style: pixelTitle(15, color: Colors.white)),
                        ),
                        const SizedBox(width: 8),
                        for (final t in p.tipos)
                          Padding(padding: const EdgeInsets.only(left: 4), child: TypeTag(t)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Grito y Shiny ──
            Row(
              children: [
                Expanded(
                  child: PixelButton(
                    label: _sonando ? '♪♪♪' : 'GRITO',
                    icon: Icons.volume_up_sharp,
                    color: Colors.white,
                    fontSize: 10,
                    onTap: p.grito == null ? null : _gritar,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: PixelButton(
                    label: _shiny ? 'SHINY ON' : 'SHINY OFF',
                    color: _shiny ? PixelColors.neon : Colors.white,
                    fontSize: 10,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _shiny = !_shiny);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Pestañas ──
            Row(
              children: [
                for (final (i, nombre) in [(0, 'INFO'), (1, 'STATS'), (2, 'EVO')]) ...[
                  if (i > 0) const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _tab = i),
                      child: Container(
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _tab == i ? PixelColors.neon : Colors.white,
                          border: Border.all(color: PixelColors.carbon, width: 3),
                        ),
                        child: Text(nombre, style: pixelTitle(10)),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            LcdScreen(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: KeyedSubtree(key: ValueKey(_tab), child: _contenidoTab()),
              ),
            ),
            const SizedBox(height: 20),

            // ── Agregar al equipo (se actualiza solo) ──
            ValueListenableBuilder<List<int>>(
              valueListenable: Equipo.ids,
              builder: (_, ids, __) {
                final esta = ids.contains(p.id);
                return PixelButton(
                  label: esta ? '¡EN TU EQUIPO!' : '+ AGREGAR AL EQUIPO',
                  color: esta ? PixelColors.acierto : PixelColors.neon,
                  height: 56,
                  onTap: esta ? () => Equipo.quitar(p.id) : _agregar,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _contenidoTab() {
    switch (_tab) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _dato('${p.pesoKg.toStringAsFixed(1)}KG', 'PESO'),
                const SizedBox(width: 8),
                _dato('${p.alturaM.toStringAsFixed(1)}M', 'ALTURA'),
              ],
            ),
            const SizedBox(height: 12),
            FutureBuilder<String>(
              future: _descripcion,
              builder: (_, s) => Text(
                s.hasData ? '> ${s.data}' : (s.hasError ? '> Sin descripción.' : '> ...'),
                style: pixelBody(21, color: PixelColors.textoClaro),
              ),
            ),
          ],
        );
      case 1:
        const nombres = {
          'hp': 'PS',
          'attack': 'ATAQUE',
          'defense': 'DEFENSA',
          'special-attack': 'AT. ESP',
          'special-defense': 'DF. ESP',
          'speed': 'VELOC.',
        };
        return Column(
          children: [
            for (final e in p.stats.entries)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: StatBar(nombre: nombres[e.key] ?? e.key, valor: e.value),
              ),
          ],
        );
      default:
        return FutureBuilder<List<String>>(
          future: _evos,
          builder: (_, s) {
            if (!s.hasData) return Text('> ...', style: pixelBody(21, color: PixelColors.textoClaro));
            return Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var i = 0; i < s.data!.length; i++) ...[
                  if (i > 0) Text('▶', style: pixelTitle(10, color: const Color(0xFFC9CDD4))),
                  Text(
                    s.data![i],
                    style: pixelBody(22,
                        color: s.data![i] == p.nombre ? PixelColors.neon : PixelColors.textoClaro),
                  ),
                ],
              ],
            );
          },
        );
    }
  }

  Widget _dato(String valor, String etiqueta) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(border: Border.all(color: PixelColors.lcdBorde, width: 2)),
          child: Column(
            children: [
              Text(valor, style: pixelTitle(11, color: PixelColors.neon)),
              Text(etiqueta, style: pixelBody(18, color: const Color(0xFFC9CDD4))),
            ],
          ),
        ),
      );
}

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../services/poke_api.dart';
import '../theme/pixel.dart';

/// Tarjeta de un Pokémon para la Pokédex y Mi Equipo.
/// La pantalla LCD ocupa todo el espacio libre y el sprite crece con ella.
class PokemonCard extends StatefulWidget {
  final Pokemon pokemon;
  final String heroTag;
  final VoidCallback? onTap;
  final VoidCallback? onQuitar; // si no es null, muestra la X roja

  const PokemonCard({
    super.key,
    required this.pokemon,
    required this.heroTag,
    this.onTap,
    this.onQuitar,
  });

  @override
  State<PokemonCard> createState() => _PokemonCardState();
}

class _PokemonCardState extends State<PokemonCard> {
  bool _abajo = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.pokemon;
    return GestureDetector(
      onTapDown: (_) => setState(() => _abajo = true),
      onTapUp: (_) {
        setState(() => _abajo = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _abajo = false),
      child: Transform.translate(
        offset: _abajo ? const Offset(4, 4) : Offset.zero,
        child: PixelBox(
          sombra: _abajo ? 0 : 5,
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Pantalla LCD: ocupa todo el alto disponible
              Expanded(
                child: LcdScreen(
                  padding: EdgeInsets.zero,
                  child: LayoutBuilder(
                    builder: (_, c) {
                      final lado = math.min(c.maxWidth, c.maxHeight) * 0.85;
                      return Stack(
                        children: [
                          Center(
                            child: Bobbing(
                              child: Hero(
                                tag: widget.heroTag,
                                child: SpriteImage(p.sprite, size: lado),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 6,
                            top: 2,
                            child: Text(p.numero, style: pixelBody(20, color: PixelColors.neon)),
                          ),
                          if (widget.onQuitar != null)
                            Positioned(
                              right: 4,
                              top: 4,
                              child: GestureDetector(
                                onTap: widget.onQuitar,
                                child: Container(
                                  width: 30,
                                  height: 30,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: PixelColors.error,
                                    border: Border.all(color: PixelColors.carbon, width: 3),
                                  ),
                                  child: Text('X', style: pixelTitle(9)),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Nombre y tipos abajo
              Text(p.nombre, maxLines: 1, overflow: TextOverflow.ellipsis, style: pixelTitle(10)),
              const SizedBox(height: 6),
              Wrap(spacing: 4, runSpacing: 4, children: [for (final t in p.tipos) TypeTag(t)]),
            ],
          ),
        ),
      ),
    );
  }
}

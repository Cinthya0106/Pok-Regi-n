// Pestaña 3 — ¿Quién es ese Pokémon? (silueta + 4 opciones aleatorias, 10 rondas)
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/poke_api.dart';
import '../theme/pixel.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  static const totalRondas = 10;
  final _rnd = Random();

  int _ronda = 1;
  int _puntos = 0;
  final List<bool> _historial = [];
  Pokemon? _correcto;
  List<String> _opciones = [];
  String? _elegida;
  int _temblor = 0;
  bool _cargando = true;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _nuevaRonda();
  }

  Future<void> _nuevaRonda() async {
    setState(() {
      _cargando = true;
      _error = false;
      _elegida = null;
    });
    try {
      // 4 números distintos al azar: el primero es la respuesta correcta.
      final ids = <int>{};
      while (ids.length < 4) {
        ids.add(PokeApi.idAleatorio());
      }
      final pokes = await Future.wait(ids.map(PokeApi.pokemon));
      final nombres = pokes.map((p) => p.nombre).toList()..shuffle(_rnd);
      if (!mounted) return;
      setState(() {
        _correcto = pokes.first;
        _opciones = nombres;
        _cargando = false;
      });
    } catch (_) {
      if (mounted) setState(() => _error = true);
    }
  }

  void _responder(String nombre) {
    if (_elegida != null) return;
    final acierto = nombre == _correcto!.nombre;
    if (acierto) {
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.heavyImpact();
    }
    setState(() {
      _elegida = nombre;
      _historial.add(acierto);
      if (acierto) {
        _puntos++;
      } else {
        _temblor++;
      }
    });
  }

  void _siguiente() {
    if (_ronda >= totalRondas) {
      _finDelJuego();
      return;
    }
    setState(() => _ronda++);
    _nuevaRonda();
  }

  void _finDelJuego() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: PixelBox(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('¡FIN DEL JUEGO!', style: pixelTitle(14)),
              const SizedBox(height: 12),
              Text('$_puntos / $totalRondas', style: pixelTitle(24)),
              const SizedBox(height: 16),
              PixelButton(
                label: '▶ JUGAR OTRA VEZ',
                onTap: () {
                  Navigator.of(context).pop();
                  setState(() {
                    _ronda = 1;
                    _puntos = 0;
                    _historial.clear();
                  });
                  _nuevaRonda();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_error) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const DialogBox('SISTEMA: No pude cargar la ronda. Revisa tu internet.'),
            const SizedBox(height: 16),
            PixelButton(label: '↺ REINTENTAR', onTap: _nuevaRonda),
          ],
        ),
      );
    }

    final respondida = _elegida != null;
    final acerto = respondida && _elegida == _correcto?.nombre;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 20, 32),
      children: [
        Row(
          children: [
            Text('RONDA ${_ronda.toString().padLeft(2, '0')}/$totalRondas',
                style: pixelTitle(10, color: Colors.white)),
            const Spacer(),
            Text('PTS ${_puntos.toString().padLeft(3, '0')}', style: pixelTitle(10, color: PixelColors.neon)),
          ],
        ),
        const SizedBox(height: 10),
        // 10 bloques: verde acierto, rojo fallo, amarillo ronda actual
        Row(
          children: [
            for (var i = 0; i < totalRondas; i++) ...[
              if (i > 0) const SizedBox(width: 4),
              Expanded(
                child: Container(
                  height: 12,
                  decoration: BoxDecoration(
                    color: i < _historial.length
                        ? (_historial[i] ? PixelColors.acierto : PixelColors.error)
                        : (i == _ronda - 1 ? PixelColors.neon : Colors.white),
                    border: Border.all(color: PixelColors.carbon, width: 2),
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 14),
        LcdScreen(
          child: SizedBox(
            height: 200,
            child: Center(
              child: _cargando || _correcto == null
                  ? Parpadeo('?', estilo: pixelTitle(30, color: PixelColors.neon))
                  : AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                      child: respondida
                          ? SpriteImage(_correcto!.sprite, key: const ValueKey('color'), size: 150)
                          : Bobbing(
                              key: const ValueKey('silueta'),
                              child: SpriteImage(_correcto!.sprite, size: 150, silueta: true),
                            ),
                    ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 2.9,
          children: [
            for (final nombre in _opciones)
              Shake(
                disparo: nombre == _elegida && !acerto ? _temblor : 0,
                child: PixelButton(
                  label: nombre,
                  fontSize: 9,
                  color: !respondida
                      ? Colors.white
                      : nombre == _correcto!.nombre
                          ? PixelColors.acierto
                          : nombre == _elegida
                              ? PixelColors.error
                              : Colors.white,
                  onTap: _cargando ? null : () => _responder(nombre),
                ),
              ),
          ],
        ),
        if (respondida) ...[
          const SizedBox(height: 16),
          PixelBox(
            padding: const EdgeInsets.fromLTRB(14, 8, 8, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    acerto ? '> ¡CORRECTO! Es ${_correcto!.nombre}.' : '> ¡Casi! Era ${_correcto!.nombre}.',
                    style: pixelBody(22),
                  ),
                ),
                SizedBox(
                  width: 110,
                  child: PixelButton(
                    label: _ronda >= totalRondas ? 'FIN ▶' : 'SIGUE ▶',
                    height: 44,
                    fontSize: 9,
                    onTap: _siguiente,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

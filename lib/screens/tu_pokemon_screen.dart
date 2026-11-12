// Pestaña 2 — ¿Qué Pokémon eres? (UNIÓN DE LAS 2 APIs)
// Peso + altura → PokéAPI (Pokémon de tamaño parecido, al azar)
//               → su tipo → API Colombia (región + departamento al azar)
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/colombia_api.dart';
import '../services/equipo_storage.dart';
import '../services/poke_api.dart';
import '../theme/pixel.dart';

enum _Fase { formulario, escaneando, resultado, error }

class TuPokemonScreen extends StatefulWidget {
  const TuPokemonScreen({super.key});

  @override
  State<TuPokemonScreen> createState() => _TuPokemonScreenState();
}

class _TuPokemonScreenState extends State<TuPokemonScreen> {
  final _peso = TextEditingController(text: '65');
  final _altura = TextEditingController(text: '170');

  _Fase _fase = _Fase.formulario;
  Pokemon? _pokemon;
  Hogar? _hogar;
  int _lineas = 0; // líneas del "log" que se van mostrando al escanear
  Timer? _timer;

  @override
  void dispose() {
    _peso.dispose();
    _altura.dispose();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _escanear() async {
    final kg = double.tryParse(_peso.text.replaceAll(',', '.'));
    final cm = double.tryParse(_altura.text.replaceAll(',', '.'));
    if (kg == null || cm == null || kg <= 0 || cm <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: PixelColors.carbon,
        content: Text('Escribe un peso y una altura válidos.', style: pixelBody(22, color: PixelColors.neon)),
      ));
      return;
    }
    FocusScope.of(context).unfocus();
    HapticFeedback.mediumImpact();
    setState(() {
      _fase = _Fase.escaneando;
      _lineas = 0;
    });
    _timer = Timer.periodic(const Duration(milliseconds: 600), (t) {
      if (!mounted || _lineas >= 3) return t.cancel();
      setState(() => _lineas++);
    });

    try {
      // API 1: PokéAPI. Esperamos mínimo 2 s para que se vea la animación.
      final res = await Future.wait([
        PokeApi.porTamano(kg, cm),
        Future.delayed(const Duration(seconds: 2)),
      ]);
      final pokemon = res[0] as Pokemon;
      // API 2: API Colombia, según el primer tipo del Pokémon.
      final hogar = await ColombiaApi.hogarPara(pokemon.tipos.first);
      if (!mounted) return;
      HapticFeedback.heavyImpact();
      setState(() {
        _pokemon = pokemon;
        _hogar = hogar;
        _fase = _Fase.resultado;
      });
    } catch (_) {
      if (mounted) setState(() => _fase = _Fase.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 20, 32),
      children: [
        Text('POKÉAPI + API COLOMBIA', style: pixelBody(22, color: Colors.white)),
        const SizedBox(height: 12),
        switch (_fase) {
          _Fase.formulario => _formulario(),
          _Fase.escaneando => _escaneando(),
          _Fase.resultado => _resultado(),
          _Fase.error => _errorVista(),
        },
      ],
    );
  }

  Widget _campo(String etiqueta, TextEditingController c, String unidad) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(etiqueta, style: pixelTitle(10)),
        const SizedBox(height: 6),
        Container(
          height: 54,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: PixelColors.carbon,
            border: Border.all(color: PixelColors.carbonBorde, width: 4),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: c,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  cursorColor: PixelColors.neon,
                  style: pixelTitle(16, color: PixelColors.neon),
                  decoration: const InputDecoration(border: InputBorder.none),
                ),
              ),
              Text(unidad, style: pixelBody(24, color: PixelColors.textoClaro)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _formulario() => Column(
        children: [
          const DialogBox(
              'SISTEMA: Escribe tu peso y tu altura. ¡Te diré qué Pokémon eres y en qué región de Colombia vivirías!'),
          const SizedBox(height: 16),
          PixelBox(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _campo('PESO', _peso, 'KG'),
                const SizedBox(height: 14),
                _campo('ALTURA', _altura, 'CM'),
                const SizedBox(height: 18),
                PixelButton(label: '▶ ESCANEAR', height: 56, fontSize: 12, onTap: _escanear),
              ],
            ),
          ),
        ],
      );

  Widget _escaneando() {
    const log = ['> PESO ......... OK', '> ALTURA ....... OK', '> BUSCANDO EN POKÉAPI...'];
    return LcdScreen(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text('ANALIZANDO', style: pixelTitle(12, color: PixelColors.neon)),
            Parpadeo('...', estilo: pixelTitle(12, color: PixelColors.neon)),
          ]),
          const SizedBox(height: 14),
          // Barra de carga a bloques (10 pasos en 2 segundos)
          Container(
            height: 22,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(border: Border.all(color: PixelColors.textoClaro, width: 3)),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(seconds: 2),
              builder: (_, v, __) => FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: (v * 10).floor() / 10,
                child: Container(color: PixelColors.neon),
              ),
            ),
          ),
          const SizedBox(height: 14),
          for (var i = 0; i < _lineas && i < log.length; i++)
            Text(log[i], style: pixelBody(22, color: PixelColors.textoClaro)),
        ],
      ),
    );
  }

  Widget _resultado() {
    final p = _pokemon!;
    final h = _hogar!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LcdScreen(
          marco: PixelColors.neon,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text('¡POKÉMON ENCONTRADO!', style: pixelTitle(10, color: PixelColors.neon)),
              const SizedBox(height: 8),
              // Aparece "de golpe" con un rebote
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.4, end: 1),
                duration: const Duration(milliseconds: 450),
                curve: Curves.elasticOut,
                builder: (_, s, child) => Transform.scale(scale: s, child: child),
                child: Bobbing(child: SpriteImage(p.sprite, size: 110)),
              ),
              const SizedBox(height: 8),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 6,
                children: [
                  Text(p.nombre, style: pixelTitle(13, color: Colors.white)),
                  for (final t in p.tipos) TypeTag(t),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'TÚ: ${_peso.text}KG · ${_altura.text}CM   |   ÉL: ${p.pesoKg}KG · ${(p.alturaM * 100).round()}CM',
                textAlign: TextAlign.center,
                style: pixelBody(19, color: PixelColors.textoClaro),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        PixelBox(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text('REGIÓN: ${h.region.nombre.toUpperCase()}', style: pixelTitle(10))),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                      color: PixelColors.neon,
                      border: Border.all(color: PixelColors.carbon, width: 2),
                    ),
                    child: Text('AL AZAR', style: pixelBody(17)),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text('HOGAR: ${h.departamento.toUpperCase()}', style: pixelBody(26)),
              if (h.region.descripcion.isNotEmpty)
                Text(h.region.descripcion,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: pixelBody(19, color: PixelColors.texto2)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: PixelButton(
                label: '↺ OTRA VEZ',
                color: Colors.white,
                fontSize: 10,
                onTap: () => setState(() => _fase = _Fase.formulario),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: PixelButton(
                label: '+ EQUIPO',
                fontSize: 10,
                onTap: () async {
                  final ok = await Equipo.agregar(p.id);
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    backgroundColor: PixelColors.carbon,
                    content: Text(ok ? '¡${p.nombre} se unió a tu equipo!' : 'No se pudo agregar (ya está o el equipo está lleno).',
                        style: pixelBody(22, color: PixelColors.neon)),
                  ));
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _errorVista() => Column(
        children: [
          const DialogBox('SISTEMA: Ups, no pude conectar con las APIs. Revisa tu internet.'),
          const SizedBox(height: 16),
          PixelButton(label: '↺ REINTENTAR', onTap: _escanear),
        ],
      );
}

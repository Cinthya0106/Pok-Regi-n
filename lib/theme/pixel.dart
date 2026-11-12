// Sistema de diseño pixel art de PokéRegión.
// Aquí están los colores, las letras y los widgets personalizados
// que se reutilizan en todas las pantallas.
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

// ─────────────────────────── COLORES ───────────────────────────
class PixelColors {
  static const rojo = Color(0xFFB8434C);
  static const carbon = Color(0xFF14161B);
  static const carbonBorde = Color(0xFF0B0C0F);
  static const lcdBorde = Color(0xFF2A2D35);
  static const panel = Colors.white;
  static const neon = Color(0xFFFFE14D);
  static const texto2 = Color(0xFF4F5562);
  static const textoClaro = Color(0xFFF5F7FA);
  static const acierto = Color(0xFF4ADE80);
  static const error = Color(0xFFFF6B81);
  static const sombra = Color(0x8C3C0810);
}

// ─────────────────────────── LETRAS ───────────────────────────
TextStyle pixelTitle(double size, {Color color = PixelColors.carbon}) =>
    GoogleFonts.pressStart2p(fontSize: size, color: color, height: 1.4);

TextStyle pixelBody(double size, {Color color = PixelColors.carbon}) =>
    GoogleFonts.vt323(fontSize: size, color: color, height: 1.1);

// ─────────────────────────── TIPOS ───────────────────────────
const tipoColores = <String, Color>{
  'fire': Color(0xFFFF9A6B),
  'water': Color(0xFF7FB8FF),
  'grass': Color(0xFF7EDC96),
  'electric': Color(0xFFFFE14D),
  'ghost': Color(0xFFB9A6FF),
  'poison': Color(0xFFD49BFF),
  'rock': Color(0xFFD8C08F),
  'ground': Color(0xFFE8C77A),
  'normal': Color(0xFFE0E0E0),
  'fighting': Color(0xFFFF8A80),
  'flying': Color(0xFFB3C7FF),
  'psychic': Color(0xFFFF9EC7),
  'bug': Color(0xFFC5E17A),
  'ice': Color(0xFFA8EEF5),
  'dragon': Color(0xFFA899FF),
  'dark': Color(0xFFB0A090),
  'steel': Color(0xFFC8CDD6),
  'fairy': Color(0xFFFFB8E0),
};

const tipoNombres = <String, String>{
  'fire': 'FUEGO',
  'water': 'AGUA',
  'grass': 'PLANTA',
  'electric': 'ELÉCTRICO',
  'ghost': 'FANTASMA',
  'poison': 'VENENO',
  'rock': 'ROCA',
  'ground': 'TIERRA',
  'normal': 'NORMAL',
  'fighting': 'LUCHA',
  'flying': 'VOLADOR',
  'psychic': 'PSÍQUICO',
  'bug': 'BICHO',
  'ice': 'HIELO',
  'dragon': 'DRAGÓN',
  'dark': 'SINIESTRO',
  'steel': 'ACERO',
  'fairy': 'HADA',
};

// ─────────────────────────── WIDGETS ───────────────────────────

/// Fondo rojo con una trama de puntos, como una pantalla retro.
class FondoPuntos extends StatelessWidget {
  final Widget child;
  const FondoPuntos({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _PuntosPainter(), child: child);
  }
}

class _PuntosPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = const Color(0x24000000);
    for (double y = 4; y < size.height; y += 8) {
      for (double x = 4; x < size.width; x += 8) {
        canvas.drawRect(Rect.fromLTWH(x, y, 1.5, 1.5), p);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Caja blanca con borde grueso y sombra dura (sin difuminar).
class PixelBox extends StatelessWidget {
  final Widget child;
  final Color color;
  final EdgeInsets padding;
  final double sombra;

  const PixelBox({
    super.key,
    required this.child,
    this.color = PixelColors.panel,
    this.padding = const EdgeInsets.all(12),
    this.sombra = 6,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: PixelColors.carbon, width: 4),
        boxShadow: [
          BoxShadow(color: PixelColors.sombra, offset: Offset(sombra, sombra)),
        ],
      ),
      child: child,
    );
  }
}

/// Pantalla oscura tipo LCD con líneas de escaneo.
class LcdScreen extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final Color marco;

  const LcdScreen({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(12),
    this.marco = PixelColors.lcdBorde,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: PixelColors.carbon,
        border: Border.fromBorderSide(
            BorderSide(color: PixelColors.carbonBorde, width: 4)),
        boxShadow: [BoxShadow(color: PixelColors.sombra, offset: Offset(6, 6))],
      ),
      child: Container(
        decoration: BoxDecoration(border: Border.all(color: marco, width: 4)),
        child: CustomPaint(
          painter: _ScanlinesPainter(),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

class _ScanlinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = const Color(0x0DFFFFFF);
    for (double y = 0; y < size.height; y += 4) {
      canvas.drawRect(Rect.fromLTWH(0, y, size.width, 2), p);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Botón pixel que "se hunde" al tocarlo y vibra un poquito.
class PixelButton extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  final Color color;
  final double height;
  final double fontSize;
  final IconData? icon;

  const PixelButton({
    super.key,
    required this.label,
    this.onTap,
    this.color = PixelColors.neon,
    this.height = 52,
    this.fontSize = 11,
    this.icon,
  });

  @override
  State<PixelButton> createState() => _PixelButtonState();
}

class _PixelButtonState extends State<PixelButton> {
  bool _abajo = false;

  @override
  Widget build(BuildContext context) {
    final activo = widget.onTap != null;
    return GestureDetector(
      onTapDown: activo
          ? (_) {
              setState(() => _abajo = true);
              HapticFeedback.lightImpact();
            }
          : null,
      onTapUp: activo
          ? (_) {
              setState(() => _abajo = false);
              widget.onTap!();
            }
          : null,
      onTapCancel: () => setState(() => _abajo = false),
      child: Transform.translate(
        offset: _abajo ? const Offset(4, 4) : Offset.zero,
        child: Container(
          height: widget.height,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: activo ? widget.color : const Color(0xFFBDBDBD),
            border: Border.all(color: PixelColors.carbon, width: 4),
            boxShadow: _abajo
                ? const []
                : const [
                    BoxShadow(color: PixelColors.carbon, offset: Offset(4, 4))
                  ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, size: 18, color: PixelColors.carbon),
                if (widget.label.isNotEmpty) const SizedBox(width: 8),
              ],
              if (widget.label.isNotEmpty)
                Flexible(
                  child: Text(
                    widget.label,
                    textAlign: TextAlign.center,
                    style: pixelTitle(widget.fontSize),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Etiqueta cuadrada con el color del tipo (FUEGO, AGUA...).
class TypeTag extends StatelessWidget {
  final String tipo; // nombre en inglés de la API: fire, water...
  final double fontSize;
  const TypeTag(this.tipo, {super.key, this.fontSize = 17});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: tipoColores[tipo] ?? Colors.white,
        border: Border.all(color: PixelColors.carbon, width: 2),
      ),
      child: Text(tipoNombres[tipo] ?? tipo.toUpperCase(),
          style: pixelBody(fontSize)),
    );
  }
}

/// Hace "flotar" a su hijo a saltos de 2 pasos (animación pixel).
class Bobbing extends StatefulWidget {
  final Widget child;
  final double altura;
  const Bobbing({super.key, required this.child, this.altura = 6});

  @override
  State<Bobbing> createState() => _BobbingState();
}

class _BobbingState extends State<Bobbing> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1200))
    ..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, child) => Transform.translate(
        offset: Offset(0, _c.value < 0.5 ? -widget.altura : 0),
        child: child,
      ),
      child: widget.child,
    );
  }
}

/// Hace temblar a su hijo cada vez que cambia [disparo].
class Shake extends StatefulWidget {
  final Widget child;
  final int disparo;
  const Shake({super.key, required this.child, required this.disparo});

  @override
  State<Shake> createState() => _ShakeState();
}

class _ShakeState extends State<Shake> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 400));

  @override
  void didUpdateWidget(covariant Shake oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.disparo > oldWidget.disparo) _c.forward(from: 0);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, child) {
        final t = _c.value;
        final dx = math.sin(t * math.pi * 6) * 8 * (1 - t);
        return Transform.translate(offset: Offset(dx, 0), child: child);
      },
      child: widget.child,
    );
  }
}

/// Texto que parpadea (el ▼ de los cuadros de diálogo o el cursor _).
class Parpadeo extends StatefulWidget {
  final String texto;
  final TextStyle estilo;
  const Parpadeo(this.texto, {super.key, required this.estilo});

  @override
  State<Parpadeo> createState() => _ParpadeoState();
}

class _ParpadeoState extends State<Parpadeo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 900))
    ..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) => Opacity(
        opacity: _c.value < 0.5 ? 1 : 0,
        child: Text(widget.texto, style: widget.estilo),
      ),
    );
  }
}

/// Cuadro de diálogo estilo RPG: "> SISTEMA: ..." con ▼ parpadeando.
class DialogBox extends StatelessWidget {
  final String mensaje;
  const DialogBox(this.mensaje, {super.key});

  @override
  Widget build(BuildContext context) {
    return PixelBox(
      sombra: 5,
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(child: Text('> $mensaje', style: pixelBody(22))),
          Parpadeo(' ▼', estilo: pixelBody(20)),
        ],
      ),
    );
  }
}

/// Imagen del Pokémon (sprite pixel de PokéAPI) sin suavizar.
/// Si [silueta] es true se pinta toda negra (para el quiz).
class SpriteImage extends StatelessWidget {
  final String url;
  final double size;
  final bool silueta;
  const SpriteImage(this.url,
      {super.key, this.size = 96, this.silueta = false});

  @override
  Widget build(BuildContext context) {
    Widget img = Image.network(
      url,
      width: size,
      height: size,
      fit: BoxFit.contain,
      filterQuality:
          FilterQuality.none, // ← clave para que se vea pixelado y nítido
      errorBuilder: (_, __, ___) => SizedBox(
        width: size,
        height: size,
        child: Center(
            child: Text('?',
                style: pixelTitle(size / 4, color: PixelColors.neon))),
      ),
      loadingBuilder: (_, child, progreso) => progreso == null
          ? child
          : SizedBox(
              width: size,
              height: size,
              child: Center(
                  child: Parpadeo('...',
                      estilo: pixelTitle(10, color: PixelColors.neon))),
            ),
    );
    if (silueta) {
      img = ColorFiltered(
        colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
        child: img,
      );
    }
    return img;
  }
}

/// Barra de estadística por bloques que se llena con animación.
class StatBar extends StatelessWidget {
  final String nombre;
  final int valor;
  const StatBar({super.key, required this.nombre, required this.valor});

  @override
  Widget build(BuildContext context) {
    final fraccion = (valor / 150).clamp(0.0, 1.0);
    return Row(
      children: [
        SizedBox(
            width: 72,
            child: Text(nombre,
                style: pixelBody(20, color: const Color(0xFFC9CDD4)))),
        SizedBox(
          width: 36,
          child: Text(valor.toString().padLeft(3, '0'),
              textAlign: TextAlign.right,
              style: pixelTitle(9, color: PixelColors.textoClaro)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: fraccion),
            duration: const Duration(milliseconds: 900),
            builder: (_, v, __) {
              // Redondeamos a 10 pasos para que se llene "a bloques".
              final pasos = (v * 10).floor() / 10;
              return CustomPaint(
                size: const Size(double.infinity, 12),
                painter: _BloquesPainter(pasos),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _BloquesPainter extends CustomPainter {
  final double fraccion;
  _BloquesPainter(this.fraccion);

  @override
  void paint(Canvas canvas, Size size) {
    const ancho = 8.0, espacio = 2.0;
    final total = (size.width / (ancho + espacio)).floor();
    final llenos = (total * fraccion).round();
    for (var i = 0; i < total; i++) {
      final p = Paint()
        ..color = i < llenos ? PixelColors.neon : PixelColors.lcdBorde;
      canvas.drawRect(
          Rect.fromLTWH(i * (ancho + espacio), 0, ancho, size.height), p);
    }
  }

  @override
  bool shouldRepaint(covariant _BloquesPainter old) => old.fraccion != fraccion;
}

/// Pantalla de "cargando" pixel.
class CargandoPixel extends StatelessWidget {
  final String texto;
  const CargandoPixel({super.key, this.texto = 'CARGANDO'});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(texto, style: pixelTitle(12, color: Colors.white)),
          Parpadeo('...', estilo: pixelTitle(12, color: Colors.white)),
        ],
      ),
    );
  }
}

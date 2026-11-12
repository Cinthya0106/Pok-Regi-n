// Servicio de PokéAPI (https://pokeapi.co) — API #1 del proyecto.
import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;

const _spritesBase =
    'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon';

class Pokemon {
  final int id;
  final String nombre;
  final List<String> tipos; // en inglés: fire, water...
  final int peso; // hectogramos (así lo da la API)
  final int altura; // decímetros (así lo da la API)
  final Map<String, int> stats;
  final String? grito; // url del sonido .ogg

  Pokemon({
    required this.id,
    required this.nombre,
    required this.tipos,
    required this.peso,
    required this.altura,
    required this.stats,
    this.grito,
  });

  double get pesoKg => peso / 10;
  double get alturaM => altura / 10;
  String get numero => id.toString().padLeft(3, '0');

  /// Sprite pixel clásico y su versión shiny.
  String get sprite => '$_spritesBase/$id.png';
  String get spriteShiny => '$_spritesBase/shiny/$id.png';

  factory Pokemon.fromJson(Map<String, dynamic> j) {
    final cries = j['cries'];
    return Pokemon(
      id: j['id'] as int,
      nombre: (j['name'] as String).toUpperCase(),
      tipos: [for (final t in j['types'] as List) t['type']['name'] as String],
      peso: j['weight'] as int,
      altura: j['height'] as int,
      stats: {
        for (final s in j['stats'] as List) s['stat']['name'] as String: s['base_stat'] as int,
      },
      grito: cries is Map ? cries['latest'] as String? : null,
    );
  }
}

class PokeApi {
  static const _url = 'https://pokeapi.co/api/v2';
  static final Map<int, Pokemon> _cache = {};
  static final _random = Random();

  static Future<Map<String, dynamic>> _get(String path) async {
    final r = await http.get(Uri.parse(path.startsWith('http') ? path : '$_url$path'));
    if (r.statusCode != 200) {
      throw Exception('PokéAPI respondió ${r.statusCode}');
    }
    return jsonDecode(r.body) as Map<String, dynamic>;
  }

  /// Un Pokémon por número (guarda en caché para no repetir llamadas).
  static Future<Pokemon> pokemon(int id) async {
    final enCache = _cache[id];
    if (enCache != null) return enCache;
    final p = Pokemon.fromJson(await _get('/pokemon/$id'));
    _cache[id] = p;
    return p;
  }

  /// Los 151 de Kanto, pedidos en grupos de 25 para no saturar la red.
  static Future<List<Pokemon>> kanto() async {
    final lista = <Pokemon>[];
    for (var inicio = 1; inicio <= 151; inicio += 25) {
      final ids = [for (var i = inicio; i < inicio + 25 && i <= 151; i++) i];
      lista.addAll(await Future.wait(ids.map(pokemon)));
    }
    return lista;
  }

  static int idAleatorio() => _random.nextInt(151) + 1;

  /// Descripción de la Pokédex en español (si no hay, en inglés).
  static Future<String> descripcion(int id) async {
    final species = await _get('/pokemon-species/$id');
    final entradas = species['flavor_text_entries'] as List;
    Map? buscar(String lang) {
      for (final e in entradas) {
        if (e['language']['name'] == lang) return e as Map;
      }
      return null;
    }

    final e = buscar('es') ?? buscar('en');
    if (e == null) return 'Sin descripción.';
    return (e['flavor_text'] as String).replaceAll(RegExp(r'[\n\f\r]'), ' ');
  }

  /// Nombres de la cadena evolutiva (ej: PICHU → PIKACHU → RAICHU).
  static Future<List<String>> evoluciones(int id) async {
    final species = await _get('/pokemon-species/$id');
    final cadena = await _get(species['evolution_chain']['url'] as String);
    final nombres = <String>[];
    void recorrer(Map nodo) {
      nombres.add((nodo['species']['name'] as String).toUpperCase());
      for (final hijo in nodo['evolves_to'] as List) {
        recorrer(hijo as Map);
      }
    }

    recorrer(cadena['chain'] as Map);
    return nombres;
  }

  /// Toma 15 Pokémon al azar y devuelve el de tamaño más parecido al usuario.
  /// (Así cumple el requisito del random y además tiene sentido.)
  static Future<Pokemon> porTamano(double pesoKg, double alturaCm) async {
    final ids = <int>{};
    while (ids.length < 15) {
      ids.add(idAleatorio());
    }
    final candidatos = await Future.wait(ids.map(pokemon));

    double distancia(Pokemon p) =>
        (log((p.pesoKg + 0.1) / (pesoKg + 0.1))).abs() +
        (log((p.alturaM * 100 + 1) / (alturaCm + 1))).abs();

    candidatos.sort((a, b) => distancia(a).compareTo(distancia(b)));
    return candidatos.first;
  }
}

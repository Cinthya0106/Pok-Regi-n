// Servicio de API Colombia (https://api-colombia.com) — API #2 del proyecto.
import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;

class Region {
  final int id;
  final String nombre;
  final String descripcion;
  Region({required this.id, required this.nombre, required this.descripcion});

  factory Region.fromJson(Map<String, dynamic> j) => Region(
        id: j['id'] as int,
        nombre: j['name'] as String,
        descripcion: (j['description'] as String?) ?? '',
      );
}

class Hogar {
  final Region region;
  final String departamento;
  Hogar(this.region, this.departamento);
}

class ColombiaApi {
  static const _url = 'https://api-colombia.com/api/v1';

  static Future<List<dynamic>> _getLista(String path) async {
    final r = await http.get(Uri.parse('$_url$path'));
    if (r.statusCode != 200) {
      throw Exception('API Colombia respondió ${r.statusCode}');
    }
    return jsonDecode(r.body) as List<dynamic>;
  }

  static Future<List<Region>> regiones() async =>
      (await _getLista('/Region')).map((j) => Region.fromJson(j as Map<String, dynamic>)).toList();

  static Future<List<String>> departamentos(int regionId) async =>
      (await _getLista('/Region/$regionId/departments'))
          .map((d) => (d as Map)['name'] as String)
          .toList();

  /// Tipo del Pokémon → región de Colombia → departamento al azar.
  static Future<Hogar> hogarPara(String tipo) async {
    final buscada = regionPorTipo(tipo);
    final lista = await regiones();
    final region = lista.firstWhere(
      (r) => _normalizar(r.nombre).contains(buscada),
      orElse: () => lista.first,
    );
    final deps = await departamentos(region.id);
    final dep = deps.isEmpty ? '—' : deps[Random().nextInt(deps.length)];
    return Hogar(region, dep);
  }
}

/// Qué región le toca a cada tipo (puedes cambiar esta tabla).
String regionPorTipo(String tipo) {
  switch (tipo) {
    case 'water':
      return 'insular';
    case 'fire':
    case 'ground':
      return 'caribe';
    case 'grass':
    case 'bug':
    case 'poison':
      return 'amazonia';
    case 'rock':
    case 'steel':
    case 'ice':
    case 'fighting':
      return 'andina';
    case 'flying':
    case 'electric':
    case 'normal':
      return 'orinoquia';
    default: // ghost, psychic, dark, dragon, fairy
      return 'pacifico';
  }
}

String _normalizar(String s) {
  const con = 'áéíóúÁÉÍÓÚ';
  const sin = 'aeiouaeiou';
  var r = s;
  for (var i = 0; i < con.length; i++) {
    r = r.replaceAll(con[i], sin[i]);
  }
  return r.toLowerCase();
}

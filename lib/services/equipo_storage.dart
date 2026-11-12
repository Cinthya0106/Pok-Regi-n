// Guarda "Mi Equipo" (máximo 6 Pokémon) en el celular.
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Equipo {
  static const maximo = 6;
  static const _clave = 'mi_equipo';

  /// Lista de ids. Las pantallas la escuchan con ValueListenableBuilder,
  /// así cuando agregas en Detalle se actualiza solo en Mi Equipo.
  static final ValueNotifier<List<int>> ids = ValueNotifier<List<int>>([]);

  static Future<void> cargar() async {
    final prefs = await SharedPreferences.getInstance();
    ids.value = (prefs.getStringList(_clave) ?? []).map(int.parse).toList();
  }

  static bool contiene(int id) => ids.value.contains(id);
  static bool get lleno => ids.value.length >= maximo;

  /// Devuelve false si ya estaba o si el equipo está lleno.
  static Future<bool> agregar(int id) async {
    if (contiene(id) || lleno) return false;
    ids.value = [...ids.value, id];
    await _guardar();
    return true;
  }

  static Future<void> quitar(int id) async {
    ids.value = ids.value.where((x) => x != id).toList();
    await _guardar();
  }

  static Future<void> _guardar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_clave, ids.value.map((e) => e.toString()).toList());
  }
}

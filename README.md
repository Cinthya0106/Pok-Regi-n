# PokéRegión 🎮

## 📲 [Descargar la app (APK)](https://github.com/Cinthya0106/Pok-Regi-n/releases/tag/v1.0)
## 📄 [Documento del proyecto y manual de usuario (PDF)](PokéRegión–Documentodelproyecto(PDF pixel).pdf)

App móvil en Flutter con estilo **pixel art retro** que une **PokéAPI** y **API Colombia**:
escribes tu peso y tu altura, la app te asigna un Pokémon de tamaño parecido y, según su tipo,
te dice en qué región de Colombia vivirías.
App móvil en Flutter con estilo **pixel art retro** que une **PokéAPI** y **API Colombia**:
escribes tu peso y tu altura, la app te asigna un Pokémon de tamaño parecido y, según su tipo,
te dice en qué región de Colombia vivirías.

## Pestañas

| Pestaña | Qué hace | API |
|---|---|---|
| **DEX** | Los 151 Pokémon de Kanto, buscador, filtros por tipo y dado al azar | PokéAPI |
| **TÚ** | Peso + altura → Pokémon → región y departamento de Colombia al azar | PokéAPI + API Colombia |
| **QUIZ** | "¿Quién es ese Pokémon?": silueta y 4 opciones al azar, 10 rondas | PokéAPI |
| **EQUIPO** | Hasta 6 Pokémon guardados en el celular | — (shared_preferences) |

Al tocar un Pokémon se abre su **detalle**: grito (sonido), versión shiny, estadísticas, descripción y evoluciones.

## Cómo correrla

1. Instala Flutter: https://docs.flutter.dev/get-started/install
2. En una terminal, dentro de esta carpeta:
   ```bash
   flutter create .        # genera las carpetas android/ e ios/ sin tocar lib/
   flutter pub get
   flutter run
   ```
3. **Android:** revisa que `android/app/src/main/AndroidManifest.xml` tenga el permiso de internet
   (antes de la etiqueta `<application>`):
   ```xml
   <uses-permission android:name="android.permission.INTERNET"/>
   ```

## Estructura

```
lib/
├── main.dart                 # AppBar + barra inferior con las 4 pestañas
├── theme/pixel.dart          # colores, letras y widgets pixel personalizados
├── services/
│   ├── poke_api.dart         # API 1: PokéAPI
│   ├── colombia_api.dart     # API 2: API Colombia + tabla tipo → región
│   └── equipo_storage.dart   # guardar Mi Equipo
├── widgets/pokemon_card.dart # tarjeta reutilizable
└── screens/                  # una pantalla por archivo
assets/images/                # logo.png, equipo_vacio.png (imágenes de Assets)
```

## Manual de uso

1. **DEX:** desliza para ver los Pokémon, escribe en el buscador o toca un tipo para filtrar. El dado abre uno al azar.
2. **Detalle:** toca al Pokémon para que salte, **GRITO** para escucharlo, **SHINY** para ver su versión brillante, y **+ AGREGAR AL EQUIPO**.
3. **TÚ:** escribe tu peso (kg) y tu altura (cm) y toca **▶ ESCANEAR**.
4. **QUIZ:** adivina el Pokémon por su silueta. Verde = acierto, rojo = fallo.
5. **EQUIPO:** la **X** quita a un Pokémon; los espacios vacíos te llevan a la DEX.

## Créditos

- Datos e imágenes: [PokéAPI](https://pokeapi.co) — Pokémon © Nintendo / Game Freak.
- Datos de Colombia: [API Colombia](https://api-colombia.com).
- Letras: Press Start 2P y VT323 (Google Fonts).
- Zharick Peña
- Sonia Sonza
- Cinthya Kuper

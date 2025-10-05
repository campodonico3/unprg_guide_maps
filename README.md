# 🗺️ UNPRG Guide Maps

<div align="center">

![Flutter Version](https://img.shields.io/badge/Flutter-3.0+-02569B?style=for-the-badge&logo=flutter)
![Dart Version](https://img.shields.io/badge/Dart-3.0+-0175C2?style=for-the-badge&logo=dart)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)
![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-lightgrey?style=for-the-badge)

**Sistema de navegación inteligente para la Universidad Nacional Pedro Ruiz Gallo**

[Características](#-características-principales) • [Instalación](#-instalación) • [Arquitectura](#-arquitectura) • [Tecnologías](#-tecnologías-utilizadas) • [Capturas](#-capturas-de-pantalla)

</div>

---

## 📋 Descripción

**UNPRG Guide Maps** es una aplicación móvil desarrollada en Flutter que permite a estudiantes, docentes y visitantes navegar por el campus universitario de manera intuitiva. El sistema proporciona rutas optimizadas, navegación guiada por voz y visualización en tiempo real de la ubicación del usuario.

### 🎯 Problema que Resuelve

- Dificultad para ubicar facultades y oficinas en el extenso campus universitario
- Falta de señalización clara para nuevos estudiantes y visitantes
- Pérdida de tiempo buscando ubicaciones específicas
- Necesidad de asistencia guiada en el campus

---

## ✨ Características Principales

### 🧭 Navegación Inteligente
- **Rutas Optimizadas**: Cálculo automático de la ruta más corta usando Google Maps Directions API
- **Navegación por Voz**: Instrucciones de navegación en español con texto a voz (TTS)
- **Actualización en Tiempo Real**: Seguimiento continuo de la ubicación del usuario
- **Recalculación Automática**: Ajuste de rutas si el usuario se desvía del camino

### 🗺️ Visualización del Mapa
- **Marcadores Personalizados**: Iconos únicos para cada ubicación con etiquetas visibles
- **Modo Vista General**: Visualización de todas las facultades y oficinas simultáneamente
- **Modo Navegación Individual**: Enfoque en una ubicación específica con ruta detallada
- **Polylines Dinámicas**: Representación visual clara de las rutas con líneas conectoras

### 🔍 Búsqueda y Filtrado
- **Búsqueda en Tiempo Real**: Filtrado instantáneo por nombre o sigla
- **Navegación por Pestañas**: Separación entre Facultades y Oficinas
- **Cambio Automático de Pestaña**: El sistema cambia a la pestaña con resultados relevantes

### 📍 Gestión de Ubicaciones
- **Múltiples Categorías**: Facultades y oficinas administrativas
- **Información Detallada**: Tarjetas informativas con datos de cada ubicación
- **Centrado Automático**: Enfoque rápido en ubicaciones seleccionadas
- **Rutas Manuales**: Posibilidad de establecer origen y destino personalizados

---

## 🚀 Instalación

### Requisitos Previos

```bash
Flutter SDK >= 3.0.0
Dart SDK >= 3.0.0
Android Studio / VS Code
Google Maps API Key
```

### Configuración del Proyecto

1. **Clonar el repositorio**
```bash
git clone https://github.com/tu-usuario/unprg-guide-maps.git
cd unprg-guide-maps
```

2. **Instalar dependencias**
```bash
flutter pub get
```

3. **Configurar Google Maps API Key**

Edita el archivo `lib/core/services/polyline_service.dart` y reemplaza la API Key:

```dart
static const String _apiKey = "TU_API_KEY_AQUI";
```

> ⚠️ **Importante**: Habilita las siguientes APIs en Google Cloud Console:
> - Maps SDK for Android
> - Maps SDK for iOS
> - Directions API

4. **Configurar permisos**

**Android** (`android/app/src/main/AndroidManifest.xml`):
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.INTERNET" />
```

**iOS** (`ios/Runner/Info.plist`):
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Esta app necesita acceso a tu ubicación para mostrarte rutas</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>Esta app necesita acceso a tu ubicación para navegación continua</string>
```

5. **Ejecutar la aplicación**
```bash
flutter run
```

---

## 🏗️ Arquitectura

El proyecto sigue una arquitectura limpia con separación de responsabilidades:

```
lib/
├── core/
│   ├── constants/          # Constantes (colores, estilos, etc.)
│   └── services/           # Servicios principales
│       ├── location_service.dart      # Gestión de ubicación GPS
│       ├── marker_service.dart        # Creación de marcadores
│       ├── navigation_service.dart    # Lógica de navegación
│       └── polyline_service.dart      # Generación de rutas
├── data/
│   ├── models/             # Modelos de datos
│   └── repositories/       # Repositorios de datos
├── presentation/
│   ├── pages/              # Páginas de la aplicación
│   │   ├── home/          # Página principal
│   │   └── map/           # Página del mapa
│   └── widgets/            # Componentes reutilizables
└── main.dart               # Punto de entrada
```

### Patrones de Diseño Utilizados

- **Repository Pattern**: Para la gestión de datos de ubicaciones
- **Service Layer**: Servicios especializados para cada funcionalidad
- **ChangeNotifier**: Para gestión de estado reactivo
- **Singleton**: En servicios que requieren instancia única

---

## 🛠️ Tecnologías Utilizadas

### Framework y Lenguaje
- **Flutter**: Framework multiplataforma
- **Dart**: Lenguaje de programación

### Principales Dependencias

```yaml
dependencies:
  google_maps_flutter: ^2.x.x          # Integración de Google Maps
  google_maps_polyline: ^1.x.x         # Generación de polylines
  location: ^5.x.x                     # Acceso a GPS
  flutter_tts: ^3.x.x                  # Texto a voz
```

### APIs Externas
- **Google Maps SDK**: Visualización de mapas
- **Google Directions API**: Cálculo de rutas
- **Location Services**: GPS del dispositivo

---

## 📱 Capturas de Pantalla

<div align="center">

| Pantalla Principal | Vista de Mapa | Navegación |
|:-----------------:|:-------------:|:----------:|
| ![Home](assets/screenshots/home.png) | ![Map](assets/screenshots/map.png) | ![Navigation](assets/screenshots/navigation.png) |

</div>

---

## 🔑 Características Técnicas Destacadas

### 1. Marcadores Personalizados con Etiquetas
```dart
// Los marcadores se generan dinámicamente con Canvas
Future<BitmapDescriptor> _createLocationMarkerWithLabel(
    String sigla, bool isSelected) async {
  final pictureRecorder = ui.PictureRecorder();
  final canvas = Canvas(pictureRecorder);
  // Dibujo personalizado del marcador con texto
}
```

### 2. Navegación con Instrucciones de Voz
```dart
// Sistema de TTS en español con instrucciones contextuales
await _flutterTts.setLanguage('es-ES');
await _flutterTts.speak('En 100 metros, gira a la derecha');
```

### 3. Cálculo de Distancias con Haversine
```dart
// Fórmula de Haversine para distancias precisas
double _calculateDistance(LatLng point1, LatLng point2) {
  const double earthRadius = 6371000;
  // Implementación de la fórmula
}
```

### 4. Gestión de Estado Reactiva
```dart
// ChangeNotifier para actualización automática de UI
class NavigationService extends ChangeNotifier {
  void updateCurrentLocation(LocationData data) {
    // Actualiza y notifica cambios
    notifyListeners();
  }
}
```

---

## 🎓 Casos de Uso

### Para Estudiantes Nuevos
- Encontrar rápidamente sus facultades el primer día
- Descubrir ubicaciones de servicios administrativos
- Navegar sin necesidad de preguntar direcciones

### Para Visitantes
- Localizar oficinas específicas sin conocimiento previo
- Explorar el campus de manera autónoma
- Acceder a información de múltiples ubicaciones

### Para Personal Administrativo
- Guiar a visitantes remotamente
- Verificar ubicaciones exactas de dependencias
- Planificar rutas eficientes entre oficinas

---

## 📊 Datos del Proyecto

| Métrica | Valor |
|---------|-------|
| Ubicaciones Mapeadas | 20+ |
| Líneas de Código | ~2,500 |
| Servicios Implementados | 5 |
| Tiempo de Desarrollo | 4 semanas |
| Plataformas Soportadas | Android, iOS |

---

## 🔮 Roadmap Futuro

- [ ] Integración con horarios de clases
- [ ] Notificaciones de eventos en ubicaciones
- [ ] Modo offline con mapas descargables
- [ ] Realidad aumentada para navegación interior
- [ ] Sistema de calificación de rutas
- [ ] Integración con transporte universitario

---

## 👥 Contribuciones

Las contribuciones son bienvenidas. Por favor:

1. Fork el proyecto
2. Crea tu rama de características (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add: nueva característica'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

---

## 📄 Licencia

Este proyecto es un trabajo universitario realizado para la Universidad Nacional Pedro Ruiz Gallo.

---

## 📧 Contacto

**Desarrollador**: Kevin Anthony Campodónico Guevara

**Universidad**: Universidad Nacional Pedro Ruiz Gallo

**Ubicación**: Lambayeque, Perú

---

<div align="center">

**⭐ Si este proyecto te fue útil, considera darle una estrella ⭐**

Hecho con ❤️ para la comunidad UNPRG

</div>

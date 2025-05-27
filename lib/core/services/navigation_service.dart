import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:flutter_tts/flutter_tts.dart';

class NavigationService extends ChangeNotifier {
  final FlutterTts _flutterTts = FlutterTts();
  Timer? _navigationTimer;
  StreamSubscription<LocationData>? _locationSubscription;
  
  // Estado de navegación
  bool _isNavigating = false;
  bool _voiceGuidanceEnabled = true; // Controla si la guía de voz está activa
  double _totalDistance = 0.0;
  double _remainingDistance = 0.0;
  int _estimatedTimeMinutes = 0;
  String _currentInstruction = '';
  LatLng? _currentLocation;
  LatLng? _destination;
  List<LatLng> _routePoints = [];
  int _currentRouteIndex = 0;
  
  // Configuración de navegación
  static const double _proximityThreshold = 20.0; // metros
  static const double _walkingSpeedKmh = 5.0; // velocidad promedio caminando
  static const int _instructionIntervalSeconds = 30; // intervalo entre instrucciones
  
  // Getters
  bool get isNavigating => _isNavigating;
  bool get voiceGuidanceEnabled => _voiceGuidanceEnabled;
  double get totalDistance => _totalDistance;
  double get remainingDistance => _remainingDistance;
  int get estimatedTimeMinutes => _estimatedTimeMinutes;
  String get currentInstruction => _currentInstruction;
  LatLng? get currentLocation => _currentLocation;
  double get progressPercentage => _totalDistance > 0 
      ? ((_totalDistance - _remainingDistance) / _totalDistance) * 100 
      : 0.0;

  NavigationService() {
    _initializeTts();
  }

  /// Inicializa el servicio de texto a voz
  Future<void> _initializeTts() async {
    try {
      await _flutterTts.setLanguage('es-ES');
      await _flutterTts.setSpeechRate(0.6);
      await _flutterTts.setVolume(0.8);
      await _flutterTts.setPitch(1.0);
      
      // Configurar callbacks del TTS
      _flutterTts.setErrorHandler((msg) {
        debugPrint('Error TTS: $msg');
      });
      
      _flutterTts.setCompletionHandler(() {
        debugPrint('TTS completado');
      });
    } catch (e) {
      debugPrint('Error al inicializar TTS: $e');
    }
  }

  /// Inicia la navegación hacia un destino
  Future<void> startNavigation({
    required LatLng destination,
    required List<LatLng> routePoints,
    required LocationData currentLocationData,
  }) async {
    try {
      _destination = destination;
      _routePoints = routePoints;
      _currentLocation = LatLng(
        currentLocationData.latitude!,
        currentLocationData.longitude!,
      );
      _currentRouteIndex = 0;
      
      // Calcular distancia total
      _totalDistance = _calculateRouteDistance(_routePoints);
      _remainingDistance = _totalDistance;
      
      // Calcular tiempo estimado
      _estimatedTimeMinutes = (_totalDistance / 1000 * 60 / _walkingSpeedKmh).round();
      
      _isNavigating = true;
      
      // Instrucción inicial
      _currentInstruction = 'Navegación iniciada. Sigue la ruta marcada.';
      await _speak(_currentInstruction);
      
      // Iniciar timer para actualizaciones periódicas
      _startNavigationTimer();
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error al iniciar navegación: $e');
    }
  }

  /// Actualiza la ubicación actual durante la navegación
  void updateCurrentLocation(LocationData locationData) {
    if (!_isNavigating || locationData.latitude == null || locationData.longitude == null) {
      return;
    }

    _currentLocation = LatLng(locationData.latitude!, locationData.longitude!);
    
    // Calcular distancia restante
    _remainingDistance = _calculateDistanceToDestination();
    
    // Actualizar tiempo estimado
    _estimatedTimeMinutes = (_remainingDistance / 1000 * 60 / _walkingSpeedKmh).round();
    
    // Verificar si llegó al destino
    if (_remainingDistance < _proximityThreshold) {
      _arriveAtDestination();
      return;
    }
    
    // Verificar proximidad a puntos de la ruta para dar instrucciones
    _checkRouteProgress();
    
    notifyListeners();
  }

  /// Inicia el timer para actualizaciones periódicas de navegación
  void _startNavigationTimer() {
    _navigationTimer?.cancel(); // Asegurar que no haya timers duplicados
    _navigationTimer = Timer.periodic(
      Duration(seconds: _instructionIntervalSeconds),
      (timer) {
        if (_isNavigating && _remainingDistance > _proximityThreshold) {
          _givePeriodicInstruction();
        } else if (!_isNavigating) {
          timer.cancel();
        }
      },
    );
  }

  /// Da instrucciones periódicas durante la navegación
  void _givePeriodicInstruction() {
    if (!_voiceGuidanceEnabled) return;
    
    String instruction;
    if (_remainingDistance > 1000) {
      instruction = 'Continúa por ${(_remainingDistance / 1000).toStringAsFixed(1)} kilómetros. '
          'Tiempo estimado: ${formatTime(_estimatedTimeMinutes)}.';
    } else {
      instruction = 'Continúa por ${_remainingDistance.toInt()} metros. '
          'Tiempo estimado: ${formatTime(_estimatedTimeMinutes)}.';
    }
    
    _currentInstruction = instruction;
    _speak(_currentInstruction);
    notifyListeners();
  }

  /// Verifica el progreso en la ruta y da instrucciones específicas
  void _checkRouteProgress() {
    if (_currentLocation == null || _routePoints.isEmpty) return;
    
    // Encontrar el punto más cercano en la ruta
    double minDistance = double.infinity;
    int nearestIndex = _currentRouteIndex;
    
    for (int i = _currentRouteIndex; i < _routePoints.length; i++) {
      final distance = _calculateDistance(_currentLocation!, _routePoints[i]);
      if (distance < minDistance) {
        minDistance = distance;
        nearestIndex = i;
      }
    }
    
    // Si hemos avanzado significativamente en la ruta
    if (nearestIndex > _currentRouteIndex + 3) { // Reducido de 5 a 3 para más responsividad
      _currentRouteIndex = nearestIndex;
      _giveDirectionInstruction();
    }
  }

  /// Da instrucciones de dirección basadas en la posición en la ruta
  void _giveDirectionInstruction() {
    if (_currentRouteIndex >= _routePoints.length - 1 || !_voiceGuidanceEnabled) return;
    
    final currentPoint = _routePoints[_currentRouteIndex];
    final nextPoint = _routePoints[min(_currentRouteIndex + 1, _routePoints.length - 1)];
    
    // Calcular dirección aproximada
    final bearing = _calculateBearing(currentPoint, nextPoint);
    final direction = _getDirectionFromBearing(bearing);
    
    final distanceToNext = _calculateDistance(currentPoint, nextPoint);
    
    if (distanceToNext > 30) { // Reducido de 50 a 30 metros
      _currentInstruction = 'En ${distanceToNext.toInt()} metros, $direction.';
      _speak(_currentInstruction);
      notifyListeners();
    }
  }

  /// Maneja la llegada al destino
  void _arriveAtDestination() {
    _currentInstruction = '¡Felicitaciones! Has llegado a tu destino.';
    _speak(_currentInstruction);
    
    // Esperar un poco antes de detener completamente la navegación
    Future.delayed(const Duration(seconds: 3), () {
      stopNavigation();
    });
  }

  /// Detiene la navegación
  void stopNavigation() {
    debugPrint('Deteniendo navegación...');
    
    // Detener TTS inmediatamente
    _flutterTts.stop();
    
    // Cancelar timer
    _navigationTimer?.cancel();
    _navigationTimer = null;
    
    // Cancelar suscripción de ubicación si existe
    _locationSubscription?.cancel();
    _locationSubscription = null;
    
    // Resetear estado
    _isNavigating = false;
    _totalDistance = 0.0;
    _remainingDistance = 0.0;
    _estimatedTimeMinutes = 0;
    _currentInstruction = '';
    _currentRouteIndex = 0;
    _destination = null;
    _routePoints.clear();
    _currentLocation = null;
    
    notifyListeners();
    debugPrint('Navegación detenida exitosamente');
  }

  /// Pausa o reanuda la guía de voz
  void toggleVoiceGuidance() {
    _voiceGuidanceEnabled = !_voiceGuidanceEnabled;
    
    if (_voiceGuidanceEnabled) {
      _currentInstruction = 'Guía de voz activada.';
      _speak(_currentInstruction);
      debugPrint('Guía de voz activada');
    } else {
      // Detener cualquier reproducción en curso
      _flutterTts.stop();
      _currentInstruction = 'Guía de voz desactivada.';
      debugPrint('Guía de voz desactivada');
    }
    
    notifyListeners();
  }

  /// Reproduce texto usando TTS solo si la guía de voz está habilitada
  Future<void> _speak(String text) async {
    if (!_voiceGuidanceEnabled || text.isEmpty) return;
    
    try {
      await _flutterTts.speak(text);
    } catch (e) {
      debugPrint('Error en TTS: $e');
    }
  }

  /// Calcula la distancia total de una ruta
  double _calculateRouteDistance(List<LatLng> points) {
    if (points.length < 2) return 0.0;
    
    double totalDistance = 0.0;
    for (int i = 0; i < points.length - 1; i++) {
      totalDistance += _calculateDistance(points[i], points[i + 1]);
    }
    return totalDistance;
  }

  /// Calcula la distancia restante hasta el destino
  double _calculateDistanceToDestination() {
    if (_currentLocation == null || _destination == null) return 0.0;
    return _calculateDistance(_currentLocation!, _destination!);
  }

  /// Calcula la distancia entre dos puntos usando la fórmula de Haversine
  double _calculateDistance(LatLng point1, LatLng point2) {
    const double earthRadius = 6371000; // Radio de la Tierra en metros
    
    final double lat1Rad = point1.latitude * (pi / 180);
    final double lat2Rad = point2.latitude * (pi / 180);
    final double deltaLatRad = (point2.latitude - point1.latitude) * (pi / 180);
    final double deltaLngRad = (point2.longitude - point1.longitude) * (pi / 180);
    
    final double a = sin(deltaLatRad / 2) * sin(deltaLatRad / 2) +
        cos(lat1Rad) * cos(lat2Rad) *
        sin(deltaLngRad / 2) * sin(deltaLngRad / 2);
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    
    return earthRadius * c;
  }

  /// Calcula el bearing (rumbo) entre dos puntos
  double _calculateBearing(LatLng point1, LatLng point2) {
    final double lat1Rad = point1.latitude * (pi / 180);
    final double lat2Rad = point2.latitude * (pi / 180);
    final double deltaLngRad = (point2.longitude - point1.longitude) * (pi / 180);
    
    final double y = sin(deltaLngRad) * cos(lat2Rad);
    final double x = cos(lat1Rad) * sin(lat2Rad) - sin(lat1Rad) * cos(lat2Rad) * cos(deltaLngRad);
    
    final double bearing = atan2(y, x) * (180 / pi);
    return (bearing + 360) % 360;
  }

  /// Convierte un bearing en instrucciones de dirección
  String _getDirectionFromBearing(double bearing) {
    if (bearing >= 337.5 || bearing < 22.5) return 'continúa recto';
    if (bearing >= 22.5 && bearing < 67.5) return 'gira ligeramente a la derecha';
    if (bearing >= 67.5 && bearing < 112.5) return 'gira a la derecha';
    if (bearing >= 112.5 && bearing < 157.5) return 'gira completamente a la derecha';
    if (bearing >= 157.5 && bearing < 202.5) return 'da la vuelta';
    if (bearing >= 202.5 && bearing < 247.5) return 'gira completamente a la izquierda';
    if (bearing >= 247.5 && bearing < 292.5) return 'gira a la izquierda';
    if (bearing >= 292.5 && bearing < 337.5) return 'gira ligeramente a la izquierda';
    return 'continúa';
  }

  /// Formatea la distancia para mostrar
  String formatDistance(double distanceInMeters) {
    if (distanceInMeters >= 1000) {
      return '${(distanceInMeters / 1000).toStringAsFixed(1)} km';
    } else {
      return '${distanceInMeters.toInt()} m';
    }
  }

  /// Formatea el tiempo para mostrar
  String formatTime(int minutes) {
     if (minutes >= 60) {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      if (remainingMinutes == 0) {
        return '${hours}h';
      }
      return '${hours}h ${remainingMinutes}min';
    } else {
      return '${minutes}min';
    }
  }

  /// Obtiene el estado actual de la navegación como un resumen
  Map<String, dynamic> getCurrentNavigationState() {
    return {
      'isNavigating': _isNavigating,
      'voiceEnabled': _voiceGuidanceEnabled,
      'totalDistance': formatDistance(_totalDistance),
      'remainingDistance': formatDistance(_remainingDistance),
      'estimatedTime': formatTime(_estimatedTimeMinutes),
      'progress': progressPercentage,
      'currentInstruction': _currentInstruction,
    };
  }

  /// Reinicia la navegación con nueva configuración
  Future<void> restartNavigation() async {
    if (_destination != null && _currentLocation != null) {
      final currentLocationData = LocationData.fromMap({
        'latitude': _currentLocation!.latitude,
        'longitude': _currentLocation!.longitude,
      });
      
      stopNavigation();
      
      await Future.delayed(const Duration(milliseconds: 500));
      
      await startNavigation(
        destination: _destination!,
        routePoints: _routePoints,
        currentLocationData: currentLocationData,
      );
    }
  }

  @override
  void dispose() {
    debugPrint('Disposing NavigationService...');
    stopNavigation();
    _flutterTts.stop();
    _locationSubscription?.cancel();
    super.dispose();
  }
}
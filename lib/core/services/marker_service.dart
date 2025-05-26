import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:unprg_guide_maps/core/constants/app_colors.dart';

/// Servicio de creación de marcadores con etiqueta visible (sigla) integrada en el icono
class MarkerService {
  BitmapDescriptor? _defaultLocationIcon;
  BitmapDescriptor? _selectedLocationIcon;
  BitmapDescriptor? _userLocationIcon;

  bool get isInitialized =>
      _defaultLocationIcon != null &&
      _selectedLocationIcon != null &&
      _userLocationIcon != null;

  Future<void> initialize() async {
    if (isInitialized) return;

    await Future.wait([
      // Se inicializa un icono genérico, luego se generarán dinámicamente con texto
      _createLocationMarkerBitmap(false)
          .then((icon) => _defaultLocationIcon = icon),
      _createLocationMarkerBitmap(true)
          .then((icon) => _selectedLocationIcon = icon),
      _createUserLocationMarkerBitmap()
          .then((icon) => _userLocationIcon = icon),
    ]);
  }

  /// Crea un BitmapDescriptor para un marcador de ubicación, dibujando la sigla centrada
  Future<BitmapDescriptor> _createLocationMarkerWithLabel(
      String sigla, bool isSelected) async {
    final markerSize = 50.0;
    final textPadding = 8.0;
    final totalWidth = 150.0;
    final totalHeight = 80.0;

    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);

    // Configurar el texto
    final textStyle = ui.TextStyle(
      color: isSelected ? AppColors.warning : AppColors.primary,
      fontSize: isSelected ? 20.0 : 16.0,
      fontWeight: FontWeight.bold,
    );

    final paragraphStyle = ui.ParagraphStyle(
      textAlign: TextAlign.left,
      fontSize: isSelected ? 20.0 : 16.0,
      fontWeight: FontWeight.bold,
      maxLines: 1,
      textDirection: ui.TextDirection.ltr,
    );

    final builder = ui.ParagraphBuilder(paragraphStyle)
      ..pushStyle(textStyle)
      ..addText(sigla);

    final paragraph = builder.build();
    paragraph.layout(ui.ParagraphConstraints(width: totalWidth));

    // Posición del marcador (centrado verticalmente)
    final markerX = 10.0;
    final markerY = (totalHeight - markerSize) / 2;
    final markerCenter = Offset(markerX + markerSize / 2, markerY + markerSize / 2);

    // Sombra del marcador
    final markerShadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(
      Offset(markerCenter.dx + 1, markerCenter.dy + 1),
      markerSize / 2 - 2,
      markerShadowPaint,
    );

    // Marcador principal
    final markerPaint = Paint()
      ..color = isSelected ? AppColors.warning : AppColors.primary
      ..style = PaintingStyle.fill;
    canvas.drawCircle(markerCenter, markerSize / 2 - 2, markerPaint);

    // Borde blanco del marcador
    final markerBorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(markerCenter, markerSize / 2 - 2, markerBorderPaint);

    // Círculo interior blanco
    final innerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(markerCenter, markerSize / 3, innerPaint);

    // Punto central
    final centerPaint = Paint()
      ..color = isSelected ? AppColors.warning : AppColors.primary
      ..style = PaintingStyle.fill;
    canvas.drawCircle(markerCenter, markerSize / 6, centerPaint);

    // Dibujar el texto al costado del marcador (con sombra para mejor legibilidad)
    final textX = markerX + markerSize + textPadding;
    final textY = markerY + (markerSize - paragraph.height) / 2;
    
    // Sombra del texto
    final shadowTextStyle = ui.TextStyle(
      color: Colors.black.withOpacity(0.3),
      fontSize: isSelected ? 20.0 : 16.0,
      fontWeight: FontWeight.bold,
    );
    
    final shadowBuilder = ui.ParagraphBuilder(paragraphStyle)
      ..pushStyle(shadowTextStyle)
      ..addText(sigla);
    
    final shadowParagraph = shadowBuilder.build();
    shadowParagraph.layout(ui.ParagraphConstraints(width: totalWidth));
    canvas.drawParagraph(shadowParagraph, Offset(textX + 1, textY + 1));
    
    // Texto principal
    canvas.drawParagraph(paragraph, Offset(textX, textY));

    // Convertir a imagen
    final img = await pictureRecorder
        .endRecording()
        .toImage(totalWidth.toInt(), totalHeight.toInt());

    final data = await img.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.fromBytes(data!.buffer.asUint8List());
  }

  // Create a custom location marker bitmap (versión original sin label)
  Future<BitmapDescriptor> _createLocationMarkerBitmap(bool isSelected) async {
    final size = isSelected ? 120.0 : 100.0;
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    final paint = Paint()
      ..color = isSelected ? AppColors.warning : AppColors.primary;

    // Draw the shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(
        Offset(size / 2, size / 2 + 2), size / 2 - 12, shadowPaint);

    // Draw the main circle
    canvas.drawCircle(Offset(size / 2, size / 2), size / 2 - 12, paint);

    // Draw the inner circle (white)
    final innerPaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(size / 2, size / 2), size / 3 - 6, innerPaint);

    // Draw the dot in the center
    final centerPaint = Paint()
      ..color = isSelected ? AppColors.accent : AppColors.primary;
    canvas.drawCircle(Offset(size / 2, size / 2), size / 6, centerPaint);

    // Draw the pointer at the bottom
    final path = Path();
    path.moveTo(size / 2, size - 10);
    path.lineTo(size / 2 - 10, size / 2 + 10);
    path.lineTo(size / 2 + 10, size / 2 + 10);
    path.close();
    canvas.drawPath(path, paint);

    // Convert to an image
    final img = await pictureRecorder
        .endRecording()
        .toImage(size.toInt(), size.toInt());
    final data = await img.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.fromBytes(data!.buffer.asUint8List());
  }

  // Create a custom user location marker bitmap
  Future<BitmapDescriptor> _createUserLocationMarkerBitmap() async {
    const size = 100.0;
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);

    // Draw the outer circle (transparent blue)
    final outerPaint = Paint()
      ..color = Colors.blue.withOpacity(0.2)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
        const Offset(size / 2, size / 2), size / 2 - 10, outerPaint);

    // Draw the middle circle
    final middlePaint = Paint()
      ..color = Colors.blue.withOpacity(0.5)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(size / 2, size / 2), size / 3, middlePaint);

    // Draw the inner circle
    final innerPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(size / 2, size / 2), size / 5, innerPaint);

    // Draw the white dot in the center
    final centerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(size / 2, size / 2), size / 10, centerPaint);

    // Convert to an image
    final img = await pictureRecorder
        .endRecording()
        .toImage(size.toInt(), size.toInt());
    final data = await img.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.fromBytes(data!.buffer.asUint8List());
  }

  // Método actualizado para crear marcadores con labels
  Future<Marker> createLocationMarkerWithLabel(
      String id, LatLng position, String snippet, bool isSelected,
      {required Function() onTap}) async {
    final icon = await _createLocationMarkerWithLabel(id, isSelected);

    return Marker(
      markerId: MarkerId(id),
      position: position,
      icon: icon,
      anchor:
          const Offset(0.5, 1.0), // Anclar desde la parte inferior del marcador
      onTap: onTap,
    );
  }

  Future<Marker> createLocationMarker(
      String id, LatLng position, String snippet, bool isSelected,
      {required Function() onTap}) async {
    if (!isInitialized) await initialize();

    return Marker(
      markerId: MarkerId(id),
      position: position,
      icon: isSelected ? _selectedLocationIcon! : _defaultLocationIcon!,
      infoWindow: InfoWindow(
        title: id,
        snippet: snippet,
      ),
      onTap: onTap,
    );
  }

  Future<Marker> createUserLocationMarker(LatLng position,
      {required Function() onTap}) async {
    if (!isInitialized) await initialize();

    return Marker(
      markerId: const MarkerId("my_location"),
      position: position,
      icon: _userLocationIcon!,
      infoWindow: const InfoWindow(title: "Mi ubicación"),
      onTap: onTap,
    );
  }

  Future<Set<Marker>> updateMarkerSelections(
      Set<Marker> markers, String selectedTitle, String defaultTitle) async {
    if (!isInitialized) await initialize();

    final updatedMarkers = <Marker>{};

    for (final marker in markers) {
      // Skip the user location marker
      if (marker.markerId.value == "my_location") {
        updatedMarkers.add(marker);
        continue;
      }

      final bool isSelected = marker.markerId.value == selectedTitle ||
          (marker.markerId.value == defaultTitle &&
              selectedTitle == defaultTitle);

      updatedMarkers.add(
        marker.copyWith(
          iconParam: isSelected ? _selectedLocationIcon : _defaultLocationIcon,
        ),
      );
    }

    return updatedMarkers;
  }

  Future<void> setMapStyle(GoogleMapController controller) async {
    // Estilo que oculta puntos de interés, etiquetas y otros elementos del mapa
    const String mapStyle = '''
    [
      {
        "featureType": "poi",
        "stylers": [
          {
            "visibility": "off"
          }
        ]
      },
      {
        "featureType": "poi.park",
        "stylers": [
          {
            "visibility": "on"
          }
        ]
      },
      {
        "featureType": "transit",
        "stylers": [
          {
            "visibility": "off"
          }
        ]
      },
      {
        "featureType": "road",
        "elementType": "labels.icon",
        "stylers": [
          {
            "visibility": "off"
          }
        ]
      },
      {
        "featureType": "landscape.man_made",
        "elementType": "labels",
        "stylers": [
          {
            "visibility": "off"
          }
        ]
      }
    ]
    ''';

    await controller.setMapStyle(mapStyle);
  }
}

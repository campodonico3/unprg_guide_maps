import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:unprg_guide_maps/core/constants/app_colors.dart';
import 'package:unprg_guide_maps/core/constants/app_style.dart';
import 'package:unprg_guide_maps/data/models/faculty_item.dart';

class FlutterMapPage extends StatefulWidget {
  final String? title;
  final String? sigla;
  final double initialLatitude;
  final double initialLongitude;
  final List<FacultyItem>?
      locations; // Nueva propiedad para recibir los marcadores

  const FlutterMapPage({
    super.key,
    this.title,
    this.sigla,
    this.initialLatitude = -6.70749760689037,
    this.initialLongitude = -79.90452516138711,
    this.locations, // Lista de ubicaciones a mostrar
  });

  @override
  State<FlutterMapPage> createState() => _FlutterMapPageState();
}

class _FlutterMapPageState extends State<FlutterMapPage> {
  late final LatLng _center;
  final double _initialZoom = 18.0;

  final MapController _mapController = MapController();

  // Track if a marker is selected to show the bottom card
  bool _isMarkerSelected = false;
  String _selectedTitle = '';
  String _selectedSigla = '';

  // Nuevo: Rastrea la posición del marcador seleccionado
  LatLng? _selectedMarkerPosition;

  bool _isCardExpanded = false;
  final double _collapsedCardHeight = 120.0;
  final double _expandedCardHeight = 665.0;

  @override
  void initState() {
    super.initState();
    _center = LatLng(
      widget.initialLatitude,
      widget.initialLongitude,
    );

    // Initialize with the widget's title if provided
    if (widget.title != null) {
      _selectedTitle = widget.title!;
      _selectedSigla = widget.sigla ?? '';
      _isMarkerSelected = true;
      // Establecer la posición del marcador seleccionado
      _selectedMarkerPosition = _center;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(
          'Mapa del Campus',
          style: AppTextStyles.medium.copyWith(
            fontSize: 21,
            color: AppColors.textOnPrimary,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: AppColors.textOnPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: _center,
          initialZoom: _initialZoom,
          maxZoom: 18.0,
          minZoom: 12.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.unprg_guide_maps',
            maxZoom: 19,
          ),
          MarkerLayer(
            markers: widget.locations != null && widget.locations!.isNotEmpty
                ? widget.locations!.map((location) {
                    return _buildMarker(
                      LatLng(
                          location.latitude ?? 0.0, location.longitude ?? 0.0),
                      location.name,
                      location.sigla,
                    );
                  }).toList()
                : [
                    _buildMarker(
                      _center,
                      widget.sigla ?? "Campus Principal",
                      widget.title,
                    ),
                  ],
          ),

          // Bottom card overlay when a marker is selected
          if (_isMarkerSelected)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildLocationInfoCard(),
            ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(
            width: 45,
            height: 45,
            child: FloatingActionButton(
              heroTag: "zoom_in",
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add, color: Colors.white),
              onPressed: () {
                final newZoom = _mapController.camera.zoom + 1;
                _mapController.move(_mapController.camera.center, newZoom);
              },
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 45,
            height: 45,
            child: FloatingActionButton(
              heroTag: "zoom_out",
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.remove, color: Colors.white),
              onPressed: () {
                final newZoom = _mapController.camera.zoom - 1;
                _mapController.move(_mapController.camera.center, newZoom);
              },
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 45,
            height: 45,
            child: FloatingActionButton(
              heroTag: "my_location",
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.my_location, color: Colors.white),
              onPressed: () {
                _mapController.move(_center, _initialZoom);
              },
            ),
          ),
          // Add padding when the card is displayed
          if (_isMarkerSelected) const SizedBox(height: 130),
        ],
      ),
    );
  }

  Marker _buildMarker(LatLng position, String title, String? sigla) {
    // Verificar si la posición es válida
    if (position.latitude == 0.0 && position.longitude == 0.0) {
      return const Marker(
        width: 0,
        height: 0,
        point: LatLng(0, 0),
        child: SizedBox.shrink(),
      );
    }
    // Verifica si este marcador es el seleccionado
    bool isSelected = _selectedMarkerPosition != null &&
        _selectedMarkerPosition!.latitude == position.latitude &&
        _selectedMarkerPosition!.longitude == position.longitude;
    // Crear el marcador con la posición y el título
    return Marker(
      width: 80.0,
      height: 80.0,
      point: position,
      child: GestureDetector(
        onTap: () {
          setState(() {
            _isMarkerSelected = true;
            _selectedTitle = title;
            _selectedSigla = sigla ?? '';
            // Actualizar la posición del marcador seleccionado
            _selectedMarkerPosition = position;
          });

          /*ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(title),
              duration: const Duration(seconds: 2),
            ),
          );*/
        },
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.neutral,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(
                Icons.location_on,
                color: Colors.white,
                size: 24,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isSelected ? AppColors.primary : AppColors.neutral,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationInfoCard() {
    return GestureDetector(
      // Detectar el gesto de deslizamiento hacia abajo
      onVerticalDragEnd: (details) {
        // Si el gesto fue hacia abajo con suficiente velocidad
        if (details.primaryVelocity != null && details.primaryVelocity! > 300) {
          setState(() {
            if (_isCardExpanded) {
              // Si está expandida, primero la contraemos
              _isCardExpanded = false;
            } else {
              // Si está contraída, la ocultamos y limpiamos la selección
              _isMarkerSelected = false;
              _selectedMarkerPosition = null;
            }
          });
        } else if (details.primaryVelocity != null &&
            details.primaryVelocity! < -300) {
          // Si el gesto fue hacia arriba con suficiente velocidad
          setState(() {
            _isCardExpanded = true; // Expandir la tarjeta
          });
        }
      },
      child: Container(
        // Altura dinámica según si está expandida o no
        height: _isCardExpanded ? _expandedCardHeight : _collapsedCardHeight,
        margin: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            // Indicador visual de arrastre
            Container(
              width: 50,
              height: 3,
              margin: EdgeInsets.only(top: 6, bottom: 2),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            //Contenido de la tarjeta
            Expanded(
              child: Row(
                children: [
                  // Left side - Image
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        bottomLeft: Radius.circular(15),
                      ),
                      image: DecorationImage(
                        image: AssetImage(
                            'assets/images/facultades/img_ing_ficsa_logo.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  // Si la tarjeta está contraída, mostramos la vista resumen
                  if (!_isCardExpanded) _buildCollapsedCardContent(),

                  // Si la tarjeta está expandida, mostramos el contenido detallado
                  if (_isCardExpanded) _buildExpandedCardContent(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Vista contraída
  Widget _buildCollapsedCardContent() {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Title
            Text(
              _selectedTitle,
              style: AppTextStyles.bold.copyWith(
                fontSize: 12,
                color: AppColors.primary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 4),
            // Sigla
            Text(
              _selectedSigla.isNotEmpty
                  ? 'Código: $_selectedSigla'
                  : 'Campus principal',
              style: AppTextStyles.regular.copyWith(
                fontSize: 10,
                color: AppColors.textSecondary,
              ),
            ),

            // Additional info like address, hours, etc. could be added here
            if (_selectedTitle.contains('Facultad'))
              Text(
                'Edificio académico',
                style: AppTextStyles.regular.copyWith(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Vista expandida (la original)
  Widget _buildExpandedCardContent() {
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedTitle,
                    style: AppTextStyles.black.copyWith(
                      fontSize: 16,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(height: 4,),
                  Text(
                    _selectedSigla.isNotEmpty
                      ? 'Código: $_selectedSigla'
                      : 'Campus principal',
                      style: AppTextStyles.regular.copyWith(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                  ),
                ],
              ),
            ),
            // Imágenes de la facultad (carrusel horizontal)
            SizedBox(
              height: 150,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  _buildFacultyImage('assets/images/facultades/img_ing_ficsa_logo.png'),
                  const SizedBox(width: 8),
                  _buildFacultyImage('assets/images/img_presentacion_1.png'),
                  const SizedBox(width: 8),
                  _buildFacultyImage('assets/images/img_presentacion_2.png'),
                ],
              ),
            ),
            
            // Información detallada
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    'Información',
                    style: AppTextStyles.bold.copyWith(
                      fontSize: 14,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Información adicional sobre la facultad
                  _buildInfoRow(Icons.access_time, 'Horario: 7:00 AM - 6:00 PM'),
                  _buildInfoRow(Icons.phone, 'Teléfono: (074) 481610'),
                  _buildInfoRow(Icons.mail, 'Email: ${_selectedSigla.toLowerCase()}@unprg.edu.pe'),
                  
                  if (_selectedTitle.contains('Facultad'))
                    _buildInfoRow(Icons.school, 'Tipo: Edificio académico'),
                    
                  const SizedBox(height: 16),
                  Text(
                    'Descripción',
                    style: AppTextStyles.bold.copyWith(
                      fontSize: 14,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Esta es una descripción detallada de ${_selectedTitle}. Aquí puedes incluir información sobre su historia, propósito, servicios ofrecidos, personal, etc.',
                    style: AppTextStyles.regular.copyWith(
                      fontSize: 12,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFacultyImage(String imagePath){
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.asset(
        imagePath,
        width: 200,
        height: 150,
        fit: BoxFit.cover,
      ),
    );
  }

  // Widget para crear filas de información con icono
  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: AppColors.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.regular.copyWith(
                fontSize: 12,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Helper method to get appropriate image based on location title
  /*String _getImageForLocation(){
  // Default image
  String imagePath = 'assets/images/presentacion1.png';

  // For faculties, try to use their specific logo if avaliable based on sigla
  if(_selectedSigla.isNotEmpty){
    // Convert to lowercase to be safe with file naming
    imagePath = 'assets/images/facultades/img_${_selectedSigla.toLowerCase()}_logo.png';
  }
  return imagePath;
  }*/

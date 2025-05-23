import 'package:flutter/material.dart';
import 'package:unprg_guide_maps/core/constants/app_colors.dart';

class InfoCard extends StatefulWidget {
  final String? sigla;
  final String? name;
  final double latitude;
  final double longitude;
  final VoidCallback onClose;

  const InfoCard({
    super.key,
    this.sigla,
    this.name,
    required this.latitude,
    required this.longitude,
    required this.onClose,
  });

  @override
  State<InfoCard> createState() => _InfoCardState();
}

class _InfoCardState extends State<InfoCard> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _heightAnimation;

  // Variables para el drag progresivo
  double _dragProgress = 0.0; // 0.0 = colapsado, 1.0 = expandido
  bool _isDragging = false;
  double _initialDragY = 0.0;

  // Constantes para el comportamiento del drag
  static const double _dragThreshold = 50.0;
  static const double _velocityThreshold = 300.0;
  static const Duration _animationDuration = Duration(milliseconds: 300);

  // Alturas de la card
  late double _collapsedHeight;
  late double _expandedHeight;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: _animationDuration,
      vsync: this,
    );

    _heightAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    ));

    // Listener para actualizar el progreso durante animaciones automáticas
    _animationController.addListener(() {
      if (!_isDragging) {
        setState(() {
          _dragProgress = _animationController.value;
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _calculateHeights();
  }

  void _calculateHeights() {
    final screenHeight = MediaQuery.of(context).size.height;
    _collapsedHeight = 140.0;
    _expandedHeight = screenHeight * 0.85;
  }

  void _handleDragStart(DragStartDetails details) {
    _animationController.stop();
    _isDragging = true;
    _initialDragY = details.globalPosition.dy;
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (!_isDragging) return;

    final currentY = details.globalPosition.dy;
    final deltaY = _initialDragY - currentY; // Positivo hacia arriba
    final maxDragDistance = _expandedHeight - _collapsedHeight;
    
    // Calcular el progreso basado en el movimiento del dedo
    double newProgress = _dragProgress + (deltaY / maxDragDistance);
    newProgress = newProgress.clamp(0.0, 1.0);

    setState(() {
      _dragProgress = newProgress;
    });

    // Actualizar la posición inicial para el siguiente frame
    _initialDragY = currentY;
  }

  void _handleDragEnd(DragEndDetails details) {
    _isDragging = false;
    final velocity = details.velocity.pixelsPerSecond.dy;

    // Determinar si debe expandirse o colapsarse basado en el progreso actual y velocidad
    bool shouldExpand;
    
    if (velocity.abs() > _velocityThreshold) {
      shouldExpand = velocity < 0; // Velocidad hacia arriba
    } else {
      shouldExpand = _dragProgress > 0.5; // Más del 50% expandido
    }

    if (shouldExpand) {
      _expandCard();
    } else {
      _collapseCard();
    }
  }

  void _expandCard() {
    setState(() => _isExpanded = true);
    _animationController.animateTo(1.0).then((_) {
      if (mounted) {
        setState(() {
          _dragProgress = 1.0;
        });
      }
    });
  }

  void _collapseCard() {
    setState(() => _isExpanded = false);
    _animationController.animateTo(0.0).then((_) {
      if (mounted) {
        setState(() {
          _dragProgress = 0.0;
        });
      }
    });
  }

  void _closeCard() {
    widget.onClose();
  }

  void _toggleExpansion() {
    if (_isExpanded) {
      _collapseCard();
    } else {
      _expandCard();
    }
  }

  // Función para calcular la opacidad del contenido expandido
  double _getExpandedContentOpacity() {
    // El contenido expandido empieza a aparecer cuando el progreso es > 0.3
    if (_dragProgress <= 0.3) return 0.0;
    if (_dragProgress >= 0.8) return 1.0;
    
    // Transición suave entre 0.3 y 0.8
    return ((_dragProgress - 0.3) / 0.5).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragStart: _handleDragStart,
      onVerticalDragUpdate: _handleDragUpdate,
      onVerticalDragEnd: _handleDragEnd,
      onTap: _toggleExpansion,
      child: AnimatedContainer(
        duration: _isDragging ? Duration.zero : _animationDuration,
        curve: Curves.easeInOutCubic,
        height: _collapsedHeight + (_expandedHeight - _collapsedHeight) * _dragProgress,
        child: Card(
          elevation: 8,
          margin: EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.background,
              ),
              child: Column(
                children: [
                  _buildDragHandle(),
                  const SizedBox(height: 2),
                  Expanded(
                    child: _buildContent(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDragHandle() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16, top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          /* const SizedBox(height: 16),
          _buildLocationInfo(),
          const SizedBox(height: 16),
          _buildActionButton(context),
          // Contenido expandido con opacidad progresiva
          AnimatedOpacity(
            opacity: _getExpandedContentOpacity(),
            duration: _isDragging ? Duration.zero : Duration(milliseconds: 150),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                _buildExpandedContent(),
              ],
            ),
          ), */
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        _buildLocationImage(),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.sigla != null)
                Text(
                  widget.sigla!,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              if (widget.name != null) ...[
                const SizedBox(height: 4),
                Text(
                  widget.name!,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryLight,
                  ),
                  maxLines: _dragProgress > 0.5 ? null : 2,
                  overflow: _dragProgress > 0.5 ? null : TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLocationInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.location_on,
            color: AppColors.primary,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Lat: ${widget.latitude.toStringAsFixed(6)}, Lng: ${widget.longitude.toStringAsFixed(6)}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _handleNavigationPressed,
        icon: const Icon(Icons.navigation, size: 20),
        label: const Text(
          'Iniciar navegación',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
      ),
    );
  }

  Widget _buildExpandedContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Información adicional'),
        const SizedBox(height: 12),
        _buildInfoRow('Coordenadas', '${widget.latitude}, ${widget.longitude}'),
        _buildInfoRow('Código', widget.sigla ?? 'N/A'),
        _buildInfoRow('Nombre completo', widget.name ?? 'N/A'),
        const SizedBox(height: 20),
        _buildSectionTitle('Acciones rápidas'),
        const SizedBox(height: 12),
        _buildQuickActions(),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildQuickActionChip(
          icon: Icons.share,
          label: 'Compartir',
          onPressed: _handleSharePressed,
        ),
        _buildQuickActionChip(
          icon: Icons.favorite_border,
          label: 'Favorito',
          onPressed: _handleFavoritePressed,
        ),
        _buildQuickActionChip(
          icon: Icons.info_outline,
          label: 'Más info',
          onPressed: _handleMoreInfoPressed,
        ),
      ],
    );
  }

  Widget _buildQuickActionChip({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ActionChip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
      onPressed: onPressed,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  Widget _buildLocationImage() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        image: widget.sigla != null
            ? DecorationImage(
                image: AssetImage(
                  'assets/images/facultades/img_${widget.sigla!.toLowerCase()}_logo.png',
                ),
                fit: BoxFit.cover,
                onError: (exception, stackTrace) {
                  // Manejar error de imagen
                },
              )
            : null,
      ),
      child: widget.sigla == null
          ? Icon(
              Icons.location_on,
              color: AppColors.primary,
              size: 30,
            )
          : null,
    );
  }

  // Métodos de manejo de eventos
  void _handleNavigationPressed() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Obteniendo direcciones...'),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _handleSharePressed() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Compartir ubicación')),
    );
  }

  void _handleFavoritePressed() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Agregado a favoritos')),
    );
  }

  void _handleMoreInfoPressed() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Más información')),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
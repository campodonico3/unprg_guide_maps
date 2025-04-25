import 'package:flutter/material.dart';
import 'package:unprg_guide_maps/core/constants/app_colors.dart';
import 'package:unprg_guide_maps/core/constants/app_style.dart';
import 'package:unprg_guide_maps/core/constants/map_constants.dart';
import 'package:unprg_guide_maps/presentation/pages/map/widgets/faculty_image.dart';
import 'package:unprg_guide_maps/presentation/pages/map/widgets/info_row.dart';

class LocationInfoCard extends StatelessWidget {
  final bool isExpanded;
  final String title;
  final String sigla;
  final Function(bool) onCardStateChanged;

  const LocationInfoCard({
    super.key,
    required this.isExpanded,
    required this.title,
    required this.sigla,
    required this.onCardStateChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragEnd: (details) => _handleDragGesture(details),
      child: AnimatedContainer(
        duration: MapConstants.animationDuration,
        height: isExpanded 
            ? MapConstants.expandedCardHeight 
            : MapConstants.collapsedCardHeight,
        margin: MapConstants.defaultPadding,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildDragIndicator(),
            Expanded(
              child: Row(
                children: [
                  _buildLocationImage(),
                  if (!isExpanded) 
                    _buildCollapsedContent(),
                  if (isExpanded) 
                    _buildExpandedContent(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleDragGesture(DragEndDetails details) {
    if (details.primaryVelocity == null) return;
    
    if (details.primaryVelocity! > MapConstants.dragThreshold) {
      // Swipe down - collapse or dismiss
      onCardStateChanged(false);
    } else if (details.primaryVelocity! < -MapConstants.dragThreshold) {
      // Swipe up - expand
      onCardStateChanged(true);
    }
  }

  Widget _buildDragIndicator() {
    return Container(
      width: 50,
      height: 3,
      margin: const EdgeInsets.only(top: 6, bottom: 2),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  Widget _buildLocationImage() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(15),
          bottomLeft: Radius.circular(15),
        ),
        image: DecorationImage(
          image: AssetImage('assets/images/facultades/img_${sigla.toLowerCase()}_logo.png'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildCollapsedContent() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: AppTextStyles.bold.copyWith(
                fontSize: 12,
                color: AppColors.primary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              sigla.isNotEmpty ? 'Código: $sigla' : 'Campus principal',
              style: AppTextStyles.regular.copyWith(
                fontSize: 10,
                color: AppColors.textSecondary,
              ),
            ),
            if (title.contains('Facultad'))
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

  Widget _buildExpandedContent() {
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildExpandedHeader(),
            _buildImageGallery(),
            _buildDetailedInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedHeader() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.black.copyWith(
              fontSize: 16,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            sigla.isNotEmpty ? 'Código: $sigla' : 'Campus principal',
            style: AppTextStyles.regular.copyWith(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageGallery() {
    return SizedBox(
      height: 150,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: const [
          FacultyImage(imagePath: 'assets/images/facultades/img_ing_ficsa_logo.png'),
          SizedBox(width: 8),
          FacultyImage(imagePath: 'assets/images/img_presentacion_1.png'),
          SizedBox(width: 8),
          FacultyImage(imagePath: 'assets/images/img_presentacion_2.png'),
        ],
      ),
    );
  }

  Widget _buildDetailedInfo() {
    return Padding(
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
          
          InfoRow(icon: Icons.access_time, text: 'Horario: 7:00 AM - 6:00 PM'),
          InfoRow(icon: Icons.phone, text: 'Teléfono: (074) 481610'),
          InfoRow(icon: Icons.mail, text: 'Email: ${sigla.toLowerCase()}@unprg.edu.pe'),
          
          if (title.contains('Facultad'))
            const InfoRow(icon: Icons.school, text: 'Tipo: Edificio académico'),
            
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
            'Esta es una descripción detallada de $title. Aquí puedes incluir información sobre su historia, propósito, servicios ofrecidos, personal, etc.',
            style: AppTextStyles.regular.copyWith(
              fontSize: 12,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
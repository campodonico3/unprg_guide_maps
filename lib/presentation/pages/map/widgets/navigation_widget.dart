import 'package:flutter/material.dart';
import 'package:unprg_guide_maps/core/constants/app_colors.dart';
import 'package:unprg_guide_maps/core/services/navigation_service.dart';

class NavigationWidget extends StatelessWidget {
  final NavigationService navigationService;
  final VoidCallback onStopNavigation;
  final VoidCallback? onToggleVoice;

  const NavigationWidget({
    super.key,
    required this.navigationService,
    required this.onStopNavigation,
    this.onToggleVoice,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: navigationService,
      builder: (context, _) {
        if (!navigationService.isNavigating) {
          return const SizedBox.shrink();
        }

        return Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildNavigationHeader(),
                  _buildProgressIndicator(),
                  _buildNavigationInfo(),
                  _buildActionButtons(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavigationHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.navigation,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Navegando',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            onPressed: onStopNavigation,
            icon: const Icon(
              Icons.close,
              color: Colors.white,
            ),
            splashRadius: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    final progress = navigationService.progressPercentage / 100;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progreso: ${navigationService.progressPercentage.toStringAsFixed(0)}%',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              Text(
                navigationService.formatDistance(navigationService.remainingDistance),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            minHeight: 6,
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationInfo() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Tiempo y distancia
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  icon: Icons.schedule,
                  title: 'Tiempo estimado',
                  value: navigationService.formatTime(navigationService.estimatedTimeMinutes),
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoCard(
                  icon: Icons.straighten,
                  title: 'Distancia total',
                  value: navigationService.formatDistance(navigationService.totalDistance),
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Instrucción actual
          _buildCurrentInstruction(),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentInstruction() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.volume_up,
                color: AppColors.primary,
                size: 16,
              ),
              const SizedBox(width: 8),
              const Text(
                'Instrucciones de voz',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            navigationService.currentInstruction.isEmpty 
                ? 'Sigue la ruta marcada en el mapa.'
                : navigationService.currentInstruction,
            style: const TextStyle(
              fontSize: 14,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onToggleVoice,
              icon: const Icon(Icons.volume_up, size: 18),
              label: const Text('Voz'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: onStopNavigation,
              icon: const Icon(Icons.stop, size: 18),
              label: const Text('Detener navegación'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
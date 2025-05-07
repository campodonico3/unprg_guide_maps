import 'package:flutter/material.dart';
import 'package:unprg_guide_maps/core/constants/app_colors.dart';

class MapFloatingButtons extends StatelessWidget {
  final bool isCardExpanded;
  final bool isMarkerSelected;
  final bool isGettingLocation;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onGetLocation;

  const MapFloatingButtons({
    super.key,
    required this.isCardExpanded,
    required this.isMarkerSelected,
    required this.isGettingLocation,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onGetLocation,
  });

  @override
  Widget build(BuildContext context) {
    // Si la tarjeta está expandida, no mostramos ningún botón flotante
    if (isCardExpanded) {
      return SizedBox(
        height: isMarkerSelected ? 130 : 0, // Mantenemos el espaciado para la tarjeta
      );
    }
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _buildFloatingButton(
          heroTag: "zoom_in",
          icon: const Icon(Icons.add, color: Colors.white),
          onPressed: onZoomIn,
        ),
        const SizedBox(height: 8),
        _buildFloatingButton(
          heroTag: "zoom_out",
          icon: const Icon(Icons.remove, color: Colors.white),
          onPressed: onZoomOut,
        ),
        const SizedBox(height: 8),
        _buildFloatingButton(
          heroTag: "my_location",
          icon: isGettingLocation 
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Icon(Icons.my_location, color: Colors.white),
          onPressed: onGetLocation,
        ),
        // Add padding when the card is displayed
        if (isMarkerSelected) const SizedBox(height: 130),
      ],
    );
  }
  
  Widget _buildFloatingButton({
    required String heroTag,
    required Widget icon,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 45,
      height: 45,
      child: FloatingActionButton(
        heroTag: heroTag,
        backgroundColor: AppColors.primary,
        onPressed: onPressed,
        child: icon,
      ),
    );
  }
}
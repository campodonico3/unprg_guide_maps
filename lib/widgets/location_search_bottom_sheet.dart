import 'package:flutter/material.dart';
import 'package:unprg_guide_maps/data/models/faculty_item.dart';
import 'package:unprg_guide_maps/data/repositories/faculty_repository.dart';

class LocationSearchBottomSheet extends StatefulWidget {
  final Function(FacultyItem) onLocationSelected;

  const LocationSearchBottomSheet({
    super.key,
    required this.onLocationSelected,
  });

  @override
  State<LocationSearchBottomSheet> createState() => _LocationSearchBottomSheetState();
}

class _LocationSearchBottomSheetState extends State<LocationSearchBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  final FacultyRepository _repository = FacultyRepository();

  late final List<FacultyItem> _allLocations;
  List<FacultyItem> _filteredLocations = [];

  @override
  void initState() {
    super.initState();
    _allLocations = [..._repository.getFaculties(), ..._repository.getOfficies()];
    _filteredLocations = _allLocations;
  }

  void _filterSearch(String query) {
    setState(() {
      _filteredLocations = _allLocations
          .where((loc) =>
              loc.name.toLowerCase().contains(query.toLowerCase()) ||
              loc.sigla.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Search field
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: _filterSearch,
                  decoration: const InputDecoration(
                    hintText: 'Buscar ubicación...',
                    hintStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.grey,
                      size: 24,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ),

            // Results list
            Flexible(
              child: _filteredLocations.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Text(
                          'No se encontraron ubicaciones',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _filteredLocations.length,
                      separatorBuilder: (context, index) => Divider(
                        height: 1,
                        color: Colors.grey[200],
                      ),
                      itemBuilder: (context, index) {
                        final location = _filteredLocations[index];
                        return Container(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 0,
                              vertical: 8,
                            ),
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.schedule,
                                color: Colors.grey,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              location.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                location.sigla,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                            onTap: () {
                              widget.onLocationSelected(location);
                              Navigator.pop(context);
                            },
                          ),
                        );
                      },
                    ),
            ),
            
            // Bottom padding for safe area
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
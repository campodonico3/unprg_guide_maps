import 'package:flutter/material.dart';
import 'package:unprg_guide_maps/data/models/faculty_item.dart';
import 'package:unprg_guide_maps/presentation/pages/map/controller/map_controller.dart';
import 'package:unprg_guide_maps/presentation/pages/map/widgets/map_widget.dart';

class FlutterMapPage extends StatefulWidget {
  final List<FacultyItem> locations;
  final String? name;
  final String? sigla;
  final double initialLatitude;
  final double initialLongitude;

  const FlutterMapPage({
    super.key,
    required this.locations,
    this.name,
    this.sigla,
    required this.initialLatitude,
    required this.initialLongitude,
  });

  @override
  State<FlutterMapPage> createState() => _FlutterMapPageState();
}

class _FlutterMapPageState extends State<FlutterMapPage> {
  late final MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController(
      initialLatitude: widget.initialLatitude,
      initialLongitude: widget.initialLongitude,
    );
    _mapController.initialize();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_buildTitle()),
      ),
      body: MapWidget(
        mapController: _mapController,
        sigla: widget.sigla,
        name: widget.name,
        initialLatitude: widget.initialLatitude,
        initialLongitude: widget.initialLongitude,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _mapController.recalculateRoute,
        child: const Icon(Icons.route),
      ),
    );
  }

  String _buildTitle() {
    if (widget.sigla != null && widget.name != null) {
      return '${widget.sigla} - ${widget.name}';
    }
    return 'Mapa';
  }
}
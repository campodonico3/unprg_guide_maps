import "package:flutter/material.dart";
import "package:unprg_guide_maps/core/constants/app_colors.dart";
import "package:unprg_guide_maps/data/models/faculty_item.dart";
import "package:unprg_guide_maps/data/repositories/faculty_repository.dart";
import "package:unprg_guide_maps/presentation/pages/home/widgets/faculty_card.dart";
import "package:unprg_guide_maps/presentation/pages/home/widgets/search_bar_widget.dart";
import "package:unprg_guide_maps/presentation/pages/map/flutter_map_page.dart";

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FacultyRepository _facultyRepository = FacultyRepository();

  late List<FacultyItem> _faculties;
  late List<FacultyItem> _offices;

  late List<FacultyItem> _filteredFaculties;
  late List<FacultyItem> _filteredOffices;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Inicializar las listas
    _faculties = _facultyRepository.getFaculties();
    _offices = _facultyRepository.getOfficies();

    _filteredFaculties = _faculties;
    _filteredOffices = _offices;

    // Escuchar cambios de pestañas para actualizar la búsqueda
    _tabController.addListener(_handleTabChange);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Método para manejar el cambio de pestaña
  void _handleTabChange(){
    if (_tabController.indexIsChanging){
      _filterItems(_searchQuery);
    }
  }

  // Método para filtrar los elementos según la búsqueda
  void _filterItems(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();

      if (_searchQuery.isEmpty){
        // Si no hay busqueda, mostrar todos los elementos
        _filteredFaculties = _faculties;
        _filteredOffices = _offices;

      }else{
        // Filtrar facultades
        _filteredFaculties = _faculties.where((faculty) {
          return faculty.name.toLowerCase().contains(_searchQuery) ||
              faculty.sigla.toLowerCase().contains(_searchQuery);
        }).toList();

        // Filtrar oficinas
        _filteredOffices = _offices.where((office) {
          return office.name.toLowerCase().contains(_searchQuery) ||
              office.sigla.toLowerCase().contains(_searchQuery);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildHeader(),
          _buildSearchBar(),
          _buildTabBar(),
          _buildTabContent(),
        ],
      ),
      floatingActionButton: _buildMapButton(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primary,
      elevation: 0,
      title: const Text(
        "Guide University Maps",
        style: TextStyle(
          color: AppColors.textOnPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(
            Icons.info_outline,
            color: AppColors.textOnPrimary,
          ),
          onPressed: () {},
        )
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.primary, AppColors.primaryLight],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            '¿A dónde quieres ir hoy?',
            style: TextStyle(
              color: AppColors.textOnPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.only(top: 20, left: 16, right: 16),
      child: SearchBarWidget(
        controller: _searchController,
        onSearchChanged: _filterItems,
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: TabBar(
        controller: _tabController,
        indicatorColor: AppColors.primary,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        tabs: const [
          Tab(text: 'FACULTADES'),
          Tab(text: 'OFICINAS'),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    return Expanded(
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildLocationGrid(_filteredFaculties),
          _buildLocationGrid(_filteredOffices),
        ],
      ),
    );
  }

  Widget _buildLocationGrid(List<FacultyItem> items) {
    if (items.isEmpty && _searchQuery.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 60, color: AppColors.neutral),
            const SizedBox(height: 16),
            Text(
              'No se encontraron resultados para "$_searchQuery"',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.5,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return FacultyCard(
            name: item.name,
            sigla: item.sigla,
            imageAsset: item.imageAsset,
          );
        },
      ),
    );
  }

  Widget _buildMapButton() {
    return FloatingActionButton(
      backgroundColor: AppColors.primary,
      child: const Icon(Icons.map, color: Colors.white),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return FlutterMapPage();
            },
          ),
        );
      },
    );
  }
}

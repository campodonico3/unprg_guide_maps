import "package:flutter/material.dart";
import "package:unprg_guide_maps/core/constants/app_colors.dart";
import "package:unprg_guide_maps/data/models/faculty_item.dart";
import "package:unprg_guide_maps/data/repositories/faculty_repository.dart";
import "package:unprg_guide_maps/presentation/pages/home/widgets/faculty_card.dart";
import "package:unprg_guide_maps/presentation/pages/home/widgets/search_bar_widget.dart";

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin{
  late TabController _tabController;
  final FacultyRepository _facultyRepository = FacultyRepository();

  @override
  void initState(){
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose(){
    _tabController.dispose();
    super.dispose();
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
    return const Padding(
      padding: EdgeInsets.only(top: 20, left: 16, right: 16),
      child: SearchBarWidget(),
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
          _buildLocationGrid(_facultyRepository.getFaculties()),
          _buildLocationGrid(_facultyRepository.getOfficies()),
        ],
      ),
    );
  }

  Widget _buildLocationGrid(List<FacultyItem> items) {
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
        // Acción al presionar el botón flotante
      },
    );
  }
}



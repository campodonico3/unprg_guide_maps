import "package:flutter/material.dart";
import "package:unprg_guide_maps/core/constants/app_colors.dart";
import "package:unprg_guide_maps/presentation/pages/home/widgets/faculty_card.dart";
import "package:unprg_guide_maps/presentation/pages/home/widgets/search_bar_widget.dart";

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin{
  late TabController _tabController;

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
      appBar: AppBar(
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
      ),
      body: Column(
        children: [
          // Header curvo con degradado
          Container(
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.primary, AppColors.primaryLight]),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Center(
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
          ),

          // Barra de busqueda
          Padding(
            padding: EdgeInsets.only(top: 20, left: 16, right: 16),
            child: SearchBarWidget(),
          ),

          // Tab bar para cambiar entre Facultades y Oficinas
          Container(
            margin: EdgeInsets.only(top: 16),
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.primary,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              tabs: [
                Tab(text: 'FACULTADES',),
                Tab(text: 'OFICINAS',),
              ],
            ),
          ),

          // Título de sección
          /*const Padding(
            padding: EdgeInsets.only(top: 24, left: 16, bottom: 12),
            child: Text(
              'FACULTADES',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),*/

          // Tab view content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildFacultiesGrid(),
                _buildOfficesGrid(),
              ],
            ),
          ),         
        ],
      ),

      // Botón flotante para mostrar el mapa completo
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        child: Icon(Icons.map, color: Colors.white,),
        onPressed: () {
          // Acción al presionar el botón flotante
        },
      ),
    );
  }
}

/*class _buildFacultiesGrid extends StatelessWidget {
  const _buildFacultiesGrid({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: GridView.count(
          crossAxisCount: 2,
          childAspectRatio: 1.5,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          children: [
            FacultyCard(
              name: 'Facultad de Ingeniería Agrícola',
              sigla: 'FIA',
              imageAsset: 'assets/images/facultades/img_agricola_logo.png',
            ),
            FacultyCard(
              name: 'Facultad de Ciencias Biológicas',
              sigla: 'FCCBB',
              imageAsset: 'assets/images/facultades/img_ciencias_biologicas_logo.png',
            ),
            FacultyCard(
              name: 'Facultad de Ingeniería Civil, de Sistemas y de Arquitectura',
              sigla: 'FICSA',
              imageAsset: 'assets/images/facultades/img_ing_ficsa_logo.png',
            ),
            FacultyCard(
              name: 'Facultad de Derechp y Ciencia Política',
              sigla: 'FDCP',
              imageAsset: 'assets/images/facultades/img_ing_ficsa_logo.png',
            ),
            FacultyCard(
              name: 'Facultad de Ciencias Económicas, Administrativas y Contables',
              sigla: 'FCEAC',                   
              imageAsset: 'assets/images/facultades/img_faceac_logo.png',
            ),       
            FacultyCard(
              name: 'Facultad de Ciencias Físicas y Matemáticas',
              sigla: 'FACFyM',                   
              imageAsset: 'assets/images/facultades/img_fisica_matematica_logo.png',
            ),            
            FacultyCard(
              name: 'Facultad de Agronomía',
              sigla: 'FAG',
              imageAsset: 'assets/images/facultades/img_agronomia_logo.png',
            ),
            FacultyCard(
              name: 'Facultad de Medicina Humana',
              sigla: 'FMH',
              imageAsset: 'assets/images/facultades/img_medicina_logo.png',
            ),
            FacultyCard(
              name: 'Facultad de Ingeniería Mecánica Eléctrica',
              sigla: 'FIME',
              imageAsset: 'assets/images/facultades/img_mecanica_logo.png',
            ),
            FacultyCard(
              name: 'Escuela de Posgrado',
              sigla: 'EPG',
              imageAsset: 'assets/images/facultades/img_sociales_educacion_logo.png',
            ),
            FacultyCard(
              name: 'Facultad de Ingeniería Química e Industrias Alimentarias',
              sigla: 'FIQUIA',
              imageAsset: 'assets/images/facultades/img_quimica_logo.png',
            ),
            FacultyCard(
              name: 'Facultad de Enfermería',
              sigla: 'FE',
              imageAsset: 'assets/images/facultades/img_enfermeria_logo.png',
            ),                 
            FacultyCard(
              name: 'Facultad de Ciencias Sociales y Educación',
              sigla: 'FACHSE',
              imageAsset: 'assets/images/facultades/img_sociales_educacion_logo.png',
            ),
            FacultyCard(
              name: 'Facultad de Veterinaria',
              sigla: 'FMV',
              imageAsset: 'assets/images/facultades/img_veterinaria_logo.png',
            ),
            FacultyCard(
              name: 'Facultad de Ingeniería Zootecnia',
              sigla: 'FIZ',
              imageAsset: 'assets/images/facultades/img_zootecnia_logo.png',
            ),
          ],
        ),
      ),
    );
  }
}*/

Widget _buildFacultiesGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GridView.count(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        children: [
          FacultyCard(
            name: 'Facultad de Ingeniería Agrícola',
            sigla: 'FIA',
            imageAsset: 'assets/images/facultades/img_agricola_logo.png',
          ),
          FacultyCard(
            name: 'Facultad de Ciencias Biológicas',
            sigla: 'FCCBB',
            imageAsset: 'assets/images/facultades/img_ciencias_biologicas_logo.png',
          ),
          FacultyCard(
            name: 'Facultad de Ingeniería Civil, de Sistemas y de Arquitectura',
            sigla: 'FICSA',
            imageAsset: 'assets/images/facultades/img_ing_ficsa_logo.png',
          ),
          FacultyCard(
            name: 'Facultad de Derechp y Ciencia Política',
            sigla: 'FDCP',
            imageAsset: 'assets/images/facultades/img_ing_ficsa_logo.png',
          ),
          FacultyCard(
            name: 'Facultad de Ciencias Económicas, Administrativas y Contables',
            sigla: 'FCEAC',                   
            imageAsset: 'assets/images/facultades/img_faceac_logo.png',
          ),       
          FacultyCard(
            name: 'Facultad de Ciencias Físicas y Matemáticas',
            sigla: 'FACFyM',                   
            imageAsset: 'assets/images/facultades/img_fisica_matematica_logo.png',
          ),            
          FacultyCard(
            name: 'Facultad de Agronomía',
            sigla: 'FAG',
            imageAsset: 'assets/images/facultades/img_agronomia_logo.png',
          ),
          FacultyCard(
            name: 'Facultad de Medicina Humana',
            sigla: 'FMH',
            imageAsset: 'assets/images/facultades/img_medicina_logo.png',
          ),
          FacultyCard(
            name: 'Facultad de Ingeniería Mecánica Eléctrica',
            sigla: 'FIME',
            imageAsset: 'assets/images/facultades/img_mecanica_logo.png',
          ),
          FacultyCard(
            name: 'Escuela de Posgrado',
            sigla: 'EPG',
            imageAsset: 'assets/images/facultades/img_sociales_educacion_logo.png',
          ),
          FacultyCard(
            name: 'Facultad de Ingeniería Química e Industrias Alimentarias',
            sigla: 'FIQUIA',
            imageAsset: 'assets/images/facultades/img_quimica_logo.png',
          ),
          FacultyCard(
            name: 'Facultad de Enfermería',
            sigla: 'FE',
            imageAsset: 'assets/images/facultades/img_enfermeria_logo.png',
          ),                 
          FacultyCard(
            name: 'Facultad de Ciencias Sociales y Educación',
            sigla: 'FACHSE',
            imageAsset: 'assets/images/facultades/img_sociales_educacion_logo.png',
          ),
          FacultyCard(
            name: 'Facultad de Veterinaria',
            sigla: 'FMV',
            imageAsset: 'assets/images/facultades/img_veterinaria_logo.png',
          ),
          FacultyCard(
            name: 'Facultad de Ingeniería Zootecnia',
            sigla: 'FIZ',
            imageAsset: 'assets/images/facultades/img_zootecnia_logo.png',
          ),
        ],
      ),
    );
  }

Widget _buildOfficesGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GridView.count(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        children: [
          FacultyCard(
            name: 'Oficina de Gestión de la Calidad',
            sigla: 'OGC',
            imageAsset: 'assets/images/unprg_logo.png',
          ),
          FacultyCard(
            name: 'Oficina de Cooperación y Relaciones Internacionales',
            sigla: 'OCRI',
            imageAsset: 'assets/images/unprg_logo.png',
          ),
          FacultyCard(
            name: 'Oficina de Comunicación e Imagen Institucional',
            sigla: 'OCII',
            imageAsset: 'assets/images/unprg_logo.png',
          ),
          FacultyCard(
            name: 'Oficina General de Admisión',
            sigla: 'OGA',
            imageAsset: 'assets/images/unprg_logo.png',
          ),
          FacultyCard(
            name: 'Oficina de Bienestar Universitario',
            sigla: 'OBU',
            imageAsset: 'assets/images/unprg_logo.png',
          ),
          FacultyCard(
            name: 'Oficina de Recursos Humanos',
            sigla: 'ORH',
            imageAsset: 'assets/images/unprg_logo.png',
          ),
          FacultyCard(
            name: 'Oficina de Tecnologías de la Información',
            sigla: 'OTI',
            imageAsset: 'assets/images/unprg_logo.png',
          ),
          FacultyCard(
            name: 'Oficina de Asuntos Académicos',
            sigla: 'OAA',
            imageAsset: 'assets/images/unprg_logo.png',
          ),
        ],
      ),
    );
  }

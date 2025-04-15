import 'package:unprg_guide_maps/data/models/faculty_item.dart';

class FacultyRepository {
  List<FacultyItem> getFaculties(){
    return [
      FacultyItem(
        name: 'Facultad de Ingeniería Agrícola',
        sigla: 'FIA',
        imageAsset: 'assets/images/facultades/img_agricola_logo.png',
      ),
      FacultyItem(
        name: 'Facultad de Ciencias Biológicas',
        sigla: 'FCCBB',
        imageAsset: 'assets/images/facultades/img_ciencias_biologicas_logo.png',
      ),
      FacultyItem(
        name: 'Facultad de Ingeniería Civil, de Sistemas y de Arquitectura',
        sigla: 'FICSA',
        imageAsset: 'assets/images/facultades/img_ing_ficsa_logo.png',
      ),
      FacultyItem(
        name: 'Facultad de Derechp y Ciencia Política',
        sigla: 'FDCP',
        imageAsset: 'assets/images/facultades/img_ing_ficsa_logo.png',
      ),
      FacultyItem(
        name: 'Facultad de Ciencias Económicas, Administrativas y Contables',
        sigla: 'FCEAC',                   
        imageAsset: 'assets/images/facultades/img_faceac_logo.png',
      ),       
      FacultyItem(
        name: 'Facultad de Ciencias Físicas y Matemáticas',
        sigla: 'FACFyM',                   
        imageAsset: 'assets/images/facultades/img_fisica_matematica_logo.png',
      ),            
      FacultyItem(
        name: 'Facultad de Agronomía',
        sigla: 'FAG',
        imageAsset: 'assets/images/facultades/img_agronomia_logo.png',
      ),
      FacultyItem(
        name: 'Facultad de Medicina Humana',
        sigla: 'FMH',
        imageAsset: 'assets/images/facultades/img_medicina_logo.png',
      ),
      FacultyItem(
        name: 'Facultad de Ingeniería Mecánica Eléctrica',
        sigla: 'FIME',
        imageAsset: 'assets/images/facultades/img_mecanica_logo.png',
      ),
      FacultyItem(
        name: 'Escuela de Posgrado',
        sigla: 'EPG',
        imageAsset: 'assets/images/facultades/img_sociales_educacion_logo.png',
      ),
      FacultyItem(
        name: 'Facultad de Ingeniería Química e Industrias Alimentarias',
        sigla: 'FIQUIA',
        imageAsset: 'assets/images/facultades/img_quimica_logo.png',
      ),
      FacultyItem(
        name: 'Facultad de Enfermería',
        sigla: 'FE',
        imageAsset: 'assets/images/facultades/img_enfermeria_logo.png',
      ),                 
      FacultyItem(
        name: 'Facultad de Ciencias Sociales y Educación',
        sigla: 'FACHSE',
        imageAsset: 'assets/images/facultades/img_sociales_educacion_logo.png',
      ),
      FacultyItem(
        name: 'Facultad de Veterinaria',
        sigla: 'FMV',
        imageAsset: 'assets/images/facultades/img_veterinaria_logo.png',
      ),
      FacultyItem(
        name: 'Facultad de Ingeniería Zootecnia',
        sigla: 'FIZ',
        imageAsset: 'assets/images/facultades/img_zootecnia_logo.png',
      ),
    ];
  }

  List<FacultyItem> getOfficies(){
    return [
      FacultyItem(
        name: 'Oficina de Gestión de la Calidad',
        sigla: 'OGC',
        imageAsset: 'assets/images/unprg_logo.png',
      ),
      FacultyItem(
        name: 'Oficina de Cooperación y Relaciones Internacionales',
        sigla: 'OCRI',
        imageAsset: 'assets/images/unprg_logo.png',
      ),
      FacultyItem(
        name: 'Oficina de Comunicación e Imagen Institucional',
        sigla: 'OCII',
        imageAsset: 'assets/images/unprg_logo.png',
      ),
      FacultyItem(
        name: 'Oficina General de Admisión',
        sigla: 'OGA',
        imageAsset: 'assets/images/unprg_logo.png',
      ),
      FacultyItem(
        name: 'Oficina de Bienestar Universitario',
        sigla: 'OBU',
        imageAsset: 'assets/images/unprg_logo.png',
      ),
      FacultyItem(
        name: 'Oficina de Recursos Humanos',
        sigla: 'ORH',
        imageAsset: 'assets/images/unprg_logo.png',
      ),
      FacultyItem(
        name: 'Oficina de Tecnologías de la Información',
        sigla: 'OTI',
        imageAsset: 'assets/images/unprg_logo.png',
      ),
      FacultyItem(
        name: 'Oficina de Asuntos Académicos',
        sigla: 'OAA',
        imageAsset: 'assets/images/unprg_logo.png',
      ),
    ];
  }
}
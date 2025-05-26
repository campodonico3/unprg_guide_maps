import 'package:unprg_guide_maps/core/constants/assets_path.dart';
import 'package:unprg_guide_maps/data/models/faculty_item.dart';

class FacultyRepository {
  List<FacultyItem> getFaculties(){
    return [
      FacultyItem(
        name: 'Facultad de Ingeniería Agrícola',
        sigla: 'FIA',
        imageAsset: 'assets/images/facultades/img_fia_logo.png',
        latitude: -6.70749760689037,
        longitude: -79.90452516138711,
      ),
      FacultyItem(
        name: 'Facultad de Ciencias Biológicas',
        sigla: 'FCCBB',
        imageAsset: 'assets/images/facultades/img_fccbb_logo.png',
        latitude: -6.707944101526591,
        longitude: -79.90890166441685,
      ),
      FacultyItem(
        name: 'Facultad de Ingeniería Civil, de Sistemas y de Arquitectura',
        sigla: 'FICSA',
        imageAsset: 'assets/images/facultades/img_ficsa_logo.png',
        latitude: -6.708409860900935,
        longitude: -79.90717965506741,
      ),
      FacultyItem(
        name: 'Facultad de Derecho y Ciencia Política',
        sigla: 'FDCP',
        imageAsset: 'assets/images/facultades/img_fdcp_logo.png',
        latitude: -6.707199017063633,
        longitude:  -79.90825422176164,
      ),
      FacultyItem(
        name: 'Facultad de Ciencias Económicas, Administrativas y Contables',
        sigla: 'FCEAC',                   
        imageAsset: 'assets/images/facultades/img_fceac_logo.png',
        latitude: -6.706804203482459,
        longitude: -79.90901597739537,
      ),       
      FacultyItem(
        name: 'Facultad de Ciencias Físicas y Matemáticas',
        sigla: 'FACFyM',                   
        imageAsset: 'assets/images/facultades/img_facfym_logo.png',
        latitude: -6.70749760689037,
        longitude: -79.90452516138711,
      ),            
      FacultyItem(
        name: 'Facultad de Agronomía',
        sigla: 'FAG',
        imageAsset: 'assets/images/facultades/img_fag_logo.png',
        latitude: -6.70749760689037,
        longitude: -79.90452516138711,
      ),
      FacultyItem(
        name: 'Facultad de Medicina Humana',
        sigla: 'FMH',
        imageAsset: 'assets/images/facultades/img_fmh_logo.png',
        latitude: -6.705964483041015,
        longitude: -79.90844493829337,
      ),
      FacultyItem(
        name: 'Facultad de Ingeniería Mecánica Eléctrica',
        sigla: 'FIME',
        imageAsset: 'assets/images/facultades/img_fime_logo.png',
        latitude: -6.708565067880151,
        longitude: -79.90409876654594,
      ),
      FacultyItem(
        name: 'Escuela de Posgrado',
        sigla: 'EPG',
        imageAsset: 'assets/images/facultades/img_epg_logo.png',
        latitude: -6.707630129848875,
        longitude: -79.90413969620664,
      ),
      FacultyItem(
        name: 'Facultad de Ingeniería Química e Industrias Alimentarias',
        sigla: 'FIQUIA',
        imageAsset: 'assets/images/facultades/img_fiquia_logo.png',
        latitude: -6.70823446900036,
        longitude: -79.90851047594063,
      ),
      FacultyItem(
        name: 'Facultad de Enfermería',
        sigla: 'FE',
        imageAsset: 'assets/images/facultades/img_fe_logo.png',
        latitude: -6.708180461097526,
        longitude: -79.90848091037995,
      ),                 
      FacultyItem(
        name: 'Facultad de Ciencias Sociales y Educación',
        sigla: 'FACHSE',
        imageAsset: 'assets/images/facultades/img_fachse_logo.png',
        latitude: -6.706313123530458,
        longitude: -79.90452516138711,
      ),
      FacultyItem(
        name: 'Facultad de Veterinaria',
        sigla: 'FMV',
        imageAsset: 'assets/images/facultades/img_fmv_logo.png',
        latitude: -6.70749760689037,
        longitude: -79.90452516138711,
      ),
      FacultyItem(
        name: 'Facultad de Ingeniería Zootecnia',
        sigla: 'FIZ',
        imageAsset: 'assets/images/facultades/img_fiz_logo.png',
        latitude: -6.70749760689037,
        longitude: -79.90452516138711,
      ),
    ];
  }

  List<FacultyItem> getOfficies(){
    return [
      FacultyItem(
        name: 'Oficina de Gestión de la Calidad',
        sigla: 'OGC',
        imageAsset: AssetsPath.unprgLogo,
        /*latitude: -6.70749760689037,
        longitude: -79.90452516138711,*/
      ),
      FacultyItem(
        name: 'Oficina de Cooperación y Relaciones Internacionales',
        sigla: 'OCRI',
        imageAsset: AssetsPath.unprgLogo,
        /*latitude: -6.70749760689037,
        longitude: -79.90452516138711,*/
      ),
      FacultyItem(
        name: 'Oficina de Comunicación e Imagen Institucional',
        sigla: 'OCII',
        imageAsset: AssetsPath.unprgLogo,
      ),
      FacultyItem(
        name: 'Dirección General de Administración',
        sigla: 'DGA',
        imageAsset: AssetsPath.unprgLogo,
        /*latitude: -6.70749760689037,
        longitude: -79.90452516138711,*/
      ),
      FacultyItem(
        name: 'Unidad Ejecutora de Inversiones',
        sigla: 'UEI',
        imageAsset: AssetsPath.unprgLogo,
        /*latitude: -6.70749760689037,
        longitude: -79.90452516138711,*/
      ),
      FacultyItem(
        name: 'Unidad de Recursos Humanos',
        sigla: 'URH',
        imageAsset: AssetsPath.unprgLogo,
        latitude: -6.706831,
        longitude: -79.907826,
      ),
      FacultyItem(
        name: 'Oficina de Tecnologías de la Información',
        sigla: 'OTI',
        imageAsset: AssetsPath.unprgLogo,
        latitude: -6.706165680357074,
        longitude: -79.90928435096573,
      ),
      FacultyItem(
        name: 'Unidad de Servicios Generales',
        sigla: 'USG',
        imageAsset: AssetsPath.unprgLogo,
        /*latitude: -6.70749760689037,
        longitude: -79.90452516138711,*/
      ),
      FacultyItem(
        name: 'Unidad de Abastecimiento',
        sigla: 'UA',
        imageAsset: AssetsPath.unprgLogo,
        /*latitude: -6.70749760689037,
        longitude: -79.90452516138711,*/
      ),
      FacultyItem(
        name: 'Unidad de Tesorería',
        sigla: 'UT',
        imageAsset: AssetsPath.unprgLogo,
        /*latitude: -6.70749760689037,
        longitude: -79.90452516138711,*/
      ),
      FacultyItem(
        name: 'Unidad de Contabilidad',
        sigla: 'UC',
        imageAsset: AssetsPath.unprgLogo,
        /*latitude: -6.70749760689037,
        longitude: -79.90452516138711,*/
      ),
      FacultyItem(
        name: 'Unidad Formuladora',
        sigla: 'UF',
        imageAsset: AssetsPath.unprgLogo,
        /*latitude: -6.70749760689037,
        longitude: -79.90452516138711,*/
      ),
      FacultyItem(
        name: 'Unidad de Modernización',
        sigla: 'UM',
        imageAsset: AssetsPath.unprgLogo,
        /*latitude: -6.70749760689037,
        longitude: -79.90452516138711,*/
      ),
      FacultyItem(
        name: 'Unidad de Planeamiento y Presupuesto',
        sigla: 'UPP',
        imageAsset: AssetsPath.unprgLogo,
        /*latitude: -6.70749760689037,
        longitude: -79.90452516138711,*/
      ),
      FacultyItem(
        name: 'Oficina de Planeamiento y Presupuesto',
        sigla: 'OPP',
        imageAsset: AssetsPath.unprgLogo,
        /*latitude: -6.70749760689037,
        longitude: -79.90452516138711,*/
      ),
      FacultyItem(
        name: 'Oficina de Asesoria Juridica',
        sigla: 'OAJ',
        imageAsset: AssetsPath.unprgLogo,
        /*latitude: -6.70749760689037,
        longitude: -79.90452516138711,*/
      ),
      FacultyItem(
        name: 'Organo de Control Institucional',
        sigla: 'OCI',
        imageAsset: AssetsPath.unprgLogo,
        /*latitude: -6.70749760689037,
        longitude: -79.90452516138711,*/
      ),
    ];
  }
}
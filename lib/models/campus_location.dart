import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';

enum LocationCategory {
  faculty('Fakülteler', Icons.school, Colors.teal),
  dining('Yemek & Cafe', Icons.restaurant, Colors.redAccent),
  shopping('Alışveriş', Icons.shopping_bag, Colors.greenAccent),
  sports('Spor', Icons.sports_basketball, Colors.blue),
  library('Kütüphane', Icons.library_books, Colors.green),
  administrative('İdari', Icons.business, Colors.orange),
  dormitory('Yurt', Icons.bed, Colors.purple),
  health('Sağlık', Icons.local_hospital, Colors.red);

  const LocationCategory(this.displayName, this.icon, this.color);

  final String displayName;
  final IconData icon;
  final Color color;
}

class CampusLocation {
  final String id;
  final String name;
  final String? description;
  final LatLng position;
  final LocationCategory category;
  final String? phoneNumber;
  final String? workingHours;
  final List<String>? services;
  final bool isFavorite;

  const CampusLocation({
    required this.id,
    required this.name,
    this.description,
    required this.position,
    required this.category,
    this.phoneNumber,
    this.workingHours,
    this.services,
    this.isFavorite = false,
  });

  CampusLocation copyWith({
    String? id,
    String? name,
    String? description,
    LatLng? position,
    LocationCategory? category,
    String? phoneNumber,
    String? workingHours,
    List<String>? services,
    bool? isFavorite,
  }) {
    return CampusLocation(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      position: position ?? this.position,
      category: category ?? this.category,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      workingHours: workingHours ?? this.workingHours,
      services: services ?? this.services,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

class CampusData {
  static const List<CampusLocation> locations = [
    CampusLocation(
      id: 'fen_fakultesi',
      name: 'Fen Fakültesi',
      description: 'Matematik, Fizik, Kimya, Biyoloji bölümleri',
      position: LatLng(36.898921, 30.655347),
      category: LocationCategory.faculty,
      workingHours: '08:00 - 17:00',
      services: ['Laboratuvarlar', 'Derslikler', 'Akademik Ofisler'],
    ),
    CampusLocation(
      id: 'muhendislik_fakultesi',
      name: 'Mühendislik Fakültesi',
      description: 'Çeşitli mühendislik bölümleri',
      position: LatLng(36.896746543260676, 30.64972008224865),
      category: LocationCategory.faculty,
      workingHours: '08:00 - 17:00',
      services: ['Laboratuvarlar', 'Proje Odaları', 'Teknik Atölyeler'],
    ),
    CampusLocation(
      id: 'hukuk_fakultesi',
      name: 'Hukuk Fakültesi',
      description: 'Hukuk eğitimi ve araştırmaları',
      position: LatLng(36.893314445576195, 30.653646835904343),
      category: LocationCategory.faculty,
      workingHours: '08:00 - 17:00',
      services: ['Derslikler', 'Moot Court', 'Hukuk Kütüphanesi'],
    ),
    CampusLocation(
      id: 'iletisim_fakultesi',
      name: 'İletişim Fakültesi',
      description: 'Gazetecilik, Halkla İlişkiler, Radyo TV bölümleri',
      position: LatLng(36.895540207250306, 30.64491372509665),
      category: LocationCategory.faculty,
      workingHours: '08:00 - 17:00',
      services: ['Stüdyolar', 'Montaj Odaları', 'Teknik Ekipmanlar'],
    ),
    CampusLocation(
      id: 'egitim_fakultesi',
      name: 'Eğitim Fakültesi',
      description: 'Öğretmen yetiştirme programları',
      position: LatLng(36.89291891504643, 30.645080022016458),
      category: LocationCategory.faculty,
      workingHours: '08:00 - 17:00',
      services: ['Mikroöğretim Sınıfları', 'Eğitim Teknolojileri'],
    ),
    CampusLocation(
      id: 'edebiyat_fakultesi',
      name: 'Edebiyat Fakültesi',
      description: 'Dil, edebiyat ve sosyal bilimler',
      position: LatLng(36.89141731593144, 30.642859152966533),
      category: LocationCategory.faculty,
      workingHours: '08:00 - 17:00',
      services: ['Dil Laboratuvarları', 'Araştırma Merkezleri'],
    ),
    CampusLocation(
      id: 'tip_fakultesi',
      name: 'Tıp Fakültesi',
      description: 'Tıp eğitimi ve sağlık hizmetleri',
      position: LatLng(36.897418206092325, 30.658002305236696),
      category: LocationCategory.faculty,
      workingHours: '24 Saat',
      services: ['Hastane', 'Anatomi Laboratuvarları', 'Simülasyon Merkezi'],
    ),
    CampusLocation(
      id: 'hemsirelik_fakultesi',
      name: 'Hemşirelik Fakültesi',
      description: 'Hemşirelik eğitimi programları',
      position: LatLng(36.89901406488422, 30.657388079378862),
      category: LocationCategory.faculty,
      workingHours: '08:00 - 17:00',
      services: ['Simülasyon Laboratuvarları', 'Beceri Laboratuvarları'],
    ),
    CampusLocation(
      id: 'iibf',
      name: 'İİBF',
      description: 'İktisadi ve İdari Bilimler Fakültesi',
      position: LatLng(36.895560618663175, 30.652302611070017),
      category: LocationCategory.faculty,
      workingHours: '08:00 - 17:00',
      services: [
        'Derslikler',
        'Seminer Salonları',
        'Bilgisayar Laboratuvarları'
      ],
    ),
    CampusLocation(
      id: 'ziraat_fakultesi',
      name: 'Ziraat Fakültesi',
      description: 'Tarım ve hayvancılık bilimleri',
      position: LatLng(36.89907114780975, 30.650473394164827),
      category: LocationCategory.faculty,
      workingHours: '08:00 - 17:00',
      services: [
        'Araştırma Çiftlikleri',
        'Laboratuvarlar',
        'Seracılık Alanları'
      ],
    ),
    CampusLocation(
      id: 'su_urunleri',
      name: 'Su Ürünleri Fakültesi',
      description: 'Balıkçılık ve su ürünleri bilimleri',
      position: LatLng(36.89832041250407, 30.6478287360597),
      category: LocationCategory.faculty,
      workingHours: '08:00 - 17:00',
      services: ['Akvaryum Sistemleri', 'Araştırma Laboratuvarları'],
    ),
    CampusLocation(
      id: 'guzel_sanatlar',
      name: 'Güzel Sanatlar Fakültesi',
      description: 'Sanat ve tasarım eğitimi',
      position: LatLng(36.89466520633171, 30.660834948892706),
      category: LocationCategory.faculty,
      workingHours: '08:00 - 17:00',
      services: ['Atölyeler', 'Sergi Salonları', 'Sanat Stüdyoları'],
    ),
    CampusLocation(
      id: 'turizm_fakultesi',
      name: 'Turizm Fakültesi',
      description: 'Turizm ve otelcilik eğitimi',
      position: LatLng(36.894496281763544, 30.65645288990452),
      category: LocationCategory.faculty,
      workingHours: '08:00 - 17:00',
      services: [
        'Uygulama Oteli',
        'Mutfak Laboratuvarları',
        'Turizm Rehberliği'
      ],
    ),
    CampusLocation(
      id: 'besyo',
      name: 'BESYO',
      description: 'Beden Eğitimi ve Spor Yüksekokulu',
      position: LatLng(36.89433256988802, 30.653924006431698),
      category: LocationCategory.faculty,
      workingHours: '08:00 - 17:00',
      services: ['Spor Salonları', 'Fitness Merkezleri', 'Yüzme Havuzu'],
    ),
    CampusLocation(
      id: 'ydyo',
      name: 'Yabancı Diller Y.O',
      description: 'Yabancı dil eğitimi yüksekokulu',
      position: LatLng(36.89327929441869, 30.642902068282826),
      category: LocationCategory.faculty,
      workingHours: '08:00 - 17:00',
      services: ['Dil Laboratuvarları', 'Konuşma Kulüpleri'],
    ),
    CampusLocation(
      id: 'merkezi_yemekhane',
      name: 'Merkezi Yemekhane',
      description: 'Ana yemekhane ve kafeterya',
      position: LatLng(36.89512835715002, 30.655535272846794),
      category: LocationCategory.dining,
      workingHours: '07:00 - 22:00',
      services: ['Sıcak Yemek', 'Kafeterya', 'Öğrenci İndirimi'],
    ),
    CampusLocation(
      id: 'zilli_tavuk',
      name: 'Zilli Tavuk',
      description: 'Tavuk ve fast-food restoranı',
      position: LatLng(36.89898622320642, 30.652846893364018),
      category: LocationCategory.dining,
      workingHours: '09:00 - 23:00',
      services: ['Fast-food', 'Paket Servis'],
    ),
    CampusLocation(
      id: 'yakut_doner',
      name: 'Yakut Döner',
      description: 'Döner ve hızlı yemek seçenekleri',
      position: LatLng(36.898843583907905, 30.653074210565926),
      category: LocationCategory.dining,
      workingHours: '09:00 - 23:00',
      services: ['Döner', 'Öğrenci Menüsü'],
    ),
    CampusLocation(
      id: 'tart_cafe',
      name: 'Tart Cafe',
      description: 'Kafe ve tatlılar',
      position: LatLng(36.89811215112476, 30.65326464739893),
      category: LocationCategory.dining,
      workingHours: '09:00 - 23:00',
      services: ['Kahve', 'Tatlı', 'Çalışma Alanı'],
    ),
    CampusLocation(
      id: 'durumgiller',
      name: 'Dürümgiller',
      description: 'Dürüm ve ızgara ürünleri',
      position: LatLng(36.8937237171942, 30.659065883690406),
      category: LocationCategory.dining,
      workingHours: '10:00 - 00:00',
      services: ['Dürüm', 'Izgara', 'Paket Servis'],
    ),
    CampusLocation(
      id: 'cafe_haylaz',
      name: 'Cafe Haylaz',
      description: 'Öğrenci kafesi',
      position: LatLng(36.89304908096722, 30.658776205132146),
      category: LocationCategory.dining,
      workingHours: '09:00 - 23:00',
      services: ['Kahve', 'Atıştırmalık', 'Oyun Alanı'],
    ),
    CampusLocation(
      id: 'olbia_carsisi',
      name: 'Olbia Çarşısı',
      description: 'Kampüs alışveriş merkezi',
      position: LatLng(36.893651226962355, 30.659689853027338),
      category: LocationCategory.shopping,
      workingHours: '09:00 - 22:00',
      services: ['Mağazalar', 'Kafeler', 'Bankalar', 'ATM'],
    ),
    CampusLocation(
      id: 'yakut_carsisi',
      name: 'Yakut Çarşısı',
      description: 'Kampüs içi alışveriş noktası',
      position: LatLng(36.89801340585834, 30.65309714480034),
      category: LocationCategory.shopping,
      workingHours: '09:00 - 22:00',
      services: ['Mağazalar', 'Restoran', 'Kırtasiye'],
    ),
    CampusLocation(
      id: 'ceypark_carsisi',
      name: 'CeyPark Çarşısı',
      description: 'Kampüs alışveriş ve sosyal alan',
      position: LatLng(36.89162539642491, 30.641732625150482),
      category: LocationCategory.shopping,
      workingHours: '09:00 - 22:00',
      services: ['Mağazalar', 'Kafeler', 'Sosyal Alanlar'],
    ),
    CampusLocation(
      id: 'spor_salonu',
      name: 'Spor Salonu',
      description: 'Ana spor kompleksi',
      position: LatLng(36.89461354129002, 30.649564675483912),
      category: LocationCategory.sports,
      workingHours: '06:00 - 23:00',
      services: ['Fitness', 'Basketbol', 'Voleybol', 'Tenis'],
    ),
    CampusLocation(
      id: 'gazi_mk_spor',
      name: 'Gazi M.K Spor Salonu',
      description: 'İkinci spor kompleksi',
      position: LatLng(36.89204799116488, 30.64805190959011),
      category: LocationCategory.sports,
      workingHours: '06:00 - 23:00',
      services: ['Kapalı Spor Alanları', 'Grup Egzersizleri'],
    ),
    CampusLocation(
      id: 'merkez_kutuphane',
      name: 'Merkez Kütüphane',
      description: 'Ana kütüphane ve araştırma merkezi',
      position: LatLng(36.89614299649112, 30.658929008470597),
      category: LocationCategory.library,
      workingHours: '7/24',
      services: [
        'Kitap Ödünç',
        'Çalışma Alanları',
        'Bilgisayar Erişimi',
      ],
    ),
    CampusLocation(
      id: 'ataturk_konferans',
      name: 'Atatürk Konferans Salonu',
      description: 'Ana konferans ve etkinlik salonu',
      position: LatLng(36.89731524631451, 30.655502486419273),
      category: LocationCategory.administrative,
      workingHours: 'Etkinlik Saatlerinde',
      services: ['Konferanslar', 'Mezuniyet Törenleri', 'Kültürel Etkinlikler'],
    ),
    CampusLocation(
      id: 'rektorluk',
      name: 'Akdeniz Üniversitesi Rektörlüğü',
      description: 'Rektörlük ve idari birimler',
      position: LatLng(36.895768104966784, 30.657539959529476),
      category: LocationCategory.administrative,
      workingHours: '08:00 - 17:00',
      services: ['Rektörlük', 'Genel Sekreterlik', 'İdari Ofisler'],
    ),
    CampusLocation(
      id: 'sks_daire_baskanligi',
      name: 'Sağlık Kültür ve Spor Dairesi Başkanlığı',
      description:
          'Öğrenci sağlık, kültür ve spor hizmetlerinin yürütüldüğü birim.',
      position: LatLng(36.896007333069576, 30.654916871207323),
      category: LocationCategory.health,
      workingHours: '08:00 - 17:00',
      services: [
        'Öğrenci Sağlık Hizmetleri',
        'Kültürel Etkinlikler',
        'Spor Faaliyetleri',
      ],
    ),
    CampusLocation(
      id: 'erkek_ogrenci_yurdu',
      name: 'Erkek Öğrenci Yurdu',
      description: 'Kampüs içi erkek öğrenci yurdu',
      position: LatLng(36.893123717159305, 30.64117338388825),
      category: LocationCategory.dormitory,
      workingHours: '7/24',
      services: ['Konaklama', 'Etüd Odası', 'Çamaşırhane'],
    ),
    CampusLocation(
      id: 'kiz_ogrenci_yurdu',
      name: 'Kız Öğrenci Yurdu',
      description: 'Kampüs içi kız öğrenci yurdu',
      position: LatLng(36.89245065439349, 30.65757527933566),
      category: LocationCategory.dormitory,
      workingHours: '7/24',
      services: ['Konaklama', 'Etüd Odası', 'Çamaşırhane'],
    ),
    CampusLocation(
      id: 'akdeniz_hastanesi',
      name: 'Akdeniz Üniversitesi Hastanesi',
      description: 'Üniversite hastanesi ve sağlık hizmetleri',
      position: LatLng(36.89850941723252, 30.661002691229964),
      category: LocationCategory.health,
      workingHours: '7/24',
      services: ['Acil Servis', 'Poliklinikler', 'Yatan Hasta Servisleri'],
    ),
  ];

  static List<CampusLocation> getLocationsByCategory(
      LocationCategory category) {
    return locations
        .where((location) => location.category == category)
        .toList();
  }

  static List<CampusLocation> searchLocations(String query) {
    if (query.isEmpty) return locations;

    return locations.where((location) {
      return location.name.toLowerCase().contains(query.toLowerCase()) ||
          (location.description?.toLowerCase().contains(query.toLowerCase()) ??
              false);
    }).toList();
  }

  static CampusLocation? getLocationById(String id) {
    try {
      return locations.firstWhere((location) => location.id == id);
    } catch (e) {
      return null;
    }
  }
}

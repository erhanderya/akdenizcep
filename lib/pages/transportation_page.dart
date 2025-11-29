import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

const kPrimary = Color.fromARGB(255, 21, 138, 173);
const kPrimaryLight = Color(0xFF00C3A5);

class UlasimPage extends StatefulWidget {
  const UlasimPage({super.key});

  @override
  State<UlasimPage> createState() => _UlasimPageState();
}

class _UlasimPageState extends State<UlasimPage> {
  int selectedLine = 102; // AÜ102 / AÜ103
  bool isWeekday = true; // Hafta içi / Hafta sonu


  int _toMinutes(String t) {
    final parts = t.split(':');
    final h = int.parse(parts[0]);
    final m = int.parse(parts[1]);
    return h * 60 + m;
  }

  List<String> _mergeWeekend(Map<String, dynamic> route) {
    final set = <String>{};
    set.addAll(List<String>.from(route['cumartesi']));
    set.addAll(List<String>.from(route['pazar']));
    final list = set.toList();
    list.sort((a, b) => _toMinutes(a).compareTo(_toMinutes(b)));
    return list;
  }

  List<String> _getTimes(Map<String, dynamic> route) {
    if (isWeekday) {
      return List<String>.from(route['haftaIci']);
    } else {
      return _mergeWeekend(route);
    }
  }

  String _findNextTime(List<String> times) {
    final now = TimeOfDay.now();
    final nowMin = now.hour * 60 + now.minute;

    for (final t in times) {
      final total = _toMinutes(t);
      if (total >= nowMin) {
        final diff = total - nowMin;
        return '$t (${diff} dk sonra)';
      }
    }
    return 'Bugün başka sefer yok';
  }

  int _findNextIndex(List<String> times) {
    final now = TimeOfDay.now();
    final nowMin = now.hour * 60 + now.minute;
    for (int i = 0; i < times.length; i++) {
      if (_toMinutes(times[i]) >= nowMin) return i;
    }
    return -1;
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> gidis =
        selectedLine == 102 ? au102_route1 : au103_route1;
    final Map<String, dynamic> donus =
        selectedLine == 102 ? au102_route2 : au103_route2;

    final gidisTimes = _getTimes(gidis);
    final donusTimes = _getTimes(donus);

    final nextGidis = _findNextTime(gidisTimes);
    final nextDonus = _findNextTime(donusTimes);

    final nextGidisIndex = _findNextIndex(gidisTimes);
    final nextDonusIndex = _findNextIndex(donusTimes);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _lineSelectorCard(),

            const SizedBox(height: 16),

            _daySelectorCard(),

            const SizedBox(height: 16),

            _nextDepartureCard(
              gidisBaslik: selectedLine == 102
                  ? 'Fen Fakültesi'
                  : 'Adli Tıp / Teknokent',
              donusBaslik: 'Meltem Kapısı',
              nextGidis: nextGidis,
              nextDonus: nextDonus,
            ),

            const SizedBox(height: 16),

            _allTimesCard(
              gidisBaslik: selectedLine == 102
                  ? 'Fen Fakültesi Kalkış'
                  : 'Adli Tıp Kalkış',
              donusBaslik: 'Meltem Kapısı Kalkış',
              gidisTimes: gidisTimes,
              donusTimes: donusTimes,
              nextGidisIndex: nextGidisIndex,
              nextDonusIndex: nextDonusIndex,
            ),

            const SizedBox(height: 16),

            _routeMapCard(),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimary,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {
                  final data =
                      selectedLine == 102 ? au102_route1 : au103_route1;
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    builder: (_) => DurakAramaSheet(data: data),
                  );
                },
                icon: const Icon(Icons.search),
                label: const Text('Durak Ara'),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _lineSelectorCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [kPrimary, kPrimaryLight],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: _segmentButton(
              text: 'AÜ102',
              icon: Icons.directions_bus_filled_rounded,
              selected: selectedLine == 102,
              onTap: () => setState(() => selectedLine = 102),
            ),
          ),
          Expanded(
            child: _segmentButton(
              text: 'AÜ103',
              icon: Icons.directions_bus_filled_rounded,
              selected: selectedLine == 103,
              onTap: () => setState(() => selectedLine = 103),
            ),
          ),
        ],
      ),
    );
  }

  Widget _daySelectorCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: _daySegment(
              text: 'Hafta İçi',
              icon: Icons.work_outline,
              selected: isWeekday,
              onTap: () => setState(() => isWeekday = true),
            ),
          ),
          Expanded(
            child: _daySegment(
              text: 'Hafta Sonu',
              icon: Icons.weekend_outlined,
              selected: !isWeekday,
              onTap: () => setState(() => isWeekday = false),
            ),
          ),
        ],
      ),
    );
  }

  Widget _nextDepartureCard({
    required String gidisBaslik,
    required String donusBaslik,
    required String nextGidis,
    required String nextDonus,
  }) {
    String extractTime(String s) {
      if (!s.contains(':')) {
        return s;
      }
      final p = s.split(' ');
      return p.isNotEmpty ? p.first : s;
    }

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFA726), Color(0xFFFF7043)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: const [
              Icon(Icons.schedule, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'En Yakın Kalkış',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _nextBox(
                  title: gidisBaslik,
                  time: extractTime(nextGidis),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _nextBox(
                  title: donusBaslik,
                  time: extractTime(nextDonus),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _allTimesCard({
    required String gidisBaslik,
    required String donusBaslik,
    required List<String> gidisTimes,
    required List<String> donusTimes,
    required int nextGidisIndex,
    required int nextDonusIndex,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: const [
              Icon(Icons.list_alt, color: kPrimary),
              SizedBox(width: 8),
              Text(
                'Tüm Sefer Saatleri',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _timesColumn(
                  title: gidisBaslik,
                  times: gidisTimes,
                  highlightIndex: nextGidisIndex,
                  highlightColor: const Color(0xFFE8F5E9),
                  textColor: Colors.green.shade700,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _timesColumn(
                  title: donusBaslik,
                  times: donusTimes,
                  highlightIndex: nextDonusIndex,
                  highlightColor: const Color(0xFFE3F2FD),
                  textColor: Colors.blue.shade700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _routeMapCard() {
    final String asset =
        selectedLine == 102 ? 'assets/au102_map.png' : 'assets/au103_map.png';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.map_outlined, color: Colors.purple),
              const SizedBox(width: 8),
              Text(
                'AÜ$selectedLine Güzergahı',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.zoom_in,
                size: 18,
                color: Colors.grey[500],
              ),
            ],
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => _showZoomableMap(asset),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.asset(
                  asset,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: const Color(0xFFF1F1F1),
                    child: const Center(
                      child: Text('Harita görselini ekle (assets)'),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showZoomableMap(String asset) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                color: Colors.white,
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Image.asset(
                    asset,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Yakınlaştırmak için sıkıştırın',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _segmentButton({
    required String text,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: selected ? kPrimary : Colors.white,
            ),
            const SizedBox(width: 6),
            Text(
              text,
              style: TextStyle(
                color: selected ? kPrimary : Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _daySegment({
    required String text,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: selected ? kPrimary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: selected ? kPrimary : Colors.grey[600],
            ),
            const SizedBox(width: 6),
            Text(
              text,
              style: TextStyle(
                color: selected ? kPrimary : Colors.grey[700],
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _nextBox({required String title, required String time}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.96),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              time,
              style: const TextStyle(
                fontSize: 20,
                color: Color(0xFFF57C00),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _timesColumn({
    required String title,
    required List<String> times,
    required int highlightIndex,
    required Color highlightColor,
    required Color textColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: highlightColor.withOpacity(0.4),
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 260,
            child: ListView.builder(
              itemCount: times.length,
              padding: EdgeInsets.zero,
              itemBuilder: (context, index) {
                final isNext = index == highlightIndex;
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 3),
                  decoration: BoxDecoration(
                    color: isNext ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: isNext
                        ? Border.all(color: textColor, width: 1.2)
                        : null,
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  child: Center(
                    child: Text(
                      times[index],
                      style: TextStyle(
                        color: isNext ? textColor : Colors.black87,
                        fontWeight: isNext ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


class DurakAramaSheet extends StatefulWidget {
  final Map<String, dynamic> data;
  const DurakAramaSheet({super.key, required this.data});

  @override
  State<DurakAramaSheet> createState() => _DurakAramaSheetState();
}

class _DurakAramaSheetState extends State<DurakAramaSheet> {
  String query = '';

  Future<void> _openStopOnMaps(String stopName) async {
    final q = Uri.encodeComponent('$stopName Antalya');
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$q');

    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      try {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      } catch (e2) {
        debugPrint('URL açılamadı: $e2');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> duraklar =
        List<Map<String, dynamic>>.from(widget.data['duraklar']);

    final filtered = duraklar.where((d) {
      final ad = (d['ad'] as String).toLowerCase();
      return ad.contains(query.toLowerCase());
    }).toList();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 16,
        left: 16,
        right: 16,
      ),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.75,
        child: Column(
          children: [
            const Text(
              'Durak Ara',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              decoration: const InputDecoration(
                hintText: 'Durak adı...',
                prefixIcon: Icon(Icons.search),
                filled: true,
                fillColor: Color(0xFFF0F0F0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
              onChanged: (v) => setState(() => query = v),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (_, i) {
                  final d = filtered[i];
                  final ad = d['ad'] as String;
                  return ListTile(
                    leading: const Icon(Icons.bus_alert_rounded),
                    title: Text(ad),
                    subtitle: Text('Durak No: ${d["id"]}'),
                    onTap: () => _openStopOnMaps(ad),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}



final Map<String, dynamic> au102_route1 = {
  "guzergah": "AÜ102 – Adli Tıp → Meltem Kapısı",
  "haftaIci": [
    "06:25",
    "06:55",
    "07:25",
    "07:55",
    "08:07",
    "08:19",
    "08:31",
    "08:43",
    "08:55",
    "09:07",
    "09:19",
    "09:34",
    "09:48",
    "10:05",
    "10:22",
    "10:39",
    "10:56",
    "11:13",
    "11:30",
    "11:47",
    "12:04",
    "12:21",
    "12:38",
    "12:55",
    "13:12",
    "13:29",
    "13:46",
    "14:03",
    "14:20",
    "14:37",
    "14:54",
    "15:06",
    "15:18",
    "15:30",
    "15:42",
    "15:54",
    "16:06",
    "16:18",
    "16:30",
    "16:42",
    "16:54",
    "17:06",
    "17:18",
    "17:33",
    "17:51",
    "18:11",
    "18:31",
    "18:51",
    "19:11",
    "19:31",
    "20:11",
    "20:51",
    "21:16",
    "21:46"
  ],
  "cumartesi": [
    "06:43",
    "07:07",
    "07:31",
    "07:55",
    "08:19",
    "08:43",
    "09:07",
    "09:31",
    "09:55",
    "10:19",
    "10:43",
    "11:07",
    "11:31",
    "11:55",
    "12:19",
    "12:43",
    "13:07",
    "13:31",
    "13:55",
    "14:19",
    "14:43",
    "15:07",
    "15:31",
    "15:55",
    "16:19",
    "16:43",
    "17:07",
    "17:31",
    "17:55",
    "18:19",
    "18:46",
    "19:16",
    "19:46",
    "20:16",
    "20:46",
    "21:16",
    "21:46"
  ],
  "pazar": [
    "06:43",
    "07:07",
    "07:31",
    "07:55",
    "08:19",
    "08:43",
    "09:07",
    "09:31",
    "09:55",
    "10:19",
    "10:43",
    "11:07",
    "11:31",
    "11:55",
    "12:19",
    "12:43",
    "13:07",
    "13:31",
    "13:55",
    "14:19",
    "14:43",
    "15:07",
    "15:31",
    "15:55",
    "16:19",
    "16:43",
    "17:07",
    "17:31",
    "17:55",
    "18:19",
    "18:46",
    "19:16",
    "19:46",
    "20:16",
    "20:46",
    "21:16",
    "21:46"
  ],
  "duraklar": [
    {"id": 10953, "ad": "Akdeniz Üniversitesi Yakut Çarşı"},
    {"id": 14143, "ad": "Akdeniz Üniversitesi Mühendislik Fakültesi-2"},
    {"id": 14117, "ad": "Akdeniz Üniversitesi Su Ürünleri-1"},
    {"id": 14119, "ad": "Akdeniz Üniversitesi İletişim Fakültesi"},
    {"id": 10958, "ad": "Akdeniz Üniversitesi Eğitim Fakültesi-2"},
    {"id": 14124, "ad": "Akdeniz Üniversitesi Gazi Mustafa Kemal Spor Salonu"},
    {"id": 10959, "ad": "Akdeniz Üniversitesi Hukuk Fakültesi-3"},
    {"id": 10960, "ad": "Akdeniz Üniversitesi Erkek Öğrenci Yurdu"},
  ]
};

final Map<String, dynamic> au102_route2 = {
  "guzergah": "AÜ102 - Meltem Kapısı → Adli Tıp",
  "haftaIci": [
    "06:37",
    "07:07",
    "07:37",
    "08:07",
    "08:19",
    "08:31",
    "08:43",
    "08:55",
    "09:07",
    "09:19",
    "09:31",
    "09:46",
    "10:00",
    "10:17",
    "10:34",
    "10:51",
    "11:08",
    "11:25",
    "11:42",
    "11:59",
    "12:16",
    "12:33",
    "12:50",
    "13:07",
    "13:24",
    "13:41",
    "13:58",
    "14:15",
    "14:32",
    "14:49",
    "15:06",
    "15:18",
    "15:30",
    "15:42",
    "15:54",
    "16:06",
    "16:18",
    "16:30",
    "16:42",
    "16:54",
    "17:06",
    "17:18",
    "17:30",
    "17:45",
    "18:03",
    "18:23",
    "18:43",
    "19:03",
    "19:23",
    "19:43",
    "20:23",
    "21:03",
    "21:28",
    "21:58"
  ],
  "cumartesi": [
    "06:55",
    "07:19",
    "07:43",
    "08:07",
    "08:31",
    "08:55",
    "09:19",
    "09:43",
    "10:07",
    "10:31",
    "10:55",
    "11:19",
    "11:43",
    "12:07",
    "12:31",
    "12:55",
    "13:19",
    "13:43",
    "14:07",
    "14:31",
    "14:55",
    "15:19",
    "15:43",
    "16:07",
    "16:31",
    "16:55",
    "17:19",
    "17:43",
    "18:07",
    "18:31",
    "18:58",
    "19:28",
    "19:58",
    "20:28",
    "20:58",
    "21:28",
    "21:58"
  ],
  "pazar": [
    "06:55",
    "07:19",
    "07:43",
    "08:07",
    "08:31",
    "08:55",
    "09:19",
    "09:43",
    "10:07",
    "10:31",
    "10:55",
    "11:19",
    "11:43",
    "12:07",
    "12:31",
    "12:55",
    "13:19",
    "13:43",
    "14:07",
    "14:31",
    "14:55",
    "15:19",
    "15:43",
    "16:07",
    "16:31",
    "16:55",
    "17:19",
    "17:43",
    "18:07",
    "18:31",
    "18:58",
    "19:28",
    "19:58",
    "20:28",
    "20:58",
    "21:28",
    "21:58"
  ],
  "duraklar": List<Map<String, dynamic>>.from(
    (au102_route1["duraklar"] as List).reversed,
  ),
};

final Map<String, dynamic> au103_route1 = {
  "guzergah": "AÜ103 – Adli Tıp → Teknokent → Meltem Kapısı",
  "haftaIci": [
    "06:31",
    "06:51",
    "07:11",
    "07:31",
    "07:51",
    "08:01",
    "08:11",
    "08:21",
    "08:31",
    "08:41",
    "08:51",
    "09:01",
    "09:11",
    "09:21",
    "09:31",
    "09:41",
    "09:51",
    "10:01",
    "10:11",
    "10:21",
    "10:36",
    "10:51",
    "11:06",
    "11:21",
    "11:36",
    "11:51",
    "12:06",
    "12:21",
    "12:36",
    "12:51",
    "13:06",
    "13:21",
    "13:36",
    "13:51",
    "14:06",
    "14:16",
    "14:26",
    "14:36",
    "14:46",
    "14:56",
    "15:06",
    "15:20",
    "15:28",
    "15:36",
    "15:44",
    "15:52",
    "16:00",
    "16:08",
    "16:16",
    "16:24",
    "16:32",
    "16:40",
    "16:48",
    "16:56",
    "17:06",
    "17:16",
    "17:26",
    "17:36",
    "17:46",
    "18:01",
    "18:16",
    "18:31",
    "18:46",
    "19:01",
    "19:21",
    "19:41",
    "20:01",
    "20:21",
    "20:41",
    "21:01",
    "21:31",
    "22:01"
  ],
  "cumartesi": [
    "06:31",
    "06:56",
    "07:21",
    "07:46",
    "08:11",
    "08:36",
    "09:01",
    "09:26",
    "09:51",
    "10:16",
    "10:41",
    "11:06",
    "11:31",
    "11:56",
    "12:21",
    "12:46",
    "13:11",
    "13:36",
    "14:01",
    "14:26",
    "14:51",
    "15:16",
    "15:41",
    "16:06",
    "16:31",
    "16:56",
    "17:21",
    "17:46",
    "18:11",
    "18:36",
    "19:01",
    "19:31",
    "20:01",
    "20:31",
    "21:01",
    "21:31",
    "22:01"
  ],
  "pazar": [
    "06:31",
    "06:56",
    "07:21",
    "07:46",
    "08:11",
    "08:36",
    "09:01",
    "09:26",
    "09:51",
    "10:16",
    "10:41",
    "11:06",
    "11:31",
    "11:56",
    "12:21",
    "12:46",
    "13:11",
    "13:36",
    "14:01",
    "14:26",
    "14:51",
    "15:16",
    "15:41",
    "16:06",
    "16:31",
    "16:56",
    "17:21",
    "17:46",
    "18:11",
    "18:36",
    "19:01",
    "19:31",
    "20:01",
    "20:31",
    "21:01",
    "21:31",
    "22:01"
  ],
  "duraklar": [
    {"id": 14115, "ad": "Akdeniz Üniversitesi Teknokent-2"},
    {"id": 14117, "ad": "Akdeniz Üniversitesi Su Ürünleri-1"},
    {"id": 14211, "ad": "Akdeniz Üniversitesi Enformatik Bölümü"},
    {"id": 14121, "ad": "Akdeniz Üniversitesi Kız Öğrenci Yurdu"},
    {"id": 14122, "ad": "Akdeniz Üniversitesi İlahiyat Fakültesi"},
    {"id": 11506, "ad": "Akdeniz Üniversitesi Edebiyat Fakültesi-1"},
    {"id": 14112, "ad": "Akdeniz Üniversitesi Eğitim Fakültesi-1"},
    {"id": 14118, "ad": "Akdeniz Üniversitesi Stadyum"},
    {"id": 14145, "ad": "Akdeniz Üniversitesi Halı Saha"},
    {"id": 14146, "ad": "Akdeniz Üniversitesi Tenis Kortları"},
    {"id": 11514, "ad": "Akdeniz Üniversitesi Spor Bilimleri Fakültesi-2"},
    {"id": 10960, "ad": "Akdeniz Üniversitesi Erkek Öğrenci Yurdu"},
    {"id": 14373, "ad": "Akdeniz Üniversitesi Doğu Kapısı Girişi"},
  ]
};

final Map<String, dynamic> au103_route2 = {
  "guzergah": "AÜ103 - Meltem Kapısı → Teknokent → Adli Tıp",
  "haftaIci": [
    "06:45",
    "07:05",
    "07:25",
    "07:45",
    "08:05",
    "08:15",
    "08:25",
    "08:35",
    "08:45",
    "08:55",
    "09:05",
    "09:15",
    "09:25",
    "09:35",
    "09:45",
    "09:55",
    "10:05",
    "10:15",
    "10:25",
    "10:35",
    "10:50",
    "11:05",
    "11:20",
    "11:35",
    "11:50",
    "12:05",
    "12:20",
    "12:35",
    "12:50",
    "13:20",
    "13:35",
    "13:50",
    "14:05",
    "14:20",
    "14:30",
    "14:40",
    "14:50",
    "15:00",
    "15:10",
    "15:18",
    "15:26",
    "15:34",
    "15:42",
    "15:50",
    "15:58",
    "16:06",
    "16:14",
    "16:22",
    "16:30",
    "16:38",
    "16:46",
    "16:54",
    "17:02",
    "17:10",
    "17:20",
    "17:30",
    "17:40",
    "17:50",
    "18:00",
    "18:15",
    "18:30",
    "18:45",
    "19:00",
    "19:15",
    "19:35",
    "19:55",
    "20:15",
    "20:45",
    "21:15",
    "21:45",
    "22:15"
  ],
  "cumartesi": [
    "06:45",
    "07:10",
    "07:35",
    "08:00",
    "08:25",
    "08:50",
    "09:15",
    "09:40",
    "10:05",
    "10:30",
    "10:55",
    "11:20",
    "11:45",
    "12:10",
    "12:35",
    "13:00",
    "13:25",
    "13:50",
    "14:15",
    "14:40",
    "15:05",
    "15:30",
    "15:55",
    "16:20",
    "16:45",
    "17:10",
    "17:35",
    "18:00",
    "18:25",
    "18:50",
    "19:15",
    "19:45",
    "20:15",
    "20:45",
    "21:15",
    "21:45",
    "22:15"
  ],
  "pazar": [
    "06:45",
    "07:10",
    "07:35",
    "08:00",
    "08:25",
    "08:50",
    "09:15",
    "09:40",
    "10:05",
    "10:30",
    "10:55",
    "11:20",
    "11:45",
    "12:10",
    "12:35",
    "13:00",
    "13:25",
    "13:50",
    "14:15",
    "14:40",
    "15:15",
    "15:30",
    "15:55",
    "16:20",
    "16:45",
    "17:10",
    "17:35",
    "18:00",
    "18:25",
    "18:50",
    "19:15",
    "19:45",
    "20:15",
    "20:45",
    "21:15",
    "21:45",
    "22:15"
  ],
  "duraklar": List<Map<String, dynamic>>.from(
    (au103_route1["duraklar"] as List).reversed,
  ),
};

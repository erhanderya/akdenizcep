import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/date_symbol_data_local.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:akdeniz_cep/services/event_service.dart';
import 'package:akdeniz_cep/models/event.dart';
import 'package:akdeniz_cep/widgets/society_event_card.dart';
import 'package:akdeniz_cep/pages/event_detail_page.dart';
import 'package:intl/intl.dart';
import 'package:weather/weather.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
    final EventService _eventService = EventService();
  bool isLoading = true;
  final WeatherFactory hava = WeatherFactory(
    "c5a6d8532079fc4ea84eefc593381ee0",
    language: Language.TURKISH,
  );
  bool _isDateFormattingReady = false;
  final CarouselSliderController _controller = CarouselSliderController();
  int _current = 0;
  Weather? _weather;
  String? iconCode;
  final String baseUrl = 'https://api.openweathermap.org/data/2.5';

  final List<String> imgList = [
    'https://picsum.photos/800/400?random=1',
    'https://picsum.photos/800/400?random=2',
    'https://picsum.photos/800/400?random=3',
    'https://picsum.photos/800/400?random=4',
  ];

  @override
  void initState() {
    super.initState();
    _initializeLocaleData();
    _loadWeather();
    fetchWeather();
  }

  Future<void> _initializeLocaleData() async {
    try {
      await initializeDateFormatting('tr_TR', null);
    } catch (e) {
      debugPrint('Date formatting init failed: $e');
    } finally {
      if (!mounted) return;
      setState(() {
        _isDateFormattingReady = true;
      });
    }
  }

  Future<void> _loadWeather() async {
    setState(() {
      isLoading = true;
    });
    try {
      final weather = await hava.currentWeatherByCityName("Antalya");
      if (!mounted) return;
      setState(() {
        _weather = weather;
      });
    } catch (e) {
      debugPrint('Weather fetch failed: $e');
    } finally {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<Map<String, dynamic>> getWeather(String city) async {
    final response = await http.get(
      Uri.parse(
          '$baseUrl/weather?q=$city&appid=c5a6d8532079fc4ea84eefc593381ee0&units=metric'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  Future<void> fetchWeather() async {
    try {
      final weatherData = await getWeather('Antalya');
      if (!mounted) return;
      setState(() {
        iconCode = weatherData['weather'][0]['icon'];
      });
    } catch (e) {
      debugPrint('Weather icon fetch failed: $e');
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }

  Future<void> _launchPhone(String phoneNumber) async {
    final uri = Uri(scheme: 'tel', path: phoneNumber);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch phone dialer for $phoneNumber');
    }
  }

  Widget currentTemp({Color color = Colors.white, double fontSize = 28}) {
    final double? temp = _weather?.temperature?.celsius;
    return Text(
      temp != null ? temp.toStringAsFixed(0) : '--',
      style: TextStyle(
          color: color, fontSize: fontSize, fontWeight: FontWeight.bold),
    );
  }

  Widget currentHumidity({Color color = Colors.white, double fontSize = 16}) {
    final double? humidity = _weather?.humidity?.toDouble();
    return Text(
      humidity != null ? humidity.toStringAsFixed(0) : '--',
      style: TextStyle(
          color: color, fontSize: fontSize, fontWeight: FontWeight.w600),
    );
  }

  Widget _buildTermProgressCard() {
    final now = DateTime.now();

    final termStart = DateTime(now.year, 9, 30); 
    final termEnd = DateTime(now.year, 12, 21); 

    double progress;

    if (now.isBefore(termStart)) {
      progress = 0;
    } else if (now.isAfter(termEnd)) {
      progress = 1;
    } else {
      final totalDays = termEnd.difference(termStart).inDays;
      final passedDays = now.difference(termStart).inDays;
      progress = passedDays / totalDays;
    }

    progress = progress.clamp(0.0, 1.0);
    final percentage = (progress * 100).round();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: const Color(0xFF1565C0).withOpacity(0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SizedBox(width: 8),
              const Text(
                'Dönem İlerlemesi',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '%$percentage',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation(
                Color.fromARGB(255, 21, 138, 173),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Derslerin sona erme tarihi: 21 Aralık',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
              child: _buildHeader(),
            ),
            _buildCarouselSliderIndicator(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: _buildQuickAccessSection(),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: _buildTermProgressCard(),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: _buildUpcomingSocietyEvents(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingSocietyEvents() {
    return StreamBuilder<List<Event>>(
      stream: _eventService.getEventsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const SizedBox();
        }
        final events = (snapshot.data ?? [])
            .where((event) {
              final now = DateTime.now();
              final diff = event.date.difference(now).inDays;
              return diff >= 0 && diff <= 14;
            })
            .toList();
        if (events.isEmpty) {
          return const SizedBox();
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Yaklaşan Topluluk Etkinlikleri',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 10),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: events.length > 3 ? 3 : events.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final event = events[index];
                return SocietyEventCard(
                  event: event,
                  dateFormat: DateFormat('d MMM, HH:mm', 'tr_TR'),
                  attendeeCount: event.attendeeCount,
                  canDelete: false,
                  onDelete: null,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EventDetailPage(
                          event: event,
                          isPresident: false,
                          societyId: event.societyId,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 42,
              width: 42,
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: Center(
                child: iconCode != null
                    ? Image.network(
                        'https://openweathermap.org/img/wn/$iconCode@2x.png',
                        height: 30,
                        fit: BoxFit.contain,
                      )
                    : (isLoading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.wb_sunny,
                            color: Colors.orange, size: 26)),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (!isLoading)
                      currentTemp(color: Colors.black87, fontSize: 26),
                    const SizedBox(width: 4),
                    const Text(
                      '°C',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (!isLoading)
                      Row(
                        children: [
                          Icon(MdiIcons.waterPercent,
                              size: 18, color: Colors.blueGrey),
                          const SizedBox(width: 4),
                          currentHumidity(color: Colors.black87, fontSize: 14),
                          const Text(
                            '%',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.location_on,
                        size: 14, color: Colors.redAccent),
                    const SizedBox(width: 4),
                    Text(
                      'Antalya',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            (_isDateFormattingReady
                    ? DateFormat('dd MMM', 'tr_TR')
                    : DateFormat('dd MMM'))
                .format(DateTime.now()),
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCarouselSliderIndicator() {
    final List<Widget> imageSliders = imgList
        .map((item) => Container(
              margin: EdgeInsets.zero,
              child: ClipRRect(
                borderRadius: BorderRadius.zero,
                child: Stack(
                  children: <Widget>[
                    Positioned.fill(
                      child: Image.network(
                        item,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) {
                            return child;
                          }
                          return const Center(
                              child: CircularProgressIndicator());
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey.shade300,
                            child: const Center(
                                child: Icon(Icons.image, size: 48)),
                          );
                        },
                      ),
                    ),
                    Positioned(
                      bottom: 0.0,
                      left: 0.0,
                      right: 0.0,
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color.fromARGB(120, 0, 0, 0),
                              Color.fromARGB(0, 0, 0, 0)
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                        padding: const EdgeInsets.all(16),
                      ),
                    ),
                  ],
                ),
              ),
            ))
        .toList();

    return Column(
      children: [
        CarouselSlider(
          items: imageSliders,
          carouselController: _controller,
          options: CarouselOptions(
            autoPlay: true,
            enlargeCenterPage: false,
            autoPlayInterval: const Duration(seconds: 4),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            aspectRatio: 1.8,
            viewportFraction: 1.0,
            onPageChanged: (index, reason) {
              if (!mounted) return;
              setState(() {
                _current = index;
              });
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: imgList.asMap().entries.map((entry) {
            return GestureDetector(
              onTap: () => _controller.animateToPage(entry.key),
              child: Container(
                width: _current == entry.key ? 24 : 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: _current == entry.key
                      ? Colors.blue.shade400
                      : Colors.grey.shade300,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildQuickAccessSection() {
    final List<Map<String, dynamic>> quickLinks = [
      {
        'icon': Icons.school,
        'label': 'OBS',
        'url': 'https://obs.akdeniz.edu.tr',
        'color': const Color(0xFF4CAF50),
      },
      {
        'icon': Icons.menu_book,
        'label': 'TL Yükleme',
        'url': 'https://merkezyemekhane.akdeniz.edu.tr/User/Login',
        'color': const Color(0xFF2196F3),
      },
      {
        'icon': Icons.local_phone,
        'label': 'Acil Güvenlik',
        'phone': '02423102222', 
        'color': Colors.red,
      },
      {
        'icon': Icons.event,
        'label': 'Akademik Takvim',
        'url': 'https://oidb.akdeniz.edu.tr/tr/20252026_akademik_takvim-9775',
        'color': const Color(0xFF9C27B0),
      },
    ];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: Container(
            height: 170,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => _launchUrl('https://akdeniz.edu.tr'),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.home_work_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Akdeniz',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Üniversitesi',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 170,
          height: 170,
          child: Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    _buildQuickButton(quickLinks[0]),
                    const SizedBox(width: 10),
                    _buildQuickButton(quickLinks[1]),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: Row(
                  children: [
                    _buildQuickButton(quickLinks[2]),
                    const SizedBox(width: 10),
                    _buildQuickButton(quickLinks[3]),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickButton(Map<String, dynamic> data) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: (data['color'] as Color).withOpacity(0.1),
          border: Border.all(
            color: (data['color'] as Color).withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              if (data.containsKey('phone')) {
                _launchPhone(data['phone'] as String);
              } else if (data.containsKey('url')) {
                _launchUrl(data['url'] as String);
              }
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  data['icon'],
                  color: data['color'],
                  size: 26,
                ),
                const SizedBox(height: 6),
                Text(
                  data['label'],
                  style: TextStyle(
                    color: data['color'],
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

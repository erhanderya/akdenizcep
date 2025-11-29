import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class YemekhanePage extends StatefulWidget {
  const YemekhanePage({super.key});

  @override
  State<YemekhanePage> createState() => _YemekhanePageState();
}

class _YemekhanePageState extends State<YemekhanePage> {
  String? userId = FirebaseAuth.instance.currentUser?.uid;
  bool isLiked = false;
  bool isDisliked = false;
  List<dynamic> likes = [];
  List<dynamic> dislikes = [];
  int todayW = DateTime.now().weekday;
  int _currentIndex = 0;
  bool _isMenuPage = true;
  late PageController _pageController;
  bool _isLoadingMenu = true;


  static const Map<String, String> _dayMapping = {
    'pzt': 'Pazartesi',
    'sl': 'Salı',
    'cm': 'Çarşamba',
    'prs': 'Perşembe',
    'crs': 'Cuma',
  };

  List<Map<String, dynamic>> _weeklyMenu = [];

  @override
  void initState() {
    super.initState();
    int today = DateTime.now().weekday;
    _currentIndex = (today >= 1 && today <= 5) ? today - 1 : 0;
    _pageController = PageController(initialPage: _currentIndex);
    fetchWeeklyMenu();
    fetchLikesAndDislikes();
  }

  /// Firebase'den haftalık yemek menüsünü çeker
  Future<void> fetchWeeklyMenu() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('yemek_list')
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();

        List<Map<String, dynamic>> menu = [];

        for (String dayKey in ['pzt', 'sl', 'cm', 'prs', 'crs']) {
          if (data.containsKey(dayKey) && data[dayKey] is Map) {
            Map<String, dynamic> dayData =
                Map<String, dynamic>.from(data[dayKey]);
            List<Map<String, dynamic>> meals = [];

   
            List<int> sortedKeys = dayData.keys
                .map((k) => int.tryParse(k.toString()) ?? -1)
                .where((k) => k >= 0)
                .toList()
              ..sort();

            for (int key in sortedKeys) {
              String mealString = dayData[key.toString()]?.toString() ?? '';
              if (mealString.isNotEmpty) {
          
                final parsed = _parseMealString(mealString);
                meals.add(parsed);
              }
            }

            menu.add({
              'day': _dayMapping[dayKey] ?? dayKey,
              'meals': meals,
              'rating': 0.0,
              'likes': 0,
              'dislikes': 0,
              'userReaction': 0,
            });
          }
        }

        if (menu.isNotEmpty) {
          setState(() {
            _weeklyMenu = menu;
            _isLoadingMenu = false;
          });
        } else {
          _setDefaultMenu();
        }
      } else {
        _setDefaultMenu();
      }
    } catch (e) {
      debugPrint('Yemek listesi çekilirken hata: $e');
      _setDefaultMenu();
    }
  }


  Map<String, dynamic> _parseMealString(String mealString) {

    final regex = RegExp(r'^(.+?)(\d+)$');
    final match = regex.firstMatch(mealString.trim());

    if (match != null) {
      String name = match.group(1)?.trim() ?? mealString;
      int calorie = int.tryParse(match.group(2) ?? '0') ?? 0;
      return {'name': name, 'calorie': calorie};
    }


    return {'name': mealString.trim(), 'calorie': 0};
  }

  void _setDefaultMenu() {
    setState(() {
      _weeklyMenu = [
        {
          'day': 'Pazartesi',
          'meals': [],
          'rating': 0.0,
          'likes': 0,
          'dislikes': 0,
          'userReaction': 0
        },
        {
          'day': 'Salı',
          'meals': [],
          'rating': 0.0,
          'likes': 0,
          'dislikes': 0,
          'userReaction': 0
        },
        {
          'day': 'Çarşamba',
          'meals': [],
          'rating': 0.0,
          'likes': 0,
          'dislikes': 0,
          'userReaction': 0
        },
        {
          'day': 'Perşembe',
          'meals': [],
          'rating': 0.0,
          'likes': 0,
          'dislikes': 0,
          'userReaction': 0
        },
        {
          'day': 'Cuma',
          'meals': [],
          'rating': 0.0,
          'likes': 0,
          'dislikes': 0,
          'userReaction': 0
        },
      ];
      _isLoadingMenu = false;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  int getTotalCalories(List meals) {
    return meals.fold(0, (sum, item) => sum + (item['calorie'] as int));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FB),
      body: Column(
        children: [
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _tabButton("Yemek Listesi", true),
              const SizedBox(width: 8),
              _tabButton("Yemekhane Bilgileri", false),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _isMenuPage ? _buildMenuPage() : _buildHoursPage(),
          ),
        ],
      ),
    );
  }

  Widget _tabButton(String text, bool isMenuTab) {
    bool selected = (isMenuTab == _isMenuPage);

    return ElevatedButton(
      onPressed: () {
        setState(() => _isMenuPage = isMenuTab);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor:
            selected ? const Color.fromARGB(255, 21, 138, 173) : Colors.white,
        foregroundColor: selected ? Colors.white : Colors.black87,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        elevation: selected ? 2 : 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: selected
                ? const Color.fromARGB(255, 21, 138, 173)
                : Colors.grey.shade300,
          ),
        ),
      ),
      child: Text(text),
    );
  }

  Widget _buildMenuPage() {

    if (_isLoadingMenu) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Color.fromARGB(255, 21, 138, 173),
            ),
            SizedBox(height: 16),
            Text('Yemek listesi yükleniyor...'),
          ],
        ),
      );
    }

    if (_weeklyMenu.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.restaurant_menu, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Yemek listesi bulunamadı',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: SizedBox(
            height: 34,
            child: Row(
              children: List.generate(_weeklyMenu.length, (index) {
                bool selected = index == _currentIndex;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: ChoiceChip(
                      label: Text(
                        _weeklyMenu[index]['day'],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight:
                              selected ? FontWeight.bold : FontWeight.normal,
                          color: selected ? Colors.white : Colors.black87,
                        ),
                      ),
                      selected: selected,
                      onSelected: (_) {
                        _pageController.animateToPage(
                          index,
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                        );
                        setState(() => _currentIndex = index);
                      },
                      selectedColor: const Color.fromARGB(255, 21, 138, 173),
                      backgroundColor: Colors.grey[200],
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: _weeklyMenu.length,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
            },
            itemBuilder: (context, index) {
              final dayData = _weeklyMenu[index];
              final meals = dayData['meals'] as List;
              int totalCal = getTotalCalories(meals);

              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              dayData['day'],
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(30, 21, 138, 173),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.local_fire_department,
                                      size: 16,
                                      color: Color.fromARGB(255, 21, 138, 173)),
                                  const SizedBox(width: 4),
                                  Text(
                                    "$totalCal kcal",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),
                        const Divider(),

                        const Text(
                          "Menü",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),

  
                        if (meals.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Text(
                              'Bu gün için menü bilgisi bulunamadı',
                              style: TextStyle(
                                color: Colors.grey,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          )
                        else
                          ...meals.map((m) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 3),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(child: Text(m['name'])),
                                  if ((m['calorie'] as int) > 0)
                                    Text(
                                      "${m['calorie']} kcal",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                ],
                              ),
                            );
                          }),

                    
                        Divider(),
          
                        if (index == todayW - 1 &&
                            todayW >= 1 &&
                            todayW <= 5) ...[
                          const Text(
                            "Beğenilme Oranı",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Builder(
                            builder: (context) {
                              int totalVotes = likes.length + dislikes.length;
                              double rating = totalVotes > 0
                                  ? likes.length / totalVotes
                                  : 0.0;
                              int percentage = (rating * 100).round();

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  LinearProgressIndicator(
                                    value: rating,
                                    minHeight: 10,
                                    borderRadius: BorderRadius.circular(8),
                                    backgroundColor: Colors.grey[200],
                                    valueColor: const AlwaysStoppedAnimation(
                                      Color.fromARGB(255, 21, 138, 173),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    totalVotes > 0
                                        ? "%$percentage • $totalVotes öğrenci oyladı"
                                        : "Henüz oy verilmedi",
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                          const Spacer(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              InkWell(
                                borderRadius: BorderRadius.circular(30),
                                onTap: userId != null
                                    ? handleLike
                                    : () {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  'Beğenmek için giriş yapmalısınız')),
                                        );
                                      },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 4),
                                  child: Row(
                                    children: [
                                      Icon(
                                        isLiked
                                            ? Icons.thumb_up_alt
                                            : Icons.thumb_up_alt_outlined,
                                        size: 20,
                                        color: isLiked
                                            ? const Color.fromARGB(
                                                255, 21, 138, 173)
                                            : const Color.fromARGB(
                                                    255, 21, 138, 173)
                                                .withOpacity(0.5),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        "Beğendim (${likes.length})",
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              InkWell(
                                borderRadius: BorderRadius.circular(30),
                                onTap: userId != null
                                    ? handleDislike
                                    : () {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  'Beğenmemek için giriş yapmalısınız')),
                                        );
                                      },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 4),
                                  child: Row(
                                    children: [
                                      Icon(
                                        isDisliked
                                            ? Icons.thumb_down_alt
                                            : Icons.thumb_down_alt_outlined,
                                        size: 20,
                                        color: isDisliked
                                            ? Colors.redAccent
                                            : Colors.redAccent.withOpacity(0.5),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        "Beğenmedim (${dislikes.length})",
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHoursPage() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Akdeniz Üniversitesi\nMerkezi Yemekhane Hizmet Saatleri",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFC928),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  "Öğle Yemeği Hizmeti",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const _HoursRow(
                title: "Merkezi Yemekhane için",
                time: "11.15 - 13.45",
              ),
              const _HoursRow(
                title: "Diş Hekimliği Fak. Yemekhanesi için",
                time: "11.30 - 13.30",
              ),
              const _HoursRow(
                title: "Edebiyat Fak. Yemekhanesi için",
                time: "12.00 - 13.30",
              ),
              const _HoursRow(
                title: "İlahiyat Fak. Yemekhanesi için",
                time: "11.30 - 13.30",
              ),
              const _HoursRow(
                title: "Yakut Çarşı Yemekhanesi için",
                time: "12.00 - 13.30",
                addSuffix: "saatleri arasındadır.",
              ),
              const SizedBox(height: 20),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF203A76),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  "Akşam Yemeği Hizmeti",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const _HoursRow(
                title: "Merkezi Yemekhane için",
                time: "16.30 - 18.30",
                addSuffix: "saatleri arasındadır.",
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<Map<String, List<dynamic>>> getArrayFields() async {
    try {
      CollectionReference<Map<String, dynamic>> items =
          FirebaseFirestore.instance.collection('yemeklike');

      DocumentSnapshot<Map<String, dynamic>> snapshot =
          await items.doc('vljOU7aY6fCyqxxc64ha').get();

      if (snapshot.exists) {
        return {
          'likes': snapshot.data()?['likes'] ?? [],
          'dislikes': snapshot.data()?['dislikes'] ?? [],
        };
      } else {
        return {'likes': [], 'dislikes': []};
      }
    } catch (e) {
      return {'likes': [], 'dislikes': []};
    }
  }

  void checkLikesAndDislikes(List<dynamic> likes, List<dynamic> dislikes) {
    isLiked = likes.contains(userId);
    isDisliked = dislikes.contains(userId);
  }

  Future<void> fetchLikesAndDislikes() async {
    Map<String, List<dynamic>> data = await getArrayFields();
    likes = data['likes'] ?? [];
    dislikes = data['dislikes'] ?? [];
    checkLikesAndDislikes(likes, dislikes);
    setState(() {});
  }

  Future<void> handleDislike() async {
    final docRef = FirebaseFirestore.instance
        .collection('yemeklike')
        .doc('vljOU7aY6fCyqxxc64ha');

    if (isDisliked) {
      await docRef.update({
        'dislikes': FieldValue.arrayRemove([userId]),
      });
    } else {
      await docRef.update({
        'dislikes': FieldValue.arrayUnion([userId]),
        'likes': FieldValue.arrayRemove([userId]),
      });
    }
    fetchLikesAndDislikes();
  }

  Future<void> handleLike() async {
    final docRef = FirebaseFirestore.instance
        .collection('yemeklike')
        .doc('vljOU7aY6fCyqxxc64ha');

    if (isLiked) {
      await docRef.update({
        'likes': FieldValue.arrayRemove([userId]),
      });
    } else {
      await docRef.update({
        'likes': FieldValue.arrayUnion([userId]),
        'dislikes': FieldValue.arrayRemove([userId]),
      });
    }
    fetchLikesAndDislikes();
  }
}


class _HoursRow extends StatelessWidget {
  final String title;
  final String time;
  final String? addSuffix;

  const _HoursRow({
    required this.title,
    required this.time,
    this.addSuffix,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              const Icon(Icons.access_time, size: 16),
              const SizedBox(width: 6),
              Text(
                time,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              if (addSuffix != null) ...[
                const SizedBox(width: 4),
                Text(
                  addSuffix!,
                  style: TextStyle(color: Colors.grey[700], fontSize: 12),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:akdeniz_cep/models/event.dart';
import 'package:akdeniz_cep/services/event_service.dart';
import 'package:akdeniz_cep/services/auth_service.dart';
import 'package:akdeniz_cep/widgets/event_card.dart';
import 'package:akdeniz_cep/pages/create_event_page.dart';

class SocietyPage extends StatefulWidget {
  const SocietyPage({super.key});

  @override
  State<SocietyPage> createState() => _SocietyPageState();
}

class _SocietyPageState extends State<SocietyPage> {
  final EventService _eventService = EventService();
  final AuthService _authService = AuthService();
  Society? _userSociety;
  bool _isLoadingPresident = true;

  @override
  void initState() {
    super.initState();
    _checkIfPresident();
  }

  Future<void> _checkIfPresident() async {
    print('🚀 [DEBUG] _checkIfPresident başladı');

    final user = _authService.currentUser;
    print(
        '👤 [DEBUG] Current user: ${user?.uid ?? "NULL - Kullanıcı giriş yapmamış!"}');
    print('👤 [DEBUG] User email: ${user?.email ?? "NULL"}');

    if (user != null) {
      print('📡 [DEBUG] getSocietyByPresident çağrılıyor...');
      final society = await _eventService.getSocietyByPresident(user.uid);

      print('📦 [DEBUG] Dönen society: ${society?.name ?? "NULL"}');
      print('📦 [DEBUG] Society ID: ${society?.id ?? "NULL"}');

      setState(() {
        _userSociety = society;
        _isLoadingPresident = false;
      });

      print(
          '✅ [DEBUG] State güncellendi - _userSociety: ${_userSociety?.name ?? "NULL"}');
    } else {
      print(
          '⚠️ [DEBUG] Kullanıcı giriş yapmamış, president kontrolü yapılamıyor');
      setState(() {
        _isLoadingPresident = false;
      });
    }

    print('🏁 [DEBUG] _checkIfPresident tamamlandı');
  }

  void _showDeleteConfirmation(Event event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Etkinliği Sil'),
        content: Text(
            '"${event.title}" etkinliğini silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _eventService.deleteEvent(event.id!);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Etkinlik silindi'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Hata: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text(
              'Sil',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.event, color: Colors.white, size: 28),
                    const SizedBox(width: 12),
                    const Text(
                      'Topluluk Etkinlikleri',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Tüm toplulukların yaklaşan etkinliklerini keşfedin',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                if (!_isLoadingPresident && _userSociety != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.verified,
                          color: Colors.amber,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${_userSociety!.name} Başkanı',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          Expanded(
            child: StreamBuilder<List<Event>>(
              stream: _eventService.getEventsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF667eea),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Bir hata oluştu',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final events = snapshot.data ?? [];

                if (events.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_busy,
                          size: 80,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Henüz etkinlik yok',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Topluluklar yakında etkinlik paylaşacak',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];
                    final canDelete = _userSociety != null &&
                        _userSociety!.id == event.societyId;

                    return EventCard(
                      event: event,
                      showDeleteButton: canDelete,
                      onDelete: canDelete
                          ? () => _showDeleteConfirmation(event)
                          : null,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: !_isLoadingPresident && _userSociety != null
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        CreateEventPage(society: _userSociety!),
                  ),
                ).then((_) => _checkIfPresident()); 
              },
              backgroundColor: const Color(0xFF667eea),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Etkinlik Ekle',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
    );
  }
}

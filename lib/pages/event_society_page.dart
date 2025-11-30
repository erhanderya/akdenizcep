import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:akdeniz_cep/models/public_event.dart';
import 'package:akdeniz_cep/models/event.dart';
import 'package:akdeniz_cep/services/event_service.dart';
import 'package:akdeniz_cep/services/auth_service.dart';
import 'package:akdeniz_cep/pages/create_event_page.dart';
import 'package:akdeniz_cep/pages/event_detail_page.dart';
import 'package:akdeniz_cep/widgets/empty_state.dart';
import 'package:akdeniz_cep/widgets/public_event_card.dart';
import 'package:akdeniz_cep/widgets/society_event_card.dart';
import 'package:akdeniz_cep/widgets/create_public_event_sheet.dart';

class EventSocietyPage extends StatefulWidget {
  const EventSocietyPage({super.key});

  @override
  State<EventSocietyPage> createState() => _EventSocietyPageState();
}

class _EventSocietyPageState extends State<EventSocietyPage>
    with SingleTickerProviderStateMixin {
  final EventService _eventService = EventService();
  final AuthService _authService = AuthService();

  late TabController _tabController;
  Society? _userSociety;
  bool _isLoadingPresident = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    _checkIfPresident();
  }

  void _onTabChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _checkIfPresident() async {
    final user = _authService.currentUser;
    if (user != null) {
      final society = await _eventService.getSocietyByPresident(user.uid);
      if (mounted) {
        setState(() {
          _userSociety = society;
          _isLoadingPresident = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoadingPresident = false;
        });
      }
    }
  }

  void _showCreatePublicEventSheet() {
    final user = _authService.currentUser;
    if (user == null) {
      _showSnackBar('Etkinlik oluşturmak için giriş yapın', Colors.orange);
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreatePublicEventSheet(
        eventService: _eventService,
        userId: user.uid,
      ),
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  Future<void> _handleJoinEvent(PublicEvent event) async {
    final user = _authService.currentUser;
    if (user == null) {
      _showSnackBar('Katılmak için giriş yapın', Colors.orange);
      return;
    }

    try {
      if (event.isUserAttending(user.uid)) {
        await _eventService.leaveEvent(event.id!, user.uid);
        if (mounted) _showSnackBar('Etkinlikten ayrıldınız', Colors.blue);
      } else {
        await _eventService.joinEvent(event.id!, user.uid);
        if (mounted) _showSnackBar('Etkinliğe katıldınız', Colors.green);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar(e.toString().replaceAll('Exception: ', ''), Colors.red);
      }
    }
  }

  void _showDeleteDialog(Event event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Etkinliği Sil'),
        content: Text('"${event.title}" silinecek. Emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('İptal', style: TextStyle(color: Colors.grey.shade600)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _eventService.deleteEvent(event.id!);
                if (mounted) _showSnackBar('Etkinlik silindi', Colors.green);
              } catch (e) {
                if (mounted) _showSnackBar('Hata: $e', Colors.red);
              }
            },
            child: const Text('Sil', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(24),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorPadding: const EdgeInsets.all(4),
              dividerColor: Colors.transparent,
              labelColor: Colors.black87,
              unselectedLabelColor: Colors.grey.shade500,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              tabs: const [
                Tab(text: 'Genel'),
                Tab(text: 'Topluluklar'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _PublicEventsTab(
            eventService: _eventService,
            authService: _authService,
            onJoin: _handleJoinEvent,
          ),
          _SocietyEventsTab(
            eventService: _eventService,
            userSociety: _userSociety,
            onDelete: _showDeleteDialog,
          ),
        ],
      ),
      floatingActionButton: _buildFab(),
    );
  }

  Widget? _buildFab() {
    final isPublicTab = _tabController.index == 0;

    if (isPublicTab) {
      return FloatingActionButton(
        onPressed: _showCreatePublicEventSheet,
        backgroundColor: const Color.fromARGB(255, 4, 4, 117),
        child: const Icon(Icons.add, color: Colors.white),
      );
    }

    if (!_isLoadingPresident && _userSociety != null) {
      return FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateEventPage(society: _userSociety!),
            ),
          ).then((_) => _checkIfPresident());
        },
        backgroundColor: const Color(0xFF1a1a2e),
        child: const Icon(Icons.add, color: Colors.white),
      );
    }

    return null;
  }
}

// Genel Etkinlikler Tab
class _PublicEventsTab extends StatelessWidget {
  final EventService eventService;
  final AuthService authService;
  final Function(PublicEvent) onJoin;

  const _PublicEventsTab({
    required this.eventService,
    required this.authService,
    required this.onJoin,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('d MMM, HH:mm', 'tr_TR');
    final currentUserId = authService.currentUser?.uid;

    return StreamBuilder<List<PublicEvent>>(
      stream: eventService.getUpcomingPublicEvents(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const EmptyState(
            icon: Icons.error_outline,
            title: 'Bir hata oluştu',
          );
        }

        final events = snapshot.data ?? [];

        if (events.isEmpty) {
          return const EmptyState(
            icon: Icons.event_available,
            title: 'Henüz etkinlik yok',
            subtitle: 'İlk etkinliği sen oluştur',
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: events.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final event = events[index];
            final isAttending =
                currentUserId != null && event.isUserAttending(currentUserId);
            final isFull = event.isFull;

            return PublicEventCard(
              event: event,
              dateFormat: dateFormat,
              isAttending: isAttending,
              isFull: isFull,
              onJoin: () => onJoin(event),
            );
          },
        );
      },
    );
  }
}

// Topluluk Etkinlikleri Tab
class _SocietyEventsTab extends StatelessWidget {
  final EventService eventService;
  final Society? userSociety;
  final Function(Event) onDelete;

  const _SocietyEventsTab({
    required this.eventService,
    required this.userSociety,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('d MMM, HH:mm', 'tr_TR');

    return StreamBuilder<List<Event>>(
      stream: eventService.getEventsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const EmptyState(
            icon: Icons.error_outline,
            title: 'Bir hata oluştu',
          );
        }

        final events = snapshot.data ?? [];

        if (events.isEmpty) {
          return const EmptyState(
            icon: Icons.groups_outlined,
            title: 'Topluluk etkinliği yok',
            subtitle: 'Topluluklar yakında paylaşacak',
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: events.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final event = events[index];
            final canDelete =
                userSociety != null && userSociety!.id == event.societyId;
            final isPresident =
                userSociety != null && userSociety!.id == event.societyId;

            return SocietyEventCard(
              event: event,
              dateFormat: dateFormat,
              attendeeCount: event.attendeeCount,
              canDelete: canDelete,
              onDelete: canDelete ? () => onDelete(event) : null,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EventDetailPage(
                      event: event,
                      isPresident: isPresident,
                      societyId: userSociety?.id,
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

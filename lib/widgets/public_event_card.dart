import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:akdeniz_cep/models/public_event.dart';
import 'package:akdeniz_cep/services/auth_service.dart';
import 'package:akdeniz_cep/utils/user_utils.dart';

class PublicEventCard extends StatefulWidget {
  final PublicEvent event;
  final DateFormat dateFormat;
  final bool isAttending;
  final bool isFull;
  final VoidCallback onJoin;

  const PublicEventCard({
    super.key,
    required this.event,
    required this.dateFormat,
    required this.isAttending,
    required this.isFull,
    required this.onJoin,
  });

  @override
  State<PublicEventCard> createState() => _PublicEventCardState();
}

class _PublicEventCardState extends State<PublicEventCard> {
  final AuthService _authService = AuthService();
  bool _loadingAttendees = false;
  List<String> _attendeeNames = [];

  Future<void> _showAttendeesDialog() async {
    setState(() => _loadingAttendees = true);
    final users = await UserUtils.fetchUsersByIds(widget.event.attendedUsers);
    setState(() {
      _attendeeNames = users.map((u) => u.fullName).toList();
      _loadingAttendees = false;
    });
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Katılımcılar'),
        content: _attendeeNames.isEmpty
            ? const Text('Henüz katılımcı yok.')
            : SizedBox(
                width: 250,
                child: ListView(
                  shrinkWrap: true,
                  children: _attendeeNames.map((name) => ListTile(title: Text(name))).toList(),
                ),
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final event = widget.event;
    final isFull = widget.isFull;
    final isAttending = widget.isAttending;
    final onJoin = widget.onJoin;
    final currentUser = _authService.currentUser;
    final isOwner = currentUser != null && event.createdBy == currentUser.uid;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isFull ? Colors.grey.shade100 : Colors.blue,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(11)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isFull ? Colors.grey.shade600 : Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 14,
                            color:
                                isFull ? Colors.grey.shade500 : Colors.white70,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.dateFormat.format(event.eventDate),
                            style: TextStyle(
                              fontSize: 12,
                              color: isFull
                                  ? Colors.grey.shade500
                                  : Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: isFull
                        ? Colors.red.shade100
                        : Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    isFull
                        ? 'Dolu'
                        : '${event.attendeeCount}/${event.capacity}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isFull ? Colors.red.shade700 : Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Kategori
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    event.categoryName,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Açıklama
                Text(
                  event.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),

                // Kapasite bar
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: event.attendeeCount / event.capacity,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isFull ? Colors.red.shade400 : Colors.blue.shade700,
                          ),
                          minHeight: 4,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${event.remainingCapacity} yer',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Katılımcılar butonu (sadece etkinlik sahibi için)
                if (isOwner)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _loadingAttendees ? null : _showAttendeesDialog,
                      icon: const Icon(Icons.people),
                      label: Text(_loadingAttendees ? 'Yükleniyor...' : 'Katılımcılar'),
                    ),
                  ),

                // Katıl/Ayrıl butonu (sahip için deaktif)
                if (!isOwner)
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: (isFull && !isAttending) ? null : onJoin,
                      style: TextButton.styleFrom(
                        backgroundColor: isAttending
                            ? Colors.red.shade50
                            : isFull
                                ? Colors.grey.shade100
                                : const Color.fromARGB(255, 82, 82, 213),
                        foregroundColor: isAttending
                            ? Colors.red.shade700
                            : isFull
                                ? Colors.grey.shade500
                                : Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        isAttending
                            ? 'Ayrıl'
                            : isFull
                                ? 'Dolu'
                                : 'Katıl',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


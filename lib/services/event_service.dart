import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:akdeniz_cep/models/event.dart';
import 'package:akdeniz_cep/models/public_event.dart';

class EventService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  CollectionReference get _eventsCollection =>
      _firestore.collection('society_events');


  CollectionReference get _publicEventsCollection =>
      _firestore.collection('events');


  CollectionReference get _societiesCollection =>
      _firestore.collection('society');


  Stream<List<Event>> getEventsStream() {
    return _eventsCollection.orderBy('date', descending: false).snapshots().map(
        (snapshot) =>
            snapshot.docs.map((doc) => Event.fromFirestore(doc)).toList());
  }


  Stream<List<Event>> getEventsBySociety(String societyId) {
    return _eventsCollection
        .where('societyId', isEqualTo: societyId)
        .orderBy('date', descending: false)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Event.fromFirestore(doc)).toList());
  }


  Stream<List<Event>> getUpcomingEvents() {
    return _eventsCollection
        .where('date', isGreaterThanOrEqualTo: Timestamp.now())
        .orderBy('date', descending: false)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Event.fromFirestore(doc)).toList());
  }

  Future<void> createEvent(Event event) async {
    await _eventsCollection.add(event.toFirestore());
  }


  Future<void> deleteEvent(String eventId) async {
    await _eventsCollection.doc(eventId).delete();
  }


  Stream<List<Society>> getSocietiesStream() {
    return _societiesCollection.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Society.fromFirestore(doc)).toList());
  }

  Future<Society?> getSocietyById(String societyId) async {
    final doc = await _societiesCollection.doc(societyId).get();
    if (doc.exists) {
      return Society.fromFirestore(doc);
    }
    return null;
  }

  Future<Society?> getSocietyByPresident(String userId) async {


    try {
      final snapshot = await _societiesCollection
          .where('president_id', isEqualTo: userId)
          .limit(1)
          .get();



  
      final allSocieties = await _societiesCollection.get();
  
      for (var doc in allSocieties.docs) {
        final data = doc.data() as Map<String, dynamic>;

      }

      if (snapshot.docs.isNotEmpty) {
        final society = Society.fromFirestore(snapshot.docs.first);

        return society;
      }


      return null;
    } catch (e) {

      return null;
    }
  }


  Future<String> getSocietyName(String societyId) async {
    final doc = await _societiesCollection.doc(societyId).get();
    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      return data['name'] ?? 'Bilinmeyen Topluluk';
    }
    return 'Bilinmeyen Topluluk';
  }


  Stream<List<PublicEvent>> getPublicEventsStream() {
    return _publicEventsCollection
        .orderBy('eventDate', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PublicEvent.fromFirestore(doc))
            .toList());
  }


  Stream<List<PublicEvent>> getUpcomingPublicEvents() {
    return _publicEventsCollection
        .where('eventDate', isGreaterThanOrEqualTo: Timestamp.now())
        .orderBy('eventDate', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PublicEvent.fromFirestore(doc))
            .toList());
  }


  Future<void> createPublicEvent(PublicEvent event) async {
    await _publicEventsCollection.add(event.toFirestore());
  }


  Future<void> deletePublicEvent(String eventId) async {
    await _publicEventsCollection.doc(eventId).delete();
  }


  Future<bool> joinEvent(String eventId, String userId) async {
    try {
      final docRef = _publicEventsCollection.doc(eventId);

      return await _firestore.runTransaction<bool>((transaction) async {
        final snapshot = await transaction.get(docRef);

        if (!snapshot.exists) {
          throw Exception('Etkinlik bulunamadı');
        }

        final data = snapshot.data() as Map<String, dynamic>;
        final attendedUsers = List<String>.from(data['attended_users'] ?? []);
        final capacity = data['capacity'] as int;


        if (attendedUsers.contains(userId)) {
          throw Exception('Bu etkinliğe zaten katıldınız');
        }

        if (attendedUsers.length >= capacity) {
          throw Exception('Etkinlik kapasitesi dolu');
        }

        attendedUsers.add(userId);
        transaction.update(docRef, {'attended_users': attendedUsers});

        return true;
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> leaveEvent(String eventId, String userId) async {
    try {
      final docRef = _publicEventsCollection.doc(eventId);

      return await _firestore.runTransaction<bool>((transaction) async {
        final snapshot = await transaction.get(docRef);

        if (!snapshot.exists) {
          throw Exception('Etkinlik bulunamadı');
        }

        final data = snapshot.data() as Map<String, dynamic>;
        final attendedUsers = List<String>.from(data['attended_users'] ?? []);


        if (!attendedUsers.contains(userId)) {
          throw Exception('Bu etkinliğe katılmamışsınız');
        }

        attendedUsers.remove(userId);
        transaction.update(docRef, {'attended_users': attendedUsers});

        return true;
      });
    } catch (e) {
      rethrow;
    }
  }


  Stream<List<PublicEvent>> getUserJoinedEvents(String userId) {
    return _publicEventsCollection
        .where('attended_users', arrayContains: userId)
        .snapshots()
        .map((snapshot) {
      final events =
          snapshot.docs.map((doc) => PublicEvent.fromFirestore(doc)).toList();

      events.sort((a, b) => b.eventDate.compareTo(a.eventDate));
      return events;
    });
  }


  Future<bool> addAttendanceToSocietyEvent(
      String eventId, String userId) async {
    try {
      final docRef = _eventsCollection.doc(eventId);

      return await _firestore.runTransaction<bool>((transaction) async {
        final snapshot = await transaction.get(docRef);

        if (!snapshot.exists) {
          throw Exception('Etkinlik bulunamadı');
        }

        final data = snapshot.data() as Map<String, dynamic>;
        final attendedUsers = List<String>.from(data['attended_users'] ?? []);


        if (attendedUsers.contains(userId)) {
          throw Exception('Bu kullanıcı zaten yoklamaya eklenmiş');
        }

        attendedUsers.add(userId);
        transaction.update(docRef, {'attended_users': attendedUsers});

        return true;
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> removeAttendanceFromSocietyEvent(
      String eventId, String userId) async {
    try {
      final docRef = _eventsCollection.doc(eventId);

      return await _firestore.runTransaction<bool>((transaction) async {
        final snapshot = await transaction.get(docRef);

        if (!snapshot.exists) {
          throw Exception('Etkinlik bulunamadı');
        }

        final data = snapshot.data() as Map<String, dynamic>;
        final attendedUsers = List<String>.from(data['attended_users'] ?? []);

   
        if (!attendedUsers.contains(userId)) {
          throw Exception('Bu kullanıcı yoklamada yok');
        }

        attendedUsers.remove(userId);
        transaction.update(docRef, {'attended_users': attendedUsers});

        return true;
      });
    } catch (e) {
      rethrow;
    }
  }

  Stream<List<String>> getEventAttendanceStream(String eventId) {
    return _eventsCollection.doc(eventId).snapshots().map((snapshot) {
      if (!snapshot.exists) return [];
      final data = snapshot.data() as Map<String, dynamic>;
      return List<String>.from(data['attended_users'] ?? []);
    });
  }


  Future<Event?> getEventById(String eventId) async {
    final doc = await _eventsCollection.doc(eventId).get();
    if (doc.exists) {
      return Event.fromFirestore(doc);
    }
    return null;
  }


  Stream<Event?> getEventStream(String eventId) {
    return _eventsCollection.doc(eventId).snapshots().map((snapshot) {
      if (!snapshot.exists) return null;
      return Event.fromFirestore(snapshot);
    });
  }


  Stream<List<Event>> getUserAttendedSocietyEvents(String userId) {
    return _eventsCollection
        .where('attended_users', arrayContains: userId)
        .snapshots()
        .map((snapshot) {
      final events =
          snapshot.docs.map((doc) => Event.fromFirestore(doc)).toList();

      events.sort((a, b) => b.date.compareTo(a.date));
      return events;
    });
  }
}

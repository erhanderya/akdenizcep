import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:label_marker/label_marker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/campus_location.dart';

class CampusPage extends StatefulWidget {
  const CampusPage({super.key});

  @override
  State<CampusPage> createState() => _CampusPageState();
}

class _CampusPageState extends State<CampusPage> {
  static const LatLng _center = LatLng(36.897001, 30.651234);

  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  List<CampusLocation> _filteredLocations = CampusData.locations;
  LocationCategory? _selectedCategory;
  bool _showSearchBar = false;

  @override
  void initState() {
    super.initState();
    _loadMarkers();
  }

  Future<void> _loadMarkers() async {
    final Set<Marker> markers = {};

    for (final location in _filteredLocations) {
      try {
        await markers.addLabelMarker(
          LabelMarker(
            label: location.name,
            markerId: MarkerId(location.id),
            position: location.position,
            backgroundColor: location.category.color,
            textStyle: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            onTap: () => _onMarkerTapped(location),
          ),
        );
      } catch (e) {
      }
    }

    if (mounted) {
      setState(() {
        _markers = markers;
      });
    }
  }

  void _onMarkerTapped(CampusLocation location) {
    _showLocationDetails(location);
  }

  void _showLocationDetails(CampusLocation location) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => LocationDetailsSheet(
        location: location,
        onNavigate: () => _navigateToLocation(location),
        onGoogleMapsNavigate: () => _openInGoogleMaps(location),
      ),
    );
  }

  Future<void> _openInGoogleMaps(CampusLocation location) async {
    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${location.position.latitude},${location.position.longitude}&travelmode=walking',
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Google Maps açılamadı'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    if (mounted) Navigator.pop(context);
  }

  void _navigateToLocation(CampusLocation location) {
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: location.position,
          zoom: 17.0,
        ),
      ),
    );
    Navigator.pop(context);
  }

  void _filterByCategory(LocationCategory? category) {
    setState(() {
      _selectedCategory = category;
      if (category == null) {
        _filteredLocations = CampusData.locations;
      } else {
        _filteredLocations = CampusData.getLocationsByCategory(category);
      }
    });
    _loadMarkers();
  }

  void _searchLocations(String query) {
    setState(() {
      _filteredLocations = CampusData.searchLocations(query);
      if (_selectedCategory != null) {
        _filteredLocations = _filteredLocations
            .where((loc) => loc.category == _selectedCategory)
            .toList();
      }
    });
    _loadMarkers();
  }

  void _toggleSearch() {
    setState(() {
      _showSearchBar = !_showSearchBar;
      if (!_showSearchBar) {
        _searchLocations('');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: const CameraPosition(
              target: _center,
              zoom: 15.0,
            ),
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
            },
            markers: _markers,
            myLocationEnabled: true,         
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            compassEnabled: false,
          ),

          SafeArea(
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              color: Theme.of(context).primaryColor,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _showSearchBar
                                  ? TextField(
                                      onChanged: _searchLocations,
                                      decoration: const InputDecoration(
                                        hintText: 'Konum ara...',
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                      autofocus: true,
                                    )
                                  : const Text(
                                      'Kampüs Haritası',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                            ),
                            IconButton(
                              onPressed: _toggleSearch,
                              icon: Icon(
                                _showSearchBar ? Icons.close : Icons.search,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Container(
                        height: 55,
                        padding: const EdgeInsets.only(bottom: 5),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: LocationCategory.values.length + 1,
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return CategoryChip(
                                label: 'Tümü',
                                icon: Icons.apps,
                                color: Colors.blue,
                                isSelected: _selectedCategory == null,
                                onTap: () => _filterByCategory(null),
                              );
                            }

                            final category = LocationCategory.values[index - 1];
                            return CategoryChip(
                              label: category.displayName,
                              icon: category.icon,
                              color: category.color,
                              isSelected: _selectedCategory == category,
                              onTap: () => _filterByCategory(category),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            right: 16,
            bottom: 100,
            child: Column(
              children: [
                FloatingActionButton(
                  heroTag: "my_location",
                  mini: true,
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black54,
                  onPressed: () => _goToMyLocation(),
                  child: const Icon(Icons.my_location),
                ),
                const SizedBox(height: 12),
                FloatingActionButton(
                  heroTag: "center_map",
                  mini: true,
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black54,
                  onPressed: () => _centerMap(),
                  child: const Icon(Icons.center_focus_strong),
                ),
              ],
            ),
          ),

          Positioned(
            bottom: 20,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Theme.of(context).primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Konum detayları için işaretçilere dokunun',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _goToMyLocation() {
    _centerMap();
  }

  void _centerMap() {
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        const CameraPosition(
          target: _center,
          zoom: 15.0,
        ),
      ),
    );
  }
}

class CategoryChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8, bottom: 8),
      child: Material(
        color: isSelected ? color : Colors.white,
        borderRadius: BorderRadius.circular(20),
        elevation: isSelected ? 4 : 2,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: isSelected ? Colors.white : color,
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LocationDetailsSheet extends StatelessWidget {
  final CampusLocation location;
  final VoidCallback onNavigate;
  final VoidCallback onGoogleMapsNavigate;

  const LocationDetailsSheet({
    super.key,
    required this.location,
    required this.onNavigate,
    required this.onGoogleMapsNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: location.category.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        location.category.icon,
                        color: location.category.color,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            location.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            location.category.displayName,
                            style: TextStyle(
                              fontSize: 14,
                              color: location.category.color,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                if (location.description != null) ...[
                  Text(
                    location.description!,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                if (location.workingHours != null)
                  InfoRow(
                    icon: Icons.access_time,
                    title: 'Çalışma Saatleri',
                    content: location.workingHours!,
                  ),

                if (location.phoneNumber != null)
                  InfoRow(
                    icon: Icons.phone,
                    title: 'Telefon',
                    content: location.phoneNumber!,
                  ),

                if (location.services != null &&
                    location.services!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.room_service,
                          color: Colors.grey[600], size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Hizmetler',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: location.services!.map((service) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: location.category.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          service,
                          style: TextStyle(
                            fontSize: 12,
                            color: location.category.color,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],

                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onNavigate,
                        icon: const Icon(Icons.map),
                        label: const Text('Haritada Göster'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: location.category.color,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onGoogleMapsNavigate,
                        icon: const Icon(Icons.directions),
                        label: const Text('Yol Tarifi'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;

  const InfoRow({
    super.key,
    required this.icon,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey[600], size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
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

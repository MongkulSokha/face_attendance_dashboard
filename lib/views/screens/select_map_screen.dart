import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:face_attendance_dashboard/views/widgets/portal_master_layout/portal_master_layout.dart';
import 'package:face_attendance_dashboard/constants/dimens.dart';
import 'package:face_attendance_dashboard/theme/theme_extensions/app_button_theme.dart';
import 'package:face_attendance_dashboard/views/widgets/card_elements.dart';
import 'package:go_router/go_router.dart';
import 'package:face_attendance_dashboard/generated/l10n.dart';
import 'package:face_attendance_dashboard/utils/app_focus_helper.dart';

import '../../app_router.dart';

class LocationSelectionScreen extends StatefulWidget {
  const LocationSelectionScreen({Key? key}) : super(key: key);

  @override
  _LocationSelectionScreenState createState() => _LocationSelectionScreenState();
}

class _LocationSelectionScreenState extends State<LocationSelectionScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  LatLng? _selectedLatLng;
  final TextEditingController _nameController = TextEditingController();
  final _formKey = GlobalKey<FormBuilderState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription<QuerySnapshot>? _subscription;
  List<DocumentSnapshot> _locations = [];

  @override
  void initState() {
    super.initState();
    _subscription = _firestore.collection('locations').snapshots().listen((snapshot) {
      setState(() {
        _locations = snapshot.docs;
      });
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveLocation() async {
    AppFocusHelper.instance.requestUnfocus();

    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState!.save();

      if (_selectedLatLng != null) {
        try {
          // Convert LatLng to GeoPoint
          GeoPoint geoPoint = GeoPoint(_selectedLatLng!.latitude, _selectedLatLng!.longitude);

          // Check if there is an existing document in Firestore
          final querySnapshot = await FirebaseFirestore.instance
              .collection('locations')
              .where('latitude', isEqualTo: _selectedLatLng!.latitude)
              .where('longitude', isEqualTo: _selectedLatLng!.longitude)
              .get();

          if (querySnapshot.docs.isNotEmpty) {
            // Update existing document
            await FirebaseFirestore.instance
                .collection('locations')
                .doc(querySnapshot.docs.first.id)
                .set({
              'latitude': _selectedLatLng!.latitude,
              'longitude': _selectedLatLng!.longitude,
              'name': _nameController.text,
            });
          } else {
            // Add new document
            await FirebaseFirestore.instance.collection('locations').add({
              'latitude': _selectedLatLng!.latitude,
              'longitude': _selectedLatLng!.longitude,
              'name': _nameController.text,
            });
          }

          // Show a success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location saved to Firestore')),
          );

          // Navigate back to the previous screen
          GoRouter.of(context).go(RouteUri.mapScreen);
        } catch (e) {
          // Show an error message if saving fails
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to save location')),
          );
        }
      }
    }
  }

  Future<void> _deleteLocation(String id) async {
    try {
      await FirebaseFirestore.instance.collection('locations').doc(id).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location deleted from Firestore')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete location')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = Lang.of(context);
    final themeData = Theme.of(context);

    return PortalMasterLayout(
      selectedMenuUri: RouteUri.mapScreen,
      body: ListView(
        padding: const EdgeInsets.all(kDefaultPadding),
        children: [
          Text(
            "Select Geofence",
            style: themeData.textTheme.headlineMedium,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: kDefaultPadding),
            child: Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CardHeader(
                    title: "Select Geofence",
                  ),
                  CardBody(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 470.0,
                          child: GoogleMap(
                            initialCameraPosition: const CameraPosition(
                              target: LatLng(11.524947, 104.884168),
                              zoom: 18,
                            ),
                            onMapCreated: (controller) {
                              _controller.complete(controller);
                            },
                            onTap: (latLng) {
                              setState(() {
                                _selectedLatLng = latLng;
                              });
                            },
                            markers: _getMarkers(),
                            circles: _getCircles(),
                          ),
                        ),
                        if (_selectedLatLng != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: kDefaultPadding),
                            child: FormBuilder(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  FormBuilderTextField(
                                    name: 'Location Name',
                                    controller: _nameController,
                                    decoration: const InputDecoration(
                                      labelText: "Location Name",
                                      hintText: "Location Name",
                                      border: OutlineInputBorder(),
                                      floatingLabelBehavior: FloatingLabelBehavior.always,
                                    ),
                                    validator: FormBuilderValidators.required(),
                                  ),
                                  const SizedBox(height: kDefaultPadding),
                                  SizedBox(
                                    height: 40.0,
                                    child: ElevatedButton(
                                      style: themeData.extension<AppButtonTheme>()!.successElevated,
                                      onPressed: _saveLocation,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(right: kDefaultPadding * 0.5),
                                            child: Icon(
                                              Icons.check_circle_outline_rounded,
                                              size: (themeData.textTheme.labelLarge!.fontSize! + 4.0),
                                            ),
                                          ),
                                          Text(lang.submit),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        const SizedBox(height: kDefaultPadding),
                        Text(
                          "Locations",
                          style: themeData.textTheme.headlineSmall,
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: _locations.length,
                          itemBuilder: (context, index) {
                            final location = _locations[index];
                            final data = location.data() as Map<String, dynamic>;
                            return ListTile(
                              title: Text(data['name']),
                              subtitle: Text('${data['latitude']}, ${data['longitude']}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () => _deleteLocation(location.id),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
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

  Set<Marker> _getMarkers() {
    Set<Marker> markers = {};
    if (_selectedLatLng != null) {
      markers.add(Marker(
        markerId: const MarkerId('selected_location'),
        position: _selectedLatLng!,
      ));
    }
    for (var location in _locations) {
      final data = location.data() as Map<String, dynamic>;
      markers.add(Marker(
        markerId: MarkerId(location.id),
        position: LatLng(data['latitude'], data['longitude']),
        infoWindow: InfoWindow(title: data['name']),
      ));
    }
    return markers;
  }

  Set<Circle> _getCircles() {
    Set<Circle> circles = {};
    if (_selectedLatLng != null) {
      circles.add(Circle(
        circleId: const CircleId('selected_geofence'),
        center: _selectedLatLng!,
        radius: 25,
        fillColor: Colors.blue.withOpacity(0.2),
        strokeColor: Colors.blue,
        strokeWidth: 2,
      ));
    }
    for (var location in _locations) {
      final data = location.data() as Map<String, dynamic>;
      circles.add(Circle(
        circleId: CircleId(location.id),
        center: LatLng(data['latitude'], data['longitude']),
        radius: 25,
        fillColor: Colors.red.withOpacity(0.2),
        strokeColor: Colors.red,
        strokeWidth: 2,
      ));
    }
    return circles;
  }
}

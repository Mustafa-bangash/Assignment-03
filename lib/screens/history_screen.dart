// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:intl/intl.dart';
// import '../providers/activity_provider.dart';
//
// class HistoryScreen extends StatefulWidget {
//   @override
//   _HistoryScreenState createState() => _HistoryScreenState();
// }
//
// class _HistoryScreenState extends State<HistoryScreen> {
//   @override
//   void initState() {
//     super.initState();
//     Provider.of<ActivityProvider>(context, listen: false).loadActivities();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Activity History')),
//       body: Consumer<ActivityProvider>(
//         builder: (context, provider, child) {
//           if (provider.isLoading) return Center(child: CircularProgressIndicator());
//           if (provider.activities.isEmpty) return Center(child: Text("No history found."));
//
//           return ListView.builder(
//             itemCount: provider.activities.length,
//             itemBuilder: (context, index) {
//               final activity = provider.activities[index];
//               return Card(
//                 child: ListTile(
//                   leading: activity.imagePath.isNotEmpty
//                       ? Image.memory(base64Decode(activity.imagePath), width: 50, fit: BoxFit.cover)
//                       : Icon(Icons.image_not_supported),
//                   title: Text(DateFormat('yyyy-MM-dd – kk:mm').format(DateTime.parse(activity.timestamp))),
//                   subtitle: Text('Lat: ${activity.latitude}, Lng: ${activity.longitude}'),
//                   trailing: IconButton(
//                     icon: Icon(Icons.delete, color: Colors.red),
//                     onPressed: () => provider.deleteActivity(activity.id),
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/activity_provider.dart';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  // 1. Controller for the Search Bar
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load activities immediately when the screen opens
    Provider.of<ActivityProvider>(context, listen: false).loadActivities();

    // 2. Listener to trigger list filtering on text change
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    // This forces the widget to rebuild and apply the filter based on the text
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Activity History')),
      body: Column( // Use Column to stack the search bar and the list
        children: [
          // 3. Search Bar UI (This is the missing part you need to ensure is included!)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search by Location or Date',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                ),
                border: const OutlineInputBorder(),
              ),
            ),
          ),

          // 4. List View (Expanded to take remaining space)
          Expanded(
            child: Consumer<ActivityProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) return const Center(child: CircularProgressIndicator());

                // --- Search and Filter Logic ---
                final searchTerm = _searchController.text.toLowerCase();
                final filteredActivities = provider.activities.where((activity) {
                  // Search coordinates and timestamp fields
                  final coordinates = 'lat: ${activity.latitude.toStringAsFixed(2)}, lng: ${activity.longitude.toStringAsFixed(2)}'.toLowerCase();
                  final date = DateFormat('yyyy-MM-dd').format(DateTime.parse(activity.timestamp)).toLowerCase();

                  return coordinates.contains(searchTerm) || date.contains(searchTerm);
                }).toList();
                // --- End Filter Logic ---

                if (filteredActivities.isEmpty) {
                  return const Center(child: Text("No history found matching your criteria."));
                }

                return ListView.builder(
                  itemCount: filteredActivities.length,
                  itemBuilder: (context, index) {
                    final activity = filteredActivities[index];

                    final formattedDate = DateFormat('yyyy-MM-dd – kk:mm').format(DateTime.parse(activity.timestamp));

                    // 5. View Details in the List Tile
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      child: ListTile(
                        // View: Image Preview
                        leading: activity.imagePath.isNotEmpty
                            ? Image.memory(
                            base64Decode(activity.imagePath),
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover
                        )
                            : const Icon(Icons.image_not_supported, size: 50),

                        // View: Title/Subtitle Details
                        title: Text(formattedDate, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Lat: ${activity.latitude.toStringAsFixed(4)}, Lng: ${activity.longitude.toStringAsFixed(4)}'),

                        // Delete Button
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => provider.deleteActivity(activity.id),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
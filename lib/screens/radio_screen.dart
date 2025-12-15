import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../services/radio_service.dart';
import '../models/radio_station.dart';

class RadioScreen extends StatelessWidget {
  const RadioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final RadioService radioService = RadioService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quran Radio'),
      ),
      body: FutureBuilder<List<RadioStation>>(
        future: radioService.getStations(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No stations found'));
          } else {
            final stations = snapshot.data!;
            return ListView.builder(
              itemCount: stations.length,
              itemBuilder: (context, index) {
                final station = stations[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(station.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(station.country),
                    trailing: IconButton(
                      icon: const Icon(Icons.play_arrow),
                      onPressed: () {
                        radioService.playStation(station);
                      },
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      bottomNavigationBar: StreamBuilder(
        stream: radioService.playerStateStream,
        builder: (context, snapshot) {
          final playerState = snapshot.data;
          final isPlaying = playerState?.playing ?? false;
          final station = radioService.currentStation;

          if (!isPlaying || station == null) {
            return const SizedBox.shrink();
          }

          return BottomAppBar(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Now Playing: ${station.name}',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.pause),
                    onPressed: () {
                      radioService.pause();
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.stop),
                    onPressed: () {
                      radioService.stop();
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class AudioPlayerBar extends StatelessWidget {
  const AudioPlayerBar({super.key});

  @override
  Widget build(BuildContext context) {
    final audioService = Provider.of<AppProvider>(context).audioService;

    return StreamBuilder<bool>(
      stream: audioService.isPlayingStream,
      builder: (context, snapshot) {
        final isPlaying = snapshot.data ?? false;

        if (!isPlaying) {
          return const SizedBox.shrink();
        }

        return BottomAppBar(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.skip_previous),
                  onPressed: () => audioService.previous(),
                ),
                IconButton(
                  icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                  onPressed: () {
                    if (isPlaying) {
                      audioService.pause();
                    } else {
                      // You would need to know the verse to resume
                      // This is a simplified example
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.skip_next),
                  onPressed: () => audioService.next(),
                ),
                IconButton(
                  icon: const Icon(Icons.stop),
                  onPressed: () => audioService.stop(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

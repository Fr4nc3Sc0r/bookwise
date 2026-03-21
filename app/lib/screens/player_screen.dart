import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../models/book.dart';

class PlayerScreen extends StatefulWidget {
  final Book book;

  const PlayerScreen({super.key, required this.book});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late AudioPlayer _player;
  bool _isPlaying = false;

  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
  try {
    print('🎵 Inizio caricamento audio...');
    
    await _player.setUrl(
      'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3' //funziona solo con url, quindi usare url anche nel database
    );
    
    print('✅ Audio caricato!');
    print('Durata: ${_player.duration}');

    _player.durationStream.listen((duration) {
      print('📏 Durata ricevuta: $duration');
      setState(() => _duration = duration ?? Duration.zero);
    });

    _player.positionStream.listen((position) {
      print('⏱ Posizione: $position');
      setState(() => _position = position);
    });

    _player.playerStateStream.listen((state) {
      print('▶️ Stato player: $state');
      setState(() => _isPlaying = state.playing);
    });

  } catch (e) {
    print('❌ Errore: $e');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore: $e'), backgroundColor: Colors.red),
      );
    }
  }
}

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Player', style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //copertina
            Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                color: Colors.grey[850],
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.music_note,
                size: 80,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 32),

            //titolo e autore
            Text(
              widget.book.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              widget.book.author,
              style: TextStyle(color: Colors.grey[400], fontSize: 16),
            ),
            const SizedBox(height: 32),

            //barra di avanzamento
            Slider(
              value: _position.inSeconds.toDouble(),
              max: _duration.inSeconds.toDouble() > 0
                  ? _duration.inSeconds.toDouble()
                  : 1,
              activeColor: Colors.orange,
              inactiveColor: Colors.grey[800],
              onChanged: (value) {
                _player.seek(Duration(seconds: value.toInt()));
              },
            ),

            //tempi
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDuration(_position),
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                  Text(
                    _formatDuration(_duration),
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            //controlli
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //indietro di 10 secondi
                IconButton(
                  icon: const Icon(
                    Icons.replay_10,
                    color: Colors.white,
                    size: 36,
                  ),
                  onPressed: () {
                    final newPosition = _position - const Duration(seconds: 10);
                    _player.seek(
                      newPosition < Duration.zero ? Duration.zero : newPosition,
                    );
                  },
                ),
                const SizedBox(width: 24),

                //play,pausa
                GestureDetector(
                  onTap: () {
                    _isPlaying ? _player.pause() : _player.play();
                  },
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: const BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
                const SizedBox(width: 24),

                //avanti di 10 secondi
                IconButton(
                  icon: const Icon(
                    Icons.forward_10,
                    color: Colors.white,
                    size: 36,
                  ),
                  onPressed: () {
                    final newPosition = _position + const Duration(seconds: 10);
                    _player.seek(
                      newPosition > _duration ? _duration : newPosition,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

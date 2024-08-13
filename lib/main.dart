import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_audio_capture/flutter_audio_capture.dart';
import 'package:pitch_detector_dart/pitch_detector.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tunner demo page',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const TurnerPage(title: 'Tunner demo page'),
    );
  }
}

class TurnerPage extends StatefulWidget {
  const TurnerPage({super.key, required this.title});

  final String title;

  @override
  State<TurnerPage> createState() => _TurnerPageState();
}

class _TurnerPageState extends State<TurnerPage> {
  final _audioRecorder = FlutterAudioCapture();
  final _pitchDetector =
      PitchDetector(audioSampleRate: 44100, bufferSize: 2048);
  String note = "Let´s Start";
  String status = "Click on start";

  @override
  void initState() {
    super.initState();
    _initializeAudioCapture();
  }

  Future<void> _initializeAudioCapture() async {
    try {
      await _audioRecorder.init();
    } catch (e) {
      setState(() {
        status = "Error initializing audio capture: $e";
      });
    }
  }

  Future<void> _startCapture() async {
    try {
      await _audioRecorder.start(
        listener,
        onError,
        sampleRate: 44100,
        bufferSize: 3000,
      );

      setState(() {
        note = "";
        status = "Play something";
      });
    } catch (e) {
      setState(() {
        status = "Error starting audio capture: $e";
      });
    }
  }

  Future<void> _stopCapture() async {
    try {
      await _audioRecorder.stop();

      setState(() {
        note = "";
        status = "Click on start";
      });
    } catch (e) {
      setState(() {
        status = "Error stopping audio capture";
      });
    }
  }

  void listener(dynamic obj) async {
    // Convert the dynamic object to a list of doubles
    var buffer = Float64List.fromList(obj.cast<double>());
    final List<double> audioSample = buffer.toList();

    // Await the pitch detection result
    final result = await _pitchDetector.getPitchFromFloatBuffer(audioSample);

    // Check if a pitch is detected
    if (result.pitched) {
      setState(() {
        note = "Pitch detected: ${result.pitch} Hz";
      });
    } else {
      setState(() {
        note = "No pitch detected";
      });
    }
  }

  void onError(Object e) {
    setState(() {
      status = "Audio capture error: $e";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              status,
            ),
            Text(
              note,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                  onPressed: _startCapture,
                  tooltip: 'Start',
                  child: const Icon(Icons.play_arrow),
                ),
                const SizedBox(width: 20),
                FloatingActionButton(
                  onPressed: _stopCapture,
                  tooltip: 'Stop',
                  child: const Icon(Icons.stop),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

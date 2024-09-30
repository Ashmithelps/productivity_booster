import 'package:flutter/material.dart';
import 'dart:async';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  _TimerScreenState createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> with TickerProviderStateMixin {
  Timer? _timer;
  Duration _duration = const Duration(); // Timer duration
  Duration _remainingTime = const Duration(); // Remaining time for the countdown
  bool _isRunning = false; // To check if the timer is running
  bool _timerCompleted = false; // To check if the timer has completed
  TextEditingController _timeController = TextEditingController(); // For time input
  AnimationController? _animationController; // For countdown animation

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
  }

  void _startTimer() {
    if (_remainingTime.inSeconds > 0 && !_isRunning) {
      setState(() {
        _isRunning = true;
        _timerCompleted = false;
        _animationController?.duration = _remainingTime; // Set duration for animation
        _animationController?.forward(from: 0); // Start animation
      });
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          if (_remainingTime.inSeconds > 0) {
            _remainingTime -= const Duration(seconds: 1);
            _animationController?.forward(from: 0);
          } else {
            _stopTimer();
            setState(() {
              _timerCompleted = true;
              _animationController?.stop();
              // Add sound notification here if needed
            });
          }
        });
      });
    }
  }

  void _stopTimer() {
    if (_isRunning) {
      _timer?.cancel();
      setState(() {
        _isRunning = false;
        _animationController?.stop();
      });
    }
  }

  void _resetTimer() {
    _stopTimer();
    setState(() {
      _remainingTime = _duration;
      _timerCompleted = false;
      _animationController?.reset();
    });
  }

  void _setTimerDuration() {
    final int seconds = int.tryParse(_timeController.text) ?? 0;
    if (seconds > 0) {
      setState(() {
        _duration = Duration(seconds: seconds);
        _remainingTime = _duration;
        _timerCompleted = false;
        _animationController?.duration = _duration; // Update animation duration
        _animationController?.reset(); // Reset animation
      });
    } else {
      // Show a Snackbar for invalid input
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid time greater than 0.')),
      );
    }
  }

  String _formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timeController.dispose();
    _animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Timer'),
        backgroundColor: Colors.blue[800], // Deep Blue
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.lightBlueAccent], // Deep Blue to Light Blue
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Display the remaining time or "Time's Up!"
            Text(
              _timerCompleted ? "Time's Up!" : _formatTime(_remainingTime),
              style: const TextStyle(
                fontSize: 72,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 20),
            // Circular countdown progress indicator
            CircularProgressIndicator(
              value: _isRunning && !_timerCompleted
                  ? _remainingTime.inSeconds / _duration.inSeconds
                  : null,
              backgroundColor: Colors.grey,
              color: Colors.green,
              strokeWidth: 10,
            ),
            const SizedBox(height: 20),
            // TextField to input time
            TextField(
              controller: _timeController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Enter time in seconds',
                filled: true,
                fillColor: Colors.white.withOpacity(0.8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Button to set timer duration
            ElevatedButton(
              onPressed: _setTimerDuration,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600], // A lighter blue
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              child: const Text('Set Timer'),
            ),
            const SizedBox(height: 20),
            // Timer control buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                  onPressed: _startTimer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                  child: const Text('Start'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _stopTimer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                  child: const Text('Pause'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _resetTimer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                  child: const Text('Reset'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

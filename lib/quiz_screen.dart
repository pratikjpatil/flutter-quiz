import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

void main() {
  runApp(MaterialApp(
    home: QuizScreen(),
  ));
}

class QuizScreen extends StatefulWidget {
  const QuizScreen({Key? key}) : super(key: key);

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int seconds = 0;
  Timer? timer;

  List<String> optionsList = ['Option 1', 'Option 2', 'Option 3', 'Option 4'];

  List<int> selectedOptions = []; // List to store selected options

  List<String> selectedOptionsText = []; // List to store selected option texts

  @override
  void initState() {
    super.initState();
    startTimer(); // Start the timer when the screen is created
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (seconds < 60) {
          seconds++;
        } else {
          // Handle time's up here
        }
      });
    });
  }

  resetQuiz() {
    setState(() {
      seconds = 0;
      selectedOptions.clear();
      selectedOptionsText.clear();
      startTimer();
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.blue, Colors.blueAccent],
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(color: Colors.lightBlue, width: 2),
                      ),
                      child: IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Text(
                          "$seconds",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                          ),
                        ),
                        SizedBox(
                          width: 80,
                          height: 80,
                          child: CircularProgressIndicator(
                            value: seconds / 60,
                            valueColor: const AlwaysStoppedAnimation(Colors.white),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.lightBlue, width: 2),
                      ),
                      child: TextButton.icon(
                        onPressed: () {
                          setState(() {
                            if (timer == null) {
                              startTimer();
                            }
                          });
                        },
                        icon: const Icon(
                          Icons.play_circle_filled,
                          color: Colors.white,
                          size: 18,
                        ),
                        label: Text(
                          "Quiz",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Question 1",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Show the question text here
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
                    child: Text(
                      "The question goes here...",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: optionsList.length + 1, // Add 1 for "OK" button
                  itemBuilder: (BuildContext context, int index) {
                    if (index == optionsList.length) {
                      // Render the "OK" button
                      return Align(
                        alignment: Alignment.bottomRight,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              // Handle selected options here (save in the list)
                              if (timer != null) {
                                timer!.cancel();
                                if (selectedOptions.isNotEmpty) {
                                  selectedOptionsText = selectedOptions
                                      .map((index) => optionsList[index])
                                      .toList();
                                }
                              }
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: Text(
                              'OK',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                      );
                    }

                    // Render the options with prefixes in the center
                    return Center(
                      child: Column(
                        children: [
                          CheckboxListTile(
                            title: Text(
                              '${optionsList[index]}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                            value: selectedOptions.contains(index),
                            activeColor: Colors.green,
                            onChanged: (value) {
                              setState(() {
                                if (selectedOptions.contains(index)) {
                                  selectedOptions.remove(index);
                                } else {
                                  selectedOptions.add(index);
                                }
                              });
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
                if (selectedOptionsText.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Selected Options: ${selectedOptionsText.join(", ")}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ElevatedButton(
                  onPressed: resetQuiz,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      'Reset',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                      ),
                    ),
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

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:quiz_app/api_services.dart';
import 'package:quiz_app/const/colors.dart';
import 'package:quiz_app/const/text_style.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({Key? key}) : super(key: key);

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  var currentQuestionIndex = 0;
  int seconds = 60;
  Timer? timer;
  late Future quiz;

  int points = 0;
  int totalTime = 0;

  var isLoaded = false;

  var optionsList = [];

  var selectedOptionIndex; // New variable for selected option index

  // List of prefixes for options
  List<String> optionPrefixes = ['Option 1', 'Option 2', 'Option 3', 'Option 4'];

  @override
  void initState() {
    super.initState();
    startTimer();
    quiz = getQuiz();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (seconds > 0) {
          seconds--;
          totalTime++;
        } else {
          gotoNextQuestion();
        }
      });
    });
  }

  gotoNextQuestion() async {
    setState(() {
      isLoaded = false;
      currentQuestionIndex++;
      selectedOptionIndex = null; // Reset selected option index
      timer?.cancel();
      seconds = 60;
      startTimer();
    });

    final newQuiz = await getQuiz();
    setState(() {
      quiz = newQuiz;
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
              colors: [blue, darkBlue],
            ),
          ),
          child: FutureBuilder(
            future: quiz,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                );
              } else if (snapshot.hasError) {
                return Text('Failed to fetch quiz questions');
              }

              if (!isLoaded) {
                var data = snapshot.data["results"];

                if (data[currentQuestionIndex]["incorrect_answers"] is List) {
                  optionsList = List.from(
                      data[currentQuestionIndex]["incorrect_answers"]);
                } else {
                  optionsList = [];
                }

                optionsList.add(data[currentQuestionIndex]["correct_answer"]);
                optionsList.shuffle();
                isLoaded = true;
              }

              var data = snapshot.data["results"];

              return SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(color: lightgrey, width: 2),
                          ),
                          child: IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: const Icon(
                              CupertinoIcons.xmark,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        ),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            normalText(
                              color: Colors.white,
                              size: 24,
                              text: "$seconds",
                            ),
                            SizedBox(
                              width: 80,
                              height: 80,
                              child: CircularProgressIndicator(
                                value: seconds / 60,
                                valueColor:
                                const AlwaysStoppedAnimation(Colors.white),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: lightgrey, width: 2),
                          ),
                          child: TextButton.icon(
                            onPressed: null,
                            icon: const Icon(
                              CupertinoIcons.heart_fill,
                              color: Colors.white,
                              size: 18,
                            ),
                            label: normalText(
                              color: Colors.white,
                              size: 14,
                              text: "Quiz",
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: normalText(
                        color: lightgrey,
                        size: 18,
                        text:
                        "Question ${currentQuestionIndex + 1} of ${data.length}",
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Show the "The question goes here..." text in the center
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
                        child: normalText(
                          color: Colors.white,
                          size: 20,
                          text: "The question goes here...",
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: optionsList.length + 1,
                      itemBuilder: (BuildContext context, int index) {
                        var answer = data[currentQuestionIndex]["correct_answer"];

                        if (index == optionsList.length) {
                          // Render the submit button
                          return Align(
                            alignment: Alignment.bottomRight,
                            child: ElevatedButton(
                              onPressed: () {
                                if (currentQuestionIndex < data.length - 1) {
                                  setState(() {
                                    currentQuestionIndex++;
                                    selectedOptionIndex =
                                    null; // Reset selected option index
                                    timer?.cancel();
                                    seconds = 60;
                                    startTimer();
                                    isLoaded = false;
                                  });
                                } else {
                                  timer?.cancel();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ResultScreen(
                                        totalQuestions: data.length,
                                        totalTime: totalTime,
                                        totalPoints: points,
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                child: headingText(
                                  color: Colors.black,
                                  size: 18,
                                  text: 'OK',
                                ),
                              ),
                            ),
                          );
                        }

                        // Render the options with prefixes in the center
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              RadioListTile(
                                title: headingText(
                                  color: Colors.white,
                                  size: 18,
                                  // text: '${optionPrefixes[index]}: ${optionsList[index]}',
                                  text: '${optionPrefixes[index]}',
                                ),
                                value: index,
                                groupValue: selectedOptionIndex,
                                activeColor: Colors.green,
                                onChanged: (value) {
                                  setState(() {
                                    selectedOptionIndex = value;
                                    if (answer.toString() == optionsList[selectedOptionIndex].toString()) {
                                      points++;
                                    }
                                  });
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class ResultScreen extends StatelessWidget {
  final int totalQuestions;
  final int totalTime;
  final int totalPoints;

  const ResultScreen({
    Key? key,
    required this.totalQuestions,
    required this.totalTime,
    required this.totalPoints,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Quiz Result',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Total Questions: $totalQuestions',
                  style: TextStyle(fontSize: 18),
                ),
                Text(
                  'Total Time: $totalTime seconds',
                  style: TextStyle(fontSize: 18),
                ),
                Text(
                  'Total Points: $totalPoints',
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

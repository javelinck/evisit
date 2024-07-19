import 'package:evisit_mobile/main.dart';
import 'package:evisit_mobile/network/evisit_api.dart';
import 'package:evisit_mobile/network/user_api.dart';
import 'package:flutter/material.dart';

import '../types/evisit.dart';
import '../types/user.dart';

class EVisitCreationScreen extends StatefulWidget {
  const EVisitCreationScreen({super.key});

  @override
  _EVisitCreationScreenState createState() => _EVisitCreationScreenState();
}

class _EVisitCreationScreenState extends State<EVisitCreationScreen> {
  String healthIssues = '';
  String birthControl = '';
  User? selectedPatient;
  Protocol? selectedProtocol;
  User? selectedDoctor;
  List<Protocol>? _protocolList;
  List<User>? _doctorList;
  User? _patient;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final patientFuture = fetchUserDataAndTransform();
    final protocolListFuture = fetchProtocols();
    final doctorListFuture = fetchDoctorList();

    final List<dynamic> results = await Future.wait([
      patientFuture,
      protocolListFuture,
      doctorListFuture,
    ]);

    setState(() {
      _patient = results[0];
      _protocolList = results[1];
      _doctorList = results[2];
    });
  }

  List<Answer> answers = [];
  bool allQuestionsAnswered = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New eVisit'),
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(text: 'Step 1'),
                Tab(text: 'Step 2'),
              ],
              labelStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.blue,
              ),
              unselectedLabelColor: Colors.black,
              labelColor: Colors.blue,
            ),
            Expanded(
              child: TabBarView(
                children: [
                  // Step 1
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        DropdownButtonFormField<User>(
                          value: selectedPatient,
                          onChanged: (value) {
                            setState(() {
                              selectedPatient = value!;
                            });
                          },
                          items: [
                            DropdownMenuItem<User>(
                              value: _patient,
                              child: const Text('Me'),
                            ),
                          ],
                          decoration: const InputDecoration(
                            labelText: 'Select Patient',
                          ),
                        ),
                        DropdownButtonFormField<Protocol>(
                          value: selectedProtocol,
                          onChanged: (value) {
                            setState(() {
                              selectedProtocol = value;
                            });
                          },
                          items: _protocolList?.map<DropdownMenuItem<Protocol>>((protocol) {
                            return DropdownMenuItem<Protocol>(
                              value: protocol,
                              child: Text(protocol.name),
                            );
                          }).toList(),
                          decoration: const InputDecoration(
                            labelText: 'Select Protocol',
                          ),
                        ),
                        DropdownButtonFormField<User>(
                          value: selectedDoctor,
                          onChanged: (value) {
                            setState(() {
                              selectedDoctor = value;
                            });
                          },
                          items: _doctorList?.map<DropdownMenuItem<User>>((doctor) {
                            return DropdownMenuItem<User>(
                              value: doctor,
                              child: Text(doctor.name),
                            );
                          }).toList(),
                          decoration: const InputDecoration(
                            labelText: 'Select Doctor',
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                  // Step 2
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Protocol: ${selectedProtocol?.name}'),
                          Text('Doctor: ${selectedDoctor?.name}'),
                          const SizedBox(height: 16),
                          if (selectedProtocol != null)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Column(
                                  children: selectedProtocol!.questions.map((question) {
                                    return QuestionWidget(
                                      question: question,
                                      existingAnswer: getAnswerForQuestion(question.text),
                                      onAnswerStored: (answer) {
                                        // Check if an answer already exists for this question.
                                        final existingAnswerIndex = answers.indexWhere(
                                              (element) => element.text == question.text,
                                        );

                                        if (existingAnswerIndex != -1) {
                                          setState(() {
                                            answers[existingAnswerIndex] = answer;
                                          });
                                        } else {
                                          setState(() {
                                            answers.add(answer);
                                          });

                                          // Check if all questions have been answered.
                                          allQuestionsAnswered = selectedProtocol!.questions.every((q) =>
                                              answers.any((a) => a.text == q.text && a.answer.isNotEmpty));

                                          // Force a rebuild to update the button state.
                                          setState(() {});
                                        }
                                      },
                                    );
                                  }).toList(),
                                ),
                                ElevatedButton(
                                  onPressed: allQuestionsAnswered ? () {
                                    PostEvisit data = PostEvisit(
                                      answers: answers,
                                      doctorId: selectedDoctor!.id,
                                      patientId: selectedPatient!.id,
                                      protocolId: selectedProtocol!.id
                                    );

                                    createEvisit(data);

                                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
                                      builder: (BuildContext context) => const MainScreen(),
                                    ), (route) => false);
                                  } : null,
                                  child: const Text('Submit'),
                                ),
                              ],
                            )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Answer getAnswerForQuestion(String questionText) {
    final existingAnswer = answers.firstWhere(
          (answer) => answer.text == questionText,
      orElse: () => Answer(text: questionText, answer: ''),
    );
    return existingAnswer;
  }
}

class QuestionWidget extends StatefulWidget {
  final Question question;
  final Answer existingAnswer;
  final Function(Answer) onAnswerStored;

  const QuestionWidget({
    super.key,
    required this.question,
    required this.onAnswerStored,
    required this.existingAnswer
  });

  @override
  _QuestionWidgetState createState() => _QuestionWidgetState();
}

class _QuestionWidgetState extends State<QuestionWidget> {
  late String selectedRadio;
  String userInputText = '';
  late TextEditingController textEditingController;

  @override
  void initState() {
    super.initState();
    if (widget.question.response.type == "radiobutton") {
      selectedRadio = widget.existingAnswer.answer ?? widget.question.response.items[0];
    }
    textEditingController = TextEditingController(text: widget.existingAnswer.answer);
  }

  @override
  void dispose() {
    setState(() {
      textEditingController.dispose();
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.question.text,
              style: const TextStyle(fontSize: 18),
            ),
            if (widget.question.response.type == "input")
              TextField(
                controller: textEditingController,
                onChanged: (text) {
                  setState(() {
                    userInputText = text;
                  });
                },
                onSubmitted: (text) {
                  final answer = Answer(
                    text: widget.question.text,
                    answer: text,
                  );
                  widget.onAnswerStored(answer);
                },
              ),
            if (widget.question.response.type == "radiobutton")
              Column(
                children: widget.question.response.items.map((item) {
                  return RadioListTile(
                    title: Text(item),
                    value: item,
                    groupValue: selectedRadio,
                    onChanged: (value) {
                      setState(() {
                        selectedRadio = value!;
                      });
                      final answer = Answer(
                        text: widget.question.text,
                        answer: value!,
                      );
                      widget.onAnswerStored(answer);
                    },
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}
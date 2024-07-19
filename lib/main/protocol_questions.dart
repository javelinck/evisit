import 'package:evisit_mobile/network/evisit_api.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import '../types/evisit.dart';

class ProtocolQuestionsScreen extends StatefulWidget {
  const ProtocolQuestionsScreen({super.key});

  @override
  _ProtocolQuestionsScreenState createState() => _ProtocolQuestionsScreenState();
}

class _ProtocolQuestionsScreenState extends State<ProtocolQuestionsScreen> with SingleTickerProviderStateMixin {
  late Future<List<Protocol>> _protocolsFuture;

  Protocol? selectedProtocol;
  List<Question> questions = [];

  @override
  void initState() {
    super.initState();
    _protocolsFuture = fetchProtocols();

    _protocolsFuture.then((protocols) {
      if (protocols.isNotEmpty) {
        setState(() {
          selectedProtocol = protocols.first;
          questions.addAll(selectedProtocol!.questions);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Protocols'),
        actions: [
          TextButton(
            onPressed: () {
              editProtocol(selectedProtocol!.id, questions);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MainScreen()),
              );
            },
            child: const Text('Save', style: TextStyle(color: Colors.white),),
          )
        ],
      ),
      body: FutureBuilder<List<Protocol>>(
        future: _protocolsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(),);
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Text('No data available');
          } else {
            final protocols = snapshot.data!;
            return Column(
              children: [
                DropdownButtonFormField<Protocol>(
                  value: selectedProtocol,
                  onChanged: (value) {
                    setState(() {
                      selectedProtocol = value!;
                    });
                  },
                  items: protocols.map<DropdownMenuItem<Protocol>>((protocol) {
                    return DropdownMenuItem<Protocol>(
                      value: protocol,
                      child: Text(protocol.name),
                    );
                  }).toList(),
                  decoration: const InputDecoration(
                    labelText: 'Select Protocol',
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: protocols.length,
                    itemBuilder: (context, index) {
                      final protocol = protocols[index];
                      if (selectedProtocol == protocol) {
                        return ProtocolCard(
                          protocol: protocol,
                          onQuestionStored: (question, indexQ) {
                            if (indexQ <= questions.length -1) {
                              setState(() {
                                questions[indexQ] = question;
                              });
                            }
                        },);
                      } else {
                        return Container();
                      }
                    },
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}

class ProtocolCard extends StatefulWidget {
  final Protocol protocol;
  final Function(Question, int) onQuestionStored;

  const ProtocolCard({
    Key? key,
    required this.protocol,
    required this.onQuestionStored
  }) : super(key: key);

  @override
  _ProtocolCardState createState() => _ProtocolCardState();
}

class _ProtocolCardState extends State<ProtocolCard> {
  Map<String, String> selectedOptions = {};
  Map<String, TextEditingController> textControllers = {};

  @override
  void initState() {
    super.initState();

    for (var question in widget.protocol.questions) {
      if (question.response.type == 'input') {
        selectedOptions[question.text] = 'input';
      } else if (question.response.type == 'checkbox') {
        selectedOptions[question.text] = 'checkbox';
      } else if (question.response.type == 'select') {
        selectedOptions[question.text] = 'select';
      } else if (question.response.type == 'radiobutton') {
        selectedOptions[question.text] = 'radiobutton';
      }

      textControllers[question.text] = TextEditingController(text: question.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: List.generate(widget.protocol.questions.length, (index) {
          final question = widget.protocol.questions[index];
          return Column(
            children: [
              TextField(
                controller: textControllers[question.text],
                onSubmitted: (newText) {
                  setState(() {
                    textControllers[question.text]!.text = newText;
                    Question q = Question(
                        text: newText,
                        response: QuestionResponse(
                          type: selectedOptions[question.text] ?? '',
                          items: question.response.items,
                        )
                    );

                    widget.protocol.questions[index] = q;
                    widget.onQuestionStored(q, index);
                  });
                },
              ),
              const SizedBox(height: 10,),
              ToggleButtons(
                isSelected: [
                  selectedOptions[question.text] == 'input',
                  selectedOptions[question.text] == 'checkbox',
                  selectedOptions[question.text] == 'select',
                  selectedOptions[question.text] == 'radiobutton',
                ],
                onPressed: (int buttonIndex) {
                  final selectedOption = ['input', 'checkbox', 'select', 'radiobutton'][buttonIndex];

                  if (selectedOption == 'checkbox' || selectedOption == 'select') {
                    return;
                  }

                  selectedOptions[question.text] = selectedOption;
                  Question q = Question(
                      text: question.text,
                      response: QuestionResponse(
                        type: selectedOption.toLowerCase(),
                        items: question.response.items,
                      )
                  );

                  widget.protocol.questions[index] = q;
                  widget.onQuestionStored(q, index);
                },
                children: const [
                  Text('Input'),
                  Text('CheckBox'),
                  Text('Select'),
                  Text('RadioButton'),
                ],
              ),
              if (selectedOptions[question.text] == 'radiobutton')
                Column(
                  children: [
                    TextField(controller: TextEditingController(text: question.response.items[0]), enabled: false,),
                    TextField(controller: TextEditingController(text: question.response.items[1]), enabled: false,),
                  ],
                ),
            ],
          );
        }),
      ),
    );
  }
}

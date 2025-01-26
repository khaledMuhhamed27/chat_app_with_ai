import 'package:chat_app_with_ai/model/model.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:intl/intl.dart';

class GeminiChatBot extends StatefulWidget {
  const GeminiChatBot({super.key});

  @override
  State<GeminiChatBot> createState() => _GeminiChatBotState();
}

class _GeminiChatBotState extends State<GeminiChatBot> {
  final TextEditingController chatInputController = TextEditingController();
  static const myAPIkey = 'AIzaSyAltfngqrThCmW29iIqpwOidQj466gSGng';
  final model = GenerativeModel(model: "gemini-pro", apiKey: myAPIkey);
  final List<ModelMessage> chat = [];
  final _formKey = GlobalKey<FormState>(); //
  bool myButtonEnable = false;
  // init
  //
  @override
  void initState() {
    super.initState();
    chatInputController.addListener(() {
      setState(() {
        myButtonEnable = chatInputController.text.trim().isNotEmpty;
      });
    });
  }

  Future<void> sendMessage() async {
    if (!_formKey.currentState!.validate()) {
      // is ancorrect
      return;
    }

    final message = chatInputController.text;

    // add the message
    setState(() {
      chat.add(ModelMessage(
        isChat: true,
        message: message,
        time: DateTime.now(),
      ));
      chatInputController.clear();
    });

    // AI Response
    final content = [Content.text(message)];
    final response = await model.generateContent(content);

    setState(() {
      chat.add(
        ModelMessage(
          isChat: false,
          message: response.text ?? "",
          time: DateTime.now(),
        ),
      );
    });
  }

// dispos
  @override
  void dispose() {
    // TODO: implement dispose
    chatInputController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal[100],
      appBar: AppBar(
        backgroundColor: Colors.teal[100],
        elevation: 3,
        title: Text("Chat With AI"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: chat.length,
              itemBuilder: (context, index) {
                final message = chat[index];
                return UserChat(
                  isChat: message.isChat,
                  message: message.message,
                  date: DateFormat('hh:mm a').format(message.time),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(25),
            child: Form(
              key: _formKey,
              child: Row(
                children: [
                  Expanded(
                    flex: 20,
                    child: TextFormField(
                      controller: chatInputController,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                      ),
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.teal,
                            width: 3,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.teal,
                            width: 3,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.red.shade400,
                            width: 3,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.red,
                            width: 3,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        hintText: "Ask artificial intelligence",
                        errorStyle: TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
                  Spacer(),
                  // My \button
                  Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          spreadRadius: myButtonEnable ? 1 : 0,
                          color: Colors.teal,
                          blurRadius: myButtonEnable ? 4 : 0,
                        )
                      ],
                      color: myButtonEnable ? Colors.teal : Colors.teal[300], //
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                        iconSize: 30,
                        color: Colors.white, //
                        padding: EdgeInsets.all(15), //
                        onPressed: myButtonEnable ? sendMessage : null, //
                        icon: Icon(Icons.send)),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Container UserChat({
    required final bool isChat,
    required String message,
    required String date,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(15),
      margin: EdgeInsets.symmetric(
        vertical: 12,
      ).copyWith(
        left: isChat ? 80 : 14,
        right: isChat ? 14 : 80,
      ),
      decoration: BoxDecoration(
        color: isChat ? Colors.teal[400] : Colors.tealAccent[100],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
          bottomLeft: isChat ? Radius.circular(12) : Radius.zero,
          bottomRight: isChat ? Radius.zero : Radius.circular(12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: TextStyle(
              fontWeight: isChat ? FontWeight.bold : FontWeight.normal,
              fontSize: 18,
              color: isChat ? Colors.white : Colors.black,
            ),
          ),
          Text(
            date,
            style: TextStyle(
              fontWeight: isChat ? FontWeight.bold : FontWeight.normal,
              fontSize: 18,
              color: isChat ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

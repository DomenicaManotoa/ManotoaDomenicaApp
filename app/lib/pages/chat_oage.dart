// ignore_for_file: unnecessary_import, prefer_const_constructors
import 'package:app/components/chat_bubble.dart';
import 'package:app/components/my_tex_field.dart';
import 'package:app/services/chat/chat_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ChatPage extends StatefulWidget {
  final String receiverUserEmail;
  final String receiverUserID;

  const ChatPage({
    super.key,
    required this.receiverUserEmail,
    required this.receiverUserID,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  String? _editingMessageId;

  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      if (_editingMessageId != null) {
        List<String> ids = [_firebaseAuth.currentUser!.uid, widget.receiverUserID];
        ids.sort();
        String chatRoomId = ids.join("_");
        await _chatService.editMessage(chatRoomId, _editingMessageId!, _messageController.text);
        _editingMessageId = null;
      } else {
        await _chatService.sendMessage(widget.receiverUserID, _messageController.text);
      }
      _messageController.clear();
    }
  }

  void editMessage(String messageId, String currentMessage) {
    setState(() {
      _messageController.text = currentMessage;
      _editingMessageId = messageId;
    });
  }

  void deleteMessage(String messageId) async {
    List<String> ids = [_firebaseAuth.currentUser!.uid, widget.receiverUserID];
    ids.sort();
    String chatRoomId = ids.join("_");
    await _chatService.deleteMessage(chatRoomId, messageId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.receiverUserEmail),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          Expanded(child: _buildMessageList()),
          _buildMessageInput(),
          const SizedBox(height: 25),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return StreamBuilder(
      stream: _chatService.getMessages(widget.receiverUserID, _firebaseAuth.currentUser!.uid),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('Cargando...');
        }
        return ListView(
          children: snapshot.data!.docs.map((document) => _buildMessageItem(document)).toList(),
        );
      },
    );
  }

  Widget _buildMessageItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;

    var alignment = (data['senderId'] == _firebaseAuth.currentUser!.uid)
        ? Alignment.centerRight
        : Alignment.centerLeft;

    return Container(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: (data['senderId'] == _firebaseAuth.currentUser!.uid)
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          mainAxisAlignment: (data['senderId'] == _firebaseAuth.currentUser!.uid)
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          children: [
            Text(data['senderEmail']),
            const SizedBox(height: 5),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(child: ChatBubble(message: data['message'])),
                if (data['senderId'] == _firebaseAuth.currentUser!.uid) ...[
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () => editMessage(document.id, data['message']),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => deleteMessage(document.id),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Row(
        children: [
          Expanded(
            child: MyTextField(
              controller: _messageController,
              hintText: 'Ingrese su mensaje',
              obscureText: false,
            ),
          ),
          IconButton(
            onPressed: sendMessage,
            icon: const Icon(Icons.arrow_upward, size: 40),
          ),
        ],
      ),
    );
  }
}

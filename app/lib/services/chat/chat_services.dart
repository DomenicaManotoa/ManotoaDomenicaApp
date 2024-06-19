import 'package:app/model/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatService extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  Future<void> sendMessage(String receiverId, String message) async {
    final String currentUserId = _firebaseAuth.currentUser!.uid;
    final String currentUserEmail = _firebaseAuth.currentUser!.email.toString();
    final Timestamp timestamp = Timestamp.now();

    String messageId = _fireStore.collection('chat_rooms').doc().id;

    Message newMessage = Message(
      messageId: messageId,
      senderId: currentUserId,
      senderEmail: currentUserEmail,
      receiverId: receiverId,
      message: message,
      timestamp: timestamp,
    );

    List<String> ids = [currentUserId, receiverId];
    ids.sort();
    String chatRoomId = ids.join("_");

    await _fireStore.collection('chat_rooms').doc(chatRoomId).collection('messages').doc(messageId).set(newMessage.toMap());
  }

  Future<void> editMessage(String chatRoomId, String messageId, String newMessage) async {
    await _fireStore.collection('chat_rooms').doc(chatRoomId).collection('messages').doc(messageId).update({
      'message': newMessage,
    });
  }

  Future<void> deleteMessage(String chatRoomId, String messageId) async {
    await _fireStore.collection('chat_rooms').doc(chatRoomId).collection('messages').doc(messageId).delete();
  }

  Stream<QuerySnapshot> getMessages(String userId, String otherUserId) {
    List<String> ids = [userId, otherUserId];
    ids.sort();
    String chatRoomId = ids.join("_");

    return _fireStore.collection('chat_rooms').doc(chatRoomId).collection('messages').orderBy('timestamp', descending: false).snapshots();
  }
}



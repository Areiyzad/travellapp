import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Comment extends StatefulWidget {
  final String postId;
  final String currentUsername;

  const Comment({
    super.key,
    required this.postId,
    required this.currentUsername,
  });

  @override
  State<Comment> createState() => _CommentState();
}

class _CommentState extends State<Comment> {
  final TextEditingController commentController = TextEditingController();
  String? editingCommentId;
  String? currentUserId;

  @override
  void initState() {
    super.initState();
    currentUserId = FirebaseAuth.instance.currentUser?.uid;
  }

  Future<void> addOrUpdateComment(String text) async {
    if (text.trim().isEmpty || currentUserId == null) return;

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(currentUserId).get();
    final currentUsername = userDoc.data()?['name'] ?? userDoc.data()?['email'] ?? 'Unknown';
    final profileImageUrl = userDoc.data()?['profileImageUrl'] ?? '';

    if (editingCommentId != null) {
      await FirebaseFirestore.instance
          .collection('comments')
          .doc(editingCommentId)
          .update({'text': text.trim()});
      setState(() => editingCommentId = null);
    } else {
      await FirebaseFirestore.instance.collection('comments').add({
        'username': currentUsername,
        'uid': currentUserId,
        'profileImageUrl': profileImageUrl,
        'text': text.trim(),
        'postId': widget.postId,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }

    commentController.clear();
  }

  void deleteComment(String docId) async {
    await FirebaseFirestore.instance.collection('comments').doc(docId).delete();
  }

  void startEditing(String docId, String currentText) {
    setState(() {
      editingCommentId = docId;
      commentController.text = currentText;
    });
  }

  @override
  Widget build(BuildContext context) {
    const mainColor = Color(0xFF26a69a);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back_ios_new_outlined, color: mainColor),
                  ),
                  const SizedBox(width: 15),
                  const Text(
                    "Comments",
                    style: TextStyle(
                      color: mainColor,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),

            // Comments List
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('comments')
                    .where('postId', isEqualTo: widget.postId)

                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final comments = snapshot.data!.docs;

                  if (comments.isEmpty) {
                    return const Center(
                      child: Text("No comments yet."),
                    );
                  }

                  return ListView.builder(
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      final data = comments[index].data() as Map<String, dynamic>;
                      final docId = comments[index].id;
                      final isOwner = data['uid'] == currentUserId;
                      final profileImageUrl = data['profileImageUrl'];

                      return ListTile(
                        leading: CircleAvatar(
                          radius: 20,
                          backgroundImage: (profileImageUrl != null && profileImageUrl.isNotEmpty)
                              ? NetworkImage(profileImageUrl)
                              : null,
                          child: (profileImageUrl == null || profileImageUrl.isEmpty)
                              ? const Icon(Icons.person, color: Colors.white)
                              : null,
                          backgroundColor: mainColor,
                        ),
                        title: Text(
                          data['username'] ?? 'Unknown User',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(data['text'] ?? ''),
                        trailing: isOwner
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, size: 20),
                                    onPressed: () => startEditing(docId, data['text']),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, size: 20),
                                    onPressed: () => deleteComment(docId),
                                  ),
                                ],
                              )
                            : null,
                      );
                    },
                  );
                },
              ),
            ),

            // Comment Input
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey.shade300)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: commentController,
                      decoration: InputDecoration(
                        hintText: editingCommentId != null
                            ? "Edit comment..."
                            : "Write a comment...",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => addOrUpdateComment(commentController.text),
                    icon: Icon(
                      editingCommentId != null ? Icons.check : Icons.send,
                      color: mainColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

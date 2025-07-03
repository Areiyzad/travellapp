import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Comment extends StatefulWidget {
  final String username;
  final String caption;
  final String imagePath;

  const Comment({
    super.key,
    required this.username,
    required this.caption,
    required this.imagePath,
  });

  @override
  State<Comment> createState() => _CommentState();
}

class _CommentState extends State<Comment> {
  final TextEditingController commentController = TextEditingController();
  String? editingCommentId;

  void addOrUpdateComment(String text) async {
    if (text.trim().isEmpty) return;

    if (editingCommentId != null) {
      await FirebaseFirestore.instance
          .collection('comments')
          .doc(editingCommentId)
          .update({'text': text.trim()});
      setState(() => editingCommentId = null);
    } else {
      await FirebaseFirestore.instance.collection('comments').add({
        'username': widget.username,
        'text': text.trim(),
        'image': widget.imagePath,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }

    if (editingCommentId == null) {
      commentController.clear();
    }
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
    const mainColor = Color(0xFF26a69a); // 💚 Consistent color

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
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

            // Post Info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: Image.asset(
                      "images/boy.jpg",
                      height: 45,
                      width: 45,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.username,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          widget.caption,
                          style: const TextStyle(fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),

            // Comment List
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('comments')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final commentDocs = snapshot.data!.docs;

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    itemCount: commentDocs.length,
                    itemBuilder: (context, index) {
                      final comment = commentDocs[index];
                      final data = comment.data() as Map<String, dynamic>;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.asset(
                                "images/boy.jpg",
                                height: 38,
                                width: 38,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          data['username'],
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          data['text'],
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (data['username'] == widget.username)
                                    Row(
                                      children: [
                                        TextButton(
                                          onPressed: () => startEditing(comment.id, data['text']),
                                          child: const Text("Edit", style: TextStyle(fontSize: 12)),
                                        ),
                                        TextButton(
                                          onPressed: () => deleteComment(comment.id),
                                          child: const Text("Delete", style: TextStyle(fontSize: 12)),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            // Input Field
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
                        hintText: editingCommentId != null ? "Edit comment..." : "Add a comment...",
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

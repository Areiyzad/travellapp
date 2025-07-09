import 'package:flutter/material.dart';
import 'package:travellapp/pages/add_page.dart';
import 'package:travellapp/pages/comment.dart';
import 'package:travellapp/pages/profile_page.dart';
import 'package:travellapp/pages/top_places.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

const Color primaryColor = Color(0xFF26a69a);

class Home extends StatefulWidget {
  final Map<String, dynamic> userData;

  const Home({super.key, required this.userData});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String? currentUserId;
  String? profileImageUrl;

  @override
  void initState() {
    super.initState();
    fetchProfileImage();
    currentUserId = FirebaseAuth.instance.currentUser?.uid;
  }

  Future<void> fetchProfileImage() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final snapshot =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    setState(() {
      profileImageUrl = snapshot.data()?['profileImageUrl'];
    });
  }

  Future<Map<String, dynamic>> fetchUserData(String uid) async {
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return userDoc.data() ?? {};
  }

  Future<void> deletePost(String postId) async {
    await FirebaseFirestore.instance.collection('posts').doc(postId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // -------------------------- Top Header Section --------------------------
            Stack(
              children: [
                Image.asset(
                  "images/home.png",
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height / 2.5,
                  fit: BoxFit.cover,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 40.0, right: 20.0, left: 20.0),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Image.asset(
                          "images/logo.png",
                          height: 65,
                          width: 50,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 10.0),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const TopPlacesPage()),
                          );
                        },
                        child: Material(
                          elevation: 3.0,
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Image.asset(
                              "images/itinerary.png",
                              height: 40.0,
                              width: 40.0,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const AddPage()),
                          );
                        },
                        child: Material(
                          elevation: 3.0,
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.add, color: primaryColor, size: 30.0),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10.0),
                      GestureDetector(
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const EditableProfilePage()),
                          );
                          await fetchProfileImage();
                        },
                        child: Material(
                          elevation: 3.0,
                          borderRadius: BorderRadius.circular(60),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(60),
                            child: profileImageUrl != null && profileImageUrl!.isNotEmpty
                                ? Image.network(
                                    profileImageUrl!,
                                    height: 50,
                                    width: 50,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    height: 50,
                                    width: 50,
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.image, color: Colors.white),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 120.0, left: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Hey, Travelers!",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 60.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        "Real People. Real Places. Travelly.",
                        style: TextStyle(
                          color: Color.fromARGB(205, 255, 255, 255),
                          fontSize: 20.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(
                    left: 30.0,
                    right: 30.0,
                    top: MediaQuery.of(context).size.height / 2.7,
                  ),
                  child: Material(
                    elevation: 5.0,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.only(left: 20.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(width: 1.5, color: primaryColor),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const TextField(
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Search your destination",
                          suffixIcon: Icon(Icons.search, color: primaryColor),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40.0),

            // -------------------------- Firestore Posts --------------------------
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("posts")
                  .orderBy("createdAt", descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                return Column(
                  children: snapshot.data!.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final postId = doc.id;
                    final isOwner = data["uid"] == currentUserId;

                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance.collection("users").doc(data["uid"]).get(),
                      builder: (context, userSnapshot) {
                        final userData = userSnapshot.data?.data() as Map<String, dynamic>? ?? {};
                        final postProfileUrl = userData["profileImageUrl"] ?? "";

                        return _buildPostCard(
                          postId: postId,
                          username: data["username"] ?? "Unknown",
                          imageUrl: data["imageUrl"] ?? "",
                          location: "${data["place"]}, ${data["city"]}",
                          caption: data["caption"] ?? "",
                          profileImageUrl: postProfileUrl,
                          isOwner: isOwner,
                        );
                      },
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 30.0),
          ],
        ),
      ),
    );
  }

  Widget _buildPostCard({
    required String postId,
    required String username,
    required String imageUrl,
    required String location,
    required String caption,
    required String profileImageUrl,
    required bool isOwner,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
      child: Material(
        elevation: 3.0,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: profileImageUrl.isNotEmpty
                          ? Image.network(
                              profileImageUrl,
                              height: 50,
                              width: 50,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: const Icon(Icons.image, color: Colors.white),
                            ),
                    ),
                    const SizedBox(width: 15.0),
                    Expanded(
                      child: Text(
                        username,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 20.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (isOwner)
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => deletePost(postId),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20.0),
              imageUrl.startsWith("http")
                  ? Image.network(imageUrl)
                  : Image.asset(imageUrl),
              const SizedBox(height: 5.0),
              Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: primaryColor),
                    Text(
                      location,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 5.0),
              Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: Text(
                  caption,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 15.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: Row(
                  children: [
                    const Icon(Icons.favorite_outline, color: primaryColor, size: 30.0),
                    const SizedBox(width: 10.0),
                    const Text(
                      "Like",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 30.0),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => Comment(
                              postId: postId,
                              currentUsername: username,
                            ),
                          ),
                        );
                      },
                      child: Row(
                        children: const [
                          Icon(Icons.comment_outlined,
                              color: primaryColor, size: 28.0),
                          SizedBox(width: 10.0),
                          Text(
                            "Comment",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30.0),
            ],
          ),
        ),
      ),
    );
  }
}

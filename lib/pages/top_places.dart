import 'package:flutter/material.dart';

class TopPlaces extends StatefulWidget {
  const TopPlaces({super.key});

  @override
  State<TopPlaces> createState() => _TopPlacesState();
}

class _TopPlacesState extends State<TopPlaces> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: EdgeInsets.only(top: 50.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: Row(
                children: [
                  Material(
                    elevation: 3.0,
                    borderRadius: BorderRadius.circular(30.0),
                    child: Container(
                      padding: const EdgeInsets.all(5.0),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new_outlined,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width / 3.5),
                  Text(
                    "Top Places",
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 30.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30.0),
            Expanded(
              child: Material(
                elevation: 3.0,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30.0),
                  topRight: Radius.circular(30.0),
                ),
                child: Container(
                  padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 30.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30.0),
                      topRight: Radius.circular(30.0),
                    ),
                  ),
                  width: MediaQuery.of(context).size.width,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Material(
                              elevation: 3.0,
                              borderRadius: BorderRadius.circular(20.0),
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(20.0),
                                    child: Image.asset(
                                      "images/bali.jpg",
                                      height: 300,
                                      width: 190,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(top: 250.0),
                                   height: 50,
                                    width: 190,
                                    decoration: BoxDecoration(
                                      color: Colors.black26, borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20.0), bottomRight: Radius.circular(20.0),)
                                    ),
                                    child: Center(
                                      child: Center(
                                        child: Text(
                                          "Bali",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 30.0,
                                            fontFamily: "Pacifico",
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Material(
                              elevation: 3.0,
                              borderRadius: BorderRadius.circular(20.0),
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(20.0),
                                    child: Image.asset(
                                      "images/india.jpg",
                                      height: 300,
                                      width: 190,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(top: 250.0),
                                   height: 50,
                                    width: 190,
                                    decoration: BoxDecoration(
                                      color: Colors.black26, borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20.0), bottomRight: Radius.circular(20.0),)
                                    ),
                                    child: Center(
                                      child: Center(
                                        child: Text(
                                          "India",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 30.0,
                                            fontFamily: "Pacifico",
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Material(
                              elevation: 3.0,
                              borderRadius: BorderRadius.circular(20.0),
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(20.0),
                                    child: Image.asset(
                                      "images/france.jpg",
                                      height: 300,
                                      width: 190,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(top: 250.0),
                                   height: 50,
                                    width: 190,
                                    decoration: BoxDecoration(
                                      color: Colors.black26, borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20.0), bottomRight: Radius.circular(20.0),)
                                    ),
                                    child: Center(
                                      child: Center(
                                        child: Text(
                                          "France",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 30.0,
                                            fontFamily: "Pacifico",
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Material(
                              elevation: 3.0,
                              borderRadius: BorderRadius.circular(20.0),
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(20.0),
                                    child: Image.asset(
                                      "images/dubai.jpg",
                                      height: 300,
                                      width: 190,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(top: 250.0),
                                   height: 50,
                                    width: 190,
                                    decoration: BoxDecoration(
                                      color: Colors.black26, borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20.0), bottomRight: Radius.circular(20.0),)
                                    ),
                                    child: Center(
                                      child: Center(
                                        child: Text(
                                          "Dubai",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 30.0,
                                            fontFamily: "Pacifico",
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ), 
                        SizedBox(height: 20.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Material(
                              elevation: 3.0,
                              borderRadius: BorderRadius.circular(20.0),
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(20.0),
                                    child: Image.asset(
                                      "images/mexico.jpg",
                                      height: 300,
                                      width: 190,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(top: 250.0),
                                   height: 50,
                                    width: 190,
                                    decoration: BoxDecoration(
                                      color: Colors.black26, borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20.0), bottomRight: Radius.circular(20.0),)
                                    ),
                                    child: Center(
                                      child: Center(
                                        child: Text(
                                          "Mexico",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 30.0,
                                            fontFamily: "Pacifico",
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Material(
                              elevation: 3.0,
                              borderRadius: BorderRadius.circular(20.0),
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(20.0),
                                    child: Image.asset(
                                      "images/newyork.jpg",
                                      height: 300,
                                      width: 190,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(top: 250.0),
                                   height: 50,
                                    width: 190,
                                    decoration: BoxDecoration(
                                      color: Colors.black26, borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20.0), bottomRight: Radius.circular(20.0),)
                                    ),
                                    child: Center(
                                      child: Center(
                                        child: Text(
                                          "New York",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 30.0,
                                            fontFamily: "Pacifico",
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 50.0), 
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

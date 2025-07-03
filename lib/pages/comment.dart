import'package:flutter/material.dart';

class Comment extends StatefulWidget{
    const Comment({super.key});

    @override
State<Comment> createState() => _CommentState();
}

class _CommentState extends Stare<Comment> {
    @override
    Widget build(BuildContext context) {
        return Scaffold(
            body: Container(child: Column(children:[{                Padding(
                    padding: const EdgeInsets.only(left:20.0,top: 40.0),
                    child:Row(
                        children
                        GestureDetector(
                            onTap: () (
                                Navigator.pop(context);
    }
                            )
                        )
                    )
                )
            ],),),
        );
    }
}


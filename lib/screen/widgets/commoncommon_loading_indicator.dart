import 'package:flutter/material.dart';

class CommonLoadingIndicator extends StatelessWidget {
  const CommonLoadingIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.blue[600]),
          SizedBox(height: 16),
          Text('Loading...', style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
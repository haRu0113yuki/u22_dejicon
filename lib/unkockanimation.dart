import 'package:flutter/material.dart';

class UnlockAnimation extends StatelessWidget {
  final VoidCallback onDismiss;

  const UnlockAnimation({Key? key, required this.onDismiss}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Stack(
        children: [
          Container(
            color: Colors.black.withOpacity(0.6),
            child: Center(
              child: SizedBox(
                width: 200,
                height: 200,
                child: Image.asset('assets/images/unlock_animation.gif'),
              ),
            ),
          ),
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton(
                onPressed: onDismiss,
                child: const Text('閉じる'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

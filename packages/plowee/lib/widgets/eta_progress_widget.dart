import 'package:flutter/material.dart';

class ETAProgressWidget extends StatelessWidget {
final int totalMinutes;
final int elapsedMinutes;

const ETAProgressWidget({
    Key? key,
    required this.totalMinutes,
    required this.elapsedMinutes,
}) : super(key: key);

@override
Widget build(BuildContext context) {
    final progress = elapsedMinutes / totalMinutes;
    final remainingMinutes = totalMinutes - elapsedMinutes;

    return Container(
    height: MediaQuery.of(context).size.height * 0.2,
    padding: const EdgeInsets.all(16.0),
    decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
        BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
        ),
        ],
    ),
    child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        Text(
            'Estimated Time Remaining',
            style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
            Theme.of(context).primaryColor,
            ),
        ),
        const SizedBox(height: 8),
        Text(
            '$remainingMinutes minutes remaining',
            style: Theme.of(context).textTheme.bodyLarge,
        ),
        ],
    ),
    );
}
}


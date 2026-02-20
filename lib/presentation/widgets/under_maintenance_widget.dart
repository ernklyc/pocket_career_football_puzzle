import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// Bakımda / geliştirme aşamasında bölüm gösterimi.
/// Sadece Lottie animasyonu gösterir.
class UnderMaintenanceWidget extends StatelessWidget {
  final bool fullPage;

  const UnderMaintenanceWidget({
    super.key,
    this.fullPage = false,
  });

  @override
  Widget build(BuildContext context) {
    final content = SizedBox(
      width: fullPage ? 200 : 120,
      height: fullPage ? 200 : 120,
      child: Lottie.asset(
        'assets/lottie/Under Maintenance.json',
        fit: BoxFit.contain,
        repeat: true,
      ),
    );

    if (fullPage) {
      return Center(child: content);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      child: Center(child: content),
    );
  }
}

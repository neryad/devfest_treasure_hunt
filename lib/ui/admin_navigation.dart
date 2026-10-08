import 'package:flutter/material.dart';

import 'screens/admin/admin_login_screen.dart';

/// Convenience access to the admin demo panel.
void openAdminDemo(BuildContext context) {
  Navigator.of(
    context,
  ).push(MaterialPageRoute<void>(builder: (_) => const AdminLoginScreen()));
}

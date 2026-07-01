import 'package:flutter_test/flutter_test.dart';

import 'architecture_rules.dart';

void main() {
  group('hasArchExemptForImport', () {
    test('accepts arch-exempt with a reason immediately above import', () {
      final lines = <String>[
        '// arch-exempt: Profile 页依赖 auth 登出能力（跨切面）。',
        "import 'package:flutter_arms/features/auth/application/auth_usecases.dart';",
      ];

      expect(hasArchExemptForImport(lines, 1), isTrue);
    });

    test('rejects file-level arch-exempt away from import', () {
      final lines = <String>[
        '// arch-exempt: not close enough',
        '',
        'final value = 1;',
        "import 'package:flutter_arms/features/auth/application/auth_usecases.dart';",
      ];

      expect(hasArchExemptForImport(lines, 3), isFalse);
    });

    test('rejects arch-exempt without a reason', () {
      final lines = <String>[
        '// arch-exempt',
        "import 'package:flutter_arms/features/auth/application/auth_usecases.dart';",
      ];

      expect(hasArchExemptForImport(lines, 1), isFalse);
    });
  });
}

library all_test_junit;

import 'package:junitconfiguration/junitconfiguration.dart';
import 'all_test.dart' as all_test;

void main() {
  JUnitConfiguration.install();
  all_test.main();
}

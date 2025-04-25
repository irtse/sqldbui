import 'package:sqldbui2/model/view.dart';

class TriggerCacheService {
  static List<Trigger> triggers = [];

  static void setTriggers(List<Trigger> t) {
    triggers.addAll(t);
  }

  static List<Trigger> getTriggers() {
    return triggers;
  }

  static void deleteTriggers(int index) {
    if (triggers.isNotEmpty) {
      triggers.removeAt(index);
    }
  }
}
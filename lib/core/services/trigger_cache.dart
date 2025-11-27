import 'package:sqldbui2/model/view.dart';

class TriggerCacheService {
  static List<Trigger> triggers = [];

  static void setTriggers(List<Trigger> t) {
    triggers = [];
    for (var t in triggers) {
      if (triggers.where( (tt) => tt.name == t.name).isEmpty) {
        triggers.add(t);
      }
    }
    print(t.length);
  }

  static List<Trigger> getTriggers() {
    return triggers;
  }

  static void deleteTriggers(int index) {
    if (triggers.isNotEmpty) {
      try{
        triggers.removeAt(index);
      } catch(e) {}
    }
  }
}
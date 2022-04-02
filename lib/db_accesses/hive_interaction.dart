import 'package:hive/hive.dart';

mixin HiveHelperFunctions {
  void reorderEntries(int oldIndex, int newIndex, Box box) {
    var reorderedEntry = box.get(oldIndex)!;
    if (oldIndex < newIndex) {
      --newIndex;
      for (int indexKey = oldIndex; indexKey < newIndex; ++indexKey) {
        var nextEntry = box.get(indexKey + 1)!;
        box.delete(indexKey + 1);
        box.put(indexKey, nextEntry);
      }
      box.put(newIndex, reorderedEntry);
    } else {
      for (int indexKey = oldIndex; indexKey > newIndex; --indexKey) {
        var nextEntry = box.get(indexKey - 1)!;
        box.delete(indexKey - 1);
        box.put(indexKey, nextEntry);
      }
      box.put(newIndex, reorderedEntry);
    }
  }

  void removeEntryAt(int indexKey, Box box) {
    reorderEntries(indexKey, box.length, box);
    box.delete(box.length - 1);
  }
}

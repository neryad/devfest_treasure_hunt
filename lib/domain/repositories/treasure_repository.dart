import '../entities/treasure_item.dart';

/// Abstraction over treasure storage. A future `FirebaseTreasureRepository`
/// implements this same interface without touching the UI.
abstract class TreasureRepository {
  Future<List<TreasureItem>> getTreasures();

  Future<TreasureItem?> getTreasure(String id);

  Future<TreasureItem?> getByCode(String code);

  Future<TreasureItem?> getByQrValue(String value);

  Future<void> setTreasureActive(String id, bool active);
}
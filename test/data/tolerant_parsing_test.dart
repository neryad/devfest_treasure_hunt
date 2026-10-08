import 'package:devfest_treasure_hunt/data/datasources/firebase_data_source.dart';
import 'package:devfest_treasure_hunt/domain/entities/participant.dart';
import 'package:devfest_treasure_hunt/domain/entities/treasure_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('tryFromJson returns null for malformed participant docs', () {
    expect(Participant.tryFromJson({'id': 'p1', 'nickname': 'x'}), isNull);
    expect(
      Participant.tryFromJson({
        'id': 'p1',
        'name': 'A',
        'nickname': 'a',
        'startedAt': 'not-a-date',
      }),
      isNull,
    );
  });

  test('tryFromJson parses a valid participant', () {
    final p = Participant.tryFromJson({
      'id': 'p1',
      'name': 'A',
      'nickname': 'a',
      'startedAt': '2026-10-07T17:45:11.699',
      'status': 'active',
      'discoveredTreasureIds': <String>[],
      'points': 0,
      'medals': 0,
    });
    expect(p, isNotNull);
    expect(p!.id, 'p1');
  });

  test('tryFromJson returns null for malformed treasure docs', () {
    expect(TreasureItem.tryFromJson({'id': 't1', 'title': 'X'}), isNull);
  });

  test('decodeTreasures skips malformed docs and sorts by order', () {
    Map<String, dynamic> valid(String id, int order) => {
      'id': id,
      'title': id,
      'description': 'desc',
      'code': 'CODE-$id',
            'clue': 'clue',
      'locationDescription': 'loc',
      'iconKey': 'code',
      'order': order,
    };

    final list = FirebaseDataSource.decodeTreasures([
      valid('b', 2),
      {'id': 'broken'},
      valid('a', 1),
    ]);

    expect(list.map((t) => t.id), ['a', 'b']);
  });
}

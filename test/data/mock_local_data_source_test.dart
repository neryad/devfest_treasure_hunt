import 'package:devfest_treasure_hunt/data/datasources/mock_local_data_source.dart';
import 'package:devfest_treasure_hunt/data/repositories/mock_app_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('setEventActive persists the event state for subsequent loads', () async {
    final dataSource = MockLocalDataSource();
    await dataSource.initialize();
    final repository = MockAppRepository(dataSource);

    expect((await repository.getEvent()).active, isTrue);

    await repository.setEventActive(false);

    expect((await repository.getEvent()).active, isFalse);
  });
}

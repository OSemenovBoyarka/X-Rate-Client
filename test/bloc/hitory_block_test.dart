import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:money/money.dart';
import 'package:x_rate_monitor/bloc/history_bloc.dart';
import 'package:x_rate_monitor/bloc/history_events.dart';
import 'package:x_rate_monitor/model/repository.dart';

import '../data/mock_network_responses.dart';

class MockRepository extends Mock implements Repository {}

void main() {
  MockRepository mockRepository;
  HistoryBloc historyBloc;

  setUp(() {
    mockRepository = MockRepository();
    historyBloc = HistoryBloc(mockRepository);
  });

  test("after dispose bloc emits no new state", () {
    expectLater(
      historyBloc.output,
      emitsInOrder([]),
    );
    historyBloc.dispose();
  });

  test("network response is being returned for history reuest", () {
    var mockedResponse = mockHistoryResponse(mockBaseCurrency);
    when(mockRepository.getRatesHistory(
      targetCurrencies: anyNamed("targetCurrencies"),
      baseCurrency: anyNamed("baseCurrency"),
      from: anyNamed("from"),
      to: anyNamed("to"),
    )).thenAnswer((_) => Future.value(mockedResponse));

    expect(
      historyBloc.output,
      emits(mockedResponse),
    );

    historyBloc.input.add(GetHistoryEvent(mockBaseCurrency, [Currency("USD")], 180));
  });

  test("bloc calls repository with correct arguments", () async {
    var event = GetHistoryEvent(mockBaseCurrency, [Currency("USD")], 180);
    historyBloc.input.add(event);

    // wait for first output event - at this point rates history repository must be called
    await historyBloc.output.first;

    var fromDate = DateTime.now().subtract(Duration(days: event.historyDays));
    var toDate = DateTime.now();

    verify(mockRepository.getRatesHistory(
      targetCurrencies: event.targetCurrencies,
      baseCurrency: event.baseCurrency,
      from: argThat(
        predicate<DateTime>((date) => date.difference(fromDate).inSeconds < 10),
        named: "from",
      ),
      to: argThat(
        predicate<DateTime>((date) => date.difference(toDate).inSeconds < 10),
        named: "to",
      ),
    )).called(1);
  });
}

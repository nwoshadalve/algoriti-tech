// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'dart:convert';
import 'dart:io';

import 'package:algoritiq_app/api/cors_policy.dart';
import 'package:algoritiq_app/api/local_api_server.dart';
import 'package:algoritiq_app/features/analytics/application/analytics_service.dart';
import 'package:algoritiq_app/features/analytics/domain/analytics_models.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/access_kit.dart';
import '../../support/queue_desk_kit.dart';

/// The test clock starts at 2026-10-27 09:00 UTC: 15:00 in Dhaka, the same day.
void main() {
  late QueueDeskKit desk;
  late AnalyticsService analytics;

  Future<void> issue(String name, String phone, int? fee) async {
    final issued = await desk.addPatient(name, phone, command: 'c-$phone');
    await desk.boardRepo.setTokenFee(issued.token.id, fee);
  }

  setUp(() async {
    desk = await QueueDeskKit.open();
    analytics = AnalyticsService(desk.kit.database, desk.kit.clock.call);
    await desk.board.startSession(desk.account, deskChamberId);
  });

  test('should read today from the database', () async {
    await issue('Rahim', '01955000444', 500);
    await issue('Mina', '01955000555', 300);

    final result = await analytics.read(period: AnalyticsPeriod.day);

    expect(result.fromDate, '2026-10-27');
    expect(result.totals.tokens, 2);
    expect(result.totals.feeBdt, 800);
    expect(result.totals.patients, 2);
    expect(result.totals.sessions, 1);
    expect(result.series, hasLength(24));
    expect(result.series[15].totals.tokens, 2);
  });

  test('should name the queue and the chamber', () async {
    await issue('Rahim', '01955000444', 500);

    final result = await analytics.read(period: AnalyticsPeriod.week);

    expect(result.byQueue.single.englishName, 'Regular');
    expect(result.byChamber.single.name, 'Room 1');
    expect(result.byChamber.single.totals.tokens, 1);
  });

  test('should count the patients registered in the period', () async {
    await issue('Rahim', '01955000444', null);

    final result = await analytics.read(period: AnalyticsPeriod.month);

    expect(result.totals.newPatients, 1);
  });

  test('should read another day by its date and leave today out', () async {
    await issue('Rahim', '01955000444', 500);

    final other = await analytics.read(
      period: AnalyticsPeriod.day,
      date: '2026-10-20',
    );

    expect(other.fromDate, '2026-10-20');
    expect(other.totals.tokens, 0);
  });

  test('should limit the figures to one chamber', () async {
    await issue('Rahim', '01955000444', 500);

    final other = await analytics.read(
      period: AnalyticsPeriod.day,
      chamberId: 'another-chamber',
    );

    expect(other.totals.tokens, 0);
    expect(other.totals.sessions, 0);
  });

  test('should read all time from the first token', () async {
    await issue('Rahim', '01955000444', 500);

    final result = await analytics.read(period: AnalyticsPeriod.all);

    expect(result.fromDate, '2026-10-27');
    expect(result.series.single.key, '2026');
    expect(result.totals.tokens, 1);
    expect(result.previous, isNull);
  });

  group('the web route', () {
    late AccessKit kit;
    late LocalApiServer server;
    late HttpClient client;

    setUp(() async {
      kit = await AccessKit.create();
      await kit.registerAdmin();
      server = LocalApiServer(
        access: () async => kit.service,
        analytics: AnalyticsService(kit.database, kit.clock.call),
        corsPolicy: CorsPolicy.reflectOrigin,
      );
      await server.start(port: 0, address: InternetAddress.loopbackIPv4);
      client = HttpClient();
    });

    tearDown(() async {
      client.close(force: true);
      await server.stop();
      await kit.close();
    });

    Future<String> signIn() async {
      final request = await client.postUrl(
        Uri.parse('http://127.0.0.1:${server.port}/api/v1/auth/login'),
      );
      request.headers.set('content-type', 'application/json');
      request.write(
        jsonEncode({
          'username': 'owner',
          'password': AccessKit.password,
          'clientKey': 'test',
        }),
      );
      final body = jsonDecode(
        await utf8.decodeStream(await request.close()),
      ) as Map<String, Object?>;
      return body['token']! as String;
    }

    Future<({int status, Map<String, Object?> body})> get(
      String path, {
      String? token,
    }) async {
      final request = await client.getUrl(
        Uri.parse('http://127.0.0.1:${server.port}$path'),
      );
      if (token != null) request.headers.set('authorization', 'Bearer $token');
      final response = await request.close();
      final text = await utf8.decodeStream(response);
      return (
        status: response.statusCode,
        body: text.isEmpty
            ? <String, Object?>{}
            : jsonDecode(text) as Map<String, Object?>,
      );
    }

    test('should answer an admin with the figures of the period', () async {
      final token = await signIn();

      final result = await get('/api/v1/analytics?period=week', token: token);

      expect(result.status, 200);
      expect(result.body['period'], 'week');
      expect(result.body['granularity'], 'day');
      expect((result.body['series']! as List), hasLength(7));
      expect((result.body['totals']! as Map)['tokens'], 0);
    });

    test('should refuse a request without a sign-in', () async {
      final result = await get('/api/v1/analytics?period=week');

      expect(result.status, 401);
    });

    test('should refuse a period or date it does not know', () async {
      final token = await signIn();

      final badPeriod = await get(
        '/api/v1/analytics?period=hour',
        token: token,
      );
      final noPeriod = await get('/api/v1/analytics', token: token);
      final badDate = await get(
        '/api/v1/analytics?period=day&date=yesterday',
        token: token,
      );

      expect(badPeriod.status, 400);
      expect(noPeriod.status, 400);
      expect(badDate.status, 400);
    });
  });
}

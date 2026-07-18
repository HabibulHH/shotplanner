import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shotkit/data/media_service.dart';
import 'package:shotkit/data/models.dart';
import 'package:shotkit/features/export/pdf_export_service.dart';

void main() {
  late Directory temp;
  late PdfExportService service;

  setUp(() async {
    temp = await Directory.systemTemp.createTemp('shotkit_pdf_test_');
    service = PdfExportService(MediaService(documents: temp));
  });

  tearDown(() async => temp.delete(recursive: true));

  test('exports an empty project as a verified non-blank PDF', () async {
    final result = await service.build(_project([]), PdfLayout.detailed,
        includeCompleted: true, isPro: false);
    expect(result.bytes.length, greaterThan(1024));
    expect(result.pageCount, 1);
  });

  test('replaces a corrupt image path and still exports', () async {
    final scene = Scene(
        id: 2,
        title: 'Scene',
        location: 'Set',
        timeOfDay: TimeOfDayTag.day,
        shots: [
          Shot(
              id: 3,
              description: 'Corrupt reference',
              size: 'CU',
              angle: 'Eye level',
              movement: 'Static',
              lens: '50mm',
              imagePath: 'media/missing.jpg'),
        ]);
    final result = await service.build(_project([scene]), PdfLayout.detailed,
        includeCompleted: true, isPro: true);
    expect(result.bytes.length, greaterThan(1024));
    expect(result.pageCount, greaterThan(0));
  });

  test('exports a 200 shot compact fixture', () async {
    final shots = List.generate(
        200,
        (index) => Shot(
              id: 100 + index,
              description: 'Fixture shot $index',
              size: 'MS',
              angle: 'Eye level',
              movement: 'Static',
              lens: '35mm',
            ));
    final scene = Scene(
        id: 2,
        title: 'Large scene',
        location: 'Stage',
        timeOfDay: TimeOfDayTag.indoor,
        shots: shots);
    final result = await service.build(_project([scene]), PdfLayout.compact,
        includeCompleted: true, isPro: true);
    expect(result.bytes.length, greaterThan(1024));
    expect(result.pageCount, greaterThan(1));
  });
}

Project _project(List<Scene> scenes) => Project(
      id: 1,
      title: 'Test Production',
      type: 'SHORT FILM',
      updatedLabel: 'Now',
      scenes: scenes,
    );

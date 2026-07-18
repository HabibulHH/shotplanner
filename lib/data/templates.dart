import 'models.dart';

List<Scene> buildTemplate(String template, int Function() nextId) {
  Shot shot(String description, String size, String movement, String lens,
          {String angle = 'Eye level',
          bool must = true,
          String camera = 'A-Cam'}) =>
      Shot(
        id: nextId(),
        description: description,
        size: size,
        angle: angle,
        movement: movement,
        lens: lens,
        camera: camera,
        mustHave: must,
      );
  Scene scene(String title, TimeOfDayTag time, List<Shot> shots) => Scene(
        id: nextId(),
        title: title,
        location: 'Location TBC',
        timeOfDay: time,
        shots: shots,
      );

  switch (template.toLowerCase()) {
    case 'wedding':
      return [
        scene('Prep & details', TimeOfDayTag.indoor, [
          shot('Rings on invitation suite', 'ECU', 'Static', '85mm',
              angle: 'High'),
          shot('Dress hanging by window', 'MS', 'Slider', '35mm'),
          shot('Makeup mirror reflection', 'CU', 'Handheld', '50mm'),
          shot('Family helping with jewellery', 'MCU', 'Gimbal', '35mm'),
          shot('Bride reveal to family', 'LS', 'Gimbal', '24mm'),
          shot('Window portrait in soft light', 'CU', 'Static', '85mm'),
          shot('Shoes, perfume and card details', 'Insert', 'Handheld', '50mm',
              must: false),
        ]),
        scene('Ceremony', TimeOfDayTag.day, [
          shot('Venue establishing', 'ELS', 'Drone', '24mm',
              angle: 'Overhead', camera: 'Drone'),
          shot('Processional wide master', 'LS', 'Static', '24mm'),
          shot('Partner reaction', 'CU', 'Static', '85mm', camera: 'B-Cam'),
          shot('Vows close-up', 'CU', 'Static', '85mm'),
          shot('Ring exchange insert', 'ECU', 'Static', '85mm'),
          shot('First kiss wide', 'LS', 'Static', '35mm'),
          shot('Recessional follow', 'MLS', 'Gimbal', '24mm'),
        ]),
        scene('Couple session', TimeOfDayTag.golden, [
          shot('Walking two-shot', 'LS', 'Gimbal', '35mm'),
          shot('Backlit portrait', 'CU', 'Static', '85mm'),
          shot('Hands and rings', 'Insert', 'Handheld', '50mm'),
          shot('Gimbal orbit', 'MLS', 'Gimbal', '24mm'),
          shot('Silhouette wide', 'ELS', 'Static', '35mm', must: false),
        ]),
        scene('Reception', TimeOfDayTag.night, [
          shot('Room and decor reveal', 'ELS', 'Gimbal', '24mm'),
          shot('Grand entrance follow', 'MLS', 'Gimbal', '24mm'),
          shot('First dance orbit', 'MS', 'Gimbal', '35mm'),
          shot('Parent reactions', 'CU', 'Handheld', '85mm', camera: 'B-Cam'),
          shot('Cake cutting', 'MS', 'Static', '50mm'),
          shot('Dance floor energy', 'MLS', 'Handheld', '24mm'),
        ]),
      ];
    case 'interview':
      return [
        scene('Interview setup', TimeOfDayTag.indoor, [
          shot('A-cam interview master', 'MS', 'Static', '50mm'),
          shot('B-cam profile', 'CU', 'Static', '85mm', camera: 'B-Cam'),
          shot('Hands and gesture cutaway', 'Insert', 'Handheld', '85mm',
              must: false),
          shot('Workspace establishing', 'LS', 'Gimbal', '24mm'),
          shot('Room tone — record 60 seconds', 'LS', 'Static', '24mm'),
        ])
      ];
    case 'music video':
      return [
        scene('Performance', TimeOfDayTag.indoor, [
          shot('Full performance master', 'LS', 'Static', '24mm'),
          shot('Lead lip-sync close-up', 'CU', 'Handheld', '50mm'),
          shot('Performance orbit', 'MLS', 'Gimbal', '24mm'),
          shot('Instrument details', 'Insert', 'Handheld', '85mm'),
        ]),
        scene('B-roll', TimeOfDayTag.night, [
          shot('Location establishing', 'ELS', 'Gimbal', '24mm'),
          shot('Slow-motion movement pass', 'MS', 'Gimbal', '50mm'),
        ]),
      ];
    case 'short film':
      return [
        scene('Scene 01', TimeOfDayTag.day, [
          shot('Scene master', 'LS', 'Static', '24mm'),
          shot('Character coverage', 'MS', 'Static', '50mm'),
          shot('Reaction close-up', 'CU', 'Static', '85mm'),
        ])
      ];
    default:
      return [];
  }
}

// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import '../domain/bengali_number_words.dart';

/// The recorded clips a spoken call is built from. Each key is a file
/// `<key>.wav` in the voice pack (`assets/announcements/`).
///
/// A call is "টোকেন নম্বর" + the serial as words + the patient's name
/// (when there is one) + a closing phrase that depends on the queue and on
/// whether this is the first call or a recall.
///
/// - `n0` .. `n99`: the numbers one by one ("এক", "বিয়াল্লিশ").
/// - `h1` .. `h9`: the hundreds ("একশো" .. "নয়শো").
/// - `thousand`: "হাজার".
/// - `t1` .. `t99`: "এক হাজার" .. "নিরানব্বই হাজার" as one phrase, spoken so
///   that it runs on into the next word.
/// - `lakh1`: "এক লাখ" (100000, the largest number that is spoken).
/// - `h1_c` .. `h9_c`: the hundreds, spoken to run on into the rest.
/// - `token_c`: "টোকেন নম্বর", spoken to run on into the number.
/// - `come`, `come_report`, `come_dressing`: the closing phrase of a first call.
/// - `recall_come`, `recall_report`, `recall_dressing`: the same, for a recall.
const callTokenKey = 'token_c';

/// Queues that have a closing phrase of their own. Every other queue,
/// regular included, uses the plain "please come in".
const _queuesWithOwnClosing = {'report', 'dressing'};

/// The closing phrase clip of a call in [queueTypeId].
String callClosingKey(String queueTypeId, {bool recall = false}) {
  final base = _queuesWithOwnClosing.contains(queueTypeId)
      ? queueTypeId
      : 'come';
  if (base == 'come') return recall ? 'recall_come' : 'come';
  return recall ? 'recall_$base' : 'come_$base';
}

/// The clips that say the number [serial] (1 .. 100000), in order: 1001 is
/// "এক হাজার" + "এক", 25678 is "পঁচিশ হাজার" + "ছয়শো" + "আটাত্তর". The words that
/// are followed by another run on into it, as a native speaker says
/// "এক-হাজার-এক" in one breath.
List<String> callClipKeys(int serial) {
  if (serial < 1 || serial > maxSpokenSerial) {
    throw RangeError.range(serial, 1, maxSpokenSerial, 'serial');
  }
  if (serial == maxSpokenSerial) return ['lakh1'];
  final thousands = serial ~/ 1000;
  final hundreds = serial % 1000 ~/ 100;
  final rest = serial % 100;
  if (hundreds == 0 && rest == 0) {
    // Nothing follows the thousand: it ends the number.
    return ['n$thousands', 'thousand'];
  }
  return [
    if (thousands > 0) 't$thousands',
    if (hundreds > 0) rest > 0 ? 'h${hundreds}_c' : 'h$hundreds',
    if (rest > 0) 'n$rest',
  ];
}

/// Every clip a call can need.
final List<String> allCallClipKeys = [
  for (var n = 0; n <= 99; n++) 'n$n',
  for (var h = 1; h <= 9; h++) ...['h$h', 'h${h}_c'],
  for (var t = 1; t <= 99; t++) 't$t',
  'thousand',
  'lakh1',
  callTokenKey,
  for (final queue in ['', ..._queuesWithOwnClosing])
    for (final recall in [false, true]) callClosingKey(queue, recall: recall),
];

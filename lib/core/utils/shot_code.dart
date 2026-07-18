String shotSuffix(int index) {
  var value = index + 1;
  var letters = '';
  while (value > 0) {
    value--;
    letters = String.fromCharCode(65 + value % 26) + letters;
    value ~/= 26;
  }
  return letters;
}

String shotCode(int sceneIndex, int shotIndex) =>
    '${sceneIndex + 1}${shotSuffix(shotIndex)}';

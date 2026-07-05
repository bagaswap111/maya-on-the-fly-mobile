import 'dart:io';
import 'package:image/image.dart' as img;

const w = 480;
const h = 854;

void main() {
  final dir = Directory('assets/screenshots');
  if (!dir.existsSync()) dir.createSync(recursive: true);

  _save('homepage', _drawHomePage());
  _save('editor', _drawEditor());
  _save('chat', _drawChat());
  _save('settings', _drawSettings());

  print('All screenshots generated in assets/screenshots/');
}

void _save(String name, img.Image image) {
  final file = File('assets/screenshots/$name.png');
  file.writeAsBytesSync(img.encodePng(image));
  print('  Created: assets/screenshots/$name.png (${file.lengthSync()} bytes)');
}

// Color helpers
int _hex(int hex) => hex; // keep as int for convenience
img.Color _c(int hex) => img.ColorRgb8((hex >> 16) & 0xFF, (hex >> 8) & 0xFF, hex & 0xFF);

final _bg = _c(0xF5F5F5);
final _white = _c(0xFFFFFF);
final _dark = _c(0x181D26);
final _blue = _c(0x1B61C9);
final _gray = _c(0x999999);
final _lightGray = _c(0xE0E0E0);
final _cream = _c(0xFFF3E0);
final _orange = _c(0xE65100);
final _chatUser = _c(0xD6E4FF);
final _chatAssistant = _c(0xE8E8E8);

img.Image _createCanvas() => img.Image(width: w, height: h);

void _fillRect(img.Image image, int x, int y, int w, int h, img.Color color) {
  for (var dy = 0; dy < h; dy++) {
    for (var dx = 0; dx < w; dx++) {
      image.setPixel(x + dx, y + dy, color);
    }
  }
}

void _drawTextLine(img.Image image, String text, int x, int y, img.Color color, {int size = 14}) {
  final textLen = text.length;
  final textW = textLen * (size ~/ 2);
  _fillRect(image, x, y, textW, 2, color);
  _fillRect(image, x, y + size - 2, textW, 2, color);
}

void _drawCard(img.Image image, int x, int y, int w, int h, img.Color color) {
  _fillRect(image, x, y, w, h, color);
  // border
  for (var dx = 0; dx < w; dx++) {
    image.setPixel(x + dx, y, _lightGray);
    image.setPixel(x + dx, y + h - 1, _lightGray);
  }
  for (var dy = 0; dy < h; dy++) {
    image.setPixel(x, y + dy, _lightGray);
    image.setPixel(x + w - 1, y + dy, _lightGray);
  }
}

void _drawAppBar(img.Image image, String title) {
  _fillRect(image, 0, 0, w, 56, _white);
  for (var dx = 0; dx < w; dx++) {
    image.setPixel(dx, 56, _lightGray);
  }
  _drawTextLine(image, title, 16, 20, _dark, size: 18);
}

img.Image _drawHomePage() {
  final image = _createCanvas();
  _fillRect(image, 0, 0, w, h, _bg);

  _drawAppBar(image, 'Maya on the Fly');

  _drawCard(image, 16, 72, 140, 80, _dark);
  _fillRect(image, 24, 112, 120, 2, _c(0xFFFFFFFF));
  _drawTextLine(image, 'New Doc', 24, 96, _c(0xFFFFFF), size: 13);

  _drawCard(image, 168, 72, 140, 80, _white);
  _fillRect(image, 176, 112, 120, 2, _dark);
  _drawTextLine(image, 'New Chat', 176, 96, _dark, size: 13);

  _drawCard(image, 320, 72, 140, 80, _white);
  _fillRect(image, 328, 112, 120, 2, _dark);
  _drawTextLine(image, 'Open Repo', 328, 96, _dark, size: 13);

  var y = 172;
  _drawTextLine(image, 'Recent Documents', 16, y, _dark, size: 16);
  y += 40;
  _drawTextLine(image, 'No documents yet', 100, y + 20, _gray);
  _drawTextLine(image, 'Create your first document', 80, y + 40, _blue, size: 13);

  y += 80;
  _drawTextLine(image, 'Recent Chats', 16, y, _dark, size: 16);
  y += 40;
  _drawTextLine(image, 'No chats yet', 100, y + 20, _gray);
  _drawTextLine(image, 'Start a conversation', 80, y + 40, _blue, size: 13);

  return image;
}

img.Image _drawEditor() {
  final image = _createCanvas();
  _fillRect(image, 0, 0, w, h, _white);

  _drawAppBar(image, 'Untitled');

  _fillRect(image, 0, 57, w, 28, _cream);
  _drawTextLine(image, 'Unsaved changes', 16, 63, _orange, size: 12);

  _drawTextLine(image, 'Start writing...', 20, 110, _gray, size: 16);

  _fillRect(image, 0, h - 32, w, 32, _bg);
  for (var dx = 0; dx < w; dx++) {
    image.setPixel(dx, h - 32, _lightGray);
  }
  _drawTextLine(image, '0 words', 16, h - 22, _gray, size: 12);
  _drawTextLine(image, '0 chars', w - 60, h - 22, _gray, size: 12);

  return image;
}

img.Image _drawChat() {
  final image = _createCanvas();
  _fillRect(image, 0, 0, w, h, _bg);

  _drawAppBar(image, 'Chat');

  _drawCard(image, 160, 72, 300, 48, _chatUser);
  _drawTextLine(image, 'Can you help me write a doc?', 170, 88, _dark, size: 13);

  _drawCard(image, 16, 136, 340, 64, _chatAssistant);
  _drawTextLine(image, 'Of course! What kind of doc?', 26, 150, _dark, size: 13);

  _drawCard(image, 140, 216, 320, 48, _chatUser);
  _drawTextLine(image, 'A project proposal template', 150, 232, _dark, size: 13);

  _drawCard(image, 16, 280, 300, 48, _chatAssistant);
  _drawTextLine(image, "Here's a template for you...", 26, 296, _dark, size: 13);

  final inputY = h - 56;
  _fillRect(image, 0, inputY, w, 56, _white);
  for (var dx = 0; dx < w; dx++) {
    image.setPixel(dx, inputY, _lightGray);
  }
  _drawCard(image, 12, inputY + 10, w - 70, 36, _white);
  _drawTextLine(image, 'Type a message...', 22, inputY + 22, _gray, size: 13);
  _fillRect(image, w - 44, inputY + 12, 32, 32, _dark);

  return image;
}

img.Image _drawSettings() {
  final image = _createCanvas();
  _fillRect(image, 0, 0, w, h, _bg);

  _drawAppBar(image, 'Settings');

  final sections = [
    ('Profile', ['Profile']),
    ('AI Configuration', ['Model Manager', 'Usage Dashboard']),
    ('Appearance', ['Theme']),
    ('Editor', ['Editor Settings']),
    ('Privacy & Security', ['App Lock']),
    ('Support', ['Help & FAQ']),
    ('About', ['About', 'Keyboard Shortcuts']),
  ];

  var y = 72;
  for (final (title, items) in sections) {
    _drawTextLine(image, title, 16, y, _gray, size: 12);
    y += 24;
    for (final item in items) {
      _drawTextLine(image, item, 16, y, _dark, size: 15);
      _fillRect(image, w - 40, y, 12, 14, _lightGray);
      y += 40;
    }
    for (var dx = 16; dx < w - 16; dx++) {
      image.setPixel(dx, y, _lightGray);
    }
    y += 4;
  }

  return image;
}

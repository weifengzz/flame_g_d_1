import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    await Flame.device.setLandscapeRightOnly();
    await Flame.device.fullScreen();
  }
  runApp(GameWidget(game: MyGame()));
}

class MyGame extends FlameGame with HasTappables {
  SpriteComponent girl = SpriteComponent();
  SpriteComponent boy = SpriteComponent();
  SpriteComponent background = SpriteComponent();
  SpriteComponent background2 = SpriteComponent();

  DialogButton dialogButton = DialogButton();
  final double characterSize = 200.0;
  bool turnAway = false;
  int dialogLevel = 0;
  final Vector2 buttonSize = Vector2(50.0, 50.0);
  int sceneLevel = 1;

  TextPaint dialogTextPaint = TextPaint(
    style: const TextStyle(
      fontSize: 30.0,
      color: Colors.white,
    ),
  );

  @override
  Future<void>? onLoad() async {
    super.onLoad();
    final double screenWidth = size[0];
    final double screenHeight = size[1];
    const double textBoxHeight = 100.0;

    background2
      ..sprite = await loadSprite('castle.jpg')
      ..size = Vector2(size[0], size[1] - 100);

    // load background
    add(
      background
        ..sprite = await loadSprite('background.png')
        ..size = Vector2(size[0], size[1] - 100),
    );

    // load girl
    girl.sprite = await loadSprite('girl.png');
    girl.size = Vector2(characterSize, characterSize);
    girl.y = screenHeight - characterSize - textBoxHeight;
    girl.anchor = Anchor.topCenter;
    add(girl);

    // load boy
    boy.sprite = await loadSprite('boy.png');
    boy.size = Vector2(characterSize, characterSize);
    boy.y = screenHeight - characterSize - textBoxHeight;
    boy.x = screenWidth - characterSize;
    boy.anchor = Anchor.topCenter;
    boy.flipHorizontally();
    add(boy);

    dialogButton
      ..sprite = await loadSprite('next_button.png')
      ..size = buttonSize
      ..position = Vector2(
        size[0] - buttonSize[0] - 10,
        size[1] - buttonSize[1] - 10,
      );

    // initialize flame audio background music
    FlameAudio.bgm.initialize();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (girl.x < size[0] / 2 - characterSize / 2) {
      girl.x += 80 * dt;
      if (girl.x > 50 && dialogLevel == 0) {
        dialogLevel = 1;
      }
      if (girl.x > 150 && dialogLevel == 1) {
        dialogLevel = 2;
      }
    } else if (!turnAway && sceneLevel == 1) {
      boy.flipHorizontally();
      turnAway = true;
      if (dialogLevel == 2) {
        dialogLevel = 3;
      }
    }
    if (boy.x > size[0] / 2 - 50 && sceneLevel == 1) {
      boy.x -= 80 * dt;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    switch (dialogLevel) {
      case 1:
        dialogTextPaint.render(
          canvas,
          '不要去...你会死的！！！！',
          Vector2(10.0, size[1] - 80.0),
        );
        break;
      case 2:
        dialogTextPaint.render(
          canvas,
          '我必须去战斗！',
          Vector2(10.0, size[1] - 80.0),
        );
        break;
      case 3:
        dialogTextPaint.render(
          canvas,
          '那孩子怎么办？',
          Vector2(10.0, size[1] - 80.0),
        );
        add(dialogButton);
        break;
    }

    switch (dialogButton.scene2Level) {
      case 1:
        sceneLevel = 2;
        dialogLevel = 4;
        canvas.drawRect(Rect.fromLTWH(0, size[1] - 80, size[0] - 60, 100),
            Paint()..color = Colors.black);
        dialogTextPaint.render(
          canvas,
          '孩子？我不知道我还有个孩子。',
          Vector2(10.0, size[1] - 80.0),
        );
        if (turnAway) {
          boy.flipHorizontally();
          boy.x = boy.x + 150;
          turnAway = false;
          remove(background);
          remove(boy);
          remove(girl);
          add(background2);
          add(boy);
          add(girl);
        }
        break;
      case 2:
        canvas.drawRect(Rect.fromLTWH(0, size[1] - 80, size[0] - 60, 100),
            Paint()..color = Colors.black);
        dialogTextPaint.render(
          canvas,
          '我们的孩子。我们的未来！',
          Vector2(10.0, size[1] - 80.0),
        );
        break;
      case 3:
        canvas.drawRect(Rect.fromLTWH(0, size[1] - 80, size[0] - 60, 100),
            Paint()..color = Colors.black);
        dialogTextPaint.render(
          canvas,
          '我的未来...',
          Vector2(10.0, size[1] - 80.0),
        );
        break;
    }
  }
}

class DialogButton extends SpriteComponent with Tappable {
  int scene2Level = 0;
  bool musicPlaying = false;
  @override
  bool onTapDown(TapDownInfo event) {
    // play music
    if (!musicPlaying) {
      FlameAudio.bgm.play('music.mp3');
      musicPlaying = true;
    }
    try {
      scene2Level++;
      return true;
    } catch (e) {
      return false;
    }
  }
}

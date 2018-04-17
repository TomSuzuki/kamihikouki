// 紙ヒコーキ

final boolean debug = false;

int MasterFlg = -1;
final int FlgInitialize = -1;
final int FlgStart = 0;
final int FlgGameInitialize = 10;
final int FlgGame = 11;

int GameTime = -60*3;
float PlayerX = 320;
float PlayerY = 0;
float PlayerDirection = 0.0;
float PlayerSpeed = 1.0;

int mouseKey = 0;

final int MaxBallNum = 32;
float Ball[][] = new float[MaxBallNum][4];

PFont FontMain;
PImage PlayerImage;

void setup() {
  size(640, 480);
  background(255, 255, 255);
  frameRate(60);
  FontMain = loadFont("rounded-x-mplus-1m-light-48.vlw");
  textFont(FontMain);
  noCursor();
  PlayerImage = loadImage("image.png");
}

void draw() {

  background(255, 255, 255);

  noFill();
  stroke(0, 0, 0);
  strokeWeight(1);
  ellipse(mouseX, mouseY, 16, 16);
  ellipse(mouseX, mouseY, 24, 24);
  line(mouseX-sin(radians(frameCount))*16, mouseY-cos(radians(frameCount))*16, mouseX+sin(radians(frameCount))*16, mouseY+cos(radians(frameCount))*16);
  line(mouseX-sin(radians(frameCount+90))*16, mouseY-cos(radians(frameCount+90))*16, mouseX+sin(radians(frameCount+90))*16, mouseY+cos(radians(frameCount+90))*16);  

  switch(MasterFlg) {
    case(FlgInitialize):  // 初期化
    MasterFlg = FlgStart;
    break;
  case FlgStart:       // 初期画面
    MasterStart();
    break;
  case FlgGameInitialize:  // ゲーム初期化
    MasterFlg = FlgGame;
    GameTime = -60*3;
    PlayerX = 320;
    PlayerY = 0;
    PlayerDirection = 0.0;
    PlayerSpeed = 2.5;
    for (int i = 0; i < MaxBallNum; i++) Ball[i][0] = 0;
    break;
  case FlgGame:        // ゲーム
    MasterGame();
    break;
  }

  if (debug) {
    fill(255, 0, 255);
    textSize(14);
    textAlign(LEFT, TOP);
    text("GameTime ["+GameTime+"]", 5, 5);
    text("PlayerDirection ["+PlayerDirection+"]", 5, 20);
  }
}

// タイトル画面
void MasterStart() {
  textAlign(CENTER, CENTER);
  fill(0, 0, 0);
  textSize(72);
  text("KAMIHIKOUKI", 320, 180);
  if (dist(mouseX, mouseY, 320, 360) < 48) {
    fill(0, 0, 255);
    if (mouseKey == 1) {
      mouseKey = 0; 
      MasterFlg = FlgGameInitialize;
    }
  }
  textSize(32);
  text("START", 320, 360);
}

// ゲーム
void MasterGame() {
  GameTime = GameTime + 1;

  if (GameTime > 0) {
    // プレイヤーの移動
    if (PlayerSpeed > 6.0) PlayerSpeed = 6.0;
    PlayerSpeed = max(0.0 + PlayerSpeed + (360.0-mouseY + random(10)-5)/240, 0.0);
    PlayerY = PlayerY - PlayerSpeed;
    PlayerDirection = atan2(320-min(mouseY, 260), PlayerX-mouseX)+radians(-90);
    if (abs(PlayerDirection) > 0.02) PlayerX = PlayerX + 1*(PlayerDirection*4);
    if (abs(PlayerDirection) > 1.2) GameTime = -1025;
    if (PlayerSpeed < 2) GameTime = -1025;
    if (PlayerX < 40) GameTime = -1025;
    if (PlayerX > 600) GameTime = -1025;
    // ボールの出現、移動
    if (GameTime%60 == 0) {
      for (int i = 0; i < MaxBallNum; i++) if (Ball[i][0] == 0) {
        Ball[i][0] = 1;
        Ball[i][1] = random(640);
        Ball[i][2] = -20;
        Ball[i][3] = atan2(380.0-Ball[i][2], PlayerX-Ball[i][1]);
        break;
      }
    } else if (GameTime%20 == 0) {
      for (int i = 0; i < MaxBallNum; i++) if (Ball[i][0] == 0) {
        Ball[i][0] = 1;
        Ball[i][1] = random(640);
        Ball[i][2] = -20;
        Ball[i][3] = atan2(380.0-Ball[i][2], random(640)-Ball[i][1]);
        break;
      }
    }
    for (int i = 0; i < MaxBallNum; i++) {
      if (Ball[i][0] == 1) {
        Ball[i][1] = Ball[i][1] + cos(Ball[i][3])*5;
        Ball[i][2] = Ball[i][2] + sin(Ball[i][3])*5+PlayerSpeed/10;
        if (Ball[i][2] > 540) Ball[i][0] = 0;
        if (dist(Ball[i][1], Ball[i][2], PlayerX, 380) < 32) GameTime = -1025;
      }
    }
  } else if (GameTime != -1024) {
    // カウントダウン
    textAlign(CENTER, CENTER);
    fill(0, 0, 0);
    textSize(72);
    text(""+(-GameTime/60+1), 320, 240);
  } else {
    // ゲームオーバー
    GameTime = -1025;
    PlayerDirection = radians(frameCount*8);

    textSize(64);
    fill(0, 0, 0);
    textAlign(CENTER, CENTER);
    text(""+abs(int(PlayerY/100))+"m", 320, 220);

    // 処理
    if (mouseKey == 1) {
      mouseKey = 0; 
      MasterFlg = FlgStart;
    }
  }

  // ボールの描画
  for (int i = 0; i < MaxBallNum; i++) {
    if (Ball[i][0] == 1) {
      fill(0, 0, 0);
      noStroke();
      ellipse(Ball[i][1], Ball[i][2], 20, 20);
    }
  }

  // 壁
  fill(0, 0, 0);
  noStroke();
  rect(0, 0, 10, 480);
  rect(630, 0, 10, 480);
  for (int i = 0; i < 11; i++) {
    rect(0, i*48-PlayerY%48-48, 20, 20);
    rect(620, i*48-PlayerY%48-48, 20, 20);
  }

  // 描画
  pushMatrix();
  translate(PlayerX, 380);
  rotate(PlayerDirection);
  image(PlayerImage, -32, -32);
  popMatrix();

  // 表示
  textSize(36);
  fill(0, 0, 0);
  textAlign(LEFT, TOP);
  text(""+abs(int(PlayerY/100))+"m", 60, 420);
  textAlign(RIGHT, TOP);
  text(""+int(PlayerSpeed*60)+"cm/s", 580, 420);
}

// マウスを押した
void mousePressed() {
  mouseKey = 1;
}

// マウスを離した
void mouseReleased() {
  mouseKey = 0;
}
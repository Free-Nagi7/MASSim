import ddf.minim.*;  //外部ライブラリの定義
ArrayList<Bird_H> HBirds;
ArrayList<Bird_O> OBirds;
ArrayList<Ball> Balls;
PImage img;
int Onum = 100;  //オソッピーの数
int Hnum = 30;  //ハヤッピーの数
float camerax = 0;  //カメラのx座標
float cameray = -770;  //カメラのy座標
float cameraz = -770;  //カメラのz座標
float speed = 30;  //カメラの移動速度
int score = 0;  //スコア
int kill = 0;  //キル数
int col = 100;  //当たり判定の範囲
int time = 60;  //制限時間
int timer;
Minim minim;
AudioPlayer BGM;  //BGM
AudioPlayer SMG;  //マシンガンの発砲音
AudioPlayer SHOT;  //単発の発砲音
AudioPlayer SHOTAFTER1;  //単発の薬莢の落下音
AudioPlayer SHOTAFTER2;  //マシンガンの薬莢の落下音
AudioPlayer KNOCK;  //鳥がダウンした時の呻き声
AudioPlayer Standby;  //ゲーム開始の合図
AudioPlayer GAMECLEAR;  //ゲームクリア音
AudioPlayer GAMEOVER;  //ゲームオーバー音
AudioPlayer voice1;  //男性の敗北ボイス
AudioPlayer voice2;  //男性の勝利ボイス
AudioPlayer voice3;  //女性の勝利ボイス
AudioPlayer voice4;  //女性の敗北ボイス

//float cameraAnglex = 0;
//float cameraAngley = 0;


void setup() {
  size(1280, 980, P3D);
  background(84, 195, 241);
  smooth();

  OBirds = new ArrayList<Bird_O>();
  for (int i = 0; i<Onum; i++) {
    OBirds.add(new Bird_O(random(-width, width), random(300, height/4+300), random(-2000, 0)));
  }

  HBirds = new ArrayList<Bird_H>();
  for (int i = 0; i<Hnum; i++) {
    HBirds.add(new Bird_H(random(-width/2, width/2), random(-height/2+300, height/2+300), random(-2000, 0)));
  }

  Balls = new ArrayList<Ball>();

  img = loadImage("073915.jpg");
  img.resize(img.width*3, img.height*3);

  //再生用のオブジェクト生成
  minim = new Minim(this);

  //音楽ファイルを読み込む
  BGM = minim.loadFile("BGM.mp3");
  SMG = minim.loadFile("SMG.mp3");
  SHOT = minim.loadFile("SHOT.mp3");
  SHOTAFTER1 = minim.loadFile("SHOTAFTER1.mp3");
  SHOTAFTER2 = minim.loadFile("SHOTAFTER2.mp3");
  KNOCK = minim.loadFile("KNOCK.mp3");
  Standby = minim.loadFile("Standby.mp3");
  GAMECLEAR = minim.loadFile("GAMECLEAR.mp3");
  GAMEOVER = minim.loadFile("GAMEOVER.mp3");
  voice1 = minim.loadFile("「くっ、こんなはずでは……」.mp3");
  voice2 = minim.loadFile("「やった！」.mp3");
  voice3 = minim.loadFile("「やりました！」.mp3");
  voice4 = minim.loadFile("「負けました…」.mp3");

  //音楽ファイルを再生
  BGM.play();
  Standby.play();
}

void draw() {
  background(84, 195, 241);

  //zバッファの制御と背景画像の描画
  hint(DISABLE_DEPTH_TEST);
  image( img, -width/2-1000, height/2-600);
  hint(ENABLE_DEPTH_TEST);

  lights();
  translate(width/2, height/2, 100);

  for (int i = 0; i<OBirds.size(); i++) {
    OBirds.get(i).run(OBirds);
  }
  for (int i = 0; i<HBirds.size(); i++) {
    HBirds.get(i).run(HBirds);
  }

  //カメラ操作、発砲のキーバインド
  if (keyPressed) {
    switch (keyCode) {
    case LEFT:
      if (camerax<=550) {
        camerax += speed;
      }
      break;
    case RIGHT:
      if (camerax>=-770) {
        camerax -= speed;
      }
      break;
    case UP:
      if (cameraz<=-800) {
        cameraz += speed;
      }
      break;
    case DOWN:
      if (cameraz>=-1400) {
        cameraz -= speed;
      }
      break;
    case SHIFT:
      if (kill>=5) {
        Balls.add(new Ball(mouseX, mouseY+height/2, 500));
        SMG.play(0);  //マシンガンの発砲音を再生
        SHOTAFTER2.play(0);  //多数の薬莢が落ちる音
      }
      break;
    default:
      break;
    }
  }
  beginCamera();
  camera();
  translate(camerax, cameray, cameraz);
  /*
  未実装・試作段階の機能（視点回転）につき、コメントアウトしています
   */
  //rotateY(0.01*cameraAnglex);
  //rotateX(0.01*cameraAngley);
  endCamera();

  for (int i = 0; i<Balls.size(); i++) {
    Balls.get(i).run();
  }

  //弾と鳥の当たり判定
  for (int i = 0; i<Balls.size(); i++) {
    for (int u= 0; u<HBirds.size(); u++) {
      float disH = PVector.dist(Balls.get(i).position, HBirds.get(u).position);
      if (col>disH) {
        HBirds.remove(u);
        KNOCK.play(0); //ノックSE(呻き声)を再生
        score = score +15;
        kill++;
      }
    }
  }
  for (int i = 0; i<Balls.size(); i++) {
    for (int u= 0; u<OBirds.size(); u++) {
      float disO = PVector.dist(Balls.get(i).position, OBirds.get(u).position);
      if (col>disO) {
        OBirds.remove(u);
        KNOCK.play(0);  //ノックSE(呻き声)再生
        score = score +5;
        kill++;
      }
    }
  }

  //弾の境界処理で、弾が範囲外に出た時削除
  for (int i = 0; i < Balls.size(); i++) {
    if (Balls.get(i).position.z<-3000) {
      Balls.remove(i);
    }
  }

  hint(DISABLE_DEPTH_TEST);
  textSize(height*0.1);
  textAlign(CENTER);
  text("Score"+score, 1600, 500);  //スコアを表示
  text("Kill"+kill, 1600, 600);  //キル数を表示
  textSize(height*0.05);
  text("mouseX;"+mouseX+" mouseY;"+mouseY, 1530, 1500);
  hint(ENABLE_DEPTH_TEST);

  if (score>=300&&timer>=0) {
    hint(DISABLE_DEPTH_TEST);
    textSize(height*0.3);
    textAlign(CENTER);
    text("Game CLear", 660, 1200);  //ゲームクリアを表示
    hint(ENABLE_DEPTH_TEST);
    GAMECLEAR.play();
    voice2.play();  //男性の勝利ボイス
    //voice3.play();  //女性の勝利ボイス
  }

  int mi = millis()/1000;
  timer = time - mi;
  hint(DISABLE_DEPTH_TEST);
  textSize(height*0.1);
  textAlign(CENTER);
  text("Time"+timer, 1600, 400);  //時間を表示
  if (score<300&&timer<0) {
    textSize(height*0.3);
    text("Time OVER", 660, 1200);  //ゲームオーバーを表示
  }
  hint(ENABLE_DEPTH_TEST);

  if (score<300&&timer<0) {
    GAMEOVER.play();
    voice1.play();  //男性の敗北ボイス
    //voice4.play();  //女性の敗北ボイス
  }

  //初手の攻撃と30で割れるスコアだと当たり判定の範囲を増加
  if (score%30==0&&score>0) {
    col=100;
    hint(DISABLE_DEPTH_TEST);
    fill(250, 100, 0);
    textSize(height*0.05);
    textAlign(LEFT);
    text("SKILL : Range Enhance", -500, 450);  //スキルレンジエンハを表示
    hint(ENABLE_DEPTH_TEST);
  } else {
    col=77;
    hint(DISABLE_DEPTH_TEST);
    fill(250, 100, 0);
    textSize(height*0.05);
    textAlign(LEFT);
    text("SKILL :", -500, 450);  //スキル発動状態を表示
    hint(ENABLE_DEPTH_TEST);
  }
  if (kill>=5) {
    hint(DISABLE_DEPTH_TEST);
    fill(250, 100, 0);
    textSize(height*0.05);
    textAlign(LEFT);
    text("GUN : scarlet/neo", -500, 400);  //銃の種類「scarlet/neo」を表示
    hint(ENABLE_DEPTH_TEST);
  } else {
    hint(DISABLE_DEPTH_TEST);
    fill(250, 100, 0);
    textSize(height*0.05);
    textAlign(LEFT);
    text("GUN : scarlet", -500, 400);  //銃の種類「scarlet」を表示
    hint(ENABLE_DEPTH_TEST);
  }
}

//銃を発砲
void mousePressed() {
  Balls.add(new Ball(mouseX, mouseY+height/2, 500));
  SHOT.play(0);  //発砲音を再生
  SHOTAFTER1.play(0);  //薬莢の音を再生
}

/*
視点回転
 未実装・試作段階の機能（視点移動）につき、コメントアウトしています
 */
/*
void mouseDragged() {
 cameraAnglex += (mouseX - pmouseX);
 cameraAngley += (mouseY - pmouseY);
 }
 */

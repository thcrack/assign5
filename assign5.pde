

PImage bg1, bg2, enemy, fighter, hp, treasure, start1, start2, end1, end2, shoot;
PImage [] flame = new PImage[6];
PFont font;

void setup () {
  size(640,480) ;
  font = createFont("Impact", 35);
  bg1 = loadImage ("img/bg1.png");
  bg2 = loadImage ("img/bg2.png");
  enemy = loadImage ("img/enemy.png");
  fighter = loadImage ("img/fighter.png");
  hp = loadImage ("img/hp.png");
  treasure = loadImage ("img/treasure.png");
  end1 = loadImage ("img/end1.png");
  end2 = loadImage ("img/end2.png");
  start1 = loadImage ("img/start1.png");
  start2 = loadImage ("img/start2.png");
  shoot = loadImage ("img/shoot.png");
  for(int i = 1; i < 6; i++){
    flame[i] = loadImage ("img/flame"+i+".png");
  }
}

final int enemyCount = 10;
final int bulletCount = 5;

boolean gameState = false;
boolean endState = false;
boolean startFlash = false;
boolean endFlash = false;
boolean upState = false;
boolean downState = false;
boolean leftState = false;
boolean rightState = false;
boolean [] enemyState = new boolean[enemyCount];
boolean [] bulletState = new boolean[bulletCount];
int [] explosion = new int[enemyCount];
int [] explosionBuffer = new int[enemyCount];
int heroSpeed = 10;
int bg1Pos = 640;
int bg2Pos = 0;
int enemyWave = 0;
int score = 0;
int startBuffer = 0;
int endBuffer = 0;
int enemyBuffer = 0;
int enemyOnline = 0;
float heroPosX = 550;
float heroPosY = 240;
float [] enemyPosX = new float [enemyCount];
float [] enemyPosY = new float [enemyCount];
float [] explosionPosX = new float[enemyCount];
float [] explosionPosY = new float[enemyCount];
float [] bulletPosX = new float[bulletCount];
float [] bulletPosY = new float[bulletCount];
float hpAmount = 195;
float hpPercentage = 0.2;
float treasurePosX = random(40,560);
float treasurePosY = random(60,420);

void draw() {
  if(gameState==false){
    for(int i = 0; i < explosion.length; i++){
      explosion[i] = -1;
      explosionPosX[i] = -500;
      explosionPosY[i] = -500;
      explosionBuffer[i] = 0;
    }
    for(int i = 0; i < bulletCount; i++){
      bulletInit(i);
    }
    score = 0;
    if(endState==true){
      if(mouseX <= 436 && mouseX >= 206 && mouseY <= 355 && mouseY >= 308){
        image(end1, 0, 0);
        endFlash = true;
      }else{
        image(end2, 0, 0);
        endFlash = false;
      }
    }else{
      if(mouseX <= 449 && mouseX >= 198 && mouseY <= 414 && mouseY >= 376){
        image(start1, 0, 0);
        startFlash = true;
      }else{
        image(start2, 0, 0);
        startFlash = false;
      }
    }
  }else{
    image(bg1,-640+bg1Pos,0);
    image(bg2,-640+bg2Pos,0);
    bg1Pos += 10;
    bg1Pos = bg1Pos % 1280;
    bg2Pos += 10;
    bg2Pos = bg2Pos % 1280; //background scrolling
    fill(255,0,0);
    noStroke();
    image(treasure, treasurePosX, treasurePosY); //treasure
    heroMovement();
    for(int i = 0; i < bulletCount; i++){
      if(!bulletState[i]){
        image(shoot, bulletPosX[i], bulletPosY[i]);
        bulletPosX[i] -= 10;
        if(closestEnemy(bulletPosX[i], bulletPosY[i])!=-1 && bulletPosX[i] > enemyPosX[closestEnemy(bulletPosX[i], bulletPosY[i])]){
          if(enemyPosY[closestEnemy(bulletPosX[i], bulletPosY[i])] > bulletPosY[i]){
            bulletPosY[i] += 3;
          }else{
            bulletPosY[i] -= 3;
          }
        }
        if(bulletPosX[i] < -30){
          bulletInit(i);
        }
      }
    }
    image(fighter, heroPosX, heroPosY); // fighter position
    if(hitDetection(heroPosX, heroPosY, 51, 51, treasurePosX, treasurePosY, 41, 41)){
      if(hpPercentage < 0.99){
        hpPercentage += 0.1;
        treasurePosX = random(40,560);
        treasurePosY = random(60,420);
      }
    }
    if(enemyBuffer <= 6){
      for(int i = 0; i < enemyCount; i++){
        enemyState[i] = true;
        enemyPosX[i] = -500;
        enemyPosY[i] = -500;
      }
      enemyWave ++;
      enemyPosX[0] = -100;
      if(enemyWave > 3){
        enemyWave = 1;
      }
      switch(enemyWave){
        case 1:
          lineEnemy();
          break;
        case 2:
          slopeEnemy();
          break;
        case 3:
          diamondEnemy();
          break;
      }
    }
    for(int i = 0; i < enemyOnline; i++){
      enemyPosX[i] += 7;
      //println(i + "=" + enemyPosX[i] + "," + enemyPosY[i]);
    }
    for(int i = 0; i < enemyOnline; i ++){
      if(enemyState[i]){
        image(enemy, enemyPosX[i], enemyPosY[i]);
        if(hitDetection(heroPosX, heroPosY, 51, 51, enemyPosX[i], enemyPosY[i], 61, 61)){
          onExplosion(i);
          if(hpPercentage > 0.21){
            hpPercentage -= 0.2;
          }else{
            gameState=false;
            endState=true;
          }
        }
        for(int j = 0; j < bulletCount; j++){
          if(hitDetection(bulletPosX[j], bulletPosY[j], 31, 27, enemyPosX[i], enemyPosY[i], 61, 61)){
            onExplosion(i);
            bulletInit(j);
            changeScore(20);
          }
        }
      }
    }
    enemyBuffer += 7;
    enemyBuffer %= 1200;
    for(int i = 0; i < enemyCount; i++){
      if(explosion[i] >= 0){
        image(flame[explosion[i]+1], explosionPosX[i], explosionPosY[i]);
        explosionBuffer[i] += 1;
        if(explosionBuffer[i] == 5){
          explosion[i] += 1;
          explosionBuffer[i] = 0;
        }
        if(explosion[i] > 4){
          explosion[i] = -1;
        }
      }
    }
    rect(50,34,hpAmount*hpPercentage,17); //hp amount
    image(hp, 40, 30); //hp outline
    textFont(font);
    fill(255);
    text("SCORE: " + score, 40, 450);
  }
}

void heroMovement(){
  if(upState == true && heroPosY>0){
    heroPosY -= heroSpeed;
  }
  if(downState == true && heroPosY<429){
    heroPosY += heroSpeed;
  }
  if(leftState == true && heroPosX>0){
    heroPosX -= heroSpeed;
  }
  if(rightState == true && heroPosX<589){
    heroPosX += heroSpeed;
  }
}

void changeScore(int x){
  score += x;
}

void lineEnemy(){
  enemyOnline = 5;
  enemyPosY[0] = random(30,420);
  for(int i = 1; i <= 4; i++){
    enemyPosX[i] = enemyPosX[i-1] - 60;
    enemyPosY[i] = enemyPosY[0];
  }
}

void slopeEnemy(){
  enemyOnline = 5;
  enemyPosY[0] = random(30,180);
  for(int i = 1; i <= 4; i++){
    enemyPosX[i] = enemyPosX[i-1] - 60;
    enemyPosY[i] = enemyPosY[i-1] + 60;
  }
}

void diamondEnemy(){
  enemyOnline = 9;
  enemyPosY[0] = random(120,300);
  for(int i = 1; i <= 3; i++){
    for(int j = 1; j <= 3; j++){
      if(i != 2 || j != 2 && i + j != 2){
        enemyPosX[(i-1)*3+(j-1)] = enemyPosX[0] - 60*((i-1)+(j-1));
        enemyPosY[(i-1)*3+(j-1)] = enemyPosY[0] + 60*((i-1)-(j-1));
      }
    }
  }
}

void onExplosion(int i){
  explosion[i] = 0;
  explosionPosX[i] = enemyPosX[i];
  explosionPosY[i] = enemyPosY[i];
  enemyState[i] = !enemyState[i];
}

void bulletInit(int j){
  bulletState[j] = true;
  bulletPosX[j] = -1000;
  bulletPosY[j] = -1000;
}

boolean hitDetection(float ax,float ay,float aw,float ah,float bx,float by,float bw,float bh){
  if(ax + aw >= bx && ax <= bx + bw && ay + ah >= by && ay <= by + bh){
    return true;
  }else{
    return false;
  }
}

int closestEnemy(float x, float y){
  int enemyID = -1;
  float dist_temp = 1000;
  for(int i = 0; i < enemyOnline ;i++){
    float distance = dist(x,y,enemyPosX[i],enemyPosY[i]);
    if(enemyState[i] && distance <=dist_temp){
      dist_temp = distance;
      enemyID = i;
    }
  }
  return enemyID;
}

void mousePressed(){
  if(endFlash){
    endState = false;
    hpPercentage = 0.2;
    enemyBuffer = 0;
    heroPosX = 550;
    heroPosY = 240;
    treasurePosX = random(40,560);
    treasurePosY = random(60,420);
    endFlash = false;
    enemyWave = 0;
  }
  if(startFlash){
    gameState = true;
    startFlash = false;
  }
}


void keyPressed(){
  if(key==CODED){
    switch(keyCode){
      case UP:
        upState = true;
        break;
      case DOWN:
        downState = true;
        break;
      case LEFT:
        leftState = true;
        break;
      case RIGHT:
        rightState = true;
        break;
    }
  }
}

void keyReleased(){
  if(key==CODED){
    switch(keyCode){
      case UP:
        upState = false;
        break;
      case DOWN:
        downState = false;
        break;
      case LEFT:
        leftState = false;
        break;
      case RIGHT:
        rightState = false;
        break;
    }
  }
  if(key==' '){
    for(int i = 0; i < bulletCount; i++){
      if(bulletState[i]){
        bulletPosX[i] = heroPosX;
        bulletPosY[i] = heroPosY + 12;
        bulletState[i] = false;
        break;
      }
    }
  }
}

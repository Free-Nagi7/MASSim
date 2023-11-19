class Bird_H {
  PVector position;
  PVector velocity;
  PVector accel;
  float r;
  float vmax; //最大速度
  float fmax; //力の最大

  Bird_H(float x, float y, float z) {
    this.position = new PVector(x, y, z);
    this.velocity = new PVector(random(3, 6), random(3, 6), random(3, 6));
    this.r = 20;
    this.accel= new PVector(0, 0, 0);
    this.vmax = 8;
    this.fmax = 0.05;
  }

  void update() {
    this.velocity.add(this.accel);
    this.velocity.limit(vmax);
    this.position.add(this.velocity);
    this.accel= new PVector(0, 0, 0);
  }

  //鳥のモデリング
  void render() {
    float a = atan2(this.velocity.y, this.velocity.x);
    float c = atan2(this.velocity.x, this.velocity.z);
    fill(0, 200, 255);
    pushMatrix();
    translate(this.position.x, this.position.y, this.position.z);
    rotateZ(a-PI/2);
    rotateY(c-PI/2);
    beginShape(TRIANGLE);
    vertex(r, 0, r);
    vertex(0, r+r, 0);
    vertex(r, 0, -r);

    vertex(r, 0, -r);
    vertex(0, r+r, 0);
    vertex(-r, 0, -r);

    vertex(-r, 0, -r);
    vertex(0, r+r, 0);
    vertex(-r, 0, r);

    vertex(-r, 0, r);
    vertex(0, r+r, 0);
    vertex(r, 0, r);

    vertex(-r, 0, r);
    vertex(0, -r-r-r, 0);
    vertex(r, 0, r);

    vertex(-r, 0, -r);
    vertex(0, -r-r-r, 0);
    vertex(-r, 0, r);

    vertex(r, 0, -r);
    vertex(0, -r-r-r, 0);
    vertex(-r, 0, -r);

    vertex(r, 0, r);
    vertex(0, -r-r-r, 0);
    vertex(r, 0, -r);
    endShape(CLOSE);

    beginShape();
    vertex(r+r+r/2, r-r/2, 0);
    vertex(r+r+r, -r, 0);
    vertex(-r-r-r, -r, 0);
    vertex(-r-r-r/2, r-r/2, 0);
    endShape(CLOSE);
    popMatrix();
  }


  //反射の境界処理メソッド
  void reflect() {
    if (this.position.x>width) {
      this.velocity.x = this.velocity.x*-1;
    }
    if (this.position.x<-width) {
      this.velocity.x = this.velocity.x*-1;
    }
    if (this.position.y>height/2+300) {
      this.velocity.y = this.velocity.y*-1;
    }
    if (this.position.y<-height/2+300) {
      this.velocity.y = this.velocity.y*-1;
    }
    if (this.position.z>0) {
      this.velocity.z = this.velocity.z*-1;
    }
    if (this.position.z<-1000) {
      this.velocity.z = this.velocity.z*-1;
    }
  }

  void run(ArrayList<Bird_H> HBirds) {
    groupBehavior(HBirds);
    this.update();
    this.render();
    this.reflect();
  }


  void applyForce(PVector force) {
    this.accel.add(force);
  }

  //群れ行動
  void groupBehavior(ArrayList<Bird_H> HBirds) {
    PVector separateForce = separate(HBirds);
    separateForce.mult(1.5); //力の強さを変更
    applyForce(separateForce);
  }

  /*
  分離メソッド
   分離に関して働く力の強さと方向を決定
   */
  PVector separate(ArrayList<Bird_H> HBirds) {
    float ran = 70;
    int q = 0;
    PVector steering = new PVector(0, 0, 0);
    for (int j = 0; j<HBirds.size(); j++) {
      float dis = PVector.dist(this.position, HBirds.get(j).position);
      if (ran > dis && dis > 0) {
        PVector d = this.position.copy();
        d.sub(HBirds.get(j).position);
        d.normalize();
        d.div(dis);
        steering.add(d);
        q++;
      }
    }
    if (0<q) {
      steering.div(q);
      steering.normalize();
      steering.mult(vmax);
      steering.sub(this.velocity);
      steering.limit(fmax);
    }
    return steering;
  }
}

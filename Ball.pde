class Ball {
  PVector position;
  PVector velocity;
  int r;

  Ball(float x, float y, float z) {
    this.position = new PVector(x, y, z);

    /*
    弾の軌道
     回りくどい記述だが、視点移動、発砲の方法の都合から、理想的な軌道を描かせたかったため、あえてこうしている
     */
    this.velocity = new PVector(0, -7, -50);
    if (this.position.x<150) {
      this.velocity=new PVector(-22, -7, -50);
    } else if (150<=this.position.x&&this.position.x<300) {
      this.velocity=new PVector(-18, -7, -50);
    } else if (300<=this.position.x&&this.position.x<450) {
      this.velocity=new PVector(-12, -7, -50);
    } else if (450<=this.position.x&&this.position.x<580) {
      this.velocity=new PVector(-5, -7, -50);
    } else if (700<this.position.x&&this.position.x<=830) {
      this.velocity=new PVector(5, -7, -50);
    } else if (830<this.position.x&&this.position.x<=980) {
      this.velocity=new PVector(12, -7, -50);
    } else if (980<this.position.x&&this.position.x<=1130) {
      this.velocity=new PVector(18, -7, -50);
    } else if (1130<this.position.x) {
      this.velocity=new PVector(22, -7, -50);
    }

    this.r = 35;  //弾の大きさ
  }

  void update() {
    this.position.add(this.velocity);
  }

  void render() {
    pushMatrix();
    translate(this.position.x, this.position.y, this.position.z);
    noStroke();
    fill(128);
    sphere(r);
    popMatrix();
  }

  void run() {
    this.update();
    this.render();
  }
}

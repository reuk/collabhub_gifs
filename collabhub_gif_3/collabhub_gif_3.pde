PFont font;
int[][] result;

void setup() {
  size(500, 500);
  colorMode(HSB, 1);
  frameRate(30);

  font = createFont("GeosansLight", 200);
  circle = get_circles();

  result = new int[width*height][3];
}

final int LOOP_LENGTH = 100;
final boolean RENDER = true;

int samplesPerFrame = 16;
float shutterAngle = 1;

void draw() {
  for (int i=0; i<width*height; i++)
      for (int a=0; a<3; a++)
        result[i][a] = 0;

    for (int sa=0; sa<samplesPerFrame; sa++) {
      final float time = map((frameCount % LOOP_LENGTH) + sa*shutterAngle/samplesPerFrame, 0, LOOP_LENGTH, 0, 1);
      frame(time);
      loadPixels();
      for (int i=0; i<pixels.length; i++) {
        result[i][0] += pixels[i] >> 16 & 0xff;
        result[i][1] += pixels[i] >> 8 & 0xff;
        result[i][2] += pixels[i] & 0xff;
      }
    }

    loadPixels();
    for (int i=0; i<pixels.length; i++)
      pixels[i] = 0xff << 24 | (result[i][0]/samplesPerFrame) << 16 |
        (result[i][1]/samplesPerFrame) << 8 | (result[i][2]/samplesPerFrame);
    updatePixels();

  if (RENDER) {
    saveFrame("render/out-###.png");

    if (frameCount == LOOP_LENGTH)
      exit();
  }
}

ArrayList<Circle> get_circles() {
  ArrayList<Circle> circle = new ArrayList<Circle>();

  final float ratio = 1.5;
  final float base_rad = height / 5;

  final int STEPS_0 = 6;
  for (int i = 0; i != STEPS_0; ++i) {
    final float ANGLE = i * TWO_PI / STEPS_0;
    final float r0 = base_rad;
    final float r1 = base_rad * ratio;
    circle.add(new Circle(0, r0 * 2, new PVector(sin(ANGLE) * r0, cos(ANGLE) * r0)));
    circle.add(new BounceCircle(0, r0, r1, 0.5 + i * 0.025, 0.3, ANGLE));
  }

  final int STEPS_1 = 12;

  for (int i = 0; i != STEPS_1; ++i) {
    final float ANGLE = i * TWO_PI / STEPS_1 + TWO_PI / (2 * STEPS_1);
    circle.add(new Circle(0.2, base_rad, new PVector(sin(ANGLE) * base_rad, cos(ANGLE) * base_rad)));
  }

  for (int i = 0; i != STEPS_0; ++i) {
    final float ANGLE = i * TWO_PI / STEPS_0 + TWO_PI / (2 * STEPS_0);
    final float r1 = base_rad * ratio;
    circle.add(new BounceCircle(0.6, base_rad, r1, 0.0 + i * 0.025, 0.3, ANGLE));
  }

  circle.add(new Circle(0.6, base_rad * 2, new PVector(0, 0)));

  return circle;
}

class Circle {
  Circle(float dist, float radius, PVector center) {
    _radius = radius;
    _current = center;
    _dist = dist;
  }

  void update(float TIME) {}

  void draw(float TIME) {
    fill((TIME + _dist + 0.2) % 1, 0.5, 0.5, 0.4);
    ellipse(_current.x, _current.y, _radius, _radius);
  }

  float _radius;
  PVector _current;
  float _dist;
}

class BounceCircle extends Circle {
  BounceCircle(float dist, float radius, float distance, float start_time, float duration, float angle) {
    super(dist, radius, new PVector(sin(angle) * distance, cos(angle) * distance));

    _distance = distance;
    _start_time = start_time;
    _duration = duration;
    _angle = angle;
  }

  void update(float TIME) {
    float ALTERED_TIME = map(cos(constrain(map(TIME, _start_time, _start_time + _duration, 0, PI), 0, PI)), -1, 1, 0, 1);
    float current_amp = map(cos(ALTERED_TIME * PI), -1, 1, _distance, -_distance);
    _current = new PVector(sin(_angle) * (current_amp), cos(_angle) * (current_amp));
  }

  float _distance;
  float _start_time;
  float _duration;
  float _angle;
}

ArrayList<Circle> circle;

void frame(float TIME) {
  pushMatrix();
  final float base_rad = height / 5;

  background(0, 0, 1);
  noStroke();

  translate(width / 2, height / 2);

  for (Circle i : circle) {
    i.update(TIME);
    i.draw(TIME);
  }

  fill(0, 0, 1, 1);
  textFont(font);
  textAlign(CENTER, CENTER);
  textSize(base_rad * (72.0 / 120));
  text("CollabHub", 0, base_rad * (-20.0 / 120));
  textSize(base_rad * (22.0 / 120));
  text("Inspire // Innovate // Collaborate", 0, base_rad * (30.0 / 120));
  popMatrix();
}
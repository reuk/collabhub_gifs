PFont font;
int[][] result;

void setup() {
  size(1920, 1080);
  colorMode(HSB, 1);
  frameRate(30);

  font = createFont("URW Gothic L Book", 200);
  circle = get_circles();

  result = new int[width*height][3];
}

final int LOOP_LENGTH = 150;
final boolean RENDER = true;

int samplesPerFrame = 1;
float shutterAngle = 1;

void draw() {
  for (int i=0; i<width*height; i++)
      for (int a=0; a<3; a++)
        result[i][a] = 0;

    for (int sa=0; sa<samplesPerFrame; sa++) {
      final float time = map(frameCount-1 + sa*shutterAngle/samplesPerFrame, 0, LOOP_LENGTH, 0, 1);
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

    if (frameCount == 2 * LOOP_LENGTH)
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
    circle.add(new SpringCircle(0, r0 * 2, new PVector(sin(ANGLE) * r0 * 8, cos(ANGLE) * r0 * 8), new PVector(sin(ANGLE) * r0, cos(ANGLE) * r0), 0.5));
    circle.add(new SpringCircle(0, r0, new PVector(sin(ANGLE) * r0 * 8, cos(ANGLE) * r0 * 8), new PVector(sin(ANGLE) * r1, cos(ANGLE) * r1), 0.18 + i * 0.03));
  }

  final int STEPS_1 = 12;

  for (int i = 0; i != STEPS_1; ++i) {
    final float ANGLE = i * TWO_PI / STEPS_1 + TWO_PI / (2 * STEPS_1);
    circle.add(new SpinEaseCircle(0.2, base_rad, ANGLE));
  }

  for (int i = 0; i != STEPS_0; ++i) {
    final float ANGLE = i * TWO_PI / STEPS_0 + TWO_PI / (2 * STEPS_0);
    final float r1 = base_rad * ratio;
    circle.add(new StraightEaseCircle(0.6, base_rad, new PVector(sin(ANGLE) * r1 * 5, cos(ANGLE) * r1 * 5), new PVector(sin(ANGLE) * r1, cos(ANGLE) * r1), i * 0.01));
  }

  circle.add(new CenterCircle(0.6, base_rad * 2));

  return circle;
}

abstract class Circle {
  Circle(float dist, float radius, PVector center) {
    _radius = radius;
    _current = center;
    _dist = dist;
  }

  abstract void update(float TIME);

  void draw(float TIME) {
    fill((TIME + _dist) % 1, 0.5, 0.5, 0.4);
    ellipse(_current.x, _current.y, _radius, _radius);
  }

  float _radius;
  PVector _current;
  float _dist;
}

class StraightEaseCircle extends Circle {
  StraightEaseCircle(float dist, float radius, PVector start, PVector end, float stagger) {
    super(dist, radius, start);
    _target = end;
    _stagger = stagger;
  }

  void update(float TIME) {
    if (TIME > _stagger)
      _current.add(PVector.sub(_target, _current).mult(0.2));
  }

  PVector _target;
  float _stagger;
}

class CenterCircle extends StraightEaseCircle {
  CenterCircle(float dist, float radius) {
    super(dist, radius, new PVector(0, height), new PVector(0, 0), 0);
  }
}

float get_angle(float TIME) {
  TIME *= 2;
  if (TIME > 1)
    TIME = 1;
  return pow(map(cos(TIME * PI), -1, 1, 0, 1), 4) * TWO_PI * 4;
}

class SpinEaseCircle extends Circle {
  SpinEaseCircle(float dist, float radius, float end_angle) {
    super(dist, radius, new PVector(0, 0));
    _radius = radius;
    _end_angle = end_angle;
  }

  void update(float TIME) {
    float base_angle = get_angle(TIME);
    base_angle *= pow((_end_angle / TWO_PI), 0.2);
    base_angle += _end_angle;

    float dist = base_angle * _radius;
    if (dist < TWO_PI * _radius)
      _current = new PVector(sin(base_angle) * _radius, cos(base_angle) * _radius);
    else
      _current = new PVector(dist - TWO_PI * _radius, _radius);
  }

  float _radius;
  float _end_angle;
}

class SpringCircle extends Circle {
  SpringCircle(float dist, float radius, PVector start, PVector end, float stagger) {
    super(dist, radius, start);
    _target = end;
    _stagger = stagger;
  }

  void update(float TIME) {
    if (TIME > _stagger) {
      PVector a = PVector.sub(_target, _current).mult(0.05);
      _velocity.add(a);
      _velocity.mult(0.8);
      _current.add(_velocity);
    }
  }

  PVector _target;
  PVector _velocity = new PVector(0, 0);
  float _stagger;
}

ArrayList<Circle> circle;

void frame(float TIME) {
  pushMatrix();
  final float base_rad = height / 5;

  background(0, 0, 1);
  noStroke();

  translate(width / 2, height / 2);

  for (Circle i : circle) {
    if (frameCount < LOOP_LENGTH)
      i.update(TIME);
    else
      i.update(1);
    i.draw(TIME);
  }

  final float alpha = frameCount < LOOP_LENGTH ? TIME : 1;

  fill(0, 0, 1, pow(alpha, 5));
  textFont(font);
  textAlign(CENTER, CENTER);
  textSize(base_rad * (72.0 / 120));
  text("CollabHub", 0, base_rad * (-20.0 / 120));
  textSize(base_rad * (22.0 / 120));
  text("Inspire // Innovate // Collaborate", 0, base_rad * (30.0 / 120));
  popMatrix();
}

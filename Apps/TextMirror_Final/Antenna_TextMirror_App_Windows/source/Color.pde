class Color {
  float r, g, b;

  Color(float _r, float _b, float _g) {
    r = _r;
    g = _g;
    b = _b;
  }

  float[] getColor() {
    float [] colors = { r, g, b };
    return colors;
  }
}


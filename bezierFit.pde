import pallav.Matrix.*;



ArrayList<PVector> raw_stroke = new ArrayList<PVector>();
ArrayList<PVector[]> bezier_strokes = new ArrayList<PVector[]>();

void setup()
{
  size(500, 500);
  colorMode(RGB, 1.0);
  background(1.0);
}


void draw()
{
  background(1.0);

  // Draw fitted curves
  stroke(0.0, 0.1, 0.2);
  for (PVector[] p : bezier_strokes)
  {
    fill(0.0);
    circle(p[0].x, p[0].y, 5);
    circle(p[3].x, p[3].y, 5);

    noFill();
    circle(p[1].x, p[1].y, 5);
    circle(p[2].x, p[2].y, 5);

    line(p[0].x, p[0].y, p[1].x, p[1].y);
    line(p[2].x, p[2].y, p[3].x, p[3].y);

    strokeWeight(2);
    bezier(p[0].x, p[0].y, p[1].x, p[1].y, p[2].x, p[2].y, p[3].x, p[3].y);
    strokeWeight(1);
  }

  // Draw raw stroke
  stroke(0.2, 0.4, 0.6);
  for (int i=1; i<raw_stroke.size(); i++)
  {
    PVector p0 = raw_stroke.get(i-1);
    PVector p1 = raw_stroke.get(i);
    line(p0.x, p0.y, p1.x, p1.y);
  }
}


void addPointToStroke(MouseEvent event)
{
  raw_stroke.add(new PVector(event.getX(), event.getY()));
}



void mousePressed(MouseEvent event)
{
  println("Start Stroke");
  raw_stroke = new ArrayList<PVector>();
  addPointToStroke(event);
}

void mouseDragged(MouseEvent event)
{
  addPointToStroke(event);
}

void mouseReleased(MouseEvent event)
{
  addPointToStroke(event);
  println("End Stroke");
  fitStroke();
}

void fitStroke()
{
  if (raw_stroke.size() <= 2)
  {
    // The mouse wasn't dragged, skip.
    return;
  } else
  {

    PVector p0, p1, p2, p3;
    int n = raw_stroke.size();

    float stroke_length = 0;
    for (int i=1; i<raw_stroke.size(); i++)
    {

      PVector a = raw_stroke.get(i-1);
      PVector b = raw_stroke.get(i);
      stroke_length += PVector.dist(a, b);
    }

    Matrix X = Matrix.array(new float[n][2]);
    Matrix Xt = Matrix.array(new float[2][n]);
    Matrix Yx = Matrix.array(new float[n][1]);
    Matrix Yy = Matrix.array(new float[n][1]);

    p0 = raw_stroke.get(0);
    p3 = raw_stroke.get(n-1);

    float current_length = 0;
    for (int i=0; i<n; i++) {
      if (i > 0)
      {
        PVector a = raw_stroke.get(i-1);
        PVector b = raw_stroke.get(i);
        current_length += PVector.dist(a, b);
      }
      float t = current_length / stroke_length;

      float w0, w1, w2, w3;
      w0 = (1-t)*(1-t)*(1-t);
      w1 = 3*(1-t)*(1-t)*t;
      w2 = 3*(1-t)*t*t;
      w3 = t*t*t;

      Xt.array[0][i] = X.array[i][0] = w1;
      Xt.array[1][i] = X.array[i][1] = w2;

      PVector p = raw_stroke.get(i).copy();
      p.sub(PVector.mult(p0, w0));
      p.sub(PVector.mult(p3, w3));

      Yx.array[i][0] = p.x;
      Yy.array[i][0] = p.y;
    }

    // Parameters = inverse(transpose(X)*X)*transpose(X)*y
    Matrix M = Matrix.Multiply(Matrix.inverse(Matrix.Multiply(Xt, X)), Xt);

    Matrix Px = Matrix.Multiply(M, Yx);
    Matrix Py = Matrix.Multiply(M, Yy);

    print("Px:"+Px.array.length+"x"+Px.array[0].length);

    p1 = new PVector(Px.array[0][0], Py.array[0][0]);
    p2 = new PVector(Px.array[1][0], Py.array[1][0]);

    println(p0+" "+p1+" "+p2+" "+p3);

    bezier_strokes.add(new PVector[]{p0, p1, p2, p3});

    // Reset raw stroke
    raw_stroke = new ArrayList<PVector>();
  }
}

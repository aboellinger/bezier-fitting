

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
    // THe mouse wasn't dragged, skip.
    return;
  }
  else
  {
    int n = raw_stroke.size();
    PVector start = raw_stroke.get(0);
    PVector end = raw_stroke.get(n-1);
    
    PVector middle = raw_stroke.get(n/2);
    
    bezier_strokes.add(new PVector[]{start, middle, middle, end});
  }
}

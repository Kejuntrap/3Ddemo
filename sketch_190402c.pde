double[] center={5.0,0.0,0.0};  //立体の中心座標
int vertex_vol=0;
int polygon_vol=0;
double[][] vertex;
int[][] polygon;
double[][] calc_V;    //計算用の変数　誤差が積もって爆発したので対策を講じた

double[] vec_unit_rotate={1/Math.sqrt(3),1/Math.sqrt(3),1/Math.sqrt(3)};  //回転軸の単位ベクトル
double rotate_angle=0;  //回転速度 \theta/s
long counter=0;
double[][] v_draw;  //3次元から2次元に落とし込む
double kyoudo=1;
long time=0;


void setup(){
  size(800,800,P2D);
  frameRate(60);
  background(0);
  textSize(32);
  String l;
  String[] lines;
  lines=loadStrings("vertex.pd");
  vertex_vol=lines.length;
  vertex=new double[vertex_vol][3];
  v_draw=new double[vertex_vol][3];
  calc_V=new double[vertex_vol][3];
  for(int i=0; i<lines.length; i++){
    l=lines[i];
    String[] co=split(l,',');
    vertex[i][0]=Double.parseDouble(co[0]);
    vertex[i][1]=Double.parseDouble(co[1]);
    vertex[i][2]=Double.parseDouble(co[2]);
  }
  
  lines=loadStrings("polygon.pd");
  polygon_vol=lines.length;
  polygon=new int[polygon_vol][3];
  for(int i=0; i<lines.length; i++){
    l=lines[i];
    String[] co=split(l,',');
    polygon[i][0]=Integer.parseInt(co[0]);
    polygon[i][1]=Integer.parseInt(co[1]);
    polygon[i][2]=Integer.parseInt(co[2]);
  }
  
  println("done");
}

void draw(){
  background(0);
  time=millis();
  calc(rotate_angle,vec_unit_rotate);
  convert3Dto2D();
  stroke(255);
  fill(255);
  int num=0;
  for(int i=0; i<polygon_vol; i++){
    if(culling(polygon[i])){
      fill((int)(255*kyoudo));
      stroke((int)(255*kyoudo));
      triangle((float)v_draw[polygon[i][0]][0],(float)v_draw[polygon[i][0]][1],(float)v_draw[polygon[i][1]][0],(float)v_draw[polygon[i][1]][1],(float)v_draw[polygon[i][2]][0],(float)v_draw[polygon[i][2]][1]);
      num++;
    }
    
  }
  counter+=2;
  counter%=720;
  rotate_angle=((float)counter);
  long now=millis();
  fill(255);
  //text("Rendered \t"+(num)+" polygon(s)", 10, 10, 600, 40);
  //text("Rendered time \t"+(now-time)+" ms", 10, 50, 600, 40);
  time=now;
}

void convert3Dto2D(){
  for(int i=0; i<vertex_vol; i++){
    double tmpx=center[0]+calc_V[i][0];
    double tmpy=center[1]+calc_V[i][1];
    double tmpz=center[2]+calc_V[i][2];
    v_draw[i][0]=400+400*(tmpz/Math.abs(tmpx));  //z
    v_draw[i][1]=400+400*(tmpy/Math.abs(tmpx));   //y　画面でいうと
  }
}

void calc(double ang,double[] vec){
  double c=Math.cos(ang*Math.PI/180);
  double s=Math.sin(ang*Math.PI/180);
  double[][] rotate_matrix={
      {c+vec[0]*vec[0]*(1-c)        ,vec[0]*vec[1]*(1-c)-vec[2]*s  , vec[0]*vec[2]*(1-c)+vec[1]*s},
      {vec[1]*vec[0]*(1-c)+vec[2]*s ,c+vec[1]*vec[1]*(1-c)         , vec[1]*vec[2]*(1-c)-vec[0]*s},
      {vec[2]*vec[0]*(1-c)-vec[1]*s ,vec[2]*vec[1]*(1-c)+vec[0]*s  , c+vec[2]*vec[2]*(1-c)}
  };
  
  for(int i=0; i<vertex_vol; i++){
    for(int j=0; j<3; j++){
      double v=vertex[i][j];
      double ans=0;
      for(int k=0; k<3; k++){
        ans+=rotate_matrix[j][k]*vertex[i][k];
      }
      calc_V[i][j]=ans;
    }
  }
}

boolean culling(int[] poly){    //カリング（描写量を減らす）
  double[] cen={0,0,0};  //カメラ
  double[] vert={0,0,0};
  double c_d=0;
  double v_d=0;
  for(int i=0; i<3; i++){
    for(int j=0; j<3; j++){
      cen[i]+=calc_V[poly[j]][i];
    }
    cen[i]/=3.0;
  }
  for(int i=0; i<3; i++){
    cen[i]+=center[i];  
  }
  c_d=Math.sqrt(cen[0]*cen[0]+cen[1]*cen[1]+cen[2]*cen[2]);
  for(int i=0; i<3; i++){
    cen[i]/=c_d;
  }
  
  double[] v1={calc_V[poly[1]][0]-calc_V[poly[0]][0],calc_V[poly[1]][1]-calc_V[poly[0]][1],calc_V[poly[1]][2]-calc_V[poly[0]][2]};
  double[] v2={calc_V[poly[2]][0]-calc_V[poly[0]][0],calc_V[poly[2]][1]-calc_V[poly[0]][1],calc_V[poly[2]][2]-calc_V[poly[0]][2]};
  
  vert[0]=v1[1]*v2[2]-v1[2]*v2[1];
  vert[1]=v1[2]*v2[0]-v1[0]*v2[2];
  vert[2]=v1[0]*v2[1]-v1[1]*v2[0];  //法線ベクトル
  
  v_d=Math.sqrt(vert[0]*vert[0]+vert[1]*vert[1]+vert[2]*vert[2]);
  for(int i=0; i<3; i++){
    vert[i]/=v_d;
  }
  double cul=cen[0]*vert[0]+cen[1]*vert[1]+cen[2]*vert[2];
  kyoudo=Math.abs(cul)*1;
  if(kyoudo>1){
    kyoudo=1;
  }
  if(cul<-0.01){
    
    return true;
  }
  else{
    return false;
  }
}

/*

https://wgld.org/d/contribution/a002.html

https://yttm-work.jp/gmpg/gmpg_0014.html
*/

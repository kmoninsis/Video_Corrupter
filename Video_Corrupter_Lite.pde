String sourceFile;
String targetFile;
String[] params;

int retVal = 0;
int threshold = 850000000/4;

float factor = 1;
int n;
String nb;
int timer = 0;
boolean ready = false;
void setup() {
  nb = nf(day(), 2)+"-"+nf(month(), 2)+"-"+nf(year(), 4)+"-"+nf(hour(), 2)+"-"+nf(minute(), 2);
  stopRec();
  record(nb);
}

void draw() {  
  if (frameCount%1000 == 0) {
    retVal = checkBytes(sourceFile); 
    println(retVal);
  }
  if (retVal > threshold) {
    retVal = 0;
    stopRec();    
    corruptFile("out", nb); 
    try {
      //Runtime rt = Runtime.getRuntime();
      //rt.exec("taskkill /IM ffplay.exe");
      //delay(100);
      //rt.exec("C:\\ffmpeg\\bin\\ffplay -i "+ targetFile);
    }
    catch(Exception e) {      
      println("     " + e);
    }

    nb = nf(day(), 2)+"-"+nf(month(), 2)+"-"+nf(year(), 4)+"-"+nf(hour(), 2)+"-"+nf(minute(), 2);
    record(nb);
  }
}

int checkBytes(String File) {
  byte b[] = loadBytes(File);
  return b.length;
}

void record(String n) {
  sourceFile = "out"+n+".ts";
  params = new String[] { "C:\\mpv\\mpv.exe", 
    "--no-audio", 
    "--ytdl-format=95", 
    "--cache-on-disk=yes", 
    "--cache-dir=C:\\Users\\Simon\\Documents\\Processing\\Video_Corrupter_Lite\\data\\", 
    "--stream-record=C:\\Users\\Simon\\Documents\\Processing\\Video_Corrupter_Lite\\data\\"+sourceFile, 
    "http://www.youtube.com/watch?v=ZjfFGJlkjmE", 
  };

  try {
    Runtime.getRuntime().exec(params);
  }
  catch (Exception e) {
    println("Error, sorry!");  
    println("     " + e);
  }
  File dataFile = sketchFile("data/"+sourceFile);
  //println("Start: "+sourceFile);
  while (!ready) {
    if (dataFile.exists()) {
      ready = true;
    } else {
      delay(100);
      timer++;
      println(timer);
    }
    if (timer > 100) {

      timer = 0;
      stopRec();
      record(n);
    }
  }
}


void stopRec() {
  try { 
    Runtime rt = Runtime.getRuntime();
    rt.exec("taskkill /IM mpv.exe");
    ready = false;
  }
  catch (Exception e) {
    println("Couldn't taskkill   "+e);
  }
}
void keyPressed() {
  // press space to corrupt
  if (key==' ') {
    stopRec();    
    corruptFile("out", nb);     
    //nb = nf(day(), 2)+"-"+nf(month(), 2)+"-"+nf(year(), 4)+"-"+nf(hour(), 2)+"-"+nf(minute(), 2);
    //record(nb);
    try {
      Runtime rt = Runtime.getRuntime();
      //rt.exec("taskkill /IM ffplay.exe");
      //delay(100);
      //Process p = rt.exec("cmd /c ffplay -i "+ targetFile);
      //int exitVal = p.waitFor();
      //println("Process exitValue: "+ exitVal);
    }
    catch(Exception e) {      
      println("     " + e);
    }
  }
}

void corruptFile(String File, String p) {
  String source = File+p+".ts";
  byte b[] = loadBytes(source);  
  targetFile = "D:\\Footage\\2020\\datamoshing\\stream\\"+nf(day(), 2)+"-"+nf(month(), 2)+"-"+nf(year(), 4)+"\\corrupt"+p+".ts";
  for (int j = 0; j < 1; j ++) // change 1 to any value to generate more images
  {
    byte bCopy[] = new byte[b.length];
    arrayCopy(b, bCopy);
    // load binary of file
    int scrambleStart = 10;
    // scramble start excludes 10 bytes
    int scrambleEnd = b.length;
    // scramble end
    n = int((b.length/50000)*factor);
    // number of replacements - go easy as too much will kill the file
    // swap bits

    for (int i = 0; i < n; i++)
    {
      int PosA = int(random (scrambleStart, scrambleEnd));
      int PosB = int(random (scrambleStart, scrambleEnd));
      byte tmp = bCopy[PosA];
      bCopy[PosA] = bCopy[PosB];
      bCopy[PosB] = tmp;
    }
    // save the file ///
    saveBytes(targetFile, bCopy);
    delay(200);
    System.gc();
    println(n, targetFile);
  }
}

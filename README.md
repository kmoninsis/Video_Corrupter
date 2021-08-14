# Video_Corrupter
Script for corrupting (live)video-stream with Processing and MPV.

Main parts of the script are:
1. Grabbing live-stream feed with MPV
2. Saving it in parts on HDD
3. Corrupting the files with Processing
4. Play and loop corrupted files (outside script) 


### Requirements:
1. [Processing IDE](https://processing.org/)
2. [MPV](https://mpv.io/installation/)

### Step 1
MPV supports commandline arguments and works well with commandline-tool Youtube-downloader (ytdl). Firstly, setup the arguments for MPV in the function `record(n)`, which takes the custom name for the file as an argument:  
```java
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
```
### Step 2
The next part of the function tries to run the program with `Runtime.getRuntime().exec(params);`. It then caches the file on HDD, until the size has met the threshold. This is checked with:
```java
int checkBytes(String File) {
  byte b[] = loadBytes(File);
  return b.length;
}
```
during `draw()`. If the bytes.length of the cached file == threshold, then function `stopRec()` is called:
```java
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
```
## Step 3
Corrupting the files is done by replacing a number of bytes in the file. Input is the newly saved video file, output is the corrupted file:
```java
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
```
`System.gc()` is used to clear memory (garbage collector), as memory will fill up with previous file data.

### Step 4
In the folder with saved corrupted files, create a .bat file with infinite loop:
```bat
:loop
for %i in (*.ts) do ffplay -autoexit %i
goto loop
```






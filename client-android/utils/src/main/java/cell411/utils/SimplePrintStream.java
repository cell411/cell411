package cell411.utils;

import android.util.Log;
import androidx.annotation.NonNull;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.io.PrintStream;
import java.util.Locale;

public class SimplePrintStream extends PrintStream {
  static byte[] smTrue  = new byte[] { 't','r','u','e' };
  static byte[] smFalse = new byte[] {'f','a','l','s','e' };

//  ByteArrayOutputStream bytes = new ByteArrayOutputStream();
//  public SimplePrintStream() {
//    this(new OutputStream() {
//      final byte[] buffer = new byte[800];
//      int pos=0;
//      @Override
//      public void write(int b) throws IOException {
//        buffer[pos++]=(byte)b;
//
//        if(pos!=buffer.length && b!=10)
//          return;
//        Log.i("|",new String(buffer,0,pos));
//        pos=0;
//      }
//    });
//  }
  public SimplePrintStream(OutputStream outputStream) {
    super(outputStream);
  }
  @Override
  public void flush() {
  }
  @Override
  public void close() {
  }
  @Override
  public boolean checkError() {
    return false;
  }
  @Override
  protected void setError() {
  }
  @Override
  protected void clearError() {
  }
  @Override
  public void write(int b) {
    try {
      out.write(b);
    } catch (IOException ignored) {

    }
  }
  @Override
  public void write(byte[] buf, int off, int len) {
    try {
      out.write(buf, off, len);
    } catch (IOException ignored) {
    }
  }
  @Override
  public void print(boolean b) {
    write(b ? smTrue : smFalse, 0, b ? 4 : 5);
  }
  @Override
  public void print(char c) {
    write(c);
  }
  @Override
  public void print(int v) {
    write(String.valueOf(v).getBytes());
  }
  @Override
  public void print(long v) {
    write(String.valueOf(v).getBytes());
  }
  @Override
  public void print(float v) {
    write(String.valueOf(v).getBytes());
  }
  @Override
  public void print(double v) {
    write(String.valueOf(v).getBytes());
  }
  @Override
  public void print(char[] v) {
    write(String.valueOf(v).getBytes());
  }
  @Override
  public void print(String v) {
    write(String.valueOf(v).getBytes());
  }
  @Override
  public void print(Object v) {
    write(String.valueOf(v).getBytes());
  }
  @Override
  public void println() {
    write(10);
  }
  @Override
  public void println(boolean x) {
    print(x);
    write(10);
  }
  @Override
  public void println(char x) {
    print(x);
    write(10);
  }
  @Override
  public void println(int x) {
    print(x);
    write(10);
  }
  @Override
  public void println(long x) {
    print(x);
    write(10);
  }
  @Override
  public void println(float x) {
    print(x);
    write(10);
  }
  @Override
  public void println(double x) {
    print(x);
    write(10);
  }
  @Override
  public void println(char[] x) {
    print(x);
    write(10);
  }
  @Override
  public void println(String x) {
    print(x);
    write(10);
  }
  @Override
  public void println(Object x) {
    print(x);
    write(10);
  }
  @Override
  public PrintStream printf(String format, Object... args) {
    write(String.format(format, args).getBytes());
    return this;
  }
  @Override
  public PrintStream printf(Locale l, String format, Object... args) {
    write(String.format(format,args).getBytes());
    return this;
  }
  @Override
  public PrintStream format(String format, Object... args) {
    write(String.format(format,args).getBytes());
    return this;
  }
  @Override
  public PrintStream format(Locale l, String format, Object... args) {
    write(String.format(format,args).getBytes());
    return this;
  }
  @Override
  @NonNull
  public PrintStream append(@NonNull CharSequence csq) {
    write(csq.toString().getBytes());
    return this;
  }
  @Override
  @NonNull
  public PrintStream append(@NonNull CharSequence csq, int start, int end) {
    write(csq.subSequence(start, end).toString().getBytes());
    return this;
  }
  @Override
  @NonNull
  public PrintStream append(char c) {
    write(c);
    return this;
  }
  @Override
  public void write(byte[] b)
  {
    write(b,0,b.length);
  }
 }

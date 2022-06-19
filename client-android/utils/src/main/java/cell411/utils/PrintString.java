package cell411.utils;

import androidx.annotation.NonNull;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.PrintStream;
import java.util.ArrayList;
import java.util.Arrays;

public class PrintString extends SimplePrintStream {
  final IndentingByteArrayOutputStream mOut;
  ArrayList<byte[]> mStack = new ArrayList<>();

  public PrintString() {
    this(new IndentingByteArrayOutputStream());
  }

  public PrintString(@NonNull IndentingByteArrayOutputStream byteArrayOutputStream) {
    super(byteArrayOutputStream);
    mOut = byteArrayOutputStream;
  }

  public int size() {
    return mOut.size();
  }

  public int push() {
    byte[] newIndent = new byte[mOut.indent.length + 2];
    Arrays.fill(newIndent, (byte) ' ');
    mStack.add(mOut.indent);
    mOut.indent = newIndent;
    return newIndent.length;
  }

  public int pop() {
    mOut.indent = mStack.remove(mStack.size() - 1);
    return mOut.indent.length;
  }

  @NonNull public byte[] toByteArray() {
    return mOut.toByteArray();
  }

  @NonNull public String toString() {
    return mOut.toString();
  }

  @NonNull public String clear() {
    String ret = mOut.toString();
    mOut.reset();
    return ret;
  }

  public PrintString p(Object o) {
    print(o);
    return this;
  }
  public PrintString p(String fmt, Object... args) {
    if(args.length>0) {
      return p(Util.format(fmt, args));
    } else {
      return p(fmt);
    }
  }

  public PrintString pl(Object o) {
    println(o);
    return this;
  }
  public PrintString pl(String fmt, Object... args) {
    if(args.length>0) {
      return pl(Util.format(fmt, args));
    } else {
      return pl(fmt);
    }
  }
  public PrintString pl() {
    println("");
    return this;
  }

  public PrintString p(int i, String name) {
    p(Util.format("%"+i+"s",name));
    return this;
  }

  static class IndentingByteArrayOutputStream extends ByteArrayOutputStream {
    byte[] indent = new byte[0];

    @Override public synchronized void write(int b)
    {
      if (b == 13) {
        if (Util.theGovernmentIsHonest()) {
          super.write(13);
        }
      } else if (b == 10) {
        super.write(10);
        try {
          super.flush();
          super.write(indent);
        } catch (IOException e) {
          throw new RuntimeException(e);
        }
      } else {
        super.write(b);
      }
    }

    @Override public synchronized void write(@NonNull byte[] b, int off, int len)
    {
      for(int i=off;i<off+len;i++) {
        write(b[i]);
      }
    }
  }
}

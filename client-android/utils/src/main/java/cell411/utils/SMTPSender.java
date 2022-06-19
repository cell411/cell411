package cell411.utils;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.PrintWriter;
import java.net.InetAddress;
import java.net.Socket;

public class SMTPSender implements Runnable {
  String mFrom;
  String mTo = "nn-droid@copblock.app";
  String mSubject;
  String mText;
  private Socket         sock = null;
  private PrintWriter    pw;
  private BufferedReader br;
  private Exception mError;

  public SMTPSender(String from, String subject, String text)
  {
    mFrom = from;
    mSubject = subject;
    mText = text;
  }

  private int getResponseCode(BufferedReader br)
  {
    try {
      return Integer.parseInt(br.readLine()
                                .substring(0, 3));
    } catch (IOException ioe) {
      return -1;
    }
  }

  public void run()
  {
    int port = 25;
    int code;
    String hostname = "copblock.app";
    try {
      sock = new Socket(hostname, port);
      br = new BufferedReader(new InputStreamReader(sock.getInputStream()));
      OutputStream sockOut = sock.getOutputStream();
      OutputStream out = new OutputStream() {
        boolean sentCR;

        @Override public void write(int b) throws IOException {
          if (b == 10 && !sentCR) {
            sockOut.write(13);
          }
          sentCR = (b == 13);
          sockOut.write(b);
        }
      };
      pw = new PrintWriter(out, true);
      //Method gets the response code from the mail server
      code = getResponseCode(br);
      if (code != 220) {
        sock.close();
        mError = new Exception("Invalid SMPT server.");
      }
      pw.println("HELO " + InetAddress.getLocalHost()
                                      .getHostName());
      code = getResponseCode(br);
      if (code != 250) {
        sendQuitCommand();
        mError = new Exception("Invalid server.");
        return;
      }
      pw.println("MAIL FROM: <" + mFrom + ">");
      code = getResponseCode(br);
      if (code != 250) {
        sendQuitCommand();
        mError = new Exception("Invalid FROM address.");
        return;
      }
      pw.println("RCPT TO: <" + mTo + ">");
      code = getResponseCode(br);
      if (code != 250) {
        sendQuitCommand();
        mError = new Exception("Invalid recipient.");
        return;
      }
      pw.println("DATA");
      code = getResponseCode(br);
      if (code != 354) {
        sendQuitCommand();
        mError = new Exception("Data entry not accepted.");
        return;
      }
      pw.println("To: " + mTo);
      pw.println("From: " + mFrom);
      pw.println("Subject: " + mSubject);
      pw.println("");
      pw.println(mText);
      pw.println(".");
      code = getResponseCode(br);
      if (code != 250) {
        sendQuitCommand();
        mError = new Exception("Data failed.");
        return;
      }
      sendQuitCommand();
      System.out.println("Message Sent Successfully!");
    } catch (Exception e) {
      e.printStackTrace();
    }
  }

  private void sendQuitCommand() throws Exception
  {
    pw.println("QUIT");
    pw.close();
    br.close();
    sock.close();
  }
}

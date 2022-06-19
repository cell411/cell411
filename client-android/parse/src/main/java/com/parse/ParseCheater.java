package com.parse;

import java.io.File;

import static com.parse.controller.ParseCorePlugins.FILENAME_CURRENT_USER;

@SuppressWarnings("ALL")
public class ParseCheater {
  @SuppressWarnings("deprecation")
  public static File getParseDir() {
    return Parse.getParseDir();
  }
  public static File getCurrentUserFile() {
    return new File(getParseDir(),FILENAME_CURRENT_USER);
  }

  static String[] files = new String[]{
          "currentUser",
          "_currentUser",
          "currentInstallation",
          "_currentInstallation",
          "currentConfig"
  };

    public static void removeCredentials() {
      for(int i=0;i<files.length;i++){
        File file = new File(getParseDir(), files[i]);
        if(file.delete())
          System.out.println("Removed!");
      }
    }
}

package cell411.parse;

import androidx.annotation.NonNull;

import java.io.Serializable;

public class CountryInfo implements Serializable {
  private static final long    serialVersionUID = 1L;
  public               String  name;
  public               String  dialingCode;
  public               String  shortCode;
  public               int     flagId;
  public               boolean selected;

  public CountryInfo(String name, String dialingCode, String shortCode)
  {
    this.name = name;
    this.dialingCode = dialingCode;
    this.shortCode = shortCode;
  }

  @Override @NonNull public String toString()
  {
    return name;
  }
}


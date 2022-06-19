package cell411.enums;

public enum BloodType {
  UNKNOWN(""),
  A_MINUS("A-"),
  A_PLUS("A+"),
  B_MINUS("B-"),
  B_PLUS("B+"),
  AB_MINUS("AB-"),
  AB_PLUS("AB+"),
  O_MINUS("O-"),
  O_PLUS("O+");
  final String mAltName;

  BloodType(String altName)
  {
    mAltName = altName;
  }

  public static BloodType forString(String name) {
    for (BloodType type : values()) {
      if (type.equalStr(name)) {
        return type;
      }
    }
    throw new IllegalArgumentException("No enum constant BloodType." + name);
  }

  public String altName() {
    return mAltName;
  }

  public boolean equalStr(String name) {
    return this.name()
               .equals(name) || altName().equals(name);
  }
}

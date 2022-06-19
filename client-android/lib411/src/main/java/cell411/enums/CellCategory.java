package cell411.enums;

/**
 * Created by Sachin on 14-05-2018.
 */
public enum CellCategory {
  None,
  Activism,
  Commercial,
  Community_Safety,
  Education,
  Government,
  Journalism,
  Personal_Safety;

  public static CellCategory forString(String category) {
    String[] parts = category.split("  *");
    if (parts.length > 1) {
      StringBuilder sb = new StringBuilder();
      sb.append(parts[0]);
      for (int i = 1; i < parts.length; i++) {
        sb.append("_")
          .append(parts[i]);
      }
      category = sb.toString();
    }
    return valueOf(category);
  }
}


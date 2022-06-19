package cell411.enums;

public enum EntityType {
  INVALID_ENTITY,
  PUBLIC_CELL,
  ALERT,
  PRIVATE_CELL;

  public static EntityType valueOf(int entityTypeId) {
    if (entityTypeId > PRIVATE_CELL.ordinal()) {
      throw new IllegalArgumentException("Unexpected typeId: " + entityTypeId);
    }
    if (entityTypeId == 0) {
      throw new IllegalArgumentException("Unexpected typeId: " + entityTypeId);
    }
    return values()[entityTypeId];
  }
}

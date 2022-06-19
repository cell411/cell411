package com.parse.http;

import androidx.annotation.NonNull;

/**
 * The {@code ParseHttpRequest} method type.
 */
public enum ParseHttpMethod {

  GET,
  POST,
  PUT,
  DELETE;

  /**
   * Creates a {@code Method} from the given string. Valid stings are {@code GET}, {@code POST},
   * {@code PUT} and {@code DELETE}.
   *
   * @param string The string value of this {@code Method}.
   * @return A {@code Method} based on the given string.
   */
  public static ParseHttpMethod fromString(String string) {
    ParseHttpMethod method;
    switch (string) {
      case "GET":
        method = GET;
        break;
      case "POST":
        method = POST;
        break;
      case "PUT":
        method = PUT;
        break;
      case "DELETE":
        method = DELETE;
        break;
      default:
        throw new IllegalArgumentException("Invalid http method: <" + string + ">");
    }
    return method;
  }

  /**
   * Returns a string value of this {@code Method}.
   *
   * @return The string value of this {@code Method}.
   */
  @Override
  @NonNull
  public String toString() {
    String string;
    switch (this) {
      case GET:
        string = "GET";
        break;
      case POST:
        string = "POST";
        break;
      case PUT:
        string = "PUT";
        break;
      case DELETE:
        string = "DELETE";
        break;
      default:
        throw new IllegalArgumentException("Invalid http method: <" + this + ">");
    }
    return string;
  }
}

package com.parse.http;

import static com.parse.ParseException.OTHER_CAUSE;

import android.util.Log;

import com.parse.Parse;
import com.parse.ParseCloud;
import com.parse.ParseException;
import com.parse.ParseQuery;
import com.parse.codec.ParseDecoder;
import com.parse.codec.PointerEncoder;
import com.parse.controller.ParseCloudCodeController;
import com.parse.controller.ParsePlugins;
import com.parse.model.ParseObject;
import com.parse.model.ParseUser;
import com.parse.rest.ParseHttpClient;
import com.parse.rest.ParseRESTCloudCommand;
import com.parse.rest.ParseRESTCommand;
import com.parse.rest.ParseRESTQueryCommand;
import com.parse.rest.ParseRequest;
import com.parse.utils.ParseFileUtils;
import com.parse.utils.ParseIOUtils;

import org.jetbrains.annotations.NotNull;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.PrintStream;
import java.net.URI;
import java.nio.file.FileSystem;
import java.nio.file.FileSystems;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import cell411.json.JSONArray;
import cell411.json.JSONException;
import cell411.json.JSONObject;
import cell411.json.JSONTokener;

public class ParseSyncUtils {

  public static JSONObject getJSON(ParseHttpResponse response) {
    InputStream responseStream = null;
    try {
      responseStream = response.getContent();
      byte[] bytes = ParseIOUtils.toByteArray(responseStream);
      String content = new String(bytes).trim();
      if (content.length() > 6 && content.substring(0, 6).equalsIgnoreCase("<html>")) {
        if (content.contains("<title>502 Bad Gateway")) {
          throw new ParseException(ParseException.CONNECTION_FAILED, "502 Bad Gateway");
        } else {
          throw new ParseException(ParseException.OTHER_CAUSE, content);
        }
      } else {
        return new JSONObject(content);
      }
    } catch (IOException e) {
      throw new RuntimeException("Reading query response", e);
    } catch (JSONException e) {
      throw new RuntimeException("Parsing query response", e);
    } finally {
      ParseIOUtils.closeQuietly(responseStream);
    }
  }

  public static JSONObject executeRequest(ParseHttpClient client, ParseHttpRequest request)
    throws IOException {
    ParseHttpResponse response = client.execute(request);
    JSONObject jsonResponse = getJSON(response);
    int statusCode = response.getStatusCode();
    switch (statusCode / 100) {
      case 4:
      case 5: {
        int code = jsonResponse.optInt("code");
        String message = jsonResponse.optString("error");
        // Internal error server side, or something, we'll
        // flag that it might be worth trying again.
        ParseRequest.ParseRequestException e =
          new ParseRequest.ParseRequestException(code, message);
        e.mIsPermanentFailure = statusCode < 500;
        throw e;
      }
      case 2:
        return jsonResponse;
      default:
        throw new ParseException(ParseException.OTHER_CAUSE, "Unexpected http code");
    }
  }

  public static <T extends ParseObject> List<T> find(ParseQuery.State<T> state)
    throws ParseException
  {
    ParseException pe = null;
    Throwable th;
    try {
      JSONObject jsonResponse = runQuery(state, false);
      JSONArray jsonResults = jsonResponse.getJSONArray("results");
      String resultClassName = jsonResponse.optString("className");
      if (resultClassName.isEmpty())
        resultClassName = state.className();
      List<T> results = new ArrayList<>(jsonResults.length());
      for (int i = 0; i < jsonResults.length(); i++) {
        JSONObject jsonResult = jsonResults.getJSONObject(i);
        T result = ParseObject.fromJSON(jsonResult, resultClassName, ParseDecoder.get(),
          state.selectedKeys());
        results.add(result);
      }
      return results;
    } catch (ParseException e) {
      th = pe = e;
    } catch (Throwable t) {
      th = t;
    }
    try {
      ByteArrayOutputStream text = new ByteArrayOutputStream();
      PrintStream printer = new PrintStream(text);
      JSONObject jsonObject = state.toJSON(PointerEncoder.get());
      String strQuery = "\\n" + jsonObject.toString(2) + "\\n\\n";
      strQuery = strQuery.replaceAll("\\n", "\n  |");
      printer.println("While running the following query:\n");
      printer.println(strQuery);
      printer.println("\nWe encountered the following error:\n");
      if (pe != null)
        pe.printStackTrace(printer);
      else
        th.printStackTrace(printer);

      printer.println("\n\nDo something about that, would you?\n");
      printer.flush();
      Log.i("ParseSyncUtils", text.toString());
      if (pe != null)
        throw pe;
      else
        throw th;
    } catch (Throwable ignored) {
      if (pe != null)
        throw pe;
      else
        throw new RuntimeException("Rethrow", th);
    }
  }

  public static <T extends ParseObject> JSONObject runQuery(ParseQuery.State<T> state,
                                                            boolean count) {
    ParseHttpClient client = ParsePlugins.get().restClient();
    try {
      ParseUser currentUser = ParseUser.getCurrentUser();
      if (currentUser == null)
        throw new ParseException(ParseException.NOT_LOGGED_IN, "session missing");

      String sessionToken = currentUser.getSessionToken();
      String httpPath = String.format("classes/%s", state.className());
      Map<String, String> parameters = ParseRESTQueryCommand.encode(state, count);
      ParseRESTQueryCommand command =
        new ParseRESTQueryCommand(httpPath, ParseHttpMethod.GET, parameters, sessionToken);
      ParseHttpMethod method = command.method;
      String url = command.url;
      ParseHttpRequest request = command.newRequest(method, url, null);
      return executeRequest(client, request);
    } catch (ParseException pe) {
      throw new ParseException(pe.getCode(), "Running query for class " + state.className(), pe);
    } catch (IOException e) {
      throw new ParseException(OTHER_CAUSE, "Executing Query for class " + state.className(), e);
    }
  }

  public static <T extends ParseObject> int count(ParseQuery.State<T> state) {
    JSONObject result = runQuery(state, true);
    return result.optInt("count", 0);
  }

  public static Object decodeObject(Object o) {
    return ParseDecoder.get().decode(o);
  }

  public static <T> T run(@NotNull String name, @NotNull Map<String, ?> params) {
    String sessionToken = ParseUser.getCurrentSessionToken();
    ParseCloudCodeController controller = ParseCloud.getCloudCodeController();
    ParseRESTCommand command =
      ParseRESTCloudCommand.callFunctionCommand(name, params, sessionToken);
    try {
      ParseHttpClient client = controller.getRestClient();
      ParseHttpRequest request = command.newRequest();
      JSONObject jsonResponse = executeRequest(client, request);
      Object result = jsonResponse.opt("result");
      //noinspection unchecked
      return (T) ParseSyncUtils.decodeObject(result);
    } catch (IOException ioe) {
      throw command.newTemporaryException("Calling Function " + name, ioe);
    }
  }

  public static Object decode(byte[] fileToBytes) {
    return decode(new String(fileToBytes));
  }

  public static Object decode(String s) {
    JSONTokener tokener = new JSONTokener(s);
    try {
      return decodeObject(tokener.nextValue());
    } catch (JSONException je) {
      throw new RuntimeException("parsing json", je);
    }
  }

  public static <X extends ParseObject> JSONObject encodeQuery(ParseQuery<X> query) {
    PointerEncoder encoder = PointerEncoder.get();
    return query.getBuilder().build().toJSON(encoder);
  }

  //    try (FileOutputStream fos = new FileOutputStream(cacheFile)) {
//      fos.write(coded.toString().getBytes());
//    } catch (IOException e) {
//      throw new ParseException(OTHER_CAUSE, "Exception", e);
//    }
//  }

}
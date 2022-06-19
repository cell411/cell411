package com.parse.http;

import static com.parse.ParseException.OTHER_CAUSE;

import com.parse.ParseException;
import com.parse.codec.ParseDecoder;
import com.parse.codec.ParseEncoder;
import com.parse.model.ParseACL;
import com.parse.model.ParseObject;
import com.parse.model.ParseUser;
import com.parse.utils.ParseDateFormat;
import com.parse.utils.ParseIOUtils;

import java.io.File;
import java.io.FileOutputStream;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

import cell411.json.JSONArray;
import cell411.json.JSONException;
import cell411.json.JSONObject;

/**
 * Handles encoding/decoding ParseObjects to/from REST JSON.
 */
public class FullObjectCoder extends ParseEncoder {

  static final ParseDateFormat smFormat = ParseDateFormat.getInstance();
  private static final String KEY_OBJECT_ID = "objectId";
  private static final String KEY_CLASS_NAME = "className";
  private static final String KEY_ACL = "ACL";
  private static final String KEY_CREATED_AT = "createdAt";
  private static final String KEY_UPDATED_AT = "updatedAt";
  private final HashMap<String, JSONObject> mNext = new HashMap<>();
  HashMap<String, JSONObject> mText = new HashMap<>();

  public FullObjectCoder() {//    JSONArray next = new JSONArray();
//    for (JSONObject json : mNext.values()) {
//      next.put(json);
//    }


    //URI uri = URI.create("jar:file:/codeSamples/zipfs/zipfstest.zip");
//    URI uri = URI.create("file://" + cacheDir);
//    try {
//      mSaveFs = FileSystems.newFileSystem(uri, new HashMap<>());
//    } catch (IOException e) {
//      throw new RuntimeException("Creating Filesystem");
//    }
  }

  static String format(Date date) {
    if (date == null)
      return null;
    else
      return smFormat.format(date);
  }

//  public <X extends ParseObject>
//  void saveData(File indexFile, final Map<String, X> values, final Date lastBatch) {
//    ParseUser currentUser = ParseUser.getCurrentUser();
//    String id = currentUser == null ? "" : currentUser.getObjectId();
//    mNext.clear();
//    mText.clear();
//    for (String key : values.keySet()) {
//      if (key.equals(id)) {
//        System.out.println("id");
//      }
//      mText.put(key, fullEncode(values.get(key)));
//    }
//
//    FileOutputStream stream = null;
//    JSONArray array = new JSONArray();
//    array.put(lastBatch.getTime());
//    array.put(values.size());
//    for (JSONObject json : mText.values()) {
//      array.put(json.toString());
//    }
//    for (JSONObject json : mNext.values()) {
//      array.put(json.toString());
//    }
//    try {
//      mkdirs(indexFile, false);
//      stream = new FileOutputStream(indexFile);
//      String arrayStr = array.toString(2);
//      stream.write(arrayStr.getBytes());
//    } catch (RuntimeException re) {
//      throw re;
//    } catch (Exception e) {
//      throw new RuntimeException("Failed to write " + indexFile, e);
//    } finally {
//      ParseIOUtils.closeQuietly(stream);
//    }
//  }
//
  public boolean mkdirs(File parentFile, boolean includeLast) {
    if (!includeLast)
      return mkdirs(parentFile.getParentFile(), true);
    if (parentFile.isDirectory()) {
//      Toast.makeText(Parse.getApplicationContext(),
//        parentFile + "  :is_dir: " + parentFile.isDirectory(),
//        Toast.LENGTH_LONG).show();
      return true;
    }
    if (parentFile.exists()) {
//      Toast.makeText(Parse.getApplicationContext(),
//        parentFile + "  :exists: " + parentFile.exists(),
//        Toast.LENGTH_LONG).show();
      return false;
    }
    if (!mkdirs(parentFile.getParentFile(), true)) {
//      Toast.makeText(Parse.getApplicationContext(),
//        parentFile + ".getParentFile().mkdir() failed",
//        Toast.LENGTH_LONG).show();
      return false;
    }
    return parentFile.mkdir();
  }

  public <X extends ParseObject> Date loadData(String text,
                                               Map<String, X> data,
                                               Map<String, ParseObject> extras) {
    try {
      JSONArray array = new JSONArray(text);
      ParseDecoder decoder = ParseDecoder.get();
      ArrayList<X> objects = new ArrayList<>();
      int objCount = array.getInt(1);
      for (int i = 2; i < 2 + objCount; i++) {
        String string = array.getString(i);
        JSONObject jsonObject = new JSONObject(string);
        X parseObject = ParseObject.fromJSON(jsonObject, null, decoder);
        objects.add(parseObject);
      }
      for (X object : objects)
        data.put(object.getObjectId(), object);
      for (int i = 2 + objCount; i < array.length(); i++) {
        String string = array.getString(i);
        JSONObject jsonObject = new JSONObject(string);
        ParseObject parseObject = ParseObject.fromJSON(jsonObject, null, decoder);
        if (parseObject != null)
          extras.put(parseObject.getObjectId(), parseObject);
      }
      return new Date((long) array.get(0));
    } catch (ParseException pe) {
      throw pe;
    } catch (Exception e) {
      throw new ParseException(OTHER_CAUSE, "Exception", e);
    }
  }


  public <T extends ParseObject> JSONObject encode(T parseObject) {
    JSONObject jsonObject = new JSONObject();

    // Serialize the data
    ParseObject.State state = parseObject.getState();
    jsonObject.put("__type", "Object");
    jsonObject.put("__className", parseObject.getClassName());
    jsonObject.put("objectId", parseObject.getObjectId());
    jsonObject.put("createdAt", parseObject.getCreatedAt());
    jsonObject.put("updatedAt", parseObject.getUpdatedAt());


    for (String key : state.availableKeys()) {
      jsonObject.put(key, this.encode(state.get(key)));
    }

    return jsonObject;
  }

  public JSONObject encodeRelatedObject(ParseObject object) {
    String objectId = object.getObjectId();
    JSONObject pointer = new JSONObject();
    pointer.put("__type", "Pointer");
    pointer.put("className", object.getClassName());
    pointer.put("objectId", objectId);
    if (mNext.get(objectId) == null)
      mNext.put(objectId, fullEncode(object));
    return pointer;
  }

  protected JSONObject encodeDate(Date date) {
    JSONObject object = new JSONObject();
    String iso = ParseDateFormat.getInstance().format(date);
    try {
      object.put("__type", "Date");
      object.put("iso", iso);
    } catch (JSONException e) {
      // This should not happen
      throw new RuntimeException(e);
    }

    return object;
  }

  /**
   * Converts REST JSON response to {@link ParseObject.State.Init}.
   * <p>
   * This returns Builder instead of a State since we'll probably want to set some additional
   * properties on it after decoding such as {@link ParseObject.State.Init#isComplete()}, etc.
   *
   * @param builder A {@link ParseObject.State.Init} instance that will have the server JSON
   *                applied
   *                (mutated) to it. This will generally be a instance created by clearing a
   *                mutable
   *                copy of a {@link ParseObject.State} to ensure it's an instance of the correct
   *                subclass: {@code state.newBuilder().clear()}
   * @param json    JSON response in REST format from the server.
   * @param decoder Decoder instance that will be used to decodeObject the server response.
   * @return The same Builder instance passed in after the JSON is applied.
   */
  public <T extends ParseObject.State.Init<?>> T decode(T builder, JSONObject json,
                                                        ParseDecoder decoder) {
    try {
      Iterator<?> keys = json.keys();
      while (keys.hasNext()) {
        String key = (String) keys.next();
        /*
        __type:       Returned by queries and cloud functions to designate body is a ParseObject
        __className:  Used by fromJSON, should be stripped out by the time it gets here...
         */
        if (key.equals("__type") || key.equals(KEY_CLASS_NAME)) {
          continue;
        }
        if (key.equals(KEY_OBJECT_ID)) {
          String newObjectId = json.getString(key);
          builder.objectId(newObjectId);
          continue;
        }
        if (key.equals(KEY_CREATED_AT)) {
          builder.createdAt(ParseDateFormat.getInstance().parse(json.getString(key)));
          continue;
        }
        if (key.equals(KEY_UPDATED_AT)) {
          builder.updatedAt(ParseDateFormat.getInstance().parse(json.getString(key)));
          continue;
        }
        if (key.equals(KEY_ACL)) {
          ParseACL acl = ParseACL.createACLFromJSONObject(json.getJSONObject(key), decoder);
          builder.put(KEY_ACL, acl);
          continue;
        }

        Object value = json.get(key);
        Object decodedObject = decoder.decode(value);
        builder.put(key, decodedObject);
      }

      return builder;
    } catch (JSONException e) {
      throw new RuntimeException(e);
    }
  }

  public <X extends ParseObject> JSONObject fullEncode(final X x) {
    JSONObject json = encode(x);
    JSONObject copy = new JSONObject();
    String className = null;
    try {
      className = json.optString("__className");
      json.remove("__classnName");
    } catch (JSONException ignored) {

    }
    if (className == null)
      className = json.optString("className");
    copy.put("className", className);
    copy.put("objectId", x.getObjectId());
    copy.put("createdAt", format(x.getCreatedAt()));
    copy.put("updatedAt", format(x.getUpdatedAt()));
    for (String key : json.keySet()) {
      if (key.equals("sessionToken"))
        continue;
      if (!copy.has(key)) {
        copy.put(key, json.get(key));
      }
    }
    return copy;

//    JSONObject json = encode(x);;
//    String className = null;
//    try {
//      className = json.optString("__className");
//      json.remove("__classnName");
//    } catch (JSONException ignored) {
//    }
//    if (className == null)
//      className = json.optString("className");
//    json.put("className", className);
//    json.put("objectId", x.getObjectId());
//    json.put("createdAt", format(x.getCreatedAt()));
//    json.put("updatedAt", format(x.getUpdatedAt()));
//    for (String key : json.keySet()) {
//      if (!json.has(key)) {
//        json.put(key, json.get(key));
//      }
//    }
//    return json;
  }


  public <X extends ParseObject>
  void saveData(File file, Map<String, X> data,
                ArrayList<ParseObject> extras,
                Date batch) {
    ParseUser currentUser = ParseUser.getCurrentUser();
    String id = currentUser == null ? "" : currentUser.getObjectId();
    mNext.clear();
    mText.clear();
    for (String key : data.keySet()) {
      if (key.equals(id)) {
        System.out.println("id");
      }
      mText.put(key, fullEncode(data.get(key)));
    }

    FileOutputStream stream = null;
    JSONArray array = new JSONArray();
    array.put(batch.getTime());
    array.put(data.size());
    for (JSONObject json : mText.values()) {
      array.put(json.toString());
    }
    for (JSONObject json : mNext.values()) {
      array.put(json.toString());
    }
    try {
      mkdirs(file, false);
      stream = new FileOutputStream(file);
      String arrayStr = array.toString(2);
      stream.write(arrayStr.getBytes());
    } catch (RuntimeException re) {
      throw re;
    } catch (Exception e) {
      throw new RuntimeException("Failed to write " + file, e);
    } finally {
      ParseIOUtils.closeQuietly(stream);
    }

  }
}


//  public <X extends ParseObject> void zipDataSet(File file, Iterable<X> objects) {
//    try {
//      Map<String, String> env = new HashMap<>();
//      env.put("create", "true");
//      // locate file system by using the syntax
//      // defined in java.net.JarURLConnection
//      Path path = mSaveFs.getPath()
//        //mkdirs(file, false);
////      URI uri = URI.create("jar:file:/" + file);
////      mSaveFs = FileSystems.newFileSystem(uri, env);
//
//    } catch (IOException e) {
//      e.printStackTrace();
//    }
//import java.util.*;
//import java.net.URI;
//import java.nio.file.Path;
//import java.nio.file.*;
//
//    public class ZipFSPUser {
//      public static void main(String [] args) throws Throwable {
//        Map<String, String> env = new HashMap<>();
//        env.put("create", "true");
//        // locate file system by using the syntax
//        // defined in java.net.JarURLConnection
//        URI uri = URI.create("jar:file:/codeSamples/zipfs/zipfstest.zip");
//
//        try (FileSystem zipfs = FileSystems.newFileSystem(uri, env)) {
//          Path externalTxtFile = Paths.get("/codeSamples/zipfs/SomeTextFile.txt");
//          Path pathInZipfile = zipfs.getPath("/SomeTextFile.txt");
//          // copy a file into the zip file
//          Files.copy( externalTxtFile,pathInZipfile,
//            StandardCopyOption.REPLACE_EXISTING );
//        }
//      }
//    }

//
//    Set<String> keys = coded.keySet();
//    while(objects.size()){
//      for(ParseObject object : objects) {
//        String objectId = object.getObjectId();
//        if(!keys.contains(objectId)) {
//          coded.put(objectId, coder.encode(object).toString());
//        }
//      }
//      for(ParseObject object : coder.getTodo().values()){
//        if(!keys.contains(object.getObjectId()))
//
//      }
//    }

//    try (FileSystem zipfs = FileSystems.newFileSystem(uri, env)) {
//      Path externalTxtFile = Paths.get("/codeSamples/zipfs/SomeTextFile.txt");
//      Path pathInZipfile = zipfs.getPath("/SomeTextFile.txt");
// copy a file into the zip file
//      Files.copy(externalTxtFile, pathInZipfile,
//        StandardCopyOption.REPLACE_EXISTING);
//    } catch (RuntimeException e) {
//      throw e;
//    } catch (Exception e) {
//      throw new RuntimeException("Failed to create zip file", e);
//    }
//  }



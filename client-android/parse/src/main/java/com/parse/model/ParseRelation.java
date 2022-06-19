/*
 * Copyright (c) 2015-present, Parse, LLC.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

package com.parse.model;

import android.os.Parcel;
import android.os.Parcelable;
import com.parse.ParseQuery;
import com.parse.codec.ParseDecoder;
import com.parse.codec.ParseEncoder;
import com.parse.operation.ParseRelationOperation;
import com.parse.codec.ParseObjectParcelDecoder;
import com.parse.codec.ParseObjectParcelEncoder;
import com.parse.codec.ParseParcelDecoder;
import com.parse.codec.ParseParcelEncoder;
import cell411.json.JSONArray;
import cell411.json.JSONException;
import cell411.json.JSONObject;

import java.lang.ref.WeakReference;
import java.util.Collections;
import java.util.HashSet;
import java.util.Set;

/**
 * A class that is used to access all of the children of a many-to-many relationship. Each instance
 * of Parse.Relation is associated with a particular parent object and key.
 */
public class ParseRelation<T extends ParseObject> implements Parcelable {
  public final static Creator<ParseRelation> CREATOR = new Creator<ParseRelation>() {
    @Override
    public ParseRelation createFromParcel(Parcel source) {
      return new ParseRelation(source, new ParseObjectParcelDecoder());
    }

    @Override
    public ParseRelation[] newArray(int size) {
      return new ParseRelation[size];
    }
  };
  private final Object mutex = new Object();
  // For offline caching, we keep track of every object we've known to be in the relation.
  private final Set<ParseObject> knownObjects = new HashSet<>();
  // The owning object of this ParseRelation.
  private WeakReference<ParseObject> parent;
  // The object Id of the parent.
  private String parentObjectId;
  // The classname of the parent to retrieve the parent ParseObject in case the parent is GC'ed.
  private String parentClassName;
  // The key of the relation in the parent object.
  private String key;
  // The className of the target objects.
  private String targetClass;

  public ParseRelation(ParseObject parent, String key) {
    this.parent = new WeakReference<>(parent);
    this.parentObjectId = parent.getObjectId();
    this.parentClassName = parent.getClassName();
    this.key = key;
    this.targetClass = null;
  }

  /* package */
  public ParseRelation(String targetClass) {
    this.parent = null;
    this.parentObjectId = null;
    this.parentClassName = null;
    this.key = null;
    this.targetClass = targetClass;
  }

  /**
   * Parses a relation from JSON with the given decoder.
   */
  /* package */
  public ParseRelation(JSONObject jsonObject, ParseDecoder decoder) {
    this.parent = null;
    this.parentObjectId = null;
    this.parentClassName = null;
    this.key = null;
    this.targetClass = jsonObject.optString("className", null);
    JSONArray objectsArray = jsonObject.optJSONArray("objects");
    if (objectsArray != null) {
      for (int i = 0; i < objectsArray.length(); ++i) {
        knownObjects.add((ParseObject) decoder.decode(objectsArray.optJSONObject(i)));
      }
    }
  }

  /**
   * Creates a ParseRelation from a Parcel with the given decoder.
   */
  public ParseRelation(Parcel source, ParseParcelDecoder decoder) {
    if (source.readByte() == 1)
      this.key = source.readString();
    if (source.readByte() == 1)
      this.targetClass = source.readString();
    if (source.readByte() == 1)
      this.parentClassName = source.readString();
    if (source.readByte() == 1)
      this.parentObjectId = source.readString();
    if (source.readByte() == 1)
      this.parent = new WeakReference<>((ParseObject) decoder.decode(source));
    int size = source.readInt();
    for (int i = 0; i < size; i++) {
      knownObjects.add((ParseObject) decoder.decode(source));
    }
  }

  /* package */
  public void ensureParentAndKey(ParseObject someParent, String someKey) {
    synchronized (mutex) {
      if (parent == null) {
        parent = new WeakReference<>(someParent);
        parentObjectId = someParent.getObjectId();
        parentClassName = someParent.getClassName();
      }
      if (key == null) {
        key = someKey;
      }
      if (parent.get() != someParent) {
        throw new IllegalStateException("Internal error. One ParseRelation retrieved from two different ParseObjects.");
      }
      if (!key.equals(someKey)) {
        throw new IllegalStateException("Internal error. One ParseRelation retrieved from two different keys.");
      }
    }
  }

  /**
   * Adds an object to this relation.
   *
   * @param object The object to add to this relation.
   */
  public void add(T object) {
    synchronized (mutex) {
      ParseRelationOperation<T> operation = new ParseRelationOperation<>(Collections.singleton(object), null);
      targetClass = operation.getTargetClass();
      getParent().performOperation(key, operation);

      knownObjects.add(object);
    }
  }

  /**
   * Removes an object from this relation.
   *
   * @param object The object to remove from this relation.
   */
  public void remove(T object) {
    synchronized (mutex) {
      ParseRelationOperation<T> operation = new ParseRelationOperation<>(null, Collections.singleton(object));
      targetClass = operation.getTargetClass();
      getParent().performOperation(key, operation);

      knownObjects.remove(object);
    }
  }

  /**
   * Gets a query that can be used to query the objects in this relation.
   *
   * @return A ParseQuery that restricts the results to objects in this relations.
   */
  public ParseQuery<T> getQuery() {
    synchronized (mutex) {
      ParseQuery.State.Builder<T> builder;
      if (targetClass == null) {
        builder = new ParseQuery.State.Builder<T>(parentClassName).redirectClassNameForKey(key);
      } else {
        builder = new ParseQuery.State.Builder<>(targetClass);
      }
      builder.whereRelatedTo(getParent(), key);
      return new ParseQuery<>(builder);
    }
  }

  /* package */
  public JSONObject encodeToJSON(ParseEncoder objectEncoder) throws JSONException {
    synchronized (mutex) {
      JSONObject relation = new JSONObject();
      relation.put("__type", "Relation");
      relation.put("className", targetClass);
      JSONArray knownObjectsArray = new JSONArray();
      for (ParseObject knownObject : knownObjects) {
        try {
          JSONObject value = objectEncoder.encodeRelatedObject(knownObject);
          knownObjectsArray.put(value);
        } catch (Exception e) {
          System.out.println("Failed to encode object: "+e);
        }
      }
      relation.put("objects", knownObjectsArray);
      return relation;
    }
  }

  /* package */
  public String getTargetClass() {
    synchronized (mutex) {
      return targetClass;
    }
  }

  /* package */ void setTargetClass(String className) {
    synchronized (mutex) {
      targetClass = className;
    }
  }

  /**
   * Adds an object that is known to be in the relation. This is used for offline caching.
   */
  /* package */
  public void addKnownObject(ParseObject object) {
    synchronized (mutex) {
      knownObjects.add(object);
    }
  }

  /**
   * Removes an object that is known to not be in the relation. This is used for offline caching.
   */
  /* package */
  public void removeKnownObject(ParseObject object) {
    synchronized (mutex) {
      knownObjects.remove(object);
    }
  }

  /**
   * Returns true iff this object was ever known to be in the relation. This is used for offline
   * caching.
   */
  /* package */
  public boolean hasKnownObject(ParseObject object) {
    synchronized (mutex) {
      return knownObjects.contains(object);
    }
  }

  /* package for tests */ ParseObject getParent() {
    if (parent == null) {
      return null;
    }
    if (parent.get() == null) {
      return ParseObject.createWithoutData(parentClassName, parentObjectId);
    }
    return parent.get();
  }

  /* package for tests */ String getKey() {
    return key;
  }

  /* package for tests */ Set<ParseObject> getKnownObjects() {
    return knownObjects;
  }

  @Override
  public int describeContents() {
    return 0;
  }

  @Override
  public void writeToParcel(Parcel dest, int flags) {
    writeToParcel(dest, new ParseObjectParcelEncoder());
  }

  public void writeToParcel(Parcel dest, ParseParcelEncoder encoder) {
    synchronized (mutex) {
      // Fields are all nullable.
      dest.writeByte(key != null ? (byte) 1 : 0);
      if (key != null)
        dest.writeString(key);
      dest.writeByte(targetClass != null ? (byte) 1 : 0);
      if (targetClass != null)
        dest.writeString(targetClass);
      dest.writeByte(parentClassName != null ? (byte) 1 : 0);
      if (parentClassName != null)
        dest.writeString(parentClassName);
      dest.writeByte(parentObjectId != null ? (byte) 1 : 0);
      if (parentObjectId != null)
        dest.writeString(parentObjectId);
      boolean has = parent != null && parent.get() != null;
      dest.writeByte(has ? (byte) 1 : 0);
      if (has)
        encoder.encode(parent.get(), dest);
      dest.writeInt(knownObjects.size());
      for (ParseObject obj : knownObjects) {
        encoder.encode(obj, dest);
      }
    }
  }
}


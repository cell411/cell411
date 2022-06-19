/*
 * Copyright (c) 2015-present, Parse, LLC.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

package com.parse.controller;

import com.parse.Parse;
import com.parse.codec.ParseUserCurrentCoder;
import com.parse.model.ParseInstallation;
import com.parse.model.ParseUser;
import com.parse.offline.FileObjectStore;
import com.parse.codec.ParseObjectCurrentCoder;
import com.parse.rest.ParseHttpClient;

import java.io.File;
import java.util.concurrent.atomic.AtomicReference;

@SuppressWarnings("unused")
public class ParseCorePlugins {

  /* package */ public static final String FILENAME_CURRENT_USER = "currentUser";
  /* package */ public static final String PIN_CURRENT_USER = "_currentUser";
  /* package */ static final String FILENAME_CURRENT_INSTALLATION = "currentInstallation";
  /* package */ static final String PIN_CURRENT_INSTALLATION = "_currentInstallation";
  /* package */ static final String FILENAME_CURRENT_CONFIG = "currentConfig";
  private static final ParseCorePlugins INSTANCE = new ParseCorePlugins();
  private final AtomicReference<ParseObjectController> objectController = new AtomicReference<>();
  private final AtomicReference<ParseUserController> userController = new AtomicReference<>();
  private final AtomicReference<ParseSessionController> sessionController = new AtomicReference<>();
  // TODO(mengyan): Inject into ParseUserInstanceController
  private final AtomicReference<ParseCurrentUserController> currentUserController = new AtomicReference<>();
  // TODO(mengyan): Inject into ParseInstallationInstanceController
  private final AtomicReference<ParseCurrentInstallationController> currentInstallationController
      = new AtomicReference<>();
  private final AtomicReference<ParseAuthenticationManager> authenticationController = new AtomicReference<>();
  private final AtomicReference<ParseQueryController> queryController = new AtomicReference<>();
  private final AtomicReference<ParseFileController> fileController = new AtomicReference<>();
  private final AtomicReference<ParseCloudCodeController> cloudCodeController = new AtomicReference<>();
  private final AtomicReference<ParseConfigController> configController = new AtomicReference<>();
//  private final AtomicReference<ParsePushController> pushController = new AtomicReference<>();
//  private final AtomicReference<ParsePushChannelsController> pushChannelsController = new AtomicReference<>();
  private final AtomicReference<ParseDefaultACLController> defaultACLController = new AtomicReference<>();
  private final AtomicReference<LocalIdManager> localIdManager = new AtomicReference<>();
  private final AtomicReference<ParseObjectSubclassingController> subclassingController = new AtomicReference<>();
  private ParseCorePlugins() {
    // do nothing
  }

  public static ParseCorePlugins getInstance() {
    return INSTANCE;
  }

  /* package for tests */
  public void reset() {
    objectController.set(null);
    userController.set(null);
    sessionController.set(null);

    currentUserController.set(null);
    currentInstallationController.set(null);

    authenticationController.set(null);

    queryController.set(null);
    fileController.set(null);
    cloudCodeController.set(null);
    configController.set(null);
//    pushController.set(null);
//    pushChannelsController.set(null);
    defaultACLController.set(null);

    localIdManager.set(null);
  }

  public ParseObjectController getObjectController() {
    if (objectController.get() == null) {
      // TODO(grantland): Do not rely on Parse global
      objectController.compareAndSet(null, new NetworkObjectController(ParsePlugins.get().restClient()));
    }
    return objectController.get();
  }

  @SuppressWarnings("unused")
  public void registerObjectController(ParseObjectController controller) {
    if (!objectController.compareAndSet(null, controller)) {
      throw new IllegalStateException("Another object controller was already registered: " + objectController.get());
    }
  }

  public ParseUserController getUserController() {
    if (userController.get() == null) {
      // TODO(grantland): Do not rely on Parse global
      userController.compareAndSet(null, new NetworkUserController(ParsePlugins.get().restClient()));
    }
    return userController.get();
  }

  public void registerUserController(ParseUserController controller) {
    if (!userController.compareAndSet(null, controller)) {
      throw new IllegalStateException("Another user controller was already registered: " + userController.get());
    }
  }

  public ParseSessionController getSessionController() {
    if (sessionController.get() == null) {
      // TODO(grantland): Do not rely on Parse global
      sessionController.compareAndSet(null, new NetworkSessionController(ParsePlugins.get().restClient()));
    }
    return sessionController.get();
  }

  public void registerSessionController(ParseSessionController controller) {
    if (!sessionController.compareAndSet(null, controller)) {
      throw new IllegalStateException("Another session controller was already registered: " + sessionController.get());
    }
  }

  public ParseCurrentUserController getCurrentUserController() {
    if (currentUserController.get() == null) {
      File file = new File(getParseDir(), FILENAME_CURRENT_USER);

      FileObjectStore<ParseUser> fileStore = new FileObjectStore<>(ParseUser.class, file, ParseUserCurrentCoder.get());
      ParseCurrentUserController controller = new CachedCurrentUserController(fileStore);
      currentUserController.compareAndSet(null, controller);
    }
    return currentUserController.get();
  }
  private File getParseDir() {
    return Parse.getParseDir();
  }

  public void registerCurrentUserController(ParseCurrentUserController controller) {
    if (!currentUserController.compareAndSet(null, controller)) {
      throw new IllegalStateException(
          "Another currentUser controller was already registered: " + currentUserController.get());
    }
  }

  public ParseQueryController getQueryController() {
    if (queryController.get() == null) {
      NetworkQueryController networkController = new NetworkQueryController(ParsePlugins.get().restClient());
      ParseQueryController controller;
      // TODO(grantland): Do not rely on Parse global
      if (Parse.isLocalDatastoreEnabled()) {
        controller = new OfflineQueryController(Parse.getLocalDatastore(), networkController);
      } else {
        controller = new CacheQueryController(networkController);
      }
      queryController.compareAndSet(null, controller);
    }
    return queryController.get();
  }

  public void registerQueryController(ParseQueryController controller) {
    if (!queryController.compareAndSet(null, controller)) {
      throw new IllegalStateException("Another query controller was already registered: " + queryController.get());
    }
  }

  public ParseFileController getFileController() {
    if (fileController.get() == null) {
      // TODO(grantland): Do not rely on Parse global
      fileController.compareAndSet(null, new ParseFileController(ParsePlugins.get().restClient(),
                                                                 Parse.getParseCacheDir("files")));
    }
    return fileController.get();
  }

  public void registerFileController(ParseFileController controller) {
    if (!fileController.compareAndSet(null, controller)) {
      throw new IllegalStateException("Another file controller was already registered: " + fileController.get());
    }
  }




  public ParseCloudCodeController getCloudCodeController() {
    if (cloudCodeController.get() == null) {
      ParsePlugins parsePlugins = ParsePlugins.get();
      ParseHttpClient restClient = parsePlugins.restClient();
      cloudCodeController.compareAndSet(null, new ParseCloudCodeController(restClient));
    }
    return cloudCodeController.get();
  }

  public void registerCloudCodeController(ParseCloudCodeController controller) {
    if (!cloudCodeController.compareAndSet(null, controller)) {
      throw new IllegalStateException(
          "Another cloud code controller was already registered: " + cloudCodeController.get());
    }
  }

  public ParseConfigController getConfigController() {
    if (configController.get() == null) {
      // TODO(mengyan): Do not rely on Parse global
      File file = new File(ParsePlugins.get().getParseDir(), FILENAME_CURRENT_CONFIG);
      ParseCurrentConfigController currentConfigController = new ParseCurrentConfigController(file);
      configController.compareAndSet(null, new ParseConfigController(ParsePlugins.get().restClient(),
                                                                     currentConfigController));
    }
    return configController.get();
  }

  public void registerConfigController(ParseConfigController controller) {
    if (!configController.compareAndSet(null, controller)) {
      throw new IllegalStateException("Another config controller was already registered: " + configController.get());
    }
  }

//  public ParsePushController getPushController() {
//    if (pushController.get() == null) {
//      pushController.compareAndSet(null, new ParsePushController(ParsePlugins.get().restClient()));
//    }
//    return pushController.get();
//  }
//
//  public void registerPushController(ParsePushController controller) {
//    if (!pushController.compareAndSet(null, controller)) {
//      throw new IllegalStateException("Another push controller was already registered: " + pushController.get());
//    }
//  }
//
//  public ParsePushChannelsController getPushChannelsController() {
//    if (pushChannelsController.get() == null) {
//      pushChannelsController.compareAndSet(null, new ParsePushChannelsController());
//    }
//    return pushChannelsController.get();
//  }
//
//  public void registerPushChannelsController(ParsePushChannelsController controller) {
//    if (!pushChannelsController.compareAndSet(null, controller)) {
//      throw new IllegalStateException(
//          "Another pushChannels controller was already registered: " + pushChannelsController.get());
//    }
//  }

  public ParseCurrentInstallationController getCurrentInstallationController() {
    if (currentInstallationController.get() == null) {
      File file = new File(ParsePlugins.get().getParseDir(), FILENAME_CURRENT_INSTALLATION);
      FileObjectStore<ParseInstallation> fileStore = new FileObjectStore<>(ParseInstallation.class, file,
                                                                           ParseObjectCurrentCoder.get());
      CachedCurrentInstallationController controller = new CachedCurrentInstallationController(fileStore, ParsePlugins.get()
                                                                                                                  .installationId());
      currentInstallationController.compareAndSet(null, controller);
    }
    return currentInstallationController.get();
  }

  public void registerCurrentInstallationController(ParseCurrentInstallationController controller) {
    if (!currentInstallationController.compareAndSet(null, controller)) {
      throw new IllegalStateException(
          "Another currentInstallation controller was already registered: " + currentInstallationController.get());
    }
  }

  public ParseAuthenticationManager getAuthenticationManager() {
    if (authenticationController.get() == null) {
      ParseAuthenticationManager controller = new ParseAuthenticationManager(getCurrentUserController());
      authenticationController.compareAndSet(null, controller);
    }
    return authenticationController.get();
  }

  public void registerAuthenticationManager(ParseAuthenticationManager manager) {
    if (!authenticationController.compareAndSet(null, manager)) {
      throw new IllegalStateException(
          "Another authentication manager was already registered: " + authenticationController.get());
    }
  }

  public ParseDefaultACLController getDefaultACLController() {
    if (defaultACLController.get() == null) {
      ParseDefaultACLController controller = new ParseDefaultACLController();
      defaultACLController.compareAndSet(null, controller);
    }
    return defaultACLController.get();
  }

  public void registerDefaultACLController(ParseDefaultACLController controller) {
    if (!defaultACLController.compareAndSet(null, controller)) {
      throw new IllegalStateException(
          "Another defaultACL controller was already registered: " + defaultACLController.get());
    }
  }

  public LocalIdManager getLocalIdManager() {
    if (localIdManager.get() == null) {
      LocalIdManager manager = new LocalIdManager(getParseDir());
      localIdManager.compareAndSet(null, manager);
    }
    return localIdManager.get();
  }

  public void registerLocalIdManager(LocalIdManager manager) {
    if (!localIdManager.compareAndSet(null, manager)) {
      throw new IllegalStateException("Another localId manager was already registered: " + localIdManager.get());
    }
  }

  public ParseObjectSubclassingController getSubclassingController() {
    if (subclassingController.get() == null) {
      ParseObjectSubclassingController controller = new ParseObjectSubclassingController();
      subclassingController.compareAndSet(null, controller);
    }
    return subclassingController.get();
  }

  public void registerSubclassingController(ParseObjectSubclassingController controller) {
    if (!subclassingController.compareAndSet(null, controller)) {
      throw new IllegalStateException(
          "Another subclassing controller was already registered: " + subclassingController.get());
    }
  }
}



package cell411.base;

import android.view.View;

import androidx.annotation.Nullable;
import androidx.annotation.StringRes;

import java.util.ArrayList;

import cell411.logic.LiveQueryService;
import cell411.logic.RelationWatcher;
import cell411.parse.util.XParse;
import cell411.services.DataService;
import cell411.services.LocationService;
import cell411.utils.CarefulHandler;
import cell411.utils.ExceptionHandler;
import cell411.utils.Timer;

public interface BaseContext extends ExceptionHandler {
  BaseContext app = new BaseContext() {
  };
  ArrayList<BaseContext> smInstances = new ArrayList<>();

  default Timer getTimer() {
    return BaseApp.get().getTimer();
  }

  default void init() {
    smInstances.add(this);
  }

  @Nullable
  default BaseActivity activity() {
    return BaseApp.get().getCurrentActivity();
  }



  default RelationWatcher relWatcher() {
    return lqs().getRelationWatcher();
  }

  default void onUI(Runnable runnable, long delay) {
    onUI().postDelayed(runnable, delay);
  }

  default void onUI(Runnable runnable) {
    onUI().post(runnable);
  }

  @SuppressWarnings("unused")
  default void refresh(View ignoredView) {
    refresh();
  }

  default String getString(@StringRes int resId) {
    return require(activity()).getString(resId);
  }

  default String getString(@StringRes int resId, Object... objs) {
    return require(activity()).getString(resId, objs);
  }

  default <X> X require(X object) {
    if (object == null)
      throw new NullPointerException("Required object was null");
    return object;
  }

  default void refresh() {
    app().refresh();
  }

  default void hideSoftKeyboard() {
    BaseActivity activity = activity();
    if (activity != null)
      activity.hideSoftKeyboard();
  }

  default void showSoftKeyboard() {
    BaseActivity activity = activity();
    if (activity != null)
      activity.showSoftKeyboard();
  }


  @Override
  default BaseApp app() {
    return BaseApp.get();
  }


  default DataService ds() {
    return app().ds();
  }

  default LiveQueryService lqs() {
    return app().lqs();
  }

  default LocationService loc() {
    return app().loc();
  }

  default XParse xpr() {
    return app().xpr();
  }

  default void onDS(Runnable runnable) {
    onDS(runnable, 0);
  }

  default void onDS(Runnable runnable, long delay) {
    if (ds() == null) {
      onUI(() -> {
        onDS(runnable, 100);
      }, delay);
      return;
    }
    ds().onDS(runnable, delay);
  }

  default CarefulHandler onUI(){
    return app().getHandler();
  }
}

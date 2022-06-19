package cell411.services;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;

import cell411.base.BaseApp;
import cell411.base.BaseService;
import cell411.logic.LiveQueryService;
import cell411.utils.Reflect;
import cell411.utils.XLog;

public class BootCompletedReceiver extends BroadcastReceiver {
    private static final String TAG = Reflect.getTag();
    static {
        XLog.i(TAG, "loading class");
    }
    BaseService.Conn<DataService> mDataServiceConn;
    BaseService.Conn<LocationService> mLocationServiceConn;
    BaseService.Conn<LiveQueryService> mLiveQueryServiceConn;

    public BootCompletedReceiver() {
        XLog.i(TAG, "creating instance");
    }
    public void finalize() throws Throwable {
        XLog.i(TAG, "finalizing instance");
        super.finalize();;
    }
    @Override
    public void onReceive(Context c, Intent intent) {
        BaseApp.get().onBootComplete();
    }
}

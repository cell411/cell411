package cell411;

import static android.content.Intent.FLAG_ACTIVITY_NEW_TASK;
import static android.content.Intent.FLAG_ACTIVITY_SINGLE_TOP;
import static androidx.core.app.NotificationManagerCompat.IMPORTANCE_DEFAULT;
import static androidx.core.app.NotificationManagerCompat.IMPORTANCE_MAX;

import android.app.Notification;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.graphics.Bitmap;
import android.media.AudioAttributes;
import android.net.Uri;

import androidx.annotation.NonNull;
import androidx.core.app.NotificationChannelCompat;
import androidx.core.app.NotificationChannelCompat.Builder;
import androidx.core.app.NotificationCompat;
import androidx.core.app.NotificationManagerCompat;

import com.parse.livequery.SubscriptionHandler;
import com.safearx.cell411.R;

import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Set;
import java.util.StringJoiner;

import cell411.base.BaseActivity;
import cell411.base.BaseApp;
import cell411.base.BaseContext;
import cell411.enums.ProblemType;
import cell411.logic.AlertWatcher;
import cell411.logic.LQListener;
import cell411.logic.LiveQueryService;
import cell411.logic.RequestWatcher;
import cell411.logic.Watcher;
import cell411.parse.XAlert;
import cell411.parse.XChatMsg;
import cell411.parse.XChatRoom;
import cell411.parse.XPublicCell;
import cell411.parse.XRequest;
import cell411.parse.XUser;
import cell411.ui.alerts.ProblemTypeInfo;
import cell411.utils.ExceptionHandler;
import cell411.utils.ImageUtils;
import cell411.utils.NetUtils;
import cell411.utils.PrintString;
import cell411.utils.Reflect;
import cell411.utils.Util;
import cell411.utils.XLog;

public class NotificationCenter implements BaseContext {
    static private final String TAG = Reflect.getTag();

    private static final String REQUEST_CHANNEL = "REQUEST_CHANNEL";
    private static final String ALERT_CHANNEL = "ALERT_CHANNEL";
    private static final String CHAT_CHANNEL = "CHAT_CHANNEL";

    static {
        XLog.i(TAG, "loading Class");
    }


    private final HashMap<String, ChData> mChData = new HashMap<>();
    private final NotificationManagerCompat mManager;
    private final LQListener<XRequest> mRequestListener = new LQListener<XRequest>() {
        @Override
        public void onEvents(final Watcher<XRequest> watcher, final SubscriptionHandler.Event event,
                             final XRequest object) {
            sendRequestNotification(object);
        }
        public void change(Watcher<XRequest> watcher){

        }
    };
    LQListener<XAlert> mAlertListener = new LQListener<XAlert>() {
        public void onEvents(final Watcher<XAlert> watcher, final SubscriptionHandler.Event event,
                             final XAlert object) {
            sendAlertNotification(object);
        }
        public void change(Watcher<XAlert> watcher){

        }
    };
    private AudioAttributes mAudioAttributes;

    {
        mManager = NotificationManagerCompat.from(BaseApp.get());
        HashMap<String,Uri> tones = app().getTones();
        ChData data;

        // ALERT_CHANNEL
        data = new ChData(ALERT_CHANNEL);
        data.mRingtone = NetUtils.toUri(tones.get("uri0"));
        NotificationChannelCompat.Builder builder;
        builder = new Builder(ALERT_CHANNEL, IMPORTANCE_MAX);
        builder.setName("Emergency Alerts");
        builder.setDescription("The channel for emergencies");
        //builder.setGroup(null);
        builder.setShowBadge(true);
        builder.setSound(data.mRingtone, audioAttributes());
        //builder.setLightsEnabled(null);
        //builder.setLightColor(null);
        builder.setVibrationEnabled(true);
        //builder.setVibrationPattern(null);
        //builder.setConversationId(null);
        data.mChannel = builder.build();
        mManager.createNotificationChannel(data.mChannel);


        // REQUEST_CHANNEL
        data = new ChData(REQUEST_CHANNEL);
        data.mRingtone = NetUtils.toUri(tones.get("uri1"));
        builder = new Builder(REQUEST_CHANNEL, IMPORTANCE_DEFAULT);
        builder.setName("Requests");
        builder.setDescription("A channel for friend and cell join requests");
        //builder.setGroup(null);
        builder.setShowBadge(true);
        builder.setSound(data.mRingtone, audioAttributes());
        //builder.setLightsEnabled(null);
        //builder.setLightColor(null);
        //builder.setVibrationEnabled(null);
        //builder.setVibrationPattern(null);
        //builder.setConversationId(null);
        data.mChannel = builder.build();
        mManager.createNotificationChannel(data.mChannel);

        // CHAT_CHANNEL
        data = new ChData(CHAT_CHANNEL);
        data.mRingtone = NetUtils.toUri(tones.get("uri2"));

        builder = new Builder(CHAT_CHANNEL, IMPORTANCE_DEFAULT);
        builder.setName("Chat Messages");
        builder.setDescription("The channel for chats");
        //builder.setGroup(null);
        builder.setShowBadge(true);
        builder.setSound(data.mRingtone, audioAttributes());
        //builder.setLightsEnabled(null);
        //builder.setLightColor(null);
        builder.setVibrationEnabled(true);
        //builder.setVibrationPattern(null);
        //builder.setConversationId(null);
        data.mChannel = builder.build();

        mManager.createNotificationChannel(data.mChannel);
    }

    public NotificationCenter() {
        LiveQueryService lqs = app().lqs();
        if(lqs==null)
            return;
        AlertWatcher alertWatcher = lqs.getAlertWatcher();
        if(alertWatcher!=null)
            alertWatcher.addListener(mAlertListener);
        RequestWatcher requestWatcher = lqs.getRequestWatcher();
        if(requestWatcher!=null)
            requestWatcher.addListener(mRequestListener);
    }

    public void restore() {
        ChData data;
        HashMap<String,Uri> tones = app().getTones();
        data = mChData.get(ALERT_CHANNEL);
        assert data != null;
        data.mRingtone = NetUtils.toUri(tones.get("uri0"));

        data = mChData.get(REQUEST_CHANNEL);
        assert data!=null;
        data.mRingtone = NetUtils.toUri(tones.get("uri1"));

        data = mChData.get(CHAT_CHANNEL);
        assert data!=null;
        data.mRingtone = NetUtils.toUri(tones.get("uri2"));
    }

    AudioAttributes audioAttributes() {
        if (mAudioAttributes == null) {
            mAudioAttributes = new AudioAttributes.Builder()
                    .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                    .setUsage(AudioAttributes.USAGE_ALARM)
                    .build();
        }
        return mAudioAttributes;
    }

    public void sendRequestNotification(XRequest request) {
        ChData chData = mChData.get(REQUEST_CHANNEL);
        assert chData != null;
        NotificationChannelCompat nc = chData.mChannel;
        NotificationCompat.Builder builder;
        Cell411 context = Cell411.get();
        builder = new NotificationCompat.Builder(context,
                nc.getId());
        builder.setSound(chData.mRingtone);
        Bitmap bitmap = ImageUtils.getLargeIconBitmap(R.mipmap.appicon);
        builder.setSmallIcon(cell411.services.R.mipmap.appicon);
        builder.setOngoing(true);
        builder.setPriority(NotificationCompat.PRIORITY_HIGH);
        Date createdAt = request.getCreatedAt();
        if (createdAt != null) {
            builder.setShowWhen(true);
            builder.setWhen(createdAt.getTime());
        }
        String title = "Request received";
        Counter counter = chData.mCounter;

        int notificationid =
                counter == null ? (int) (Math.random() * Integer.MAX_VALUE) : counter.next();
        builder.setContentTitle(title + "  #" + notificationid);
        builder.setChannelId(nc.getId());
        builder.setLargeIcon(bitmap);

        PrintString ps = new PrintString();
        ps.print("You have received a new ");
        XPublicCell cell = request.getCell();
        ps.print(cell != null ? "cell" : "friend");
        ps.print(" request from ");
        XUser owner = request.getOwner();
        ps.print(owner == null ? "<null>" : owner.getName());
        if (cell != null) {
            ps.print(" he wants to join cell '");
            ps.p(cell.getName());
            ps.p("'");
        }
        ps.p(".");
        String message = ps.toString();
        builder.setContentText(message);
        builder.setStyle(new NotificationCompat.BigTextStyle().bigText(message));

        PendingIntent pendingIntent =
                PendingIntent.getActivity(context, 0,
                        createIntent(context), PendingIntent.FLAG_IMMUTABLE);

        if (pendingIntent != null)
            builder.setContentIntent(pendingIntent);

        Notification notification = builder.build();
        mManager.notify(notificationid, notification);

    }

    @NonNull
    private Intent createIntent(final Cell411 context) {
        BaseActivity currentActivity = context.getCurrentActivity();
        Context intentContext = currentActivity == null ? context : currentActivity;
        Intent notificationIntent = new Intent(intentContext, MainActivity.class);
        notificationIntent.addFlags(FLAG_ACTIVITY_NEW_TASK);
        notificationIntent.addFlags(FLAG_ACTIVITY_SINGLE_TOP);
        notificationIntent.putExtra("Extra1", "extra1");
        notificationIntent.putExtra("Extra2", System.currentTimeMillis());
        return notificationIntent;
    }

    public void sendAlertNotification(XAlert alert) {
        ChData chData = mChData.get(ALERT_CHANNEL);
        assert chData != null;
        NotificationChannelCompat nc = chData.mChannel;
        NotificationCompat.Builder builder;
        Cell411 context = Cell411.get();
        builder = new NotificationCompat.Builder(context,
                nc.getId());
        builder.setSound(chData.mRingtone);
        Bitmap bitmap = ImageUtils.getLargeIconBitmap(R.mipmap.appicon);
        builder.setSmallIcon(cell411.services.R.mipmap.appicon);
        builder.setOngoing(true);
        builder.setPriority(NotificationCompat.PRIORITY_HIGH);
        Date createdAt = alert.getCreatedAt();
        if (createdAt != null) {
            builder.setShowWhen(true);
            builder.setWhen(createdAt.getTime());
        }
        String title = "Request received";
        Counter counter = chData.mCounter;

        int notificationid =
                counter == null ? (int) (Math.random() * Integer.MAX_VALUE) : counter.next();
        builder.setContentTitle(title + "  #" + notificationid);
        builder.setChannelId(nc.getId());
        builder.setLargeIcon(bitmap);

        PrintString ps = new PrintString();
        XUser owner = alert.getOwner();
        ProblemTypeInfo pti = ProblemTypeInfo.fromString(alert.getString("problemType"));
        alert.setProblemType(pti.getType());
        ProblemType problemType = alert.getProblemType();
        ps.print("You have received a new ");
        ps.print(problemType);
        ps.print(" alert from ");
        ps.print(owner == null ? "<null>" : owner.getName());
        ps.p(".");
        String message = ps.toString();
        builder.setContentText(message);
        builder.setStyle(new NotificationCompat.BigTextStyle().bigText(message));

        PendingIntent pendingIntent =
                PendingIntent.getActivity(context, 0,
                        createIntent(context), PendingIntent.FLAG_IMMUTABLE);

        if (pendingIntent != null)
            builder.setContentIntent(pendingIntent);

        Notification notification = builder.build();
        mManager.notify(notificationid, notification);
    }

    public void sendChatNotification(XChatMsg chatMsg) {
        ChData chData = mChData.get(CHAT_CHANNEL);
        assert chData != null;
        NotificationChannelCompat nc = chData.mChannel;
        NotificationCompat.Builder builder;
        Cell411 context = Cell411.get();
        builder = new NotificationCompat.Builder(context,
                nc.getId());
        builder.setSound(chData.mRingtone);

        Bitmap bitmap = ImageUtils.getLargeIconBitmap(R.mipmap.appicon);
        builder.setSmallIcon(cell411.services.R.mipmap.appicon);
        builder.setOngoing(true);
        builder.setPriority(NotificationCompat.PRIORITY_HIGH);
        Date createdAt = chatMsg.getCreatedAt();
        if (createdAt != null) {
            builder.setShowWhen(true);
            builder.setWhen(createdAt.getTime());
        }
        String title = "Request received";
        Counter counter = chData.mCounter;

        int notificationid =
                counter == null ? (int) (Math.random() * Integer.MAX_VALUE) : counter.next();
        builder.setContentTitle(title + "  #" + notificationid);
        builder.setChannelId(nc.getId());
        builder.setLargeIcon(bitmap);

        PrintString ps = new PrintString();
        XUser owner = chatMsg.getOwner();
        ps.print(owner == null ? "<null>" : owner.getName());
        ps.print(" posted a new mesage to the chatroom ");
        XChatRoom chatRoom = chatMsg.getChatRoom();
        ps.print(chatRoom.getName());
        ps.p(".");
        String message = ps.toString();
        builder.setContentText(message);
        builder.setStyle(new NotificationCompat.BigTextStyle().bigText(message));

        PendingIntent pendingIntent =
                PendingIntent.getActivity(context, 0,
                        createIntent(context), PendingIntent.FLAG_IMMUTABLE);

        if (pendingIntent != null)
            builder.setContentIntent(pendingIntent);

        Notification notification = builder.build();
        mManager.notify(notificationid, notification);


    }

    @NonNull
    public String toString() {
        StringJoiner joiner = new StringJoiner("");
        joiner.add(TAG).add("[");
        joiner.add(getClass().getSimpleName());
        if (Util.theGovernmentIsHonest())
            joiner.add(mManager.toString());
        joiner.add("]");
        return joiner.toString();
    }

    public void start() {
    }

    public void stop() {
    }

    public Set<String> getMissingRingtones() {
        HashSet<String> res = new HashSet<>();
        for (String key : mChData.keySet()) {
            ChData data = mChData.get(key);
            assert data != null;
            if (data.mRingtone == null)
                res.add(key);
        }
        return res;
    }


    class ChData {
        String mId;
        NotificationChannelCompat mChannel;
        Uri mRingtone;
        Counter mCounter = new Counter();

        ChData(String id) {
            mId = id;
            mChData.put(id, this);
        }
    }

    class Counter {
        int mValue;

        Counter() {
            this(0);
        }

        Counter(int value) {
            mValue = value;
        }

        public int next() {
            return mValue++;
        }
    }
//  public void showNotification(String title, String message, XObject object)
//  {
//    NotificationManagerCompat nm = NotificationManagerCompat.from(mContext);
//
//    Intent notificationIntent = new Intent(mContext,
//      MainActivity.class);
//    //FIXME!    mCurrentUser.addPendingEvent(object);
//
//    notificationIntent.putExtra("object", object.getClassName() + "::" + object.getObjectId());
//
//    PendingIntent pendingIntent =
//      PendingIntent.getActivity(mContext, 0, notificationIntent, PendingIntent.FLAG_IMMUTABLE);
//
//    NotificationCompat.Builder notificationBuilder =
//      new NotificationCompat.Builder(mContext, CHANNEL);
//    notificationBuilder.setSmallIcon(cell411.services.R.mipmap.appicon);
//    notificationBuilder.setOngoing(true);
//    notificationBuilder.setPriority(NotificationCompat.PRIORITY_HIGH);
//    notificationBuilder.setShowWhen(true);
//    notificationBuilder.setWhen(object.getCreatedAt().getTime());
//    notificationBuilder.setContentTitle(title + "  #" + mLastId);
//    notificationBuilder.setChannelId(CHANNEL);
//    Bitmap bitmap = BitmapFactory.decodeResource(Cell411.get().getResources(), R.mipmap.appicon);
//
//    notificationBuilder.setLargeIcon(bitmap);
//
//    if (message == null)
//      message = "The service is running";
//
//    notificationBuilder.setContentText(message);
//
//    notificationBuilder.setStyle(new NotificationCompat.BigTextStyle().bigText(message));
//    if (pendingIntent != null)
//      notificationBuilder.setContentIntent(pendingIntent);
//
//    Notification notification = notificationBuilder.build();
//    notification.defaults =
//      Notification.DEFAULT_SOUND | Notification.DEFAULT_LIGHTS | Notification.DEFAULT_VIBRATE;
//    ++mLastId;
//    nm.notify(mLastId, notification);
//  }


}

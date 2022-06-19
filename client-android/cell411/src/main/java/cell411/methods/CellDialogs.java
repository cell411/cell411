package cell411.methods;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Looper;

import androidx.annotation.Nullable;
import androidx.localbroadcastmanager.content.LocalBroadcastManager;

import com.safearx.cell411.R;

import java.util.List;

import cell411.Cell411;
import cell411.base.BaseApp;
import cell411.base.BaseContext;
import cell411.base.EnterTextDialog;
import cell411.enums.RequestType;
import cell411.parse.XPrivateCell;
import cell411.parse.XPublicCell;
import cell411.parse.XUser;

import cell411.parse.util.OnCompletionListener;
import cell411.ui.cells.PrivateCellFragment;
import cell411.utils.Util;
import cell411.utils.XLog;

public class CellDialogs implements BaseContext {
  public static final String TAG = CellDialogs.class.getSimpleName();

  public static void leaveCell(XPublicCell cell, OnCompletionListener listener) {
    if (Util.isCurrentThread(Looper.getMainLooper())) {

      app.onDS(() -> {
        XLog.i(TAG, "calling leaveCell on new thread");
        leaveCell(cell, listener);
      });
      return;
    }
    List<String> members = cell.getList("memberList");
    if (members != null) {
      members.remove(XUser.getCurrentUser()
        .getObjectId());
    }
    if (listener != null) {
      BaseApp.get().onUI(() -> listener.done(true), 0);
    }
  }

  public static void joinCell(XPublicCell publicCell, OnCompletionListener listener) {

    app.ds()
      .handleRequest(RequestType.CellJoinRequest, publicCell, listener);
  }


  public static void showLeaveCellDialog(Activity context, XPublicCell cell, @Nullable OnCompletionListener listener)
  {
    AlertDialog.Builder builder = new AlertDialog.Builder(context);
    builder.setTitle("Leave Public Cell?");
    builder.setMessage("Are you sure you want to leave cell " + cell.getName());
    builder.setPositiveButton("Yes", (dialog, which) -> leaveCell(cell, listener));
    builder.setNegativeButton("No", (dialog, which) -> {
      if (listener != null) {
        listener.done(false);
      }
    });
    AlertDialog dialog = builder.create();
    dialog.show();
    XLog.i(TAG, "Exiting showLeaveCellDialog");
  }

  public static void showDeleteCellDialog(Activity context, XPublicCell cell, OnCompletionListener listener)
  {
    AlertDialog.Builder alert = new AlertDialog.Builder(context);
    alert.setMessage(context.getString(R.string.dialog_msg_delete_public_cell, cell.getName()));
    alert.setNegativeButton(R.string.cancel, Util.nullClickListener());
    alert.setPositiveButton(R.string.dialog_btn_ok, (dialogInterface, i) -> {
      try {
        cell.delete();
        if (listener != null) {
          listener.done(true);
        }
      } catch (Exception e) {
        if (listener != null) {
          listener.done(false);
        }
      }
    });
    AlertDialog dialog = alert.create();
    dialog.show();
  }

  public static void showDeleteCellDialog(Activity activity, final XPrivateCell cell, OnCompletionListener listener)
  {
    AlertDialog.Builder alert = new AlertDialog.Builder(activity);
    alert.setMessage(activity.getString(R.string.dialog_msg_delete_cell, cell.getName()));
    alert.setNegativeButton(R.string.dialog_btn_cancel, (dialogInterface, i) -> listener.done(false));
    alert.setPositiveButton(R.string.dialog_btn_ok, (dialogInterface, i) -> cell.deleteInBackground(e -> {
      if (e == null) {
        listener.done(true);
      } else {
        Cell411.get().handleException("While deleting group", e, null);
        listener.done(false);
      }
    }));
    AlertDialog dialog = alert.create();
    dialog.show();
  }

  public static void showCreateNewCellDialog(Activity context)
  {
    EnterTextDialog dialog = new EnterTextDialog(context);
    dialog.setMessage(dialog.getString(R.string.dialog_message_create_new_cell));
    dialog.setNegativeButton(dialog.getString(cell411.services.R.string.dialog_btn_cancel));
    dialog.setPositiveButton(dialog.getString(cell411.services.R.string.dialog_btn_ok));

    dialog.setOnDismissListener(new DialogInterface.OnDismissListener() {
      @Override
      public void onDismiss(DialogInterface dialogIf) {
        createNewPrivateCell(context, dialog.getAnswer());
      }
    });
//    AlertDialog.Builder alert = new AlertDialog.Builder(context);
//    alert.setMessage(R.string.dialog_message_create_new_cell);
//    LayoutInflater inflater = (LayoutInflater) context.getSystemService(Service.LAYOUT_INFLATER_SERVICE);
//    View view = inflater.inflate(R.layout.layout_create_cell, null);
//    final EditText etCellName = view.findViewById(R.id.et_cell_name);
//    alert.setView(view);
//    alert.setNegativeButton(R.string.dialog_btn_cancel, (dialog, arg1) -> dialog.dismiss());
//    alert.setPositiveButton(R.string.dialog_btn_ok, (dialog, which) -> {
//      final String cellName = etCellName.getText()
//                                        .toString()
//                                        .trim();
//      if (cellName.isEmpty()) {
//        Cell411.get().showToast(R.string.please_enter_cell_name);
//        return;
//      }
//      createNewPrivateCell(context, cellName);
//    });
//    AlertDialog dialog = alert.create();
//    dialog.show();
  }

  public static void createNewPrivateCell(Activity activity, final String cellName)
  {
    final XPrivateCell cellObject = new XPrivateCell();
    cellObject.put("owner", XUser.getCurrentUser());
    cellObject.put("name", cellName);
    cellObject.saveInBackground(e -> {
      if (e != null) {
        Cell411.get().handleException("While saving cell", e, null);
        return;
      }
      // Notify PrivateCellFragment for the newly created newPrivateCell
      Intent intent = new Intent(PrivateCellFragment.BROADCAST_ACTION_NEW_PRIVATE_CELL);
      // Puts the status into the Intent
      intent.putExtra("newPrivateCell", cellObject);
      // Broadcasts the Intent to receivers in this app.
      LocalBroadcastManager.getInstance(activity)
                           .sendBroadcast(intent);
      Cell411.get().showToast(R.string.cell_added_successfully);
    });
  }
}


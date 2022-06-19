package cell411.methods;

import android.app.Activity;
import android.app.ProgressDialog;
import android.app.Service;
import android.content.DialogInterface;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.EditText;
import android.widget.ProgressBar;

import androidx.appcompat.app.AlertDialog;

import com.parse.ParseQuery;
import com.parse.model.ParseUser;
import com.safearx.cell411.R;

import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

import cell411.Cell411;
import cell411.base.BaseActivity;
import cell411.base.BaseDialogs;
import cell411.parse.XUser;
import cell411.parse.util.OnCompletionListener;
import cell411.utils.Util;
import cell411.utils.XLog;

/**
 * Created by Sachin on 27-03-2016.
 */
public class Dialogs extends BaseDialogs {
  private static final String TAG = "Dialogs";
  static ArrayList<ExtraDismissListener> mDismissListeners = new ArrayList<>();

  static {
    XLog.i(TAG, "loading class");
  }

  public static void showForgotPasswordDialog(Activity activity) {
    AlertDialog.Builder alert = new AlertDialog.Builder(activity);
    alert.setTitle(R.string.dialog_title_forgot_password);
    alert.setMessage(R.string.dialog_message_tap_submit);
    alert.setCancelable(false);
    Cell411 s = Cell411.get();
    LayoutInflater inflater =
      (LayoutInflater) s.getSystemService(Service.LAYOUT_INFLATER_SERVICE);
    View view = inflater.inflate(R.layout.dialog_forgot_password, null);
    final ProgressBar pb = view.findViewById(R.id.pb_progress);
    final EditText etEmail = view.findViewById(R.id.et_email);
    alert.setView(view);
    alert.setNegativeButton(R.string.dialog_btn_cancel, Util.nullClickListener());
    alert.setPositiveButton(R.string.dialog_btn_submit, Util.nullClickListener());
    final AlertDialog dialog = alert.create();
    dialog.show();
    dialog.getButton(AlertDialog.BUTTON_POSITIVE).setOnClickListener(v -> {
      if (pb.getVisibility() != View.VISIBLE) {
        final String email = etEmail.getText().toString().trim();
        if (email.isEmpty()) {
          Cell411.get().showToast(R.string.validation_email);
          return;
        }
        pb.setVisibility(View.VISIBLE);
//        XParse.resetPassword(email);
      }
    });
  }

  @SuppressWarnings("deprecation")
  public static void showConfirmDeletionAlertDialog(Activity activity) {
    AlertDialog.Builder alert = new AlertDialog.Builder(activity);
    alert.setMessage(activity.getString(R.string.dialog_msg_delete_my_account));
    alert.setNegativeButton(R.string.dialog_btn_no, (dialog, which) -> {
    });
    alert.setPositiveButton(R.string.dialog_btn_yes, (dialogInterface, i) -> {
      final ProgressDialog dialog = new ProgressDialog(activity);
      dialog.setMessage(activity.getString(R.string.dialog_msg_deleting_account));
      dialog.setCancelable(false);
      dialog.show();
      Cell411.get().deleteUser();
    });
    AlertDialog dialog = alert.create();
    dialog.show();
  }


  public static boolean isDialogShowing() {
    return !mDismissListeners.isEmpty();
  }

  public static void showQRCodeDialog(BaseActivity activity) {
//    AlertDialog.Builder alert = new AlertDialog.Builder(activity);
//    alert.setTitle(R.string.dialog_title_qr_code);
//    LayoutInflater inflater =
//      (LayoutInflater) activity.getSystemService(Service.LAYOUT_INFLATER_SERVICE);
//    View view = inflater.inflate(R.layout.layout_qrcode, null);
//    final LinearLayout linearLayout = view.findViewById(R.id.ll_qrcode);
//    final ImageView imgQRCode = view.findViewById(R.id.img_qrcode);
//    TextView txtEmail = view.findViewById(R.id.txt_email);
//    XUser currentUser = XUser.getCurrentUser();
//    txtEmail.setText(currentUser.getEmail());
//    //Find screen size
//    //Encode with a QR Code image
//    int smallerDimension =
//      Math.min(ImageUtils.getScreenWidth(), ImageUtils.getScreenHeight()) * 3 / 4;
//    QRCodeEncoder qrCodeEncoder = new QRCodeEncoder(currentUser.getUsername(), smallerDimension);
//    Bitmap bitmap = qrCodeEncoder.encodeAsBitmap();
//    imgQRCode.setImageBitmap(bitmap);
//    alert.setView(view);
//    alert.setNegativeButton(R.string.dialog_btn_cancel, (dialog, arg1) -> dialog.dismiss());
//    alert.setPositiveButton(R.string.dialog_btn_share, (dialog, which) -> {
//      linearLayout.measure(View.MeasureSpec.makeMeasureSpec(0, View.MeasureSpec.UNSPECIFIED),
//        View.MeasureSpec.makeMeasureSpec(0, View.MeasureSpec.UNSPECIFIED));
//      linearLayout.layout(0, 0, linearLayout.getMeasuredWidth(), linearLayout.getMeasuredHeight());
//      linearLayout.setDrawingCacheEnabled(true);
//      linearLayout.buildDrawingCache(true);
//      Bitmap finalBitmap = Bitmap.createBitmap(linearLayout.getDrawingCache());
//      linearLayout.destroyDrawingCache();
//      Intent share = new Intent(Intent.ACTION_SEND);
//      share.setType("image/jpeg");
//      ByteArrayOutputStream bytes = new ByteArrayOutputStream();
//      assert finalBitmap != null;
//      finalBitmap.compress(Bitmap.CompressFormat.JPEG, 100, bytes);
//      File cacheDir;
//      // Make sure external shared storage is available
//      if (Environment.MEDIA_MOUNTED.equals(Environment.getExternalStorageState())) {
//        // We can read and write the media
//        cacheDir = activity.getExternalFilesDir(null);
//      } else {
//        // Load another directory, probably local memory
//        cacheDir = activity.getFilesDir();
//      }
//      File photoFile = new File(cacheDir + File.separator + "cell411.jpg");
//      if (!IOUtil.createNewFile(photoFile))
//        return;
//      try (FileOutputStream fo = new FileOutputStream(photoFile)) {
//        fo.write(bytes.toByteArray());
//      } catch (IOException e) {
//        e.printStackTrace();
//      }
//      Uri photoURI =
//        FileProvider.getUriForFile(activity, "app.copblock.dev",
//          photoFile);
//
//      share.putExtra(Intent.EXTRA_STREAM, photoURI);
//      share.putExtra(Intent.EXTRA_SUBJECT, activity.getString(R.string.share_qr_code_subject));
//      share.putExtra(Intent.EXTRA_TEXT, activity.getString(R.string.share_qr_code_desc));
//      activity.startActivity(Intent.createChooser(share, activity.getString(R.string.share_qr_code_title)));
//    });
//    androidx.appcompat.app.AlertDialog dialog = alert.create();
//    dialog.show();
  }

  public static void showLogoutAlertDialog(BaseActivity activity) {
    AlertDialog.Builder alert = new AlertDialog.Builder(activity);
    alert.setCancelable(false);
    LayoutInflater inflater =
      (LayoutInflater) activity.getSystemService(Service.LAYOUT_INFLATER_SERVICE);
    View view = inflater.inflate(R.layout.dialog_logout, null);
    alert.setView(view);
    alert.setNegativeButton(R.string.dialog_btn_cancel, Util.nullClickListener());
    alert.setPositiveButton(R.string.dialog_btn_logout, Util.nullClickListener());
    final AlertDialog dialog = alert.create();
    dialog.show();
    dialog.getButton(android.app.AlertDialog.BUTTON_POSITIVE).setOnClickListener(v -> {
      Cell411.get().logOut();
      dialog.dismiss();
    });
  }

  public static void showEmailRequiredDialog(BaseActivity activity) {
    android.app.AlertDialog.Builder alert = new android.app.AlertDialog.Builder(activity);
    alert.setTitle(R.string.dialog_title_email);
    alert.setMessage(R.string.dialog_message_email_required);
    alert.setCancelable(false);
    LayoutInflater inflater =
      (LayoutInflater) activity.getSystemService(Service.LAYOUT_INFLATER_SERVICE);
    View view = inflater.inflate(R.layout.dialog_email, null);
    final ProgressBar pb = view.findViewById(R.id.pb_progress);
    final EditText etEmail = view.findViewById(R.id.et_email);
    alert.setView(view);
    alert.setNegativeButton(R.string.dialog_btn_cancel, (dialog, arg1) -> dialog.dismiss());
    alert.setPositiveButton(R.string.dialog_btn_submit, (dialog, which) -> {
    });
    final android.app.AlertDialog dialog = alert.create();
    dialog.show();
    dialog.getButton(android.app.AlertDialog.BUTTON_POSITIVE).setOnClickListener(v -> {
      if (pb.getVisibility() != View.VISIBLE) {
        final String email = etEmail.getText().toString().trim();
        if (email.isEmpty()) {
          Cell411.get().showToast(R.string.validation_email);
          return;
        } else if (!email.contains("@")) {
          Cell411.get().showToast(R.string.validation_email_invalid);
          return;
        }
        pb.setVisibility(View.VISIBLE);
        ParseQuery<ParseUser> userParseQuery = ParseUser.getQuery();
        userParseQuery.whereEqualTo("username", email);
        ParseQuery<ParseUser> userParseQuery2 = ParseUser.getQuery();
        userParseQuery2.whereEqualTo("email", email);
        // Club all the queries into one master query
        List<ParseQuery<ParseUser>> queries = new ArrayList<>();
        queries.add(userParseQuery);
        queries.add(userParseQuery2);
        ParseQuery<ParseUser> mainQuery = ParseQuery.or(queries);
        mainQuery.findInBackground((list, e) -> {
          if (e != null) {
            pb.setVisibility(View.GONE);
            activity.handleException("While updating email", e, null);
            return;
          }
          if (list != null && list.size() != 0) {
            pb.setVisibility(View.GONE);
            // display popup
            Dialogs.showEmailAlreadyRegisteredAlert(activity, email);
            return;
          }
          XUser currentUser = XUser.getCurrentUser();
          currentUser.setEmail(email.toLowerCase(Locale.US).trim());
          currentUser.saveInBackground(e1 -> {
            pb.setVisibility(View.GONE);
            if (e1 == null) {
              Cell411.get().showToast(R.string.email_updated_successfully);
              showQRCodeDialog(activity);
            } else {
              Cell411.get().showToast("While updating email", e1);
            }
            dialog.dismiss();
          });
        });
      }
    });
  }

  public static void showEmailAlreadyRegisteredAlert(BaseActivity activity, String email) {
    AlertDialog.Builder alert = new AlertDialog.Builder(activity);
    alert.setMessage(email + " " + activity.getString(R.string.email_already_registered));
    alert.setPositiveButton(R.string.dialog_btn_ok, (dialog, which) -> dialog.dismiss());
    alert.create().show();
  }

  static class ExtraDismissListener implements DialogInterface.OnDismissListener {
    final DialogInterface.OnDismissListener mListener;
    final OnCompletionListener mCompletionListener;

    ExtraDismissListener(DialogInterface.OnDismissListener listener,
                         OnCompletionListener completionListener) {
      mListener = listener;
      mCompletionListener = completionListener;
      mDismissListeners.add(this);
    }

    boolean success() {
      return true;
    }

    public void onDismiss(DialogInterface dialog) {
      if (mCompletionListener != null) {
        mCompletionListener.done(success());
      }
      if (mListener != null) {
        mListener.onDismiss(dialog);
      }
      mDismissListeners.remove(this);
    }
  }

}



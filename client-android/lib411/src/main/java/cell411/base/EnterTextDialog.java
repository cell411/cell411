package cell411.base;

import android.annotation.SuppressLint;
import android.app.AlertDialog;
import android.app.Service;
import android.content.Context;
import android.content.DialogInterface;
import android.view.ContextThemeWrapper;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.EditText;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.StringRes;

import org.jetbrains.annotations.NotNull;

import cell411.parse.util.OnCompletionListener;
import cell411.services.R;
import cell411.utils.Util;

public class EnterTextDialog extends AlertDialog
{
  final @NotNull Context mContext;
  String mAnswer = null;
  TextView mInstructions;
  EditText mEditText;

  public EnterTextDialog() {
    this(BaseApp.get().getCurrentActivity());
  }

  public EnterTextDialog(@NonNull ContextThemeWrapper context) {
    super(context);
    mContext = context;
    LayoutInflater inflater =
      (LayoutInflater) context.getSystemService(Service.LAYOUT_INFLATER_SERVICE);
    @SuppressLint("InflateParams")
    View view = inflater.inflate(R.layout.layout_enter_text_dialog, null);
    setView(view);
    mInstructions = view.findViewById(R.id.instructions);
    mEditText = view.findViewById(R.id.edit_text);
    setPositiveButton(getString(R.string.dialog_btn_ok));
    setNegativeButton(getString(R.string.dialog_btn_cancel));
  }
  
  public String getString(@StringRes int res) {
    return mContext.getString(res);
  }

  public void setPositiveButton(String okText) {
    setButton(DialogInterface.BUTTON_POSITIVE, okText, this::onButtonClick);
  }
  public void setNegativeButton(String cancelText) {
    setButton(DialogInterface.BUTTON_NEGATIVE, cancelText, this::onButtonClick);
  }

  public static EnterTextDialog showEnterTextDialog(String title, String hint, String initVal,
                                                    OnCompletionListener listener) {
    EnterTextDialog dialog = buildEnterTextDialog(title, hint, initVal);
    BaseDialogs.ExtraDismissListener extraListener;
    extraListener = new BaseDialogs.ExtraDismissListener(null, listener);
    dialog.setOnDismissListener(extraListener);
    dialog.show();
    return dialog;
  }

  public static EnterTextDialog buildEnterTextDialog(String title, String hint, String initVal) {
    EnterTextDialog dialog = new EnterTextDialog();
    dialog.setTitle(title);
    dialog.setHint(hint);
    dialog.setInitVal(initVal);

    return dialog;
  }

  public String getAnswer() {
    return mAnswer;
  }

  public void onButtonClick(DialogInterface dialog, int which) {
    assert dialog == this;
    if (which == BUTTON_POSITIVE)
      mAnswer = String.valueOf(mEditText.getText());
  }

  public void setHint(String hint) {
    mEditText.setHint(hint);
  }

  public void setInitVal(String initVal) {
    mEditText.setText(initVal);
  }

  public void setInstructions(String instructions) {
    if (Util.isNoE(instructions)) {
      mInstructions.setVisibility(View.GONE);
    } else {
      mInstructions.setVisibility(View.VISIBLE);
      mInstructions.setText(instructions);
    }
  }
}

package cell411.ui.self;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.EditText;
import android.widget.Spinner;
import android.widget.TextView;

import androidx.annotation.Nullable;

import cell411.base.BaseActivity;
import com.safearx.cell411.R;

import cell411.Cell411;
import cell411.parse.CountryInfo;
import cell411.parse.XUser;
import cell411.utils.Cell411GuiUtils;
import cell411.utils.Reflect;
import cell411.utils.Util;
import cell411.utils.XLog;

/**
 * Created by Sachin on 28-07-2017.
 */
public class EnterPhoneActivity extends BaseActivity {
  public static final String TAG = Reflect.getTag();

  static {
    XLog.i(TAG, "loading class");
  }

  private EditText               etMobile;
  private Spinner                spCountryCode;

  public static void start(Context context) {
    context.startActivity(new Intent(context, EnterPhoneActivity.class));
  }

  public static boolean checkPhone() {
    XUser user = XUser.getCurrentUser();
    String mobileNumber = user.getMobileNumber();
    return !Util.isNoE(mobileNumber);
  }

  @Override protected void onCreate(@Nullable Bundle savedInstanceState)
  {
    super.onCreate(savedInstanceState);
    if (checkPhone()) {
      finish();
      return;
    }
    setContentView(R.layout.activity_enter_phone);
    etMobile = findViewById(R.id.et_mobile);
    spCountryCode = Cell411GuiUtils.createCCSpinner(this, etMobile, null);

    TextView btnSubmit = findViewById(R.id.txt_btn_submit);
    btnSubmit.setOnClickListener(this::onSubmitClick);
  }

  public void onSubmitClick(View view)
  {
    String mobileNumber = etMobile.getText()
                                  .toString();
    if (mobileNumber.isEmpty()) {
      Cell411.get().showToast(R.string.validation_mobile_number);
    } else {
      // Check if the mobile number is not already registered
      String newNumber = ((CountryInfo) spCountryCode.getSelectedItem()).dialingCode + mobileNumber.trim();
      XUser user = XUser.getCurrentUser();
      user.setMobileNumber(newNumber);
      user.saveInBackground();
    }
  }
//  private static class ItemViewHolder {
//    TextView  txtCountryName;
//    TextView  txtCountryCode;
//    ImageView imgFlag;
//    ImageView imgTick;
//  }
//
//  private class CountryListAdapter extends ArrayAdapter<CountryInfo> {
//    private final ArrayList<CountryInfo> list;
//    private final int                    resourceId;
//    private final LayoutInflater         inflater;
//
//    public CountryListAdapter(Context context, int resourceId, ArrayList<CountryInfo> list)
//    {
//      super(context, resourceId, list);
//      this.list = list;
//      this.resourceId = resourceId;
//      inflater = getLayoutInflater();
//    }
//
//    @Override public View getView(final int position, View convertView, ViewGroup parent)
//    {
//      ItemViewHolder holder;
//      CountryInfo item = list.get(position);
//      if (convertView == null) {
//        holder = new ItemViewHolder();
//        convertView = inflater.inflate(R.layout.cell_country_code, null);
//        holder.txtCountryCode = convertView.findViewById(R.id.txt_country_code);
//        convertView.setTag(holder);
//      }
//      holder = (ItemViewHolder) convertView.getTag();
//      String text = "+" + item.dialingCode;
//      holder.txtCountryCode.setText(text);
//      holder.txtCountryCode.setTextColor(Color.BLACK);
//      return convertView;
//    }
//
//    @Override public View getDropDownView(int position, View convertView, @NonNull ViewGroup parent)
//    {
//      ItemViewHolder holder;
//      CountryInfo item = list.get(position);
//      if (convertView == null) {
//        holder = new ItemViewHolder();
//        convertView = inflater.inflate(resourceId, null);
//        holder.txtCountryName = convertView.findViewById(R.id.txt_country_name);
//        holder.imgFlag = convertView.findViewById(R.id.img_flag);
//        holder.imgTick = convertView.findViewById(R.id.img_tick);
//        convertView.setTag(holder);
//      }
//      holder = (ItemViewHolder) convertView.getTag();
//      String text = item.name + " +" + item.dialingCode;
//      holder.txtCountryName.setText(text);
//      holder.imgFlag.setImageResource(item.flagId);
//      if (item.selected) {
//        holder.imgTick.setVisibility(View.VISIBLE);
//      } else {
//        holder.imgTick.setVisibility(View.GONE);
//      }
//      return convertView;
//    }
//  }
}


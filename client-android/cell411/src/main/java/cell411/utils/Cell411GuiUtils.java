package cell411.utils;

import android.app.Activity;
import android.text.Html;
import android.text.SpannableStringBuilder;
import android.text.method.LinkMovementMethod;
import android.text.style.ClickableSpan;
import android.text.style.URLSpan;
import android.view.View;
import android.widget.AdapterView;
import android.widget.Spinner;
import android.widget.TextView;

import com.safearx.cell411.R;

import java.util.ArrayList;
import java.util.function.Function;

import cell411.methods.UtilityMethods;
import cell411.parse.CountryInfo;
import cell411.ui.utils.CountryListAdapter;

public class Cell411GuiUtils {
  public static final String TAG = Reflect.getTag();

  public static void setTextViewHTML(TextView text, String html, Function<URLSpan, ClickableSpan> func) {
    CharSequence sequence = Html.fromHtml(html, Html.FROM_HTML_MODE_LEGACY);
    SpannableStringBuilder strBuilder = new SpannableStringBuilder(sequence);
    URLSpan[] urls = strBuilder.getSpans(0, sequence.length(), URLSpan.class);
    for (URLSpan span : urls) {
      int start = strBuilder.getSpanStart(span);
      int end = strBuilder.getSpanEnd(span);
      int flags = strBuilder.getSpanFlags(span);
      strBuilder.setSpan(func.apply(span), start, end, flags);
      strBuilder.removeSpan(span);
    }
    text.setText(strBuilder);
    text.setMovementMethod(LinkMovementMethod.getInstance());
  }

  public static Spinner createCCSpinner(Activity activity, TextView etMobile, String phoneNo) {
    ArrayList<CountryInfo> list = new ArrayList<>();
    // FIXME:  I think this can be removed.
    UtilityMethods.initializeCountryCodeList(list);
    Spinner spCountryCode = activity.findViewById(R.id.sp_country_code);
    CountryListAdapter countryListAdapter =
      new CountryListAdapter(activity, R.layout.cell_country, list);
    countryListAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
    spCountryCode.setAdapter(countryListAdapter);
    spCountryCode.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
      @Override
      public void onItemSelected(AdapterView<?> adapterView, View view, int position, long l) {
        CountryInfo countryInfo = (CountryInfo) spCountryCode.getSelectedItem();
        for (CountryInfo info : list) {
          info.selected = false;
        }
        countryInfo.selected = true;
        XLog.i(TAG,
          "countryInfo: " + countryInfo.name + " (" + countryInfo.shortCode + ") + " + countryInfo.dialingCode);
        XLog.i(TAG, "position: " + position);
      }

      @Override
      public void onNothingSelected(AdapterView<?> adapterView) {
      }
    });
    // FIXME: Do we need this?
    spCountryCode.setSelection(UtilityMethods.getDefaultCountryCodeIndex(list));
    if (phoneNo != null && etMobile != null) {
      UtilityMethods.setPhoneAndCountryCode(phoneNo, etMobile,
        spCountryCode, list);
    }
    return spCountryCode;
  }
}
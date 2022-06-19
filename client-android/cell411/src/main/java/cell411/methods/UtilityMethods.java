package cell411.methods;

import android.widget.EditText;
import android.widget.Spinner;
import android.widget.TextView;

import java.util.ArrayList;
import java.util.Locale;

import cell411.parse.CountryCodes;
import cell411.parse.CountryInfo;

/**
 * Created by Sachin on 14-07-2017.
 */
public class UtilityMethods {
  public static void setPhoneAndCountryCode(String mobileNumber, TextView etMobileNumber, Spinner spCountryCode,
                                            ArrayList<CountryInfo> list)
  {
    if (mobileNumber != null && !mobileNumber.isEmpty()) {
      // if number matches the character of the country code
      //mobileNumber = mobileNumber.replaceAll("[-\\[\\]^/,'*:.!><~@+#$%=?|\"\\\\()]+", "").replaceAll(" ", "");
      mobileNumber = mobileNumber.replaceAll("[\\D]+", "");
      String countryCodeBasedOnLocale = Locale.getDefault()
                                              .getCountry();
      String dialingCodeBasedOnLocale = null;
      int index = 0;
      for (int i = 0; i < list.size(); i++) {
        if (countryCodeBasedOnLocale.equalsIgnoreCase(list.get(i).shortCode)) {
          index = i;
          dialingCodeBasedOnLocale = list.get(i).dialingCode;
          break;
        }
      }
      // check if the country code is included in the phone number field
      if (dialingCodeBasedOnLocale != null && mobileNumber.startsWith(dialingCodeBasedOnLocale)) {
        // country code is included in the phone field, so it should be split into
        // separate country code and phone number
        int countryCodeLength = dialingCodeBasedOnLocale.length();
        mobileNumber = mobileNumber.substring(countryCodeLength);
        spCountryCode.setSelection(index);
      } else {
        for (int i = 0; i < list.size(); i++) {
          // check if the country code is included in the phone number field
          if (mobileNumber.startsWith(list.get(i).dialingCode)) {
            // country code is included in the phone field, so it should be split into
            // separate country code and phone number
            int countryCodeLength = list.get(i).dialingCode.length();
            mobileNumber = mobileNumber.substring(countryCodeLength);
            spCountryCode.setSelection(i);
            break;
          }
        }
      }
      etMobileNumber.setText(mobileNumber);
    }
  }

  public static int getDefaultCountryCodeIndex(ArrayList<CountryInfo> list)
  {
    String country = Locale.getDefault()
                           .getCountry();
    int index = 228;
    for (int i = 0; i < list.size(); i++) {
      if (country.equalsIgnoreCase(list.get(i).shortCode)) {
        index = i;
        break;
      }
    }
    return index;
  }

  public static void initializeCountryCodeList(ArrayList<CountryInfo> list)
  {
    for (int i = 0; i < CountryCodes.countryNameCodesArray.length; i++) {
      Locale loc = new Locale("", CountryCodes.countryNameCodesArray[i]);
      list.add(new CountryInfo(loc.getDisplayCountry(), String.valueOf(CountryCodes.countryCodesArray[i]),
                               CountryCodes.countryNameCodesArray[i]));
    }
    list.sort((lhs, rhs) -> lhs.name.compareToIgnoreCase(rhs.name));
  }
}


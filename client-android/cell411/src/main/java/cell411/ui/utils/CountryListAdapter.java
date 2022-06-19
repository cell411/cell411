package cell411.ui.utils;

import android.app.Activity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;

import com.safearx.cell411.R;

import java.util.ArrayList;

import cell411.parse.CountryInfo;

public class CountryListAdapter extends ArrayAdapter<CountryInfo> {
  private final ArrayList<CountryInfo> mCountryInfoList;
  private final int                    mResourceId;
  private final LayoutInflater         mInflater;

  public CountryListAdapter(Activity context, int resourceId, ArrayList<CountryInfo> countryInfoList)
  {
    super(context, resourceId, countryInfoList);
    this.mCountryInfoList = countryInfoList;
    this.mResourceId = resourceId;
    mInflater = context.getLayoutInflater();
  }

  @Override public View getView(final int position, View convertView, ViewGroup parent)
  {
    ItemViewHolder holder;
    CountryInfo item = mCountryInfoList.get(position);
    if (convertView == null) {
      holder = new ItemViewHolder();
      convertView = mInflater.inflate(R.layout.cell_country_code, parent, false);
      holder.txtCountryCode = convertView.findViewById(R.id.txt_country_code);
      convertView.setTag(holder);
    }
    holder = (ItemViewHolder) convertView.getTag();
    String text = "+" + item.dialingCode;
    holder.txtCountryCode.setText(text);
    return convertView;
  }

  @Override public View getDropDownView(int position, View convertView, @NonNull ViewGroup parent)
  {
    ItemViewHolder holder;
    CountryInfo item = mCountryInfoList.get(position);
    if (convertView == null) {
      holder = new ItemViewHolder();
      convertView = mInflater.inflate(mResourceId, null);
      holder.txtCountryName = convertView.findViewById(R.id.txt_country_name);
      holder.imgFlag = convertView.findViewById(R.id.img_flag);
      holder.imgTick = convertView.findViewById(R.id.img_tick);
      convertView.setTag(holder);
    }
    holder = (ItemViewHolder) convertView.getTag();
    String text = item.name + " +" + item.dialingCode;
    holder.txtCountryName.setText(text);
    holder.imgFlag.setImageResource(item.flagId);
    if (item.selected) {
      holder.imgTick.setVisibility(View.VISIBLE);
    } else {
      holder.imgTick.setVisibility(View.GONE);
    }
    return convertView;
  }

  public static class ItemViewHolder {
    TextView  txtCountryName;
    TextView  txtCountryCode;
    ImageView imgFlag;
    ImageView imgTick;
  }
}

package cell411.ui.cells;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.TextView;

import androidx.annotation.NonNull;

import com.safearx.cell411.R;

import cell411.enums.CellCategory;

public class CellCategoryListAdapter extends ArrayAdapter<CellCategory> {
  private final Activity mActivity;
  private final int            resourceId;
  private final LayoutInflater inflater;
  public CellCategoryListAdapter(Activity activity, int resourceId)
  {
    super(activity, resourceId);
    mActivity = activity;
    for (CellCategory category : CellCategory.values()) {
      add(category);
    }
    this.resourceId = resourceId;
    inflater = mActivity.getLayoutInflater();
  }

  @SuppressLint("InflateParams") @Override public View getView(final int position, View convertView, ViewGroup parent) {
    ItemViewHolder holder;
    if (convertView == null) {
      holder = new ItemViewHolder();
      convertView = inflater.inflate(R.layout.cell_public_cell_category, null);
      holder.txtPublicCellCategory = convertView.findViewById(R.id.txt_public_cell_category);
      convertView.setTag(holder);
    }
    holder = (ItemViewHolder) convertView.getTag();
    holder.txtPublicCellCategory.setText(getItem(position).toString());
    return convertView;
  }

  @Override public View getDropDownView(int position, View convertView, @NonNull ViewGroup parent) {
    ItemViewHolder holder;
    CellCategory item = getItem(position);
    if (convertView == null) {
      holder = new ItemViewHolder();
      convertView = inflater.inflate(resourceId, null);
      holder.txtPublicCellCategory = convertView.findViewById(R.id.txt_public_cell_category);
      convertView.setTag(holder);
    }
    holder = (ItemViewHolder) convertView.getTag();
    holder.txtPublicCellCategory.setText(item.toString());
    return convertView;
  }

  public static class ItemViewHolder {
    TextView txtPublicCellCategory;
  }
}

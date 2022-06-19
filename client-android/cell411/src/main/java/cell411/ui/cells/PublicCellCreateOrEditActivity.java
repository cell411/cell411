package cell411.ui.cells;

import android.app.Activity;
import android.content.Intent;
import android.location.Location;
import android.os.Bundle;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.TextView;
import androidx.appcompat.app.ActionBar;
import cell411.Cell411;
import cell411.base.EnterTextDialog;
import cell411.enums.CellCategory;
import cell411.base.BaseActivity;
import cell411.base.BaseApp;
import cell411.parse.XPublicCell;
import cell411.parse.XUser;
import cell411.parse.util.OnCompletionListener;
import cell411.services.LocationService;
import cell411.utils.LocationUtil;
import cell411.utils.ObservableValue;
import cell411.utils.XLog;
import com.parse.ParseCloud;
import com.parse.ParseException;
import com.parse.model.ParseGeoPoint;
import com.parse.model.ParseObject;
import com.safearx.cell411.R;

import java.util.HashMap;

import static cell411.enums.CellCategory.Activism;
import static cell411.enums.CellCategory.None;

/**
 * Created by Sachin on 19-04-2016.
 */
public class PublicCellCreateOrEditActivity extends BaseActivity {
  static public final String TAG = "CreateOrEditPublicCellActivity";

  static {
    XLog.i(TAG, "Loading Class");
  }

  private final ObservableValue<ParseGeoPoint> mLocation = new ObservableValue<>(null);
  private       EditText                       etCellName;
  private       EditText                       etCellDescription;
  private       android.widget.Spinner         spCellCategory;
  private       boolean                        isInEditMode;
  private       MenuItem                       miCreate;
  private       MenuItem                       miUpdate;
  private       XPublicCell                    mPublicCell;
  private       TextView                       txtCity;
  private       ImageView                      mBtnGPS;
  private       CellCategoryListAdapter        mAdapterCategory;
  private EnterTextDialog mDialog;
  private Menu mMenu;

  public static void start(Activity activity, XPublicCell publicCell) {
    Intent intent = new Intent(activity, PublicCellCreateOrEditActivity.class);
    intent.putExtra("objectId", publicCell.getObjectId());
    activity.startActivity(intent);
  }

  public static void start(Activity activity) {
    Intent intent = new Intent(activity, PublicCellCreateOrEditActivity.class);
    activity.startActivity(intent);
  }

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    setContentView(R.layout.activity_create_public_cell);
    // Set up the action bar.
    txtCity           = findViewById(R.id.txt_city);
    etCellName        = findViewById(R.id.et_cell_name);
    etCellDescription = findViewById(R.id.et_cell_description);
    spCellCategory    = findViewById(R.id.sp_cell_category);
    mAdapterCategory  = new CellCategoryListAdapter(this, R.layout.cell_public_cell_category);
    mAdapterCategory.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
    spCellCategory.setAdapter(mAdapterCategory);
    spCellCategory.setSelection(0);
    mBtnGPS = findViewById(R.id.btn_gps);
    mBtnGPS.setOnClickListener(this::selectLocation);
    txtCity.setOnClickListener(this::selectLocation);
    mLocation.addObserver(this::onLocationChanged);
  }
  private void onLocationChanged(ParseGeoPoint parseGeoPoint, ParseGeoPoint parseGeoPoint1) {

    ds().requestCity(parseGeoPoint, address -> {
      txtCity.setText(address.cityPlus());
      mLocation.set(parseGeoPoint);
    });
  }

  private XPublicCell getPublicCell(String objectId) {

    return ds().getPublicCell(objectId);
  }

  @Override
  public void populateUI() {
    final ActionBar actionBar = getSupportActionBar();
    if (actionBar != null) {
      actionBar.setDisplayHomeAsUpEnabled(true);
      actionBar.setTitle(
        isInEditMode ? R.string.title_update_public_cell : R.string.title_create_public_cell);
    }
    String temp = mPublicCell.getName();
    etCellName.setText(temp);
    temp = mPublicCell.getDescription();
    etCellDescription.setText(temp);
    CellCategory category = mPublicCell.getCategory();
    if(category==None)
      category=Activism;
    System.out.println("category="+category+"("+category.ordinal()+")");
    spCellCategory.setSelection(category.ordinal());
    onPrepareOptionsMenu(mMenu);
  }
  private void selectLocation(View view) {
    if(view == mBtnGPS) {
      LocationService watcher     = loc();
      watcher.addObserver(this::onLocationChanged);
    } else {
      OnCompletionListener listener = success -> {
        if(success) {
          if(mDialog==null) {
            Cell411.get().showToast("Dialog disappeared!");
            return;
          }

          ds().requestCity(mDialog.getAnswer(), address -> {
            mLocation.set(LocationUtil.getGeoPoint(address.mLocation));
          });
        } else {
          Cell411.get().showToast("Cancelled Location Selection");
        }
      };
      mDialog = EnterTextDialog.showEnterTextDialog("Public Cell Location", "Enter City Here", "",
                                           listener);
    }
  }
  private void onLocationChanged(Location location, Location location1) {
    if(location!=null) {
      mLocation.set(LocationUtil.getGeoPoint(location));
    }
  }
  @Override
  public void loadData() {
    String objectId = getIntent().getStringExtra("objectId");
    if (objectId == null) {
      isInEditMode=false;
      mPublicCell = (XPublicCell) ParseObject.create("PublicCell");
      mPublicCell.setVerificationStatus(0);
      mPublicCell.setOwner(XUser.getCurrentUser());
      selectLocation(mBtnGPS);
    } else {
      isInEditMode=true;
      mPublicCell = getPublicCell(objectId);
      if (mPublicCell == null) {
        Cell411.get().showAlertDialog("Failed to load public cell");
        finish();
      }
      mLocation.set(mPublicCell.getLocation());
    }

  }
  private void setLocation(Location location) {
    mLocation.set(LocationUtil.getGeoPoint(location));
  }

  @Override
  public boolean onCreateOptionsMenu(Menu menu) {
    getMenuInflater().inflate(R.menu.menu_create_public_cell, menu);
    mMenu=menu;
    miCreate = menu.findItem(R.id.create);
    miUpdate = menu.findItem(R.id.update);
    return super.onCreateOptionsMenu(menu);
  }

  @Override
  public boolean onPrepareOptionsMenu(Menu menu) {
    if (isInEditMode) {
      miCreate.setVisible(false);
      miUpdate.setVisible(true);
      miUpdate.setOnMenuItemClickListener(item -> {
        updatePublicCell();
        return true;
      });
    } else {
      miCreate.setVisible(true);
      miUpdate.setVisible(false);
      miCreate.setOnMenuItemClickListener(item -> {
        updatePublicCell();
        return true;
      });
    }
    return super.onPrepareOptionsMenu(menu);
  }

  @Override
  public boolean onOptionsItemSelected(MenuItem item) {
    int itemId = item.getItemId();
    if (itemId == android.R.id.home) {
      finish();
      return true;
    } else if (itemId == R.id.create) {
      updatePublicCell();
      return true;
    } else if (itemId == R.id.update) {
      updatePublicCell();
      return true;
    }
    return super.onOptionsItemSelected(item);
  }

  private void updatePublicCell() {
    final String        cellName      = etCellName.getText().toString().trim();
    final String        description   = etCellDescription.getText().toString().trim();
    final CellCategory  category      = (CellCategory) spCellCategory.getSelectedItem();
    final ParseGeoPoint parseGeoPoint = mLocation.get();
    if (cellName.isEmpty()) {
      Cell411.get().showToast(getString(R.string.please_enter_cell_name));
      return;
    }
    if (description.isEmpty()) {
      Cell411.get().showToast(getString(R.string.please_enter_cell_description));
      return;
    }
    if (category == None) {
      Cell411.get().showToast("Please select a category");
      return;
    }
    // Check what are the things that are changed
    mPublicCell.setName(cellName);
    mPublicCell.setDescription(description);
    mPublicCell.setLocation(parseGeoPoint);
    mPublicCell.setCategory(category);

    ds().onDS(this::saveData);
  }

  public void saveData() {
    try {
      mPublicCell.save();
      if (isInEditMode) {
        Cell411.get().showToast("Cell saved");
      } else {
        HashMap<String, Object> params = new HashMap<>();
        params.put("cellId", mPublicCell.getObjectId());
        try {
          ParseCloud.run("announceCellCreation", params);
          Cell411.get().showToast(getString(R.string.cell_added_successfully));
        } catch (ParseException pe) {
          Cell411.get().showToast("Announcement failed");
        }
      }
      BaseApp.get().onUI(this::finish,0);
    } catch (ParseException e) {
      handleException("saving edited cell", e, null);
    }
  }

  public void finish() {
    super.finish();
  }

  @Override
  public void prepareToLoad() {

  }

}


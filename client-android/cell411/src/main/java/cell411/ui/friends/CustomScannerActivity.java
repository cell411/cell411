//package cell411.ui.friends;
//
//import android.content.pm.PackageManager;
//import android.os.Bundle;
//import android.view.KeyEvent;
//import android.view.View;
//import android.widget.Button;
//
//import cell411.base.BaseActivity;
//import com.journeyapps.barcodescanner.CaptureManager;
//import com.journeyapps.barcodescanner.CompoundBarcodeView;
//import com.safearx.cell411.R;
//
//
//
///**
// * Custom Scannner Activity extending from Activity to display a custom layout form scanner view.
// */
//public class CustomScannerActivity extends BaseActivity implements CompoundBarcodeView.TorchListener {
//  private CaptureManager      capture;
//  private CompoundBarcodeView barcodeScannerView;
//  private Button              switchFlashlightButton;
//
//  @Override protected void onCreate(Bundle savedInstanceState)
//  {
//    super.onCreate(savedInstanceState);
//    setContentView(R.layout.activity_custom_scanner);
//    barcodeScannerView = findViewById(R.id.zxing_barcode_scanner);
//    barcodeScannerView.setTorchListener(this);
//    switchFlashlightButton = findViewById(R.id.switch_flashlight);
//    // if the device does not have flashlight in its camera,
//    // then remove the switch flashlight button...
//    if (!hasFlash()) {
//      switchFlashlightButton.setVisibility(View.GONE);
//    }
//    capture = new CaptureManager(this, barcodeScannerView);
//    capture.initializeFromIntent(getIntent(), savedInstanceState);
//    capture.decode();
//  }
//
//  @Override protected void onPause()
//  {
//    super.onPause();
//    capture.onPause();
//  }
//
//  @Override protected void onResume()
//  {
//    super.onResume();
//    capture.onResume();
//  }
//
//  @Override protected void onDestroy()
//  {
//    super.onDestroy();
//    capture.onDestroy();
//  }
//
//  @Override public boolean onKeyDown(int keyCode, KeyEvent event)
//  {
//    return barcodeScannerView.onKeyDown(keyCode, event) || super.onKeyDown(keyCode, event);
//  }
//
//  @Override protected void onSaveInstanceState(Bundle outState)
//  {
//    super.onSaveInstanceState(outState);
//    capture.onSaveInstanceState(outState);
//  }
//
//  /**
//   * Check if the device's camera has a Flashlight.
//   *
//   * @return true if there is Flashlight, otherwise false.
//   */
//  private boolean hasFlash()
//  {
//    return getApplicationContext().getPackageManager()
//                                  .hasSystemFeature(PackageManager.FEATURE_CAMERA_FLASH);
//  }
//
//  public void switchFlashlight(View view)
//  {
//    if (getString(R.string.turn_on_flashlight).equals(switchFlashlightButton.getText())) {
//      barcodeScannerView.setTorchOn();
//    } else {
//      barcodeScannerView.setTorchOff();
//    }
//  }
//
//  @Override public void onTorchOn()
//  {
//    switchFlashlightButton.setText(R.string.turn_off_flashlight);
//  }
//
//  @Override public void onTorchOff()
//  {
//    switchFlashlightButton.setText(R.string.turn_on_flashlight);
//  }
//}
//

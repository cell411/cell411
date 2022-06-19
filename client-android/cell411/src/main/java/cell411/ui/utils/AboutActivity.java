package cell411.ui.utils;

import android.annotation.SuppressLint;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.ColorFilter;
import android.graphics.PorterDuff;
import android.graphics.PorterDuffColorFilter;
import android.net.Uri;
import android.os.Bundle;
import android.view.MenuItem;
import android.view.View;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.ImageView;
import android.widget.ProgressBar;

import androidx.appcompat.app.ActionBar;
import androidx.appcompat.app.AppCompatDelegate;

import com.safearx.cell411.R;

import cell411.base.BaseActivity;
import cell411.utils.XLog;

public class AboutActivity extends BaseActivity implements View.OnClickListener {
  private static final String TAG = AboutActivity.class.getSimpleName();

  static {
    XLog.i(TAG, "loading class");
  }

  private WebView wvAbout;
  private ProgressBar pb;

  @Override
  public boolean onOptionsItemSelected(MenuItem item) {
    if (item.getItemId() == android.R.id.home) {
      finish();
      return true;
    }
    return super.onOptionsItemSelected(item);
  }

  @SuppressLint("SetJavaScriptEnabled")
  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    setContentView(R.layout.activity_about);
    final ActionBar actionBar = getSupportActionBar();
    if (actionBar != null) {
      actionBar.setDisplayHomeAsUpEnabled(true);
      actionBar.setDisplayShowHomeEnabled(true);
    }
    pb = findViewById(R.id.pb_progress);
    final ImageView imgPrevious = findViewById(R.id.img_previous);
    final ImageView imgForward = findViewById(R.id.img_forward);
    final ImageView imgRefresh = findViewById(R.id.img_refresh);
    imgPrevious.setOnClickListener(this);
    imgForward.setOnClickListener(this);
    imgRefresh.setOnClickListener(this);
    final ColorFilter colorFilterActive = new PorterDuffColorFilter(getColor(R.color.highlight_color),
      PorterDuff.Mode.MULTIPLY);
    final ColorFilter colorFilterInActive = new PorterDuffColorFilter(getColor(R.color.gray_666),
      PorterDuff.Mode.MULTIPLY);
    wvAbout = findViewById(R.id.wv_about);
    WebSettings settings = wvAbout.getSettings();
    settings.setJavaScriptEnabled(true);
    settings.setCacheMode(WebSettings.LOAD_NO_CACHE);
    settings.setDatabaseEnabled(true);
    settings.setDomStorageEnabled(true);
    wvAbout.setWebViewClient(new WebViewClient() {
      public boolean shouldOverrideUrlLoading(WebView view, String url) {
        if ((url.contains("http") || url.contains("market://") || url.contains("mailto:") ||
          url.contains("play.google") || url.contains("tel:") || url.contains("vid:"))) {
          // Load new URL Don't override URL Link
          view.getContext()
            .startActivity(new Intent(Intent.ACTION_VIEW, Uri.parse(url.replace("file:///android_asset/", ""))));
          return true;
        } else {
          // do your handling codes here, which url is the requested url
          // probably you need to open that url rather than redirect:
          XLog.i(TAG, "url: " + url);
          view.loadUrl(url);
          return false; // then it is not handled by default action
        }
      }

      @Override
      public void onPageStarted(WebView view, String url, Bitmap favicon) {
        super.onPageStarted(view, url, favicon);
        pb.setVisibility(View.VISIBLE);
        //txtTitle.setText("Loading...");
        imgRefresh.setImageResource(R.drawable.ic_web_cancel);
      }

      public void onPageFinished(WebView view, String url) {
        pb.setVisibility(View.GONE);
        //txtTitle.setText(webView.getTitle());
        imgRefresh.setImageResource(R.drawable.ic_web_refresh);
        if (wvAbout.canGoBack()) {
          imgPrevious.setColorFilter(colorFilterActive);
        } else {
          imgPrevious.setColorFilter(colorFilterInActive);
        }
        if (wvAbout.canGoForward()) {
          imgForward.setColorFilter(colorFilterActive);
        } else {
          imgForward.setColorFilter(colorFilterInActive);
        }
      }
    });
    if (AppCompatDelegate.getDefaultNightMode() == AppCompatDelegate.MODE_NIGHT_NO) {
      wvAbout.loadUrl("file:///android_asset/about_en.html");
    } else {
      wvAbout.loadUrl("file:///android_asset/about_en_night.html");
    }
  }

  @Override
  public void onClick(View view) {
    int id = view.getId();
    if (id == R.id.img_previous) {
      wvAbout.goBack();
    } else if (id == R.id.img_refresh) {
      if (pb.getVisibility() == View.VISIBLE) {
        wvAbout.stopLoading();
      } else {
        wvAbout.reload();
      }
    } else if (id == R.id.img_forward) {
      wvAbout.goForward();
    }
  }
}


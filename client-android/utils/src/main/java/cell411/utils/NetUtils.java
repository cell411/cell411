package cell411.utils;

import android.net.Uri;

import java.io.File;
import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.net.MalformedURLException;
import java.net.URI;
import java.net.URISyntaxException;
import java.net.URL;
import java.net.URLEncoder;

import okhttp3.Call;
import okhttp3.HttpUrl;
import okhttp3.MediaType;
import okhttp3.MultipartBody;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.RequestBody;
import okhttp3.Response;
import okhttp3.ResponseBody;
import org.jetbrains.annotations.NotNull;


public class NetUtils {
  static OkHttpClient.Builder clientBuilder;
  public void setClientBuilder(OkHttpClient.Builder builder) {
    clientBuilder=builder;
  }

  public static HttpUrl toHttpUrl(HttpUrl url) {
    return url;
  }
  public static HttpUrl toHttpUrl(String str) {
    return HttpUrl.get(str);
  }
  public static HttpUrl toHttpUrl(Uri uri) {
    return HttpUrl.get(uri.toString());
  }
  public static HttpUrl toHttpUrl(URI uri) {
    return HttpUrl.get(uri);
  }
  public static HttpUrl toHttpUrl(URL uri) {
    return HttpUrl.get(uri);
  }
  public static Uri toUri(HttpUrl url) {
    return url==null?null:toUri(url.toString());
  }
  public static Uri toUri(String url) {
    return url==null?null:Uri.parse(url);
  }
  public static Uri toUri(Uri uri) {
    return uri;
  }
  public static Uri toUri(URI uri) {
    return uri==null?null:toUri(uri.toString());
  }
  public static Uri toUri(URL uri) {
    return uri==null?null:toUri(uri.toString());
  }
   public static URI toURI(HttpUrl url) {
    if (url == null)
      return null;
    return toURI(url.toString());
  }

  public static URI toURI(String str) {
    try {
      return str==null?null:new URI(str);
    } catch (URISyntaxException ex) {
      throw new RuntimeException("Converting '" + str + "'");
    }
  }
  public static URI toURI(Uri uri) {
    return toURI(uri.toString());
  }
  public static URI toURI(URI uri) {
    return uri;
  }
 public static URI toURI(URL url) {
    return url==null?null:toURI(url.toString());
  }

  public static URL toURL(HttpUrl url) {
    return url==null?null:url.url();
  }
  public static URL toURL(String str) {
    try {
      return str==null?null:new URL(str);
    } catch (Exception e) {
      throw new RuntimeException("Bad URL: " + str + "\n" + e);
    }
  }
  public static URL toURL(Uri uri) {
    return uri==null?null:toURL(uri.toString());
  }
  public static URL toURL(URI uri) {
    try {
      return uri==null?null:uri.toURL();
    } catch (MalformedURLException e) {
      e.printStackTrace();
      throw new RuntimeException("Bad URL: " + uri + "\n" + e);
    }
  }
  public static URL toURL(URL url) {
    return url;
  }



  public static String urlEncode(String objectId) {
    try {
      return URLEncoder.encode(objectId, "UTF-8");
    } catch (UnsupportedEncodingException uee) {
      throw new RuntimeException("Error encoding url", uee);
    }
  }

  // This just sucks down a URL and returns it as an array of byes.
  @NotNull
  public static String loadURL(URL url) {
    try {
      OkHttpClient         client        = clientBuilder.build();
      Request.Builder      builder       = new Request.Builder();
      assert url != null;
      builder.url(url);
      builder.get();
      Request      request  = builder.build();
      Call         call     = client.newCall(request);
      Response     response = call.execute();
      ResponseBody body     = response.body();
      assert body != null;
      return new String(body.bytes());
    } catch ( Throwable t ) {
      throw new RuntimeException("loading URL: "+url,t);
    }
  }

  public static String sendUpload(URL url, String fileName, File file, String mimeType) {
    MediaType mediaType = MediaType.get(mimeType);
    RequestBody requestBody = RequestBody.create(mediaType,file);
    return sendUpload(url, fileName, requestBody);
  }

  public static String sendUpload(URL url, String fileName, byte[] bytes, String mimeType) {
    MediaType mediaType = MediaType.get(mimeType);
    RequestBody requestBody = RequestBody.create(mediaType,bytes);
    return sendUpload(url, fileName, requestBody);
  }

  public static String sendUpload(URL url, String fileName, RequestBody requestBody) {
    try {
      OkHttpClient client = clientBuilder.build();
      Request.Builder builder = new Request.Builder();
      assert url != null;
      builder.url(url);

      MultipartBody.Builder multipartBuilder = new MultipartBody.Builder();
      multipartBuilder.setType(MultipartBody.FORM);
      multipartBuilder.addFormDataPart("sampleFile", fileName, requestBody);
      //      multipartBuilder.addFormDataPart("filename", "data.json");
      //      multipartBuilder.addPart(requestBody);
      MultipartBody multipartBody = multipartBuilder.build();
      builder.post(multipartBody);
      Request request = builder.build();
      Call call = client.newCall(request);
      Response response = call.execute();
      ResponseBody body = response.body();
      assert body != null;
      byte[] bytes = body.bytes();
      return new String(bytes);
    } catch (IOException e) {
      e.printStackTrace();
      return null;
    }
  }
  public static String loadURL(String url) {
    return loadURL(toURL(url));
  }
}

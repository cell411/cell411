package cell411.logic;

import com.parse.livequery.OkHttp3SocketClientFactory;

import java.time.Duration;

import cell411.base.BaseApp;
import okhttp3.OkHttpClient;

public class Cell411SocketClientFactory extends OkHttp3SocketClientFactory
{
  public Cell411SocketClientFactory() {
    super(getClient());
  }

  private static OkHttpClient getClient() {
    OkHttpClient.Builder clientBuilder = BaseApp.get().getClientBuilder();
    clientBuilder.pingInterval(Duration.ofSeconds(45));
    return clientBuilder.build();
  }
}

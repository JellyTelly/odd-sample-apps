package sample.oddworks.com.oddsampleapp;

import android.content.Context;
import android.net.ConnectivityManager;
import android.os.Handler;
import android.os.Looper;

/**
 * Created by hunterfortuin on 1/21/16.
 */
public class Utility {
    public static boolean hasInternetConnection(Context context) {
        ConnectivityManager con_manager = (ConnectivityManager) context.getSystemService(Context.CONNECTIVITY_SERVICE);

        if (con_manager.getActiveNetworkInfo() != null && con_manager.getActiveNetworkInfo().isAvailable() && con_manager.getActiveNetworkInfo().isConnected()) {
            return true;
        } else {
            return false;
        }
    }

    public static void runOnUiThread(Runnable task) {
        new Handler(Looper.getMainLooper()).post(task);
    }
}

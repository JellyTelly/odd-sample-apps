package sample.oddworks.com.oddsampleapp.activity;

import android.content.Intent;
import android.os.Handler;
import android.support.design.widget.Snackbar;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.view.View;

import java.util.Map;

import io.oddworks.device.model.Config;
import io.oddworks.device.model.OddView;
import io.oddworks.device.request.ApiCaller;
import io.oddworks.device.request.OddCallback;
import io.oddworks.device.request.RestServiceProvider;
import sample.oddworks.com.oddsampleapp.OddApp;
import sample.oddworks.com.oddsampleapp.R;
import sample.oddworks.com.oddsampleapp.Utility;

public class SplashActivity extends AppCompatActivity {
    // Constants
    private static final String HOME_VIEW = "homepage";
    private static final String MENU_VIEW = "menu";

    // Data
    private RestServiceProvider restServiceProvider = RestServiceProvider.getInstance();
    private ApiCaller apiCaller = restServiceProvider.getApiCaller();

    // View
    private View rootView = null;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_splash);

        rootView = findViewById(android.R.id.content);

        if (Utility.hasInternetConnection(getApplicationContext())) {
            initializeData();
        } else {
            String error = getString(R.string.no_internet_connection);
            showErrorMessage(error);
        }
    }


    private void initializeData() {
        apiCaller.getConfig(new ConfigRequestCallback());
    }

    private void showErrorMessage(final String error) {
        final Handler handler = new Handler();
        handler.postDelayed(new Runnable() {
            @Override
            public void run() {
                String msg = "Unknown Error";
                if (error != null) {
                    msg = error;
                }
                Snackbar sb = Snackbar.make(rootView, getString(R.string.initialization_failed_message, msg), Snackbar.LENGTH_INDEFINITE);
                sb.setAction(R.string.initialization_failed_retry_prompt, new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        initializeData();
                    }
                });
                sb.show();
            }
        }, 1000);
    }

    private final class ConfigRequestCallback implements OddCallback<Config> {
        @Override
        public void onSuccess(Config config) {
            Config newConfig = config;
            Map<String, String> views = config.getViews();
            String homeView = views.get(HOME_VIEW);
            String menuView = views.get(MENU_VIEW);

            apiCaller.getView(homeView, new ViewRequestCallback(HOME_VIEW));
            apiCaller.getView(menuView, new ViewRequestCallback(MENU_VIEW));
        }

        @Override
        public void onFailure(final Exception exception) {
            Utility.runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    showErrorMessage("Unable to initialize device.");
                }
            });
        }
    }

    private final class ViewRequestCallback implements OddCallback<OddView> {
        private String viewType;

        public ViewRequestCallback(String viewType) {
            this.viewType = viewType;
        }

        @Override
        public void onSuccess(OddView view) {
            OddApp oddApp = OddApp.getInstance();

            if (getViewType().equals(HOME_VIEW)) {
                oddApp.setHomeView(view);
            } else if (getViewType().equals(MENU_VIEW)) {
                oddApp.setMenuView(view);

            }

            if (oddApp.getHomeView() != null && oddApp.getMenuView() != null) {
                Intent home = new Intent(getApplicationContext(), HomeActivity.class);
                startActivity(home);
            }
        }

        @Override
        public void onFailure(final Exception exception) {
            Utility.runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    showErrorMessage("Unable to fetch data.");
                }
            });
        }

        public String getViewType() {
            return viewType;
        }
    }
}
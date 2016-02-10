package sample.oddworks.com.oddsampleapp;

import android.app.Application;
import android.content.res.Configuration;

import io.oddworks.device.model.AuthToken;
import io.oddworks.device.model.OddView;
import io.oddworks.device.request.ApiCaller;
import io.oddworks.device.request.RestServiceProvider;
import io.oddworks.device.service.OddStore;


/**
 * Created by hunterfortuin on 1/21/16.
 */
public class OddApp extends Application {
    private static OddApp singleton;
    public static OddApp getInstance() {
        return singleton;
    }

    private OddView homeView;
    private OddView menuView;

    @Override
    public void onConfigurationChanged(Configuration newConfig) {
        super.onConfigurationChanged(newConfig);
    }

    @Override
    public void onCreate() {
        super.onCreate();
        singleton = this;

        RestServiceProvider.init(getApplicationContext(),
                getString(R.string.x_access_token),
                getString(R.string.git_revision));
        RestServiceProvider mRestServices = RestServiceProvider.getInstance();
        AuthToken authToken = mRestServices.getAuthenticationService().getStoredToken();
        ApiCaller apiCaller = mRestServices.getApiCaller();
        if(authToken != null) apiCaller.setAuthToken(authToken);
    }

    @Override
    public void onLowMemory() {
        super.onLowMemory();
    }

    @Override
    public void onTerminate() {
        super.onTerminate();
    }

    public OddView getHomeView() {
        return homeView;
    }

    public void setHomeView(OddView homeView) {
        OddStore.getInstance().storeObjects(homeView.getIncluded());
        this.homeView = homeView;
    }

    public OddView getMenuView() {
        return menuView;
    }

    public void setMenuView(OddView menuView) {
        OddStore.getInstance().storeObjects(menuView.getIncluded());
        this.menuView = menuView;
    }
}

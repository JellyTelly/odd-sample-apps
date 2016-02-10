package sample.oddworks.com.oddsampleapp.lib;

import android.support.v7.widget.SearchView;
import android.util.Log;

import java.util.List;

import io.oddworks.device.model.OddObject;
import io.oddworks.device.request.ApiCaller;
import io.oddworks.device.request.OddCallback;
import io.oddworks.device.request.RestServiceProvider;
import sample.oddworks.com.oddsampleapp.Utility;
import sample.oddworks.com.oddsampleapp.activity.SearchActivity;

/**
 * Created by hunterfortuin on 1/29/16.
 */
public class SearchQueryHandler implements SearchView.OnQueryTextListener {
    private static final String TAG = SearchQueryHandler.class.getSimpleName();
    private final static Integer SEARCH_RESULTS_LIMIT = 50;

    private SearchActivity searchActivity;
    private ApiCaller apiCaller;

    public SearchQueryHandler(SearchActivity passedSearchActivity) {
        searchActivity = passedSearchActivity;
        apiCaller = RestServiceProvider.getInstance().getApiCaller();
    }

    @Override
    public boolean onQueryTextSubmit(String query) {
        search(query);
        return true;
    }

    @Override
    public boolean onQueryTextChange(String newText) {
        return false;
    }

    private void search(String query) {
        searchActivity.showProcessing();
        searchActivity.setSearchPhrase(query);

        apiCaller.getSearch(query, SEARCH_RESULTS_LIMIT, 0, new OddCallback<List<OddObject>>() {
            @Override
            public void onSuccess(final List<OddObject> oddObjects) {
                Utility.runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        searchActivity.processSearchResults(oddObjects);
                    }
                });
            }

            @Override
            public void onFailure(Exception exception) {
                Log.d(TAG, exception.toString());
            }
        });
    }
}

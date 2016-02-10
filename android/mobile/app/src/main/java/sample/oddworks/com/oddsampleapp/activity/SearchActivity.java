package sample.oddworks.com.oddsampleapp.activity;

import android.content.Context;
import android.os.Bundle;
import android.support.v7.app.ActionBar;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.support.v7.widget.SearchView;
import android.support.v7.widget.Toolbar;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.inputmethod.InputMethodManager;
import android.widget.ProgressBar;
import android.widget.TextView;

import java.util.List;

import io.oddworks.device.model.OddObject;
import sample.oddworks.com.oddsampleapp.R;
import sample.oddworks.com.oddsampleapp.adapter.OddListAdapter;
import sample.oddworks.com.oddsampleapp.lib.SearchQueryHandler;

/**
 * Created by hunterfortuin on 1/29/16.
 */
public class SearchActivity extends AppCompatActivity {
    public final static String EXTRA_SEARCH_PHRASE = "search_phrase_extra";
    private String searchPhrase;

    private RecyclerView searchRecyclerView;
    private ProgressBar searchProgressBar;
    private TextView noResultsTextView;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_search);

        searchPhrase = getIntent().getStringExtra(EXTRA_SEARCH_PHRASE);
        searchRecyclerView = (RecyclerView) findViewById(R.id.search_results_recycler_view);
        searchProgressBar = (ProgressBar) findViewById(R.id.search_progress_bar);
        noResultsTextView = (TextView) findViewById(R.id.search_no_results_found_text_view);

        configureToolbar();
    }

    private void configureToolbar() {
        Toolbar toolbar = (Toolbar) findViewById(R.id.search_toolbar);

        setSupportActionBar(toolbar);
        ActionBar actionBar = getSupportActionBar();
        if (actionBar != null) {
            actionBar.setDisplayHomeAsUpEnabled(true);
            actionBar.setDisplayShowTitleEnabled(false);
        }
    }

    public void showProcessing() {
        resetViewState();
        searchProgressBar.setVisibility(View.VISIBLE);
    }

    public void setSearchPhrase(String passedSearchPhrase) {
        searchPhrase = passedSearchPhrase;
    }

    public void processSearchResults(List<OddObject> oddObjects) {
        if (oddObjects.size() >= 1) {
            showSearchResults(oddObjects);
        } else {
            showNoSearchResults();
        }
    }

    private void showSearchResults(List<OddObject> oddObjects) {
        resetViewState();
        loadDataIntoSearchRecyclerView(oddObjects);
        searchRecyclerView.setVisibility(View.VISIBLE);
    }

    private void showNoSearchResults() {
        resetViewState();
        noResultsTextView.setVisibility(View.VISIBLE);
    }

    private void loadDataIntoSearchRecyclerView(List<OddObject> oddObjects) {
        OddListAdapter adapter = new OddListAdapter(this, oddObjects, null);
        LinearLayoutManager layoutManager = new LinearLayoutManager(this);
        layoutManager.setOrientation(LinearLayoutManager.VERTICAL);
        searchRecyclerView.setLayoutManager(layoutManager);
        searchRecyclerView.setAdapter(adapter);
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        SearchView searchView;
        SearchQueryHandler searchQueryHandler = new SearchQueryHandler(this);

        getMenuInflater().inflate(R.menu.search_menu, menu);
        searchView = (SearchView) menu.findItem(R.id.search_menu_item).getActionView();

        searchView.setOnQueryTextListener(searchQueryHandler);

        searchView.setIconified(false);
        searchView.setQuery(searchPhrase, true);
        searchView.clearFocus();

        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        switch (item.getItemId()) {
            case android.R.id.home:
                onBackPressed();
                return true;
            default:
                return super.onOptionsItemSelected(item);
        }
    }

    private void resetViewState() {
        InputMethodManager imm = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);

        imm.hideSoftInputFromWindow(searchRecyclerView.getWindowToken(), 0);
        searchProgressBar.setVisibility(View.GONE);
        searchRecyclerView.setVisibility(View.GONE);
        noResultsTextView.setVisibility(View.GONE);
    }
}

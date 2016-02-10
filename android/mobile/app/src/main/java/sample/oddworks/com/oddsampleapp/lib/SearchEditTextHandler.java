package sample.oddworks.com.oddsampleapp.lib;

import android.content.Context;
import android.content.Intent;
import android.view.KeyEvent;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;

import sample.oddworks.com.oddsampleapp.activity.SearchActivity;

public class SearchEditTextHandler implements TextView.OnEditorActionListener {
    private Context mContext;
    private EditText mSearchEditText;

    public SearchEditTextHandler(Context context, EditText searchEditText) {
        mContext = context;
        mSearchEditText = searchEditText;
    }

    @Override
    public boolean onEditorAction(TextView v, int actionId, KeyEvent event) {
        String searchPhrase = mSearchEditText.getText().toString();

        switchToSearchResultsActivity(searchPhrase);
        return true;
    }

    private void switchToSearchResultsActivity(String searchPhrase) {
        Intent searchIntent = new Intent(mContext, SearchActivity.class);

        mSearchEditText.setText("");
        searchIntent.putExtra(SearchActivity.EXTRA_SEARCH_PHRASE, searchPhrase);
        mContext.startActivity(searchIntent);
    }
}
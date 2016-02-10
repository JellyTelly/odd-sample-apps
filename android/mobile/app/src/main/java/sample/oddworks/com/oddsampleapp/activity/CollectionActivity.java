package sample.oddworks.com.oddsampleapp.activity;

import android.content.Context;
import android.os.Bundle;
import android.support.design.widget.CollapsingToolbarLayout;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.CardView;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.support.v7.widget.Toolbar;
import android.view.MenuItem;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;

import com.bumptech.glide.Glide;

import java.util.List;

import io.oddworks.device.model.OddCollection;
import io.oddworks.device.model.OddObject;
import io.oddworks.device.request.ApiCaller;
import io.oddworks.device.request.OddCallback;
import io.oddworks.device.request.RestServiceProvider;
import io.oddworks.device.service.OddStore;
import sample.oddworks.com.oddsampleapp.R;
import sample.oddworks.com.oddsampleapp.adapter.OddListAdapter;

/**
 * Created by hunterfortuin on 1/27/16.
 */
public class CollectionActivity extends AppCompatActivity {
    public static final String EXTRA_ODD_COLLECTION = "odd_collection_extra";

    private Context context;
    private OddCollection collection;
    private List<OddObject> entities;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_collection);
        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);
        if (getSupportActionBar() != null) getSupportActionBar().setDisplayHomeAsUpEnabled(true);

        context = this;

        initializeContent();
    }

    private void initializeContent() {
        collection = (OddCollection) OddStore.getInstance().getObject(getIntent().getStringExtra(EXTRA_ODD_COLLECTION));
        entities = collection.getIncludedByRelationship("entities");
        if (entities.isEmpty() &&  !collection.getRelationship("entities").getIdentifiers().isEmpty()) {
            fetchEntities();
        } else {
            configureViewLayout();
        }
    }

    private void fetchEntities() {
        ApiCaller apiCaller = RestServiceProvider.getInstance().getApiCaller();
        apiCaller.getCollection(collection.getId(), new OddCallback<OddCollection>() {
            @Override
            public void onSuccess(final OddCollection collection) {
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        CollectionActivity.this.collection = collection;
                        OddStore.getInstance().storeObject(collection);
                        OddStore.getInstance().storeObjects(collection.getIncluded());
                        entities = CollectionActivity.this.collection.getIncludedByRelationship("entities");
                        configureViewLayout();
                    }
                });
            }

            @Override
            public void onFailure(final Exception exception) {
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        configureViewLayout();
                    }
                });
            }
        });
    }

    private void configureViewLayout() {
        ImageView collectionImage = (ImageView) findViewById(R.id.collectionImage);
        Glide.with(context)
                .load(collection.getMediaImage().getAspect16x9())
                .placeholder(R.drawable.preview_tile_16x9)
                .into(collectionImage);

        CollapsingToolbarLayout collapsingToolbarLayout = (CollapsingToolbarLayout) findViewById(R.id.collapsing_toolbar);
        collapsingToolbarLayout.setTitle(collection.getTitle());

        if (collection.getDescription() == null || collection.getDescription().equals("")) {
            CardView collectionDescriptionCardView = (CardView) findViewById(R.id.collectionDescriptionCardView);
            collectionDescriptionCardView.setVisibility(View.GONE);
        } else {
            TextView collectionDescriptionTextView = (TextView) findViewById(R.id.collectionDescriptionTextView);
            collectionDescriptionTextView.setText(collection.getDescription());
        }

        RecyclerView collectionRecyclerView = (RecyclerView) findViewById(R.id.collectionRecyclerView);
        OddListAdapter oddListAdapter = new OddListAdapter(context, entities, collection);
        LinearLayoutManager layoutManager = new LinearLayoutManager(this);
        layoutManager.setOrientation(LinearLayoutManager.VERTICAL);
        collectionRecyclerView.setLayoutManager(layoutManager);
        collectionRecyclerView.setAdapter(oddListAdapter);
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
}

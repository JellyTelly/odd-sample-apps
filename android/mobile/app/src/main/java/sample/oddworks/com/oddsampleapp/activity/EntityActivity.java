package sample.oddworks.com.oddsampleapp.activity;

import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.support.design.widget.FloatingActionButton;
import android.support.v7.app.ActionBar;
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
import com.google.android.exoplayer.util.Util;

import java.util.List;

import io.oddworks.device.model.Media;
import io.oddworks.device.model.OddCollection;
import io.oddworks.device.model.OddObject;
import io.oddworks.device.service.OddStore;
import sample.oddworks.com.oddsampleapp.R;
import sample.oddworks.com.oddsampleapp.adapter.OddListAdapter;

/**
 * Created by hunterfortuin on 1/27/16.
 */
public class EntityActivity extends AppCompatActivity {
    public static final String EXTRA_ODD_ENTITY = "odd_entity_extra";
    public static final String EXTRA_ODD_COLLECTION = "odd_collection_extra";

    private Context context;
    private Media media;
    private OddCollection oddCollection;
    private List<OddObject> relatedEntities = null;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_entity);
        configureToolbar();

        context = this;

        initializeContent();
    }


    public void configureToolbar() {
        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);
        ActionBar actionBar = getSupportActionBar();
        if (actionBar != null) {
            actionBar.setDisplayHomeAsUpEnabled(true);
            actionBar.setDisplayShowTitleEnabled(false);
        }
    }

    private void initializeContent() {
        media = (Media) OddStore.getInstance().getObject(getIntent().getStringExtra(EXTRA_ODD_ENTITY));
        if (getIntent().getStringExtra(EXTRA_ODD_COLLECTION) != null) oddCollection = (OddCollection) OddStore.getInstance().getObject(getIntent().getStringExtra(EXTRA_ODD_COLLECTION));
        if (oddCollection != null) {
            relatedEntities = oddCollection.getIncludedByRelationship("entities");
            relatedEntities.remove(media);
        }
        configureViewLayout();
    }

    private void configureViewLayout() {
        ImageView entityPreviewImage = (ImageView) findViewById(R.id.entityPreviewImage);
        Glide.with(getApplicationContext())
                .load(media.getMediaImage().getAspect16x9())
                .placeholder(R.drawable.preview_tile_16x9)
                .into(entityPreviewImage);

        if ((media.getDescription() == null || media.getDescription().equals("")) && (media.getTitle() == null || media.getTitle().equals(""))) {
            CardView entityDescriptionCardView = (CardView) findViewById(R.id.entityDescriptionCardView);
            entityDescriptionCardView.setVisibility(View.GONE);
        } else {
            TextView entityDescriptionTextView = (TextView) findViewById(R.id.entityDescriptionTextView);
            entityDescriptionTextView.setText(media.getDescription());

            TextView entityTitleTextView = (TextView) findViewById(R.id.entityTitleTextView);
            entityTitleTextView.setText(media.getTitle());
        }

        FloatingActionButton entityPlayButton = (FloatingActionButton) findViewById(R.id.entityPlayButton);
        entityPlayButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent playbackActivity = new Intent(context, PlayerActivity.class)
                        .setData(Uri.parse(media.getUrl()))
                        .putExtra(PlayerActivity.CONTENT_TYPE_EXTRA, getExoMimeTypeInt());
                startActivity(playbackActivity);
            }
        });

        RecyclerView entityRecyclerView = (RecyclerView) findViewById(R.id.entityRecyclerView);
        OddListAdapter oddListAdapter = new OddListAdapter(context, relatedEntities, oddCollection);
        LinearLayoutManager layoutManager = new LinearLayoutManager(this);
        layoutManager.setOrientation(LinearLayoutManager.VERTICAL);
        entityRecyclerView.setLayoutManager(layoutManager);
        entityRecyclerView.setAdapter(oddListAdapter);
    }

    private int getExoMimeTypeInt() {
        if (media.getUrl().matches("/\\.m3u8\\z/")) {
            return Util.TYPE_HLS;
        } else {
            return Util.TYPE_OTHER;
        }
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

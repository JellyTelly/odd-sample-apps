package sample.oddworks.com.oddsampleapp.activity;

import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.support.design.widget.FloatingActionButton;
import android.support.design.widget.NavigationView;
import android.support.v4.view.GravityCompat;
import android.support.v4.widget.DrawerLayout;
import android.support.v7.app.ActionBar;
import android.support.v7.app.ActionBarDrawerToggle;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.support.v7.widget.Toolbar;
import android.view.MenuItem;
import android.view.View;
import android.widget.EditText;
import android.widget.ImageView;

import com.bumptech.glide.Glide;
import com.google.android.exoplayer.util.Util;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.oddworks.device.model.Identifier;
import io.oddworks.device.model.Media;
import io.oddworks.device.model.OddCollection;
import io.oddworks.device.model.OddObject;
import io.oddworks.device.model.OddView;
import io.oddworks.device.service.OddStore;
import sample.oddworks.com.oddsampleapp.NavigationViewBuilder;
import sample.oddworks.com.oddsampleapp.OddApp;
import sample.oddworks.com.oddsampleapp.R;
import sample.oddworks.com.oddsampleapp.adapter.OddListAdapter;
import sample.oddworks.com.oddsampleapp.lib.SearchEditTextHandler;

public class HomeActivity extends AppCompatActivity {

    private static final String FEATURED_MEDIA = "featuredMedia";
    private static final String FEATURED_COLLECTION = "featuredCollections";
    private static final String FEATURED_OBJECTS = "entities";
    private OddView homeView;
    private Media featuredMedia;
    private OddCollection featuredCollection;
    private List<OddObject> featuredCollectionObjects;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_home);

        configureToolbar();
        configureData();
        configureView();
        configureNavigation();
    }

    private void configureToolbar() {
        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);
        ActionBar actionBar = getSupportActionBar();
        if (actionBar != null) {
            actionBar.setDisplayShowTitleEnabled(false);
        }

        DrawerLayout drawer = (DrawerLayout) findViewById(R.id.drawer_layout);
        ActionBarDrawerToggle toggle = new ActionBarDrawerToggle(
                this, drawer, toolbar, R.string.navigation_drawer_open, R.string.navigation_drawer_close);
        drawer.setDrawerListener(toggle);
        toggle.syncState();
    }

    private void configureData() {
        homeView = OddApp.getInstance().getHomeView();
        List<Identifier> mediaIds = homeView.getIdentifiersByRelationship(FEATURED_MEDIA);
        List<Identifier> collectionIds = homeView.getIdentifiersByRelationship(FEATURED_COLLECTION);

        if (mediaIds != null && !mediaIds.isEmpty()) {
            Identifier featuredMediaId = mediaIds.get(0);
            featuredMedia = (Media) OddStore.getInstance().getObject(featuredMediaId);
        }
        if (collectionIds != null && mediaIds != null && !mediaIds.isEmpty()) {
            Identifier featuredCollectionId = collectionIds.get(0);
            featuredCollection = (OddCollection) OddStore.getInstance().getObject(featuredCollectionId);
        }
        if (featuredCollection != null) {
            featuredCollectionObjects = featuredCollection.getIncludedByRelationship(FEATURED_OBJECTS);
        }
    }

    private void configureView() {
        ImageView featuredMediaPreviewImage = (ImageView) findViewById(R.id.featuredMediaPreviewImage);
        Glide.with(getApplicationContext())
                .load(featuredMedia.getMediaImage().getAspect16x9())
                .placeholder(R.drawable.preview_tile_16x9)
                .into(featuredMediaPreviewImage);

        FloatingActionButton featuredMediaPlayButton = (FloatingActionButton) findViewById(R.id.featuredMediaPlayButton);
        featuredMediaPlayButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent playbackActivity = new Intent(getApplicationContext(), PlayerActivity.class)
                        .setData(Uri.parse(featuredMedia.getUrl()))
                        .putExtra(PlayerActivity.CONTENT_TYPE_EXTRA, getExoMimeTypeInt());
                startActivity(playbackActivity);
            }
        });

        RecyclerView featuredMediaRecyclerView = (RecyclerView) findViewById(R.id.featuredMediaRecyclerView);
        OddListAdapter oddListAdapter = new OddListAdapter(getApplicationContext(), featuredCollectionObjects, null);
        LinearLayoutManager layoutManager = new LinearLayoutManager(this);
        layoutManager.setOrientation(LinearLayoutManager.VERTICAL);
        featuredMediaRecyclerView.setLayoutManager(layoutManager);
        featuredMediaRecyclerView.setAdapter(oddListAdapter);
    }

    private int getExoMimeTypeInt() {
        if (featuredMedia.getUrl().matches("/\\.m3u8\\z/")) {
            return Util.TYPE_HLS;
        } else {
            return Util.TYPE_OTHER;
        }
    }

    private void configureNavigation() {
        NavigationViewBuilder navigationViewBuilder = new NavigationViewBuilder();
        NavigationView navigationView = (NavigationView) findViewById(R.id.nav_view);

        navigationViewBuilder.build(navigationView);
        configureOnMenuClickListeners(navigationViewBuilder);
        configureSearch();
    }

    private void configureSearch() {
        NavigationView navigationView = (NavigationView) findViewById(R.id.nav_view);
        View headerView = navigationView.getHeaderView(0);
        EditText searchEditText = (EditText) headerView.findViewById(R.id.search_edit_text);
        SearchEditTextHandler handler = new SearchEditTextHandler(this, searchEditText);

        searchEditText.setOnEditorActionListener(handler);
    }

    private void configureOnMenuClickListeners(NavigationViewBuilder navigationViewBuilder) {
        HashMap<OddObject, MenuItem> associations = navigationViewBuilder.getMenuItems();

        MenuItem menuItem;
        for (Map.Entry<OddObject, MenuItem> association : associations.entrySet()) {
            final OddObject oddObject = association.getKey();
            menuItem = association.getValue();

            menuItem.setOnMenuItemClickListener(new MenuItem.OnMenuItemClickListener() {
                @Override
                public boolean onMenuItemClick(MenuItem item) {
                    switch(oddObject.getType()) {
                        case OddObject.TYPE_COLLECTION:
                            Intent intent = new Intent(getApplicationContext(), CollectionActivity.class);
                            intent.putExtra(CollectionActivity.EXTRA_ODD_COLLECTION, oddObject.getId());
                            startActivity(intent);
                            break;
                        case OddObject.TYPE_VIDEO:
                        case OddObject.TYPE_LIVE_STREAM:
                            Intent mediaIntent = new Intent(getApplicationContext(), EntityActivity.class);
                            mediaIntent.putExtra(EntityActivity.EXTRA_ODD_ENTITY, oddObject.getId());
                            startActivity(mediaIntent);
                            break;
                    }
                    return false;
                }
            });
        }
    }

    @Override
    public void onBackPressed() {
        DrawerLayout drawer = (DrawerLayout) findViewById(R.id.drawer_layout);
        if (drawer.isDrawerOpen(GravityCompat.START)) {
            drawer.closeDrawer(GravityCompat.START);
        } else {
            super.onBackPressed();
        }
    }
}

package sample.oddworks.com.oddsampleapp.adapter;

import android.app.Activity;
import android.content.Context;
import android.content.Entity;
import android.content.Intent;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.TextView;

import com.bumptech.glide.Glide;

import java.util.List;
import java.util.Locale;
import java.util.concurrent.TimeUnit;

import io.oddworks.device.model.Media;
import io.oddworks.device.model.OddCollection;
import io.oddworks.device.model.OddObject;
import io.oddworks.device.service.OddStore;
import sample.oddworks.com.oddsampleapp.R;
import sample.oddworks.com.oddsampleapp.activity.CollectionActivity;
import sample.oddworks.com.oddsampleapp.activity.EntityActivity;

/**
 * Created by hunterfortuin on 1/24/16.
 */
public class OddListAdapter extends RecyclerView.Adapter<OddListAdapter.ListItemViewHolder> {
    private Context context;
    private OddCollection collection;
    private List<OddObject> oddObjects;
    private String titleText;
    private String descriptionText;
    private String mediaUrl;

    public OddListAdapter(Context context, List<OddObject> oddObjects, OddCollection collection) {
        super();

        this.context = context;
        this.oddObjects = oddObjects;
        this.collection = collection;
    }

    @Override
    public ListItemViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        View itemView = LayoutInflater.from(parent.getContext()).inflate(R.layout.list_item, parent, false);
        return new ListItemViewHolder(itemView);
    }

    @Override
    public void onBindViewHolder(ListItemViewHolder holder, int position) {
        OddObject oddObject = oddObjects.get(position);

        switch (oddObject.getType()) {
            case (OddObject.TYPE_LIVE_STREAM):
            case (OddObject.TYPE_VIDEO):
                setMediaDetails(oddObject);
                setupDuration(holder, oddObject);
                break;
            case (OddObject.TYPE_COLLECTION):
                setCollectionDetails(oddObject);
                break;
        }

        setupView(holder);
        addClickHandler(holder, oddObject);
    }

    public void setMediaDetails(OddObject oddObject) {
        Media media = (Media) oddObject;

        this.titleText = media.getTitle();
        this.descriptionText = media.getDescription();
        this.mediaUrl = media.getMediaImage().getAspect16x9();
    }

    public void setCollectionDetails(OddObject oddObject) {
        OddCollection collection = (OddCollection) oddObject;

        this.titleText = collection.getTitle();
        this.descriptionText = collection.getDescription();
        this.mediaUrl = collection.getMediaImage().getAspect16x9();
    }

    public void setupView(ListItemViewHolder holder) {
        holder.title.setText(titleText);
        holder.description.setText(descriptionText);

        if (holder.title.getLineCount() == 1) {
            holder.description.setMaxLines(4);
        } else {
            holder.description.setMaxLines(3);
        }

        if (mediaUrl != null) {
            Glide.with(context)
                    .load(mediaUrl)
                    .placeholder(R.drawable.preview_tile_16x9)
                    .error(R.drawable.preview_tile_16x9)
                    .into(holder.imageView);
        }
    }

    public void setupDuration(ListItemViewHolder holder, OddObject oddObject) {
        Media media = (Media) oddObject;

        holder.durationWrapper.setVisibility(View.VISIBLE);
        long duration = media.getDuration();

        if (TimeUnit.MILLISECONDS.toHours(duration) >= 1) {
            String durationText = String.format(Locale.getDefault(), "%02d:%02d:%02d",
                    TimeUnit.MILLISECONDS.toHours(duration),
                    TimeUnit.MILLISECONDS.toMinutes(duration) -
                            TimeUnit.HOURS.toMinutes(TimeUnit.MILLISECONDS.toHours(duration)),
                    TimeUnit.MILLISECONDS.toSeconds(duration) -
                            TimeUnit.MINUTES.toSeconds(TimeUnit.MILLISECONDS.toMinutes(duration)));
            holder.duration.setText(durationText);
        } else {
            String durationText = String.format(Locale.getDefault(), "%02d:%02d",
                    TimeUnit.MILLISECONDS.toMinutes(duration) -
                            TimeUnit.HOURS.toMinutes(TimeUnit.MILLISECONDS.toHours(duration)),
                    TimeUnit.MILLISECONDS.toSeconds(duration) -
                            TimeUnit.MINUTES.toSeconds(TimeUnit.MILLISECONDS.toMinutes(duration)));
            holder.duration.setText(durationText);
        }
    }

    public void addClickHandler(ListItemViewHolder holder, final OddObject oddObject) {
        OddStore.getInstance().storeObject(oddObject);
        if (collection != null) OddStore.getInstance().storeObject(collection);

        holder.getItemView().setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                switch (oddObject.getType()){
                    case (OddObject.TYPE_VIDEO):
                    case (OddObject.TYPE_LIVE_STREAM):
                        Intent entity = new Intent(context, EntityActivity.class);
                        entity.putExtra(EntityActivity.EXTRA_ODD_ENTITY, oddObject.getId());
                        if (collection != null) entity.putExtra(EntityActivity.EXTRA_ODD_COLLECTION, collection.getId());
                        Activity activity = (Activity) context;
                        boolean fromEntity = activity.getClass().getSimpleName().equals(Entity.class.getSimpleName());
                        if (fromEntity) entity.setFlags(entity.getFlags() | Intent.FLAG_ACTIVITY_CLEAR_TOP);
                        entity.setFlags(entity.getFlags() | Intent.FLAG_ACTIVITY_NEW_TASK);
                        context.startActivity(entity);
                        break;
                    case (OddObject.TYPE_COLLECTION):
                        Intent collection = new Intent(context, CollectionActivity.class);
                        collection.putExtra(CollectionActivity.EXTRA_ODD_COLLECTION, oddObject.getId());
                        collection.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                        context.startActivity(collection);
                        break;
                }
            }
        });
    }

    @Override
    public int getItemCount() {
        if (oddObjects == null) {
            return 0;
        } else {
            return oddObjects.size();
        }
    }

    public final static class ListItemViewHolder extends RecyclerView.ViewHolder {
        View itemView;
        TextView title;
        TextView description;
        TextView duration;
        FrameLayout durationWrapper;
        ImageView imageView;

        public ListItemViewHolder(View itemView) {
            super(itemView);

            this.itemView = itemView;
            title = (TextView) itemView.findViewById(R.id.list_item_title);
            description = (TextView) itemView.findViewById(R.id.list_item_description);
            duration = (TextView) itemView.findViewById(R.id.entity_thumbnail_duration_overlay);
            durationWrapper = (FrameLayout) itemView.findViewById(R.id.media_duration_wrapper);
            imageView = (ImageView) itemView.findViewById(R.id.list_item_image_view);
        }

        public View getItemView() {
            return itemView;
        }
    }
}
package sample.oddworks.com.oddsampleapp;

import android.support.design.internal.NavigationMenuView;
import android.support.design.widget.NavigationView;
import android.view.Menu;
import android.view.MenuItem;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.oddworks.device.model.OddObject;
import io.oddworks.device.model.OddView;

/**
 * Created by hunterfortuin on 1/27/16.
 */
public class NavigationViewBuilder {
    private final static String ITEMS_KEY = "items";
    private final static String ODD_OBJECT_TITLE_ATTRIBUTE_KEY = "title";

    private OddView menuView;
    private HashMap<OddObject, MenuItem> menuItems;

    public HashMap<OddObject, MenuItem> getMenuItems() { return menuItems; }

    public NavigationViewBuilder() {
        menuView = OddApp.getInstance().getMenuView();
        menuItems = new HashMap<>();
    }

    public void build(NavigationView navigationView) {
        if (menuView == null) { return; }

        Menu rootMenu = navigationView.getMenu();
        Menu subMenu = rootMenu.addSubMenu("All categories");
        List<OddObject> oddObjects = menuView.getIncludedByRelationship(ITEMS_KEY);
        HashMap<OddObject, MenuItem> associations = new HashMap<>();

        MenuItem menuItem;
        for(OddObject oddObject : oddObjects) {
            menuItem = processOddObject(subMenu, oddObject);

            if (menuItem != null) {
                associations.put(oddObject, menuItem);
            }
        }

        if (!associations.isEmpty()) {
            menuItems.putAll(associations);
        }

        // Disable scrollbar
        NavigationMenuView mv = (NavigationMenuView) navigationView.getChildAt(0);
        mv.setVerticalScrollBarEnabled(false);
    }

    private MenuItem processOddObject(Menu menu, OddObject oddObject) {
        Map<String, Object> attributes = oddObject.getAttributes();

        if (attributes == null) {
            return null;
        }

        Object attribute = attributes.get(ODD_OBJECT_TITLE_ATTRIBUTE_KEY);
        if (attribute == null) {
            return null;
        }

        String title = attribute.toString();
        return menu.add(title);
    }
}
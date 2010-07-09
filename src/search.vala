/*
 * This file is part of LaTeXila.
 *
 * Copyright © 2010 Sébastien Wilmet
 *
 * LaTeXila is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * LaTeXila is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with LaTeXila.  If not, see <http://www.gnu.org/licenses/>.
 */

using Gtk;

public static void set_entry_error (Widget entry, bool error)
{
    if (error)
    {
        Gdk.Color red, white;
        Gdk.Color.parse ("#FF6666", out red);
        Gdk.Color.parse ("white", out white);
        entry.modify_base (StateType.NORMAL, red);
        entry.modify_text (StateType.NORMAL, white);
    }
    else
    {
        entry.modify_base (StateType.NORMAL, null);
        entry.modify_text (StateType.NORMAL, null);
    }
}

public class GotoLine : HBox
{
    private MainWindow main_window;
    private Entry entry;

    public GotoLine (MainWindow main_window)
    {
        this.main_window = main_window;
        spacing = 3;

        Button close_button = new Button ();
        pack_start (close_button, false, false, 0);
        close_button.set_relief (ReliefStyle.NONE);
        var img = new Image.from_stock (STOCK_CLOSE, IconSize.MENU);
        close_button.add (img);
        close_button.clicked.connect (() => { hide (); });

        var label = new Label (_("Go to Line:"));
        pack_start (label, false, false, 2);

        entry = new Entry ();
        pack_start (entry, false, false, 0);
        entry.set_icon_from_stock (EntryIconPosition.SECONDARY, STOCK_JUMP_TO);
        entry.set_tooltip_text (_("Line you want to move the cursor to"));
        entry.set_size_request (100, -1);
        entry.activate.connect (() => { hide (); });
        entry.changed.connect (on_changed);
    }

    public new void show ()
    {
        entry.text = "";
        base.show ();
        entry.grab_focus ();
    }

    private void on_changed ()
    {
        if (entry.get_text_length () == 0)
        {
            set_entry_error (entry, false);
            return;
        }

        string text = entry.get_text ();

        // check if all characters are digits
        for (int i = 0 ; i < text.length ; i++)
        {
            unichar c = text[i];
            if (! c.isdigit ())
            {
                set_entry_error (entry, true);
                return;
            }
        }

        int line = text.to_int ();
        bool error = ! main_window.active_document.goto_line (--line);
        set_entry_error (entry, error);
        main_window.active_view.scroll_to_cursor ();
    }
}

public class SearchAndReplace : GLib.Object
{
    private MainWindow main_window;

    public Widget search_and_replace;
    private Button button_arrow;
    private Arrow arrow;
    private Entry entry_find;
    private Entry entry_replace;
    private HBox hbox_replace;

    public SearchAndReplace (MainWindow main_window)
    {
        this.main_window = main_window;

        var path = Path.build_filename (Config.DATA_DIR, "ui", "search_and_replace.ui");

        try
        {
            Builder builder = new Builder ();
            builder.add_from_file (path);
            search_and_replace = (Widget) builder.get_object ("search_and_replace");

            // we unparent the main widget because the ui file contains a window
            search_and_replace.unparent ();

            button_arrow = (Button) builder.get_object ("button_arrow");
            arrow = (Arrow) builder.get_object ("arrow");
            entry_find = (Entry) builder.get_object ("entry_find");
            entry_replace = (Entry) builder.get_object ("entry_replace");
            hbox_replace = (HBox) builder.get_object ("hbox_replace");
            Button button_close = (Button) builder.get_object ("button_close");

            button_arrow.clicked.connect (() =>
            {
                // search -> search and replace
                if (arrow.arrow_type == ArrowType.DOWN)
                    show_search_and_replace ();

                // search and replace -> search
                else
                    show_search ();
            });

            button_close.clicked.connect (hide);
        }
        catch (Error e)
        {
            stderr.printf ("Error search and replace: %s\n", e.message);
            var label = new Label (e.message);
            label.set_line_wrap (true);
            search_and_replace = label;
        }
    }

    public void show_search ()
    {
        arrow.arrow_type = ArrowType.DOWN;
        entry_replace.hide ();
        hbox_replace.hide ();
        search_and_replace.show ();
    }

    public void show_search_and_replace ()
    {
        arrow.arrow_type = ArrowType.UP;
        entry_replace.show ();
        hbox_replace.show ();
        search_and_replace.show ();
    }

    public void hide ()
    {
        search_and_replace.hide ();
    }
}

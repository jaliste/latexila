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
        entry.set_icon_activatable (EntryIconPosition.SECONDARY, true);
        entry.set_tooltip_text (_("Line you want to move the cursor to"));
        entry.set_size_request (100, -1);
        entry.activate.connect (() => { hide (); });
        entry.icon_press.connect (() => { hide (); });
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
        if (entry.text_length == 0)
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
    private Label label_find_normal;
    private Label label_find_error;

    private Entry entry_replace;
    private Frame frame_replace;

    private HBox hbox_replace;

    private CheckMenuItem match_case;
    private CheckMenuItem entire_word;

    public SearchAndReplace (MainWindow main_window)
    {
        this.main_window = main_window;

        var path = Path.build_filename (Config.DATA_DIR, "ui", "search_and_replace.ui");

        try
        {
            Builder builder = new Builder ();
            builder.add_from_file (path);

            /* get objects */
            search_and_replace = (Widget) builder.get_object ("search_and_replace");
            // we unparent the main widget because the ui file contains a window
            search_and_replace.unparent ();

            button_arrow = (Button) builder.get_object ("button_arrow");
            arrow = (Arrow) builder.get_object ("arrow");

            entry_find = (Entry) builder.get_object ("entry_find");
            label_find_normal = (Label) builder.get_object ("label_find_normal");
            label_find_error = (Label) builder.get_object ("label_find_error");
            EventBox eventbox_label1 = (EventBox) builder.get_object ("eventbox_label1");
            EventBox eventbox_label2 = (EventBox) builder.get_object ("eventbox_label2");
            Button button_clear_find = (Button) builder.get_object ("button_clear_find");

            entry_replace = (Entry) builder.get_object ("entry_replace");
            frame_replace = (Frame) builder.get_object ("frame_replace");
            Button button_clear_replace =
                (Button) builder.get_object ("button_clear_replace");

            hbox_replace = (HBox) builder.get_object ("hbox_replace");

            Button button_previous = (Button) builder.get_object ("button_previous");
            Button button_next = (Button) builder.get_object ("button_next");

            Button button_close = (Button) builder.get_object ("button_close");

            /* styles */
            Gdk.Color white;
            Gdk.Color.parse ("white", out white);
            eventbox_label1.modify_bg (StateType.NORMAL, white);
            eventbox_label2.modify_bg (StateType.NORMAL, white);

            /* options menu */
            var menu = new Menu ();
            match_case = new CheckMenuItem.with_label (_("Case sensitive"));
            entire_word = new CheckMenuItem.with_label (_("Entire words only"));
            menu.append (match_case);
            menu.append (entire_word);
            menu.show_all ();

            /* signal handlers */

            entry_find.icon_press.connect ((icon_pos, event) =>
            {
                // options menu
                if (icon_pos == EntryIconPosition.PRIMARY)
                    menu.popup (null, null, null, event.button.button, event.button.time);
            });

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

            button_clear_find.clicked.connect (() =>
            {
                entry_find.text = "";
            });

            button_clear_replace.clicked.connect (() =>
            {
                entry_replace.text = "";
            });

            button_previous.clicked.connect (() =>
            {
                set_label_text ("42 of 77", false);
            });

            button_next.clicked.connect (() =>
            {
                set_label_text (_("Not found"), true);
            });

            entry_find.changed.connect (() =>
            {
                if (entry_find.text_length == 0)
                {
                    label_find_normal.hide ();
                    label_find_error.hide ();
                }
            });
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
        frame_replace.hide ();
        hbox_replace.hide ();
        search_and_replace.show ();
        label_find_normal.hide ();
        label_find_error.hide ();
    }

    public void show_search_and_replace ()
    {
        arrow.arrow_type = ArrowType.UP;
        frame_replace.show ();
        hbox_replace.show ();
        search_and_replace.show ();
        label_find_normal.hide ();
        label_find_error.hide ();
    }

    public void hide ()
    {
        search_and_replace.hide ();
    }

    private void set_label_text (string text, bool error)
    {
        if (error)
        {
            label_find_error.set_text (text);
            label_find_error.show ();
            label_find_normal.hide ();
        }
        else
        {
            label_find_normal.set_text (text);
            label_find_normal.show ();
            label_find_error.hide ();
        }
    }
}

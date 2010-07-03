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

public class Application : GLib.Object
{
    public static int NEW_WINDOW = 1;
    private static Application instance = null;
    public unowned List<MainWindow> windows { get; private set; }
    public MainWindow active_window { get; private set; }

    // we must keep the settings accessible
    // without that, the code for the changed signals are not executed
    private GLib.Settings settings;

    /* Application is a singleton
     * We must use Application.get_default ()
     */
    private Application ()
    {
        windows = new List<MainWindow> ();

        /* personal style */
        // make the close buttons in tabs smaller
        Gtk.rc_parse_string ("""
            style "my-button-style"
            {
                GtkWidget::focus-padding = 0
                GtkWidget::focus-line-width = 0
                xthickness = 0
                ythickness = 0
            }
            widget "*.my-close-button" style "my-button-style"
        """);

        init_settings ();
        create_window ();
    }

    public static Application get_default ()
    {
        if (instance == null)
            instance = new Application ();
        return instance;
    }

    // get all the documents currently opened
    public List<Document> get_documents ()
    {
        List<Document> res = null;
        foreach (MainWindow w in windows)
            res.concat (w.get_documents ());
        return res;
    }

    // get all the document views
    public List<DocumentView> get_views ()
    {
        List<DocumentView> res = null;
        foreach (MainWindow w in windows)
            res.concat (w.get_views ());
        return res;
    }

    public Unique.Response message (Unique.App sender, int command,
                                    Unique.MessageData data, uint time)
    {
        if (command == NEW_WINDOW)
        {
            create_window ();
            return Unique.Response.OK;
        }

        var workspace = data.get_workspace ();
        var screen = data.get_screen ();

        // if active_window not on current workspace, try to find an other window on the
        // current workspace.
        if (! active_window.is_on_workspace_screen (screen, workspace))
        {
            bool found = false;
            foreach (MainWindow w in windows)
            {
                if (w == active_window)
                    continue;
                if (w.is_on_workspace_screen (screen, workspace))
                {
                    found = true;
                    active_window = w;
                    break;
                }
            }

            if (! found)
                create_window (screen);
        }

        if (command == Unique.Command.NEW)
            create_document ();

        else if (command == Unique.Command.OPEN)
            open_documents (data.get_uris ());

        active_window.present_with_time (time);
        return Unique.Response.OK;
    }

    public void create_window (Gdk.Screen? screen = null)
    {
        var window = new MainWindow ();
        active_window = window;

        if (screen != null)
            window.set_screen (screen);

        window.destroy.connect (() =>
        {
            windows.remove (window);
            if (windows.length () == 0)
                Gtk.main_quit ();
            else if (window == active_window)
                active_window = windows.data;
        });

        window.focus_in_event.connect (() =>
        {
            active_window = window;
            return false;
        });

        windows.append (window);
        window.show_all ();
    }

    public void create_document ()
    {
        active_window.on_file_new ();
    }

    public void open_documents (string[] uris)
    {
        for (int i = 0 ; uris[i] != null ; i++)
        {
            var location = File.new_for_uri (uris[i]);
            active_window.open_document (location);
        }
    }

    private void init_settings ()
    {
        settings = new GLib.Settings ("org.gnome.latexila.preferences.editor");

        /*
        settings.changed["use-default-font"].connect ((setting, key) =>
        {
        });

        settings.changed["editor-font"].connect ((setting, key) =>
        {
        });

        settings.changed["scheme"].connect ((setting, key) =>
        {
        });
        */

        settings.changed["tabs-size"].connect ((setting, key) =>
        {
            Variant variant = setting.get_value (key);
            uint val = variant.get_uint32 ();
            val = val.clamp (1, 24);
            foreach (DocumentView view in get_views ())
                view.tab_width = val;
        });

        settings.changed["insert-spaces"].connect ((setting, key) =>
        {
            bool val = setting.get_boolean (key);
            foreach (DocumentView view in get_views ())
                view.insert_spaces_instead_of_tabs = val;
        });

        settings.changed["display-line-numbers"].connect ((setting, key) =>
        {
            bool val = setting.get_boolean (key);
            foreach (DocumentView view in get_views ())
                view.show_line_numbers = val;
        });

        settings.changed["highlight-current-line"].connect ((setting, key) =>
        {
            bool val = setting.get_boolean (key);
            foreach (DocumentView view in get_views ())
                view.highlight_current_line = val;
        });

        settings.changed["bracket-matching"].connect ((setting, key) =>
        {
            bool val = setting.get_boolean (key);
            foreach (Document doc in get_documents ())
                doc.highlight_matching_brackets = val;
        });
    }
}

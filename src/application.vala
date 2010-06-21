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
    private static Application instance = null;
    private List<MainWindow> windows = new List<MainWindow> ();
    private MainWindow active_window;
    public static enum CustomCommand
    {
        NEW_WINDOW = 1
    }

    /* Application is a singleton
     * We must use Application.get_default ()
     */
    private Application ()
    {
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

        create_new_window ();
    }

    public static Application get_default ()
    {
        if (instance == null)
            instance = new Application ();
        return instance;
    }

    public Unique.Response message (Unique.App sender, int command,
                                    Unique.MessageData data, uint time)
    {
        if (command == this.CustomCommand.NEW_WINDOW)
        {
            create_new_window ();
            return Unique.Response.OK;
        }

        uint workspace = data.get_workspace ();

        // if active_window not on current workspace, try to find an other window on the
        // current workspace.
        if (! active_window.is_on_workspace (workspace))
        {
            unowned List<MainWindow> l = windows;
            while (true)
            {
                if (l == null)
                {
                    create_new_window ();
                    break;
                }

                MainWindow window = l.data;
                if (window == active_window)
                {
                    l = l.next;
                    continue;
                }
                if (window.is_on_workspace (workspace))
                {
                    active_window = window;
                    break;
                }

                l = l.next;
            }
        }

        if (command == Unique.Command.NEW)
            active_window.on_new ();

        else if (command == Unique.Command.OPEN)
        {
            string[] files = data.get_uris ();
            for (int i = 0 ; files[i] != null ; i++)
            {
                var location = File.new_for_uri (files[i]);
                active_window.open_document (location);
            }
        }

        active_window.present_with_time (time);
        return Unique.Response.OK;
    }

    public void create_new_window ()
    {
        var window = new MainWindow ();
        active_window = window;

        window.destroy.connect (() =>
        {
            window.on_quit ();
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
}

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
    //private List<MainWindow> windows = new List<MainWindow> ();
    private MainWindow active_window;

    public Application ()
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

        active_window = new MainWindow ();
        active_window.destroy.connect (MainWindow.on_quit);
        active_window.show_all ();
    }

    public Unique.Response message (Unique.App sender, int command,
                                    Unique.MessageData data, uint time)
    {
        //uint workspace = data.get_workspace ();

        if (command == Unique.Command.NEW)
            active_window.on_new ();

        else if (command == Unique.Command.OPEN)
        {
            string[] files = data.get_uris ();
            for (int i = 0 ; files[i] != null ; i++)
            {
                var location = File.new_for_commandline_arg (files[i]);
                active_window.open_document (location);
            }
        }

        active_window.present_with_time (time);
        return Unique.Response.OK;
    }
}

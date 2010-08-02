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

namespace Utils
{
    public void flush_queue ()
    {
        while (Gtk.events_pending ())
            Gtk.main_iteration ();
    }

    public string str_middle_truncate (string str, uint max_length)
    {
        if (str.length <= max_length)
            return str;

        var half_length = (max_length - 4) / 2;
        var l = str.length;
        return str[0:half_length] + "..." + str[l-half_length:l];
    }

    public string replace_home_dir_with_tilde (string uri)
    {
        return_val_if_fail (uri != null, null);
        string home = Environment.get_home_dir ();
        if (uri == home)
            return "~";
        if (uri.has_prefix (home))
            return "~" + uri[home.length:uri.length];
        return uri;
    }

    public string? uri_get_dirname (string uri)
    {
        return_val_if_fail (uri != null, null);
        string dir = Path.get_dirname (uri);
        if (dir == ".")
            return null;
        return replace_home_dir_with_tilde (dir);
    }

    /* Returns a string suitable to be displayed in the UI indicating
     * the name of the directory where the file is located.
     * For remote files it may also contain the hostname etc.
     * For local files it tries to replace the home dir with ~.
     */
    public string? get_dirname_for_display (File location)
    {
        try
        {
            Mount mount = location.find_enclosing_mount (null);
            string mount_name = mount.get_name ();
            var dirname = uri_get_dirname (location.get_path () ?? location.get_uri ());

            if (dirname == null || dirname == ".")
                return mount_name;
            return mount_name + " " + dirname;
        }

        // local files or uri without mounts
        catch (Error e)
        {
            return uri_get_dirname (location.get_path () ?? location.get_uri ());
        }
    }

    public const uint ALL_WORKSPACES = 0xffffff;

    /* Get the workspace the window is on
     *
     * This function gets the workspace that the #GtkWindow is visible on,
     * it returns ALL_WORKSPACES if the window is sticky, or if
     * the window manager doesn't support this function.
     */
    public uint get_window_workspace (Gtk.Window gtkwindow)
    {
        return_val_if_fail (gtkwindow.get_realized (), 0);

        uint ret = ALL_WORKSPACES;

        Gdk.Window window = gtkwindow.get_window ();
        Gdk.Display display = window.get_display ();
        unowned X.Display x_display = Gdk.x11_display_get_xdisplay (display);

        X.Atom type;
        int format;
        ulong nitems;
        ulong bytes_after;
        uint *workspace;

        Gdk.error_trap_push ();

        int result = x_display.get_window_property (Gdk.x11_drawable_get_xid (window),
            Gdk.x11_get_xatom_by_name_for_display (display, "_NET_WM_DESKTOP"),
            0, long.MAX, false, X.XA_CARDINAL, out type, out format, out nitems,
            out bytes_after, out workspace);

        int err = Gdk.error_trap_pop ();

        if (err != X.Success || result != X.Success)
            return ret;

        if (type == X.XA_CARDINAL && format == 32 && nitems > 0)
            ret = workspace[0];

        X.free (workspace);
        return ret;
    }

    public Widget add_scrollbar (Widget child)
    {
        var scrollbar = new ScrolledWindow (null, null);
        scrollbar.set_policy (PolicyType.AUTOMATIC, PolicyType.AUTOMATIC);
        scrollbar.add (child);
        return scrollbar;
    }
}

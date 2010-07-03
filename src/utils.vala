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

namespace Utils
{
    public static void flush_queue ()
    {
        while (Gtk.events_pending ())
            Gtk.main_iteration ();
    }

    public static string str_middle_truncate (string str, uint max_length)
    {
        if (str.length <= max_length)
            return str;

        var half_length = (max_length - 4) / 2;
        var l = str.length;
        return str[0:half_length] + "..." + str[l-half_length:l];
    }

    public static string replace_home_dir_with_tilde (string uri)
    {
        return_val_if_fail (uri != null, null);
        string home = Environment.get_home_dir ();
        if (uri == home)
            return "~";
        if (uri.has_prefix (home))
            return "~" + uri[home.length:uri.length];
        return uri;
    }

    public static string? uri_get_dirname (string uri)
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
    public static string? get_dirname_for_display (File location)
    {
        try
        {
            Mount mount = location.find_enclosing_mount (null);
            string mount_name = mount.get_name ();
            string dirname;
            string path = location.get_path ();

            if (path == null)
                dirname = uri_get_dirname (location.get_uri ());
            else
                dirname = uri_get_dirname (path);

            if (dirname == null || dirname == ".")
                return mount_name;
            return mount_name + " " + dirname;
        }

        // local files or uri without mounts
        catch (Error e)
        {
            string path = location.get_path ();
            if (path == null)
                return uri_get_dirname (location.get_uri ());
            return uri_get_dirname (path);
        }
    }
}

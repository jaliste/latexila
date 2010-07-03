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

public class PreferencesDialog : Dialog
{
    private static PreferencesDialog preferences_dialog = null;

    private PreferencesDialog ()
    {
        add_button (STOCK_CLOSE, ResponseType.CLOSE);
        title = _("Preferences");
        has_separator = false;
        destroy_with_parent = true;
        border_width = 5;

        response.connect ((dialog, response_id) =>
        {
            dialog.hide ();
        });

        var path = Path.build_filename (Config.DATA_DIR, "ui", "preferences_dialog.ui");

        try
        {
            Builder builder = new Builder ();
            builder.add_from_file (path);

            // get objects
            Widget notebook = (Widget) builder.get_object ("notebook");
            GLib.Object display_line_nb_checkbutton =
                builder.get_object ("display_line_nb_checkbutton");
            GLib.Object tab_width_spinbutton = builder.get_object ("tab_width_spinbutton");
            GLib.Object insert_spaces_checkbutton =
                builder.get_object ("insert_spaces_checkbutton");
            GLib.Object hl_current_line_checkbutton =
                builder.get_object ("hl_current_line_checkbutton");
            GLib.Object bracket_matching_checkbutton =
                builder.get_object ("bracket_matching_checkbutton");

            // bind settings
            GLib.Settings settings =
                new GLib.Settings ("org.gnome.latexila.preferences.editor");

            settings.bind ("tabs-size", tab_width_spinbutton, "value",
                SettingsBindFlags.GET | SettingsBindFlags.SET);
            settings.bind ("insert-spaces", insert_spaces_checkbutton, "active",
                SettingsBindFlags.GET | SettingsBindFlags.SET);
            settings.bind ("display-line-numbers", display_line_nb_checkbutton, "active",
                SettingsBindFlags.GET | SettingsBindFlags.SET);
            settings.bind ("highlight-current-line", hl_current_line_checkbutton,
                "active", SettingsBindFlags.GET | SettingsBindFlags.SET);
            settings.bind ("bracket-matching", bracket_matching_checkbutton, "active",
                SettingsBindFlags.GET | SettingsBindFlags.SET);

            // pack notebook
            Box content_area = (Box) get_content_area ();
            content_area.pack_start (notebook, false, false, 0);
            ((Container) notebook).border_width = 5;
        }
        catch (Error e)
        {
            string message = "Error: %s".printf (e.message);
            stderr.printf ("%s\n", message);

            Label label_error = new Label (message);
            label_error.set_line_wrap (true);
            Box content_area = (Box) get_content_area ();
            content_area.pack_start (label_error, true, true, 0);
        }
    }

    public static void show_me (MainWindow parent)
    {
        if (preferences_dialog == null)
        {
            preferences_dialog = new PreferencesDialog ();

            // FIXME how to connect Widget.destroyed?
            preferences_dialog.destroy.connect (() =>
            {
                if (preferences_dialog != null)
                    preferences_dialog = null;
            });
        }

        if (parent != preferences_dialog.get_transient_for ())
            preferences_dialog.set_transient_for (parent);

        preferences_dialog.present ();
    }
}

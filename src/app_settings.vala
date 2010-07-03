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

public class AppSettings : GLib.Settings
{
    private Settings editor;
    //private Settings desktop_interface;

    public AppSettings ()
    {
        Object (schema: "org.gnome.latexila");
        initialize ();
    }

    private void initialize ()
    {
        Settings prefs = get_child ("preferences");
        editor = prefs.get_child ("editor");
        //desktop_interface = new Settings ("org.gnome.Desktop.Interface");

        editor.changed["tabs-size"].connect ((setting, key) =>
        {
            Variant variant = setting.get_value (key);
            uint val = variant.get_uint32 ();
            val = val.clamp (1, 24);

            List<DocumentView> views = Application.get_default ().get_views ();
            foreach (DocumentView view in views)
                view.tab_width = val;
        });

        editor.changed["insert-spaces"].connect ((setting, key) =>
        {
            bool val = setting.get_boolean (key);

            List<DocumentView> views = Application.get_default ().get_views ();
            foreach (DocumentView view in views)
                view.insert_spaces_instead_of_tabs = val;
        });

        editor.changed["display-line-numbers"].connect ((setting, key) =>
        {
            bool val = setting.get_boolean (key);

            List<DocumentView> views = Application.get_default ().get_views ();
            foreach (DocumentView view in views)
                view.show_line_numbers = val;
        });

        editor.changed["highlight-current-line"].connect ((setting, key) =>
        {
            bool val = setting.get_boolean (key);

            List<DocumentView> views = Application.get_default ().get_views ();
            foreach (DocumentView view in views)
                view.highlight_current_line = val;
        });

        editor.changed["bracket-matching"].connect ((setting, key) =>
        {
            bool val = setting.get_boolean (key);

            List<Document> docs = Application.get_default ().get_documents ();
            foreach (Document doc in docs)
                doc.highlight_matching_brackets = val;
        });
    }
}

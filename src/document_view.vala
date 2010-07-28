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

public class DocumentView : Gtk.SourceView
{
    public bool readonly { get; set; default = false; }
    public const double SCROLL_MARGIN = 0.02;

    private GLib.Settings editor_settings;
    private Pango.FontDescription font_desc;

    public DocumentView (Document doc)
    {
        this.buffer = doc;

        notify["readonly"].connect (() => this.editable = !readonly);

        wrap_mode = WrapMode.WORD;
        auto_indent = true;
        indent_width = -1;

        /* settings */
        editor_settings = new GLib.Settings ("org.gnome.latexila.preferences.editor");

        set_font_from_settings ();

        // tab width
        uint tmp;
        editor_settings.get ("tabs-size", "u", out tmp);
        tab_width = tmp;

        insert_spaces_instead_of_tabs = editor_settings.get_boolean ("insert-spaces");
        show_line_numbers = editor_settings.get_boolean ("display-line-numbers");
        highlight_current_line = editor_settings.get_boolean ("highlight-current-line");
        doc.highlight_matching_brackets =
            editor_settings.get_boolean ("bracket-matching");
        doc.set_style_scheme_from_string (editor_settings.get_string ("scheme"));
    }

    public void scroll_to_cursor (double margin = 0.25)
    {
        scroll_to_mark (this.buffer.get_insert (), margin, false, 0, 0);
    }

    public void cut_selection ()
    {
        return_if_fail (this.buffer != null);
        var clipboard = get_clipboard (Gdk.SELECTION_CLIPBOARD);
        this.buffer.cut_clipboard (clipboard, ! readonly);
        scroll_to_cursor (SCROLL_MARGIN);
        grab_focus ();
    }

    public void copy_selection ()
    {
        return_if_fail (this.buffer != null);
        var clipboard = get_clipboard (Gdk.SELECTION_CLIPBOARD);
        this.buffer.copy_clipboard (clipboard);
        grab_focus ();
    }

    public void my_paste_clipboard ()
    {
        return_if_fail (this.buffer != null);
        var clipboard = get_clipboard (Gdk.SELECTION_CLIPBOARD);
        this.buffer.paste_clipboard (clipboard, null, ! readonly);
        scroll_to_cursor (SCROLL_MARGIN);
        grab_focus ();
    }

    public void delete_selection ()
    {
        return_if_fail (this.buffer != null);
        this.buffer.delete_selection (true, ! readonly);
        scroll_to_cursor (SCROLL_MARGIN);
    }

    public void my_select_all ()
    {
        return_if_fail (this.buffer != null);
        TextIter start, end;
        this.buffer.get_bounds (out start, out end);
        this.buffer.select_range (start, end);
    }

    // TODO when GtkSourceView 3.0 is released we can delete this function
    public uint my_get_visual_column (TextIter iter)
    {
        uint column = 0;
        uint tab_width = get_tab_width ();

        var position = iter;
        position.set_visible_line_offset (0);

        while (! iter.equal (position))
        {
            if (position.get_char () == '\t')
                column += (tab_width - (column % tab_width));
            else
                column++;

            if (! position.forward_visible_cursor_position ())
                break;
        }

        return column;
    }

    public void set_font_from_settings ()
    {
        string font;
        if (editor_settings.get_boolean ("use-default-font"))
            font = Application.get_default ().settings.get_system_font ();
        else
            font = editor_settings.get_string ("editor-font");

        set_font_from_string (font);
    }

    public void set_font_from_string (string font)
    {
        font_desc = Pango.FontDescription.from_string (font);
        modify_font (font_desc);
    }

    public void enlarge_font ()
    {
        // this is not saved in the settings
        font_desc.set_size (font_desc.get_size () + Pango.SCALE);
        modify_font (font_desc);
    }

    public void shrink_font ()
    {
        // this is not saved in the settings
        font_desc.set_size (font_desc.get_size () - Pango.SCALE);
        modify_font (font_desc);
    }
}

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

    public DocumentView (Document doc)
    {
        set_buffer (doc);
        show_line_numbers = true;
        notify["readonly"].connect (() => { set_editable (! readonly); });
    }

    public void scroll_to_cursor (double margin = 0.25)
    {
        scroll_to_mark (this.buffer.get_insert (), margin, false, 0, 0);
    }

    public void cut_selection ()
    {
        TextBuffer buffer = get_buffer ();
        return_if_fail (buffer != null);
        var clipboard = get_clipboard (Gdk.SELECTION_CLIPBOARD);
        buffer.cut_clipboard (clipboard, ! readonly);
        scroll_to_cursor (SCROLL_MARGIN);
        grab_focus ();
    }

    public void copy_selection ()
    {
        TextBuffer buffer = get_buffer ();
        return_if_fail (buffer != null);
        var clipboard = get_clipboard (Gdk.SELECTION_CLIPBOARD);
        buffer.copy_clipboard (clipboard);
        grab_focus ();
    }

    public void my_paste_clipboard ()
    {
        TextBuffer buffer = get_buffer ();
        return_if_fail (buffer != null);
        var clipboard = get_clipboard (Gdk.SELECTION_CLIPBOARD);
        buffer.paste_clipboard (clipboard, null, ! readonly);
        scroll_to_cursor (SCROLL_MARGIN);
        grab_focus ();
    }

    public void delete_selection ()
    {
        TextBuffer buffer = get_buffer ();
        return_if_fail (buffer != null);
        buffer.delete_selection (true, ! readonly);
        scroll_to_cursor (SCROLL_MARGIN);
    }

    public void my_select_all ()
    {
        TextBuffer buffer = get_buffer ();
        return_if_fail (buffer != null);
        TextIter start, end;
        buffer.get_bounds (out start, out end);
        buffer.select_range (start, end);
    }

    // TODO when GtkSourceView 3.0 is released we can delete this function
    public uint my_get_visual_column (TextIter iter)
    {
        uint column = 0;
        uint tab_width = get_tab_width ();

        TextIter position = iter;
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
}

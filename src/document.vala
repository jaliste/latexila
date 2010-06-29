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

public class Document : Gtk.SourceBuffer
{
    public File location { get; set; }
    public DocumentTab tab;
    public uint unsaved_document_n { get; set; }

    public Document ()
    {
        // syntax highlighting: LaTeX by default
        var lm = Gtk.SourceLanguageManager.get_default ();
        set_language (lm.get_language ("latex"));

        notify["location"].connect (update_syntax_highlighting);
    }

    public void load (File location)
    {
        this.location = location;

        try
        {
            string text;
            location.load_contents (null, out text, null, null);
            begin_not_undoable_action ();
            set_text (text, -1);
            end_not_undoable_action ();
            Utils.flush_queue ();
            set_modified (false);

            // move the cursor at the first line
            TextIter iter;
            get_start_iter (out iter);
            place_cursor (iter);

            update_syntax_highlighting ();
        }
        catch (Error e)
        {
            stderr.printf ("Error: %s\n", e.message);

            string primary_msg = _("Impossible to load the file '%s'.")
                .printf (location.get_parse_name ());
            tab.add_message (primary_msg, e.message, MessageType.ERROR);
        }
    }

    public void save ()
    {
        assert (location != null);

        // we use get_text () to exclude undisplayed text
        TextIter start, end;
        get_bounds (out start, out end);
        string text = get_text (start, end, false);

        try
        {
            // TODO avoid get_path(), use GIO
            FileUtils.set_contents (location.get_path (), text);
            set_modified (false);
        }
        catch (FileError e)
        {
            stderr.printf ("Error: %s\n", e.message);

            string primary_msg = _("Impossible to save the file.");
            var infobar = tab.add_message (primary_msg, e.message, MessageType.ERROR);
            DocumentTab.infobar_add_ok_button (infobar);
        }
    }

    private void update_syntax_highlighting ()
    {
        Gtk.SourceLanguageManager lm = Gtk.SourceLanguageManager.get_default ();
        string content_type = null;
        try
        {
            FileInfo info = location.query_info (FILE_ATTRIBUTE_STANDARD_CONTENT_TYPE,
                FileQueryInfoFlags.NONE, null);
            content_type = info.get_content_type ();
        }
        catch (Error e) {}

        var lang = lm.guess_language (location.get_parse_name (), content_type);
        set_language (lang);
    }

    public string get_unsaved_document_name ()
    {
        return _("Unsaved Document") + " %u".printf (unsaved_document_n);
    }
}

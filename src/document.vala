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
    private TimeVal mtime;

    private bool stop_cursor_moved_emission = false;
    public signal void cursor_moved ();

    public Document ()
    {
        // syntax highlighting: LaTeX by default
        var lm = Gtk.SourceLanguageManager.get_default ();
        set_language (lm.get_language ("latex"));

        notify["location"].connect (update_syntax_highlighting);
        mark_set.connect ((location, mark) =>
        {
            if (mark == get_insert ())
                emit_cursor_moved ();
        });
        changed.connect (emit_cursor_moved);

        mtime = { 0, 0 };
    }

    public void load (File location)
    {
        this.location = location;

        try
        {
            string text;
            location.load_contents (null, out text, null, null);

            mtime = get_modification_time ();

            begin_not_undoable_action ();
            set_text (text, -1);
            Utils.flush_queue ();
            set_modified (false);
            end_not_undoable_action ();

            // move the cursor at the first line
            TextIter iter;
            get_start_iter (out iter);
            place_cursor (iter);

            update_syntax_highlighting ();

            RecentManager.get_default ().add_item (location.get_uri ());
        }
        catch (Error e)
        {
            stderr.printf ("Error: %s\n", e.message);

            string primary_msg = _("Impossible to load the file '%s'.")
                .printf (location.get_parse_name ());
            tab.add_message (primary_msg, e.message, MessageType.ERROR);
        }
    }

    public void save (bool check_file_changed_on_disk = true)
    {
        assert (location != null);

        if (check_file_changed_on_disk && is_externally_modified ())
        {
            string primary_msg = _("The file %s has been modified since reading it.")
                .printf (location.get_parse_name ());
            string secondary_msg = _("If you save it, all the external changes could be lost. Save it anyway?");
            TabInfoBar infobar = tab.add_message (primary_msg, secondary_msg,
                MessageType.WARNING);
            infobar.add_stock_button_with_text (_("Save Anyway"), STOCK_SAVE,
                ResponseType.YES);
            infobar.add_button (_("Don't Save"), ResponseType.CANCEL);
            infobar.response.connect ((response_id) =>
            {
                if (response_id == ResponseType.YES)
                    save (false);
                infobar.destroy ();
            });
            return;
        }

        // we use get_text () to exclude undisplayed text
        TextIter start, end;
        get_bounds (out start, out end);
        string text = get_text (start, end, false);

        try
        {
            location.replace_contents (text, text.length, null, false,
                FileCreateFlags.NONE, null, null);
            mtime = get_modification_time ();
            set_modified (false);

            RecentManager.get_default ().add_item (location.get_uri ());
        }
        catch (Error e)
        {
            stderr.printf ("Error: %s\n", e.message);

            string primary_msg = _("Impossible to save the file.");
            TabInfoBar infobar = tab.add_message (primary_msg, e.message, MessageType.ERROR);
            infobar.add_ok_button ();
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

    public bool is_local ()
    {
        if (location == null)
            return false;
        return location.has_uri_scheme ("file");
    }

    public bool is_externally_modified ()
    {
        if (location == null)
            return false;

        TimeVal timeval = get_modification_time ();

        return (timeval.tv_sec > mtime.tv_sec) ||
            (timeval.tv_sec == mtime.tv_sec && timeval.tv_usec > mtime.tv_usec);
    }

    public void set_style_scheme_from_string (string scheme_id)
    {
        SourceStyleSchemeManager manager = SourceStyleSchemeManager.get_default ();
        style_scheme = manager.get_scheme (scheme_id);
    }

    private TimeVal get_modification_time ()
    {
        TimeVal timeval = { 0, 0 };
        try
        {
            FileInfo info = location.query_info (FILE_ATTRIBUTE_TIME_MODIFIED,
                FileQueryInfoFlags.NONE, null);
            if (info.has_attribute (FILE_ATTRIBUTE_TIME_MODIFIED))
            {
                info.get_modification_time (out timeval);
                return timeval;
            }
        }
        catch (Error e) {}
        return timeval;
    }

    private void emit_cursor_moved ()
    {
        if (! stop_cursor_moved_emission)
            cursor_moved ();
    }
}

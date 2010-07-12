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

    private TextTag found_tag;
    private TextTag found_tag_selected;
    public signal void search_info_updated (bool selected, uint nb_matches,
        uint num_match);
    private string search_text;
    private uint search_nb_matches;
    private uint search_num_match;
    private bool search_case_sensitive;
    private bool search_entire_word;
    //private TextMark search_delete_tag_start;
    //private TextMark search_delete_tag_end;

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

        found_tag = new TextTag ("found");
        found_tag_selected = new TextTag ("found_selected");
        found_tag.background = "#FF8800";
        found_tag_selected.background = "#FFFF00";
        TextTagTable tag_table = get_tag_table ();
        tag_table.add (found_tag);
        tag_table.add (found_tag_selected);

        TextIter iter;
        get_iter_at_line (out iter, 0);
        create_mark ("search_selected_start", iter, true);
        create_mark ("search_selected_end", iter, true);
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
            // Attention, the second parameter named "length" in the API is the size in
            // bytes, not the number of characters, so we must use text.size() and not
            // text.length.
            location.replace_contents (text, text.size (), null, false,
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

    public string get_uri_for_display ()
    {
        if (location == null)
            return get_unsaved_document_name ();

        return Utils.replace_home_dir_with_tilde (location.get_parse_name ());
    }

    public string get_short_name_for_display ()
    {
        if (location == null)
            return get_unsaved_document_name ();

        return location.get_basename ();
    }

    private string get_unsaved_document_name ()
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

    private void insert_text_at_beginning_of_selected_lines (string text)
    {
        TextIter start, end;
        get_selection_bounds (out start, out end);

        int start_line = start.get_line ();
        int end_line = end.get_line ();

        begin_user_action ();
        for (int i = start_line ; i <= end_line ; i++)
        {
            TextIter iter;
            get_iter_at_line (out iter, i);
            insert (iter, text, -1);
        }
        end_user_action ();
    }

    public void comment_selected_lines ()
    {
        insert_text_at_beginning_of_selected_lines ("% ");
    }

    public void uncomment_selected_lines ()
    {
        TextIter start, end;
        get_selection_bounds (out start, out end);

        int start_line = start.get_line ();
        int end_line = end.get_line ();
        int line_count = get_line_count ();

        begin_user_action ();

        for (int i = start_line ; i <= end_line ; i++)
        {
            get_iter_at_line (out start, i);

            // if last line
            if (i == line_count - 1)
                get_end_iter (out end);
            else
                get_iter_at_line (out end, i + 1);

            string line = get_text (start, end, false);

            /* find the first '%' character */
            int j = 0;
            int start_delete = -1;
            int stop_delete = -1;
            while (line[j] != '\0')
            {
                if (line[j] == '%')
                {
                    start_delete = j;
                    stop_delete = j + 1;
                    if (line[j + 1] == ' ')
                        stop_delete++;
                    break;
                }

                else if (line[j] != ' ' && line[j] != '\t')
                    break;

                j++;
            }

            if (start_delete == -1)
                continue;

            get_iter_at_line_offset (out start, i, start_delete);
            get_iter_at_line_offset (out end, i, stop_delete);
            this.delete (start, end);
        }

        end_user_action ();
    }

    // If line is bigger than the number of lines of the document, the cursor is moved
    // to the last line and false is returned.
    public bool goto_line (int line)
    {
        return_val_if_fail (line >= -1, false);

        bool ret = true;
        TextIter iter;

        if (line >= get_line_count ())
        {
            ret = false;
            get_end_iter (out iter);
        }
        else
            get_iter_at_line (out iter, line);

        place_cursor (iter);
        return ret;
    }


    /***************
     *    SEARCH
     ***************/

    public void set_search_text (string text, bool case_sensitive, bool entire_word,
        out uint nb_matches, out uint num_match, bool select = true)
    {
        // connect signals
        if (search_text == null)
        {
            cursor_moved.connect (search_cursor_moved_handler);
            delete_range.connect (search_delete_range_before_handler);
            delete_range.connect_after (search_delete_range_after_handler);
            insert_text.connect (search_insert_text_before_handler);
            insert_text.connect_after (search_insert_text_after_handler);
        }

        // if nothing has changed
        if (search_text == text
            && search_case_sensitive == case_sensitive
            && search_entire_word == entire_word)
        {
            nb_matches = search_nb_matches;
            num_match = search_num_match;
            return;
        }

        clear_search (false);
        search_text = text;
        search_case_sensitive = case_sensitive;
        search_entire_word = entire_word;

        var flags = get_search_flags ();

        TextIter start, match_start, match_end, insert;
        get_start_iter (out start);
        get_iter_at_mark (out insert, get_insert ());
        bool next_match_after_cursor_found = ! select;
        uint i = 0;

        while (source_iter_forward_search (start, text, flags, out match_start,
            out match_end, null))
        {
            i++;
            if (! next_match_after_cursor_found && insert.compare (match_end) <= 0)
            {
                next_match_after_cursor_found = true;
                search_num_match = num_match = i;
                move_search_marks (match_start, match_end, true);
            }
            else
                apply_tag (found_tag, match_start, match_end);

            start = match_end;
        }

        search_nb_matches = nb_matches = i;
    }

    public void search_forward ()
    {
        return_if_fail (search_text != null);

        if (search_nb_matches == 0)
            return;

        var flags = get_search_flags ();

        TextIter start_search, start, match_start, match_end;
        get_iter_at_mark (out start_search, get_insert ());
        get_start_iter (out start);

        bool increment = false;
        if (start_search.has_tag (found_tag_selected))
        {
            get_iter_at_mark (out start_search, get_mark ("search_selected_end"));
            increment = true;
        }

        replace_found_tag_selected ();

        // search forward
        if (source_iter_forward_search (start_search, search_text, flags, out match_start,
            out match_end, null))
        {
            move_search_marks (match_start, match_end, true);

            if (increment)
            {
                search_num_match++;
                search_info_updated (true, search_nb_matches, search_num_match);
                return;
            }
        }

        else if (source_iter_forward_search (start, search_text, flags, out match_start,
            out match_end, null))
        {
            move_search_marks (match_start, match_end, true);

            search_num_match = 1;
            search_info_updated (true, search_nb_matches, search_num_match);
            return;
        }

        find_num_match ();
    }

    public void search_backward ()
    {
        return_if_fail (search_text != null);

        if (search_nb_matches == 0)
            return;

        var flags = get_search_flags ();

        TextIter start_search, end, match_start, match_end;
        get_iter_at_mark (out start_search, get_insert ());
        get_end_iter (out end);

        bool decrement = false;
        bool move_cursor = true;

        TextIter start_prev = start_search;
        start_prev.backward_char ();

        // the cursor is on a match
        if (start_search.has_tag (found_tag_selected) ||
            start_prev.has_tag (found_tag_selected))
        {
            get_iter_at_mark (out start_search, get_mark ("search_selected_start"));
            decrement = true;
        }

        // the user has clicked in the middle or at the beginning of a match
        else if (start_search.has_tag (found_tag))
        {
            move_cursor = false;
            start_search.forward_chars ((int) search_text.length);
        }

        // the user has clicked at the end of a match
        else if (start_prev.has_tag (found_tag))
            move_cursor = false;

        replace_found_tag_selected ();

        // search backward
        if (source_iter_backward_search (start_search, search_text, flags,
            out match_start, out match_end, null))
        {
            move_search_marks (match_start, match_end, move_cursor);

            if (decrement)
            {
                search_num_match--;
                search_info_updated (true, search_nb_matches, search_num_match);
                return;
            }
        }

        // take the last match
        else if (source_iter_backward_search (end, search_text, flags, out match_start,
            out match_end, null))
        {
            move_search_marks (match_start, match_end, true);

            search_num_match = search_nb_matches;
            search_info_updated (true, search_nb_matches, search_num_match);
            return;
        }

        find_num_match ();
    }

    public void clear_search (bool disconnect_signals = true)
    {
        TextIter start, end;
        get_bounds (out start, out end);
        remove_tag (found_tag, start, end);
        remove_tag (found_tag_selected, start, end);
        search_text = null;

        if (disconnect_signals)
        {
            cursor_moved.disconnect (search_cursor_moved_handler);
            delete_range.disconnect (search_delete_range_before_handler);
            delete_range.disconnect (search_delete_range_after_handler);
            insert_text.disconnect (search_insert_text_before_handler);
            insert_text.disconnect (search_insert_text_after_handler);
        }
    }

    private void search_cursor_moved_handler ()
    {
        TextIter insert, insert_previous;
        get_iter_at_mark (out insert, get_insert ());
        insert_previous = insert;
        insert_previous.backward_char ();
        if (insert.has_tag (found_tag_selected) ||
            insert_previous.has_tag (found_tag_selected))
            return;

        replace_found_tag_selected ();

        if (insert.has_tag (found_tag) || insert_previous.has_tag (found_tag))
            search_backward ();
        else
            search_info_updated (false, search_nb_matches, 0);
    }

    private void search_delete_range_before_handler (TextIter start, TextIter end)
    {
        TextIter start_search, stop_search, match_start, match_end;
        start_search = start;
        start_search.backward_chars ((int) search_text.length - 1);
        stop_search = end;
        stop_search.forward_chars ((int) search_text.length - 1);

        invalidate_search_selected_marks ();

        var flags = get_search_flags ();

        while (source_iter_forward_search (start_search, search_text, flags,
            out match_start, out match_end, stop_search))
        {
            if (match_start.compare (start) < 0 || match_end.compare (end) > 0)
            {
                remove_tag (found_tag, match_start, match_end);
                remove_tag (found_tag_selected, match_start, match_end);
            }

            search_nb_matches--;
            start_search = match_end;
        }
    }

    private void search_delete_range_after_handler (TextIter location)
    {
        TextIter start_search, stop_search;
        start_search = stop_search = location;
        start_search.backward_chars ((int) search_text.length - 1);
        stop_search.forward_chars ((int) search_text.length - 1);

        search_matches_between (start_search, stop_search);
    }

    private void search_insert_text_before_handler (TextIter location)
    {
        // if text inserted in the middle of a current match, remove the tags

        if (location.has_tag (found_tag) || location.has_tag (found_tag_selected))
        {
            replace_found_tag_selected ();
            invalidate_search_selected_marks ();

            TextIter start_search, match_start, match_end;
            start_search = location;
            start_search.forward_chars ((int) search_text.length - 1);
            if (source_iter_backward_search (start_search, search_text, get_search_flags (),
                out match_start, out match_end, null))
            {
                // in the middle
                if (location.compare (match_end) < 0)
                {
                    remove_tag (found_tag, match_start, match_end);
                    remove_tag (found_tag_selected, match_start, match_end);
                    search_nb_matches--;
                }

                // ugly hack
                // if location is between two matches
                else if (location.compare (match_end) == 0)
                {
                    string search_text_backup = search_text;
                    uint nb_matches, num_match;
                    clear_search ();
                    set_search_text (search_text_backup, search_case_sensitive,
                        search_entire_word, out nb_matches, out num_match);
                    search_info_updated (true, nb_matches, num_match);
                    place_cursor (location);
                }
            }
        }
    }

    private void search_insert_text_after_handler (TextIter location, string text, int len)
    {
        TextIter start_search, stop_search;
        start_search = stop_search = location;
        start_search.backward_chars (len + (int) search_text.length - 1);
        stop_search.forward_chars ((int) search_text.length - 1);

        search_matches_between (start_search, stop_search);
    }

    private void search_matches_between (TextIter start_search, TextIter stop_search)
    {
        TextIter match_start, match_end;

        var flags = get_search_flags ();

        while (source_iter_forward_search (start_search, search_text, flags,
            out match_start, out match_end, stop_search))
        {
            apply_tag (found_tag, match_start, match_end);
            search_nb_matches++;
            start_search = match_end;
        }

        // simulate a cursor move
        search_cursor_moved_handler ();
    }

    private SourceSearchFlags get_search_flags ()
    {
        var flags = SourceSearchFlags.TEXT_ONLY | SourceSearchFlags.VISIBLE_ONLY;
        if (! search_case_sensitive)
            flags |= SourceSearchFlags.CASE_INSENSITIVE;
        return flags;
    }

    private void move_search_marks (TextIter start, TextIter end, bool move_cursor)
    {
        remove_tag (found_tag, start, end);
        apply_tag (found_tag_selected, start, end);

        move_mark_by_name ("search_selected_start", start);
        move_mark_by_name ("search_selected_end", end);

        if (move_cursor)
        {
            place_cursor (start);
            tab.view.scroll_to_cursor ();
        }
    }

    private void replace_found_tag_selected ()
    {
        TextIter start, end;
        get_iter_at_mark (out start, get_mark ("search_selected_start"));
        get_iter_at_mark (out end, get_mark ("search_selected_end"));
        remove_tag (found_tag_selected, start, end);

        apply_tag (found_tag, start, end);
    }

    private void find_num_match ()
    {
        TextIter start, stop, match_end;
        get_start_iter (out start);
        get_iter_at_mark (out stop, get_mark ("search_selected_start"));

        var flags = get_search_flags ();

        uint i = 0;
        while (source_iter_forward_search (start, search_text, flags, null,
            out match_end, stop))
        {
            i++;
            start = match_end;
        }

        search_num_match = i + 1;
        search_info_updated (true, search_nb_matches, search_num_match);
    }

    private void invalidate_search_selected_marks ()
    {
        TextIter iter;
        get_start_iter (out iter);
        move_mark_by_name ("search_selected_start", iter);
        move_mark_by_name ("search_selected_end", iter);
    }
}

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

public enum OutputMessageType
{
    OTHER, BADBOX, WARNING, ERROR
}

public enum OutputLineColumn
{
    BASENAME,
    FILENAME,
    LINE_NUMBER,
    MESSAGE,
    MESSAGE_TYPE,
    COLOR,
    BG_COLOR,
    WEIGHT,
    N_COLUMNS
}

public class LogZone : HPaned
{
    private TreeView history_view;
    private TreeView output_view;
    private LogStore current_log_store;
    private int action_num = 1;

    private Action action_previous_msg;
    private Action action_next_msg;

    enum HistoryActionColumn
    {
        TITLE,
        OUTPUT_STORE,
        N_COLUMNS
    }

    public bool show_errors { get; set; }
    public bool show_warnings { get; set; }
    public bool show_badboxes { get; set; }

    public LogZone (Toolbar log_toolbar, Action previous_msg, Action next_msg)
    {
        action_previous_msg = previous_msg;
        action_next_msg = next_msg;

        /* action history */
        TreeStore history_tree_store = new TreeStore (HistoryActionColumn.N_COLUMNS,
            typeof (string), typeof (TreeModelFilter));

        history_view = new TreeView.with_model (history_tree_store);
        var renderer = new CellRendererText ();
        TreeViewColumn column = new TreeViewColumn.with_attributes (_("Action History"),
            renderer, "text", HistoryActionColumn.TITLE, null);
        history_view.append_column (column);

        TreeSelection select = history_view.get_selection ();
        select.set_mode (SelectionMode.SINGLE);
        select.changed.connect ((selection) =>
        {
            TreeIter iter;
            TreeModel history_model;
            if (selection.get_selected (out history_model, out iter))
            {
                TreeModelFilter output_model;
                history_model.get (iter,
                    HistoryActionColumn.OUTPUT_STORE, out output_model,
                    -1);

                // disconnect scroll signal from current model
                current_log_store.scroll_and_flush.disconnect (on_scroll_and_flush);

                output_model.refilter ();
                output_view.set_model (output_model);

                current_log_store = (LogStore) output_model.child_model;
                current_log_store.scroll_and_flush.connect (on_scroll_and_flush);

                output_view.columns_autosize ();
                current_log_store.scroll_to_selected_row ();
                set_previous_next_actions_sensitivity ();
            }
        });

        var sw = Utils.add_scrollbar (history_view);
        add1 (sw);

        /* log details */
        current_log_store = new LogStore ();
        current_log_store.print_output_normal (_("Welcome to LaTeXila!"));

        TreeModelFilter output_filter = new TreeModelFilter (current_log_store, null);
        output_filter.set_visible_func (filter_visible_func);

        output_view = new TreeView.with_model (output_filter);
        output_view.set_headers_visible (false);
        output_view.set_tooltip_column (OutputLineColumn.FILENAME);

        // one column with 3 cell renderers (basename, line number, and message)
        column = new TreeViewColumn ();
        output_view.append_column (column);

        // basename
        CellRendererText renderer1 = new CellRendererText ();
        renderer1.weight_set = true;
        column.pack_start (renderer1, false);
        column.set_attributes (renderer1,
            "text", OutputLineColumn.BASENAME,
            "foreground", OutputLineColumn.COLOR,
            "background", OutputLineColumn.BG_COLOR,
            "weight", OutputLineColumn.WEIGHT,
            null);

        // line number
        CellRendererText renderer2 = new CellRendererText ();
        renderer2.weight_set = true;
        column.pack_start (renderer2, false);
        column.set_attributes (renderer2,
            "text", OutputLineColumn.LINE_NUMBER,
            "foreground", OutputLineColumn.COLOR,
            "background", OutputLineColumn.BG_COLOR,
            "weight", OutputLineColumn.WEIGHT,
            null);

        // message
        CellRendererText renderer3 = new CellRendererText ();
        renderer3.weight_set = true;
        column.pack_start (renderer3, false);
        column.set_attributes (renderer3,
            "text", OutputLineColumn.MESSAGE,
            "foreground", OutputLineColumn.COLOR,
            "background", OutputLineColumn.BG_COLOR,
            "weight", OutputLineColumn.WEIGHT,
            null);

        // selection
        select = output_view.get_selection ();
        select.set_mode (SelectionMode.SINGLE);

        // If the user clicks on a row, output_row_selection_func() will be
		// called, but no row will be selected (the function returns always FALSE).
		// Instead, if the row can be "selected" (if the message
		// type is an error, a warning or a badbox, and if the filename is not
		// empty), the background and foreground colors are inverted.
        select.set_select_function (output_row_selection_func);

        sw = Utils.add_scrollbar (output_view);
        HBox hbox = new HBox (false, 0);
        hbox.pack_start (sw);
        hbox.pack_start (log_toolbar, false, false, 0);
        add2 (hbox);

        /* show errors/warnings/badboxes */
        notify["show-errors"].connect (on_show_property_changed);
        notify["show-warnings"].connect (on_show_property_changed);
        notify["show-badboxes"].connect (on_show_property_changed);
    }

    private bool filter_visible_func (TreeModel model, TreeIter iter)
    {
        OutputMessageType msg_type;
        model.get (iter, OutputLineColumn.MESSAGE_TYPE, out msg_type, -1);

        switch (msg_type)
        {
            case OutputMessageType.ERROR:
                return show_errors;
            case OutputMessageType.WARNING:
                return show_warnings;
            case OutputMessageType.BADBOX:
                return show_badboxes;
            default:
                return true;
        }
    }

    private void on_show_property_changed ()
    {
        return_if_fail (output_view != null);
        TreeModelFilter filter = (TreeModelFilter) output_view.get_model ();
        filter.refilter ();
        set_previous_next_actions_sensitivity ();
    }

    public LogStore add_simple_action (string title)
    {
        return add_action_full (title, false, null, null, null, null);
    }

    public LogStore add_parent_action (string title, out TreePath path)
    {
        return add_action_full (title, true, out path, null, null, null);
    }

    public LogStore add_child_action (string title, TreePath parent, int step,
        int nb_steps)
    {
        return add_action_full (title, false, null, parent, step, nb_steps);
    }

    private LogStore add_action_full (string title, bool set_path,
        out TreePath? path_to_set, TreePath? parent, int? step, int? nb_steps)
    {
        LogStore log_store = new LogStore ();
        TreeModelFilter filter = new TreeModelFilter (log_store, null);
        filter.set_visible_func (filter_visible_func);

        // print title to the new list store
        string log_store_title;
        if (step != null && nb_steps != null)
            log_store_title = "%s (step %d of %d)".printf (title, step, nb_steps);
        else
            log_store_title = "%d. %s".printf (action_num, title);

        log_store.print_output_title (log_store_title);

        string history_title = log_store_title;
        if (parent != null)
            history_title = title;

        // append a new entry to the history action tree
        TreeStore history_model = (TreeStore) history_view.get_model ();
        TreeIter iter, parent_iter;
        if (parent != null)
        {
            history_model.get_iter (out parent_iter, parent);
            history_model.append (out iter, parent_iter);
        }
        else
            history_model.append (out iter, null);
        history_model.set (iter,
            HistoryActionColumn.TITLE, history_title,
            HistoryActionColumn.OUTPUT_STORE, filter,
            -1);

        // select the new entry
        TreeSelection select = history_view.get_selection ();
        select.select_iter (iter);

        // scroll to the end
        TreePath path = history_model.get_path (iter);
        history_view.scroll_to_cell (path, null, false, 0, 0);

        if (set_path)
            path_to_set = path;

        // delete the first entry
        if (action_num > 5)
        {
            TreeIter first;
            history_model.get_iter_first (out first);
            history_model.remove (first);
        }

        if (parent == null)
            action_num++;
        else
        {
            history_view.collapse_all ();
            history_view.expand_to_path (parent);
        }
        return log_store;
    }

    private bool output_row_selection_func (TreeSelection selection, TreeModel filter,
        TreePath path, bool path_currently_selected)
    {
        TreeIter iter;
        if (filter.get_iter (out iter, path))
        {
            int msg_type;
            string filename;
            filter.get (iter,
                OutputLineColumn.FILENAME, out filename,
                OutputLineColumn.MESSAGE_TYPE, out msg_type,
                -1);

            if (msg_type != OutputMessageType.OTHER && filename != null
                && filename.length > 0)
            {
                TreeModelFilter filter2 = (TreeModelFilter) filter;
                TreeIter child_iter;
                filter2.convert_iter_to_child_iter (out child_iter, iter);

                LogStore model = (LogStore) filter2.child_model;
                model.select_row (child_iter);
                set_previous_next_actions_sensitivity ();
            }
        }

        // rows will never be selected
        return false;
    }

    private void on_scroll_and_flush (TreeIter iter)
    {
        return_if_fail (output_view != null);
        TreeModelFilter filter = (TreeModelFilter) output_view.get_model ();
        TreeIter filter_iter;
        if (filter.convert_child_iter_to_iter (out filter_iter, iter))
        {
            TreePath path = filter.get_path (filter_iter);
            output_view.scroll_to_cell (path, null, false, 0, 0);
            Utils.flush_queue ();
        }
    }

    public void go_to_message (bool next)
    {
        current_log_store.go_to_message (next, show_errors, show_warnings, show_badboxes);
        current_log_store.scroll_to_selected_row ();
        set_previous_next_actions_sensitivity ();
    }

    private void set_previous_next_actions_sensitivity ()
    {
        bool can_prev, can_next;
        current_log_store.can_go_to_previous_next_msg (out can_prev, out can_next,
            show_errors, show_warnings, show_badboxes);
        action_previous_msg.sensitive = can_prev;
        action_next_msg.sensitive = can_next;
    }
}

public class LogStore : ListStore
{
    private static const string COLOR_RED =     "#C00000";
    private static const string COLOR_ORANGE =  "#FF7200";
    private static const string COLOR_BROWN =   "#663106";
    private static const string COLOR_GREEN =   "#009900";
    private static const int WEIGHT_NORMAL = 400;
    private static const int WEIGHT_BOLD = 800;
    private static const string INFO_MESSAGE = "*****";

    private int nb_lines = 0;
    private TreeIter selected_row;
    private bool selected_row_valid = false;

    public signal void scroll_and_flush (TreeIter iter);

    struct MsgInfo
    {
        public OutputMessageType type;
        public TreeIter iter;
    }

    private MsgInfo[] index = {};

    public LogStore ()
    {
        Type[] types =
        {
            typeof (string),    // basename
            typeof (string),    // filename
            typeof (string),    // line number
            typeof (string),    // message
            typeof (OutputMessageType), // message type
            typeof (string),    // color
            typeof (string),    // background color
            typeof (int)        // weight
        };

        set_column_types (types);
    }

    public void print_output_title (string title)
    {
        print_output_info (title, true);
    }

    public void print_output_info (string info, bool title = false)
    {
        nb_lines++;

        TreeIter iter;
        append (out iter);
        set (iter,
            OutputLineColumn.BASENAME, INFO_MESSAGE,
            OutputLineColumn.LINE_NUMBER, "",
            OutputLineColumn.MESSAGE, info,
            OutputLineColumn.MESSAGE_TYPE, OutputMessageType.OTHER,
            OutputLineColumn.WEIGHT, title ? WEIGHT_BOLD : WEIGHT_NORMAL,
            -1);

        scroll_to_iter (iter);
    }

    public void print_output_stats (int nb_errors, int nb_warnings, int nb_badboxes)
    {
        print_output_info ("%d %s, %d %s, %d %s".printf (
            nb_errors, nb_errors > 1 ? "errors" : "error",
            nb_warnings, nb_warnings > 1 ? "warnings" : "warning",
            nb_badboxes, nb_badboxes > 1 ? "badboxes" : "badbox"));
    }

    public void print_output_exit (int exit_code, string? msg = null)
    {
        nb_lines++;

        TreeIter iter;
        append (out iter);
        set (iter,
            OutputLineColumn.BASENAME, INFO_MESSAGE,
            OutputLineColumn.LINE_NUMBER, "",
            OutputLineColumn.MESSAGE_TYPE, OutputMessageType.OTHER,
            OutputLineColumn.WEIGHT, WEIGHT_NORMAL,
            -1);

        if (msg != null)
        {
            set (iter,
                OutputLineColumn.MESSAGE, msg,
                OutputLineColumn.COLOR, COLOR_RED,
                -1);
        }
        else if (exit_code == 0)
        {
            set (iter,
                OutputLineColumn.MESSAGE, _("Done!"),
                OutputLineColumn.COLOR, COLOR_GREEN,
                -1);
        }
        else
        {
            string tmp = _("Finished with exit code %d").printf (exit_code);
            set (iter,
                OutputLineColumn.MESSAGE, tmp,
                OutputLineColumn.COLOR, COLOR_RED,
                -1);
        }

        // force the scrolling and the flush
        scroll_to_iter (iter, true);
    }

    public void print_output_message (string? filename, int? line_number, string msg,
        OutputMessageType msg_type)
    {
        nb_lines++;

        string basename = "";
        if (filename != null)
            basename = Path.get_basename (filename);

        string line = "";
        if (line_number != null)
            line = line_number.to_string ();

        string color;
        switch (msg_type)
        {
            case OutputMessageType.ERROR:
                color = COLOR_RED;
                break;
            case OutputMessageType.WARNING:
                color = COLOR_ORANGE;
                break;
            case OutputMessageType.BADBOX:
                color = COLOR_BROWN;
                break;
            default:
                color = null;
                break;
        }

        TreeIter iter;
        append (out iter);
        set (iter,
            OutputLineColumn.BASENAME, basename,
            OutputLineColumn.FILENAME, filename,
            OutputLineColumn.LINE_NUMBER, line,
            OutputLineColumn.MESSAGE, msg,
            OutputLineColumn.MESSAGE_TYPE, msg_type,
            OutputLineColumn.COLOR, color,
            OutputLineColumn.WEIGHT, WEIGHT_NORMAL,
            -1);

        scroll_to_iter (iter);

        // append to index
        MsgInfo index_info = { msg_type, iter };
        index += index_info;
    }

    public void print_output_normal (string msg)
    {
        nb_lines++;

        TreeIter iter;
        append (out iter);
        set (iter,
            OutputLineColumn.BASENAME, "",
            OutputLineColumn.LINE_NUMBER, "",
            OutputLineColumn.MESSAGE, msg,
            OutputLineColumn.MESSAGE_TYPE, OutputMessageType.OTHER,
            OutputLineColumn.WEIGHT, WEIGHT_NORMAL,
            -1);

        scroll_to_iter (iter);
    }

    private void scroll_to_iter (TreeIter iter, bool force = false)
    {
        /* Flush the queue for the 50 first lines and then every 40 lines.
	     * This is for the fluidity of the output, without that the lines do not
	     * appear directly and it's ugly. But it is very slow, for a command that
	     * execute for example in 10 seconds, it could take 250 seconds (!) if we
	     * flush the queue at each line... But with commands that take 1
	     * second or so there is not a big difference.
	     */
	    if (force || nb_lines < 50 || nb_lines % 40 == 0)
	        scroll_and_flush (iter);
    }

    public void scroll_to_selected_row ()
    {
        if (selected_row_valid)
            scroll_and_flush (selected_row);
    }

    public void select_row (TreeIter iter)
    {
        TreeModel model = (TreeModel) this;

        if (selected_row_valid)
        {
            // if the row to select is not the same as the row already selected,
		    // we must deselect this row
		    if (selected_row != iter)
		    {
		        // invert the colors
		        string bg_color;
		        model.get (selected_row,
		            OutputLineColumn.BG_COLOR, out bg_color,
		            -1);
                set (selected_row,
                    OutputLineColumn.COLOR, bg_color,
                    OutputLineColumn.BG_COLOR, null,
                    -1);
		    }
		    else
		        return;
        }

        // invert the colors
        string color;
        model.get (iter, OutputLineColumn.COLOR, out color, -1);
        set (iter,
            OutputLineColumn.COLOR, "white",
            OutputLineColumn.BG_COLOR, color,
            -1);

        selected_row = iter;
        selected_row_valid = true;
    }

    // for going to previous message: next=false
    public void go_to_message (bool next, bool error, bool warning, bool badbox)
    {
        return_if_fail (index.length > 0);

        // no row selected
        if (! selected_row_valid)
        {
            return_if_fail (next);

            // take the first
            for (int i = 0 ; i < index.length ; i++)
            {
                if (! msg_type_accepted (index[i].type, error, warning, badbox))
                    continue;

                select_row (index[i].iter);
                return;
            }
            return_if_reached ();
        }

        // used only when going to previous message
        int row_to_select = -1;

        for (int i = 0 ; i < index.length ; i++)
        {
            // if we are on the selected row
            if (index[i].iter == selected_row)
            {
                // if we go to the next message we search... the next ok message
                if (next)
                {
                    for (int j = i + 1 ; j < index.length ; j++)
                    {
                        if (! msg_type_accepted (index[j].type, error, warning, badbox))
                            continue;

                        select_row (index[j].iter);
                        return;
                    }
                    return_if_reached ();
                }

                // if we go to the previous message, we know already which row to select
                else
                {
                    return_if_fail (row_to_select != -1);
                    select_row (index[row_to_select].iter);
                    return;
                }
            }

            if (! next)
            {
                if (! msg_type_accepted (index[i].type, error, warning, badbox))
                    continue;

                // We are on a previous ok message, we save the position in the index so
                // if it is the last previous ok message we must not search it when we
                // reach the selected row.
                row_to_select = i;
            }
        }

        return_if_reached ();
    }

    private bool msg_type_accepted (OutputMessageType type, bool accept_error,
        bool accept_warning, bool accept_badbox)
    {
        return (accept_error && type == OutputMessageType.ERROR)
            || (accept_warning && type == OutputMessageType.WARNING)
            || (accept_badbox && type == OutputMessageType.BADBOX);
    }

    public void can_go_to_previous_next_msg (out bool can_prev, out bool can_next,
        bool accept_error, bool accept_warning, bool accept_badbox)
    {
        // no message
        if (index.length == 0)
        {
            can_prev = can_next = false;
            return;
        }

        // no row selected
        if (! selected_row_valid)
        {
            can_prev = false;
            can_next = true;
            return;
        }

        // a row is selected, can we go to a previous message?
        for (int i = 0 ; i < index.length ; i++)
        {
            if (index[i].iter == selected_row)
            {
                can_prev = false;
                break;
            }

            if (! msg_type_accepted (index[i].type, accept_error, accept_warning,
                accept_badbox))
                continue;

            can_prev = true;
            break;
        }

        // a row is selected, can we go to a next message?
        for (int i = index.length - 1 ; i >= 0 ; i--)
        {
            if (index[i].iter == selected_row)
            {
                can_next = false;
                break;
            }

            if (! msg_type_accepted (index[i].type, accept_error, accept_warning,
                accept_badbox))
                continue;

            can_next = true;
            break;
        }
    }
}

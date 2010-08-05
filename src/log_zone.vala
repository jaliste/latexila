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
    private int action_num = 1;

    enum HistoryActionColumn
    {
        TITLE,
        OUTPUT_STORE,
        N_COLUMNS
    }

    public LogZone ()
    {
        /* action history */
        ListStore history_list_store = new ListStore (HistoryActionColumn.N_COLUMNS,
            typeof (string), typeof (LogStore));

        history_view = new TreeView.with_model (history_list_store);
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
                LogStore output_model;
                history_model.get (iter,
                    HistoryActionColumn.OUTPUT_STORE, out output_model,
                    -1);

                // disconnect scroll signal from current model
                LogStore current_output_model = (LogStore) output_view.get_model ();
                current_output_model.scroll_and_flush.disconnect (on_scroll_and_flush);

                output_view.set_model (output_model);
                output_model.scroll_and_flush.connect (on_scroll_and_flush);

                output_view.columns_autosize ();
                output_model.scroll_to_selected_row ();
            }
        });

        var sw = Utils.add_scrollbar (history_view);
        add1 (sw);

        /* log details */
        LogStore output_list_store = new LogStore ();
        output_list_store.print_output_normal (_("Welcome to LaTeXila!"));

        output_view = new TreeView.with_model (output_list_store);
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
        add2 (sw);
    }

    public LogStore add_action (string title, string command)
    {
        LogStore log_store = new LogStore ();

        // print title and command to the new list store
        string title_with_num = "%d. %s".printf (action_num, title);
        log_store.print_output_title (title_with_num);
        log_store.print_output_info ("$ " + command);

        // append a new entry to the history action list
        ListStore history_model = (ListStore) history_view.get_model ();
        TreeIter iter;
        history_model.append (out iter);
        history_model.set (iter,
            HistoryActionColumn.TITLE, title_with_num,
            HistoryActionColumn.OUTPUT_STORE, log_store,
            -1);

        // select the new entry
        TreeSelection select = history_view.get_selection ();
        select.select_iter (iter);

        // scroll to the end
        TreePath path = history_model.get_path (iter);
        history_view.scroll_to_cell (path, null, false, 0, 0);

        // delete the first entry
        if (action_num > 5)
        {
            TreeIter first;
            history_model.get_iter_first (out first);
            history_model.remove (first);
        }

        action_num++;
        return log_store;
    }

    private bool output_row_selection_func (TreeSelection selection, TreeModel model,
        TreePath path, bool path_currently_selected)
    {
        TreeIter iter;
        if (model.get_iter (out iter, path))
        {
            int msg_type;
            string filename;
            model.get (iter,
                OutputLineColumn.FILENAME, out filename,
                OutputLineColumn.MESSAGE_TYPE, out msg_type,
                -1);

            if (msg_type != OutputMessageType.OTHER && filename != null
                && filename.length > 0)
                ((LogStore) model).select_row (iter);
        }

        // rows will never be selected
        return false;
    }

    private void on_scroll_and_flush (TreePath path)
    {
        return_if_fail (output_view != null);
        output_view.scroll_to_cell (path, null, false, 0, 0);
        Utils.flush_queue ();
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
    private TreePath selected_row = null;

    public signal void scroll_and_flush (TreePath path);

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
	    {
	        TreePath path = get_path (iter);
	        scroll_and_flush (path);
        }
    }

    public void scroll_to_selected_row ()
    {
        if (selected_row != null)
            scroll_and_flush (selected_row);
    }

    public void select_row (TreeIter iter)
    {
        TreePath path = get_path (iter);
        TreeModel model = (TreeModel) this;

        if (selected_row != null)
        {
            // if the row to select is not the same as the row already selected,
		    // we must deselect this row
		    if (selected_row.compare (path) != 0)
		    {
		        TreeIter current_iter_selected;
		        get_iter (out current_iter_selected, selected_row);

		        // invert the colors
		        string bg_color;
		        model.get (current_iter_selected,
		            OutputLineColumn.BG_COLOR, out bg_color,
		            -1);
                set (current_iter_selected,
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

        selected_row = path;
    }
}

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

public class MainWindow : Window
{
    // for the menu and the toolbar
    // name, stock_id, label, accelerator, tooltip, callback
    private const ActionEntry[] action_entries =
    {
        // File
        { "File", null, N_("_File") },
        { "FileNew", STOCK_NEW, null, null,
            N_("New file"), on_file_new },
        { "FileNewWindow", null, N_("New _Window"), null,
            N_("Create a new window"), on_new_window },
        { "FileOpen", STOCK_OPEN, null, null,
            N_("Open a file"), on_file_open },
        { "FileSave", STOCK_SAVE, null, null,
            N_("Save the current file"), on_file_save },
        { "FileSaveAs", STOCK_SAVE_AS, null, null,
            N_("Save the current file with a different name"), on_file_save_as },
        { "FileClose", STOCK_CLOSE, null, null,
            N_("Close the current file"), on_file_close },
        { "FileQuit", STOCK_QUIT, null, null,
            N_("Quit the program"), on_quit },

        // Edit
        { "Edit", null, N_("_Edit") },
        { "EditUndo", STOCK_UNDO, null, "<Control>Z",
            N_("Undo the last action"), on_edit_undo },
        { "EditRedo", STOCK_REDO, null, "<Shift><Control>Z",
            N_("Redo the last undone action"), on_edit_redo },
        { "EditCut", STOCK_CUT, null, null,
            N_("Cut the selection"), on_edit_cut },
        { "EditCopy", STOCK_COPY, null, null,
            N_("Copy the selection"), on_edit_copy },
        { "EditPaste", STOCK_PASTE, null, null,
            N_("Paste the clipboard"), on_edit_paste },
        { "EditDelete", STOCK_DELETE, null, null,
            N_("Delete the selected text"), on_edit_delete },
        { "EditSelectAll", STOCK_SELECT_ALL, null, "<Control>A",
            N_("Select the entire document"), on_edit_select_all },
        { "EditPreferences", STOCK_PREFERENCES, null, null,
            N_("Configure the application"), null }
    };

    private string file_chooser_current_folder = Environment.get_home_dir ();
    private DocumentsPanel documents_panel;
    private ActionGroup action_group;

    // actions that must be insensitive if the notebook is empty
    private const string[] file_actions =
    {
        "FileSave", "FileSaveAs", "FileClose", "EditUndo", "EditRedo", "EditCut",
        "EditCopy", "EditPaste", "EditDelete", "EditSelectAll"
    };

    // actions that must be insensitive if there is no selection
    private const string[] selection_actions = { "EditCut", "EditCopy", "EditDelete" };

    public DocumentTab? active_tab
    {
        get
        {
            if (documents_panel.get_n_pages () == 0)
                return null;
            return documents_panel.active_tab;
        }

        set
        {
            int n = documents_panel.page_num (value);
            if (n != -1)
                documents_panel.set_current_page (n);
        }
    }

    public DocumentView? active_view
    {
        get
        {
            if (active_tab == null)
                return null;
            return active_tab.view;
        }
    }

    public Document? active_document
    {
        get
        {
            if (active_tab == null)
                return null;
            return active_tab.document;
        }
    }

    public MainWindow ()
    {
        this.title = "LaTeXila";
        set_default_size (700, 600);

        /* menu and toolbar */
        action_group = new ActionGroup ("ActionGroup");
        action_group.set_translation_domain (Config.GETTEXT_PACKAGE);
        action_group.add_actions (action_entries, this);

        var ui_manager = new UIManager ();
        ui_manager.insert_action_group (action_group, 0);
        try
        {
            var path = Path.build_filename (Config.DATA_DIR, "ui", "ui.xml");
            ui_manager.add_ui_from_file (path);
        }
        catch (GLib.Error err)
        {
            error ("%s", err.message);
        }

        /* documents panel (notebook) */
        documents_panel = new DocumentsPanel ();
        documents_panel.page_added.connect (set_file_actions_sensitive);
        documents_panel.page_removed.connect (() =>
        {
            set_file_actions_insensitive ();
            my_set_title ();
        });
        documents_panel.switch_page.connect (() =>
        {
            set_undo_sensitivity ();
            set_redo_sensitivity ();
            my_set_title ();
        });
        set_file_actions_insensitive ();

        var menu = ui_manager.get_widget ("/MainMenu");
        var toolbar = ui_manager.get_widget ("/MainToolbar");

        // packing widgets
        var main_vbox = new VBox (false, 0);
        main_vbox.pack_start (menu, false, false, 0);
        main_vbox.pack_start (toolbar, false, false, 0);
        main_vbox.pack_start (documents_panel, true, true, 0);

        add (main_vbox);
    }

    public List<Document> get_documents ()
    {
        List<Document> res = null;
        int nb = documents_panel.get_n_pages ();
        for (int i = 0 ; i < nb ; i++)
        {
            DocumentTab tab = (DocumentTab) documents_panel.get_nth_page (i);
            res.append (tab.document);
        }
        return res;
    }

    public List<DocumentView> get_views ()
    {
        List<DocumentView> res = null;
        int nb = documents_panel.get_n_pages ();
        for (int i = 0 ; i < nb ; i++)
        {
            DocumentTab tab = (DocumentTab) documents_panel.get_nth_page (i);
            res.append (tab.view);
        }
        return res;
    }

    public void open_document (File location)
    {
        /* check if the document is already opened */
        foreach (MainWindow w in Application.get_default ().windows)
        {
            foreach (Document doc in w.get_documents ())
            {
                if (doc.location != null && location.equal (doc.location))
                {
                    // if the document is already opened in this window
                    if (this == w)
                        active_tab = doc.tab;

                    // if the document is already opened in an other window
                    else
                        stdout.printf ("'%s' already opened in an other window\n",
                            location.get_path ());

                    return;
                }
            }
        }

        create_tab_from_location (location, true);
    }

    public DocumentTab? create_tab (bool jump_to)
    {
        var tab = new DocumentTab ();

        /* get unsaved document number */
        uint[] all_nums = {};
        foreach (Document doc in Application.get_default ().get_documents ())
        {
            if (doc.location == null)
                all_nums += doc.unsaved_document_n;
        }

        uint num;
        for (num = 1 ; num in all_nums ; num++);
        tab.document.unsaved_document_n = num;

        return process_create_tab (tab, jump_to);
    }

    public DocumentTab? create_tab_from_location (File location, bool jump_to)
    {
        var tab = new DocumentTab.from_location (location);
        return process_create_tab (tab, jump_to);
    }

    private DocumentTab? process_create_tab (DocumentTab? tab, bool jump_to)
    {
        if (tab == null)
            return null;

        tab.close_document.connect (() => { close_tab (tab); });

        /* sensitivity of undo and redo */
        tab.document.notify["can-undo"].connect (() =>
        {

            if (tab != active_tab)
                return;
            set_undo_sensitivity ();
        });

        tab.document.notify["can-redo"].connect (() =>
        {
            if (tab != active_tab)
                return;
            set_redo_sensitivity ();
        });

        /* sensitivity of cut/copy/delete */
        tab.document.notify["has-selection"].connect (() =>
        {
            if (tab != active_tab)
                return;
            selection_changed ();
        });

        /* set window title */
        tab.document.notify["location"].connect (() =>
        {
            if (tab != active_tab)
                return;
            my_set_title ();
        });

        tab.document.modified_changed.connect (() =>
        {
            if (tab != active_tab)
                return;
            my_set_title ();
        });

        tab.show ();

        // add the tab at the end of the notebook
        documents_panel.add_tab (tab, -1, jump_to);

        set_undo_sensitivity ();
        set_redo_sensitivity ();
        selection_changed ();

        if (! this.get_visible ())
            this.present ();

        return tab;
    }

    public void close_tab (DocumentTab tab)
    {
        /* If document not saved
         * Ask the user if he wants to save the file, or close without saving, or cancel
         */
        if (tab.document.get_modified ())
        {
            var dialog = new MessageDialog (this,
                DialogFlags.DESTROY_WITH_PARENT,
                MessageType.QUESTION,
                ButtonsType.NONE,
                _("Save changes to document \"%s\" before closing?"),
                tab.label_text);

            dialog.add_buttons (_("Close without Saving"), ResponseType.CLOSE,
                STOCK_CANCEL, ResponseType.CANCEL);

            if (tab.document.location == null)
                dialog.add_button (STOCK_SAVE_AS, ResponseType.ACCEPT);
            else
                dialog.add_button (STOCK_SAVE, ResponseType.ACCEPT);

            while (true)
            {
                int res = dialog.run ();
                // Close without Saving
                if (res == ResponseType.CLOSE)
                    break;

                // Save or Save As
                else if (res == ResponseType.ACCEPT)
                {
                    if (save_document (tab.document, false))
                        break;
                    continue;
                }

                // Cancel
                else
                {
                    dialog.destroy ();
                    return;
                }
            }

            dialog.destroy ();
        }

        documents_panel.remove_tab (tab);
    }

    public DocumentTab? get_tab_from_location (File location)
    {
        foreach (Document doc in get_documents ())
        {
            if (location.equal (doc.location))
                return doc.tab;
        }

        // not found
        return null;
    }

    public bool is_on_workspace_screen (Gdk.Screen? screen, uint workspace)
    {
        if (screen != null)
        {
            var cur_name = screen.get_display ().get_name ();
            var cur_n = screen.get_number ();
            Gdk.Screen s = this.get_screen ();
            var name = s.get_display ().get_name ();
            var n = s.get_number ();

            if (cur_name != name || cur_n != n)
                return false;
        }

        if (! this.get_realized ())
            this.realize ();

        uint ws = Gedit.Utils.get_window_workspace (this);
        return ws == workspace || ws == Gedit.Utils.Workspace.ALL_WORKSPACES;
    }

    private void set_file_actions_sensitive ()
    {
        // the notebook was empty and one page is added
        // after, when other pages are added, we do nothing
        if (documents_panel.get_n_pages () == 1)
        {
            foreach (string file_action in file_actions)
            {
                Action action = action_group.get_action (file_action);
                action.set_sensitive (true);
            }
        }
    }

    private void set_file_actions_insensitive ()
    {
        if (documents_panel.get_n_pages () == 0)
        {
            foreach (string file_action in file_actions)
            {
                Action action = action_group.get_action (file_action);
                action.set_sensitive (false);
            }
        }
    }

    private void set_undo_sensitivity ()
    {
        if (active_tab != null)
        {
            Action action = action_group.get_action ("EditUndo");
            action.set_sensitive (active_document.can_undo);
        }
    }

    private void set_redo_sensitivity ()
    {
        if (active_tab != null)
        {
            Action action = action_group.get_action ("EditRedo");
            action.set_sensitive (active_document.can_redo);
        }
    }

    private void selection_changed ()
    {
        if (active_tab != null)
        {
            bool has_selection = active_document.has_selection;
            foreach (string selection_action in selection_actions)
            {
                Action action = action_group.get_action (selection_action);
                action.set_sensitive (has_selection);
            }
        }
    }

    private void my_set_title ()
    {
        if (active_tab == null)
        {
            set_title ("LaTeXila");
            return;
        }

        uint max_title_length = 100;
        string title = null;
        string dirname = null;

        File loc = active_document.location;
        if (loc == null)
            title = active_document.get_unsaved_document_name ();
        else
        {
            string basename = loc.get_basename ();
            if (basename.length > max_title_length)
                title = Utils.str_middle_truncate (basename, max_title_length);
            else
            {
                title = basename;
                dirname = Utils.str_middle_truncate (
                    Utils.get_dirname_for_display (loc),
                    (uint) long.max (20, max_title_length - basename.length));
            }
        }

        if (active_document.get_modified ())
            title = "*" + title;

        if (active_view.readonly)
        {
            if (dirname != null)
                set_title (title + " [" + _("Read-Only") + "] (" + dirname
                    + ") - LaTeXila");
            else
                set_title (title + " [" + _("Read-Only") + "] - LaTeXila");
        }
        else
        {
            if (dirname != null)
                set_title (title + " (" + dirname + ") - LaTeXila");
            else
                set_title (title + " - LaTeXila");
        }
    }

    // return true if the document has been saved
    private bool save_document (Document doc, bool force_save_as)
    {
        if (! force_save_as && doc.location != null)
        {
            doc.save ();
            return true;
        }

        var file_chooser = new FileChooserDialog (_("Save File"), this,
            FileChooserAction.SAVE,
            STOCK_CANCEL, ResponseType.CANCEL,
            STOCK_SAVE, ResponseType.ACCEPT,
            null);

        if (this.file_chooser_current_folder != null)
            file_chooser.set_current_folder (this.file_chooser_current_folder);

        while (file_chooser.run () == ResponseType.ACCEPT)
        {
            File file = file_chooser.get_file ();

            /* if the file exists, ask the user if the file can be replaced */
            if (file.query_exists (null))
            {
                var confirmation = new MessageDialog (this,
                    DialogFlags.DESTROY_WITH_PARENT,
                    MessageType.QUESTION,
                    ButtonsType.NONE,
                    _("A file named \"%s\" already exists. Do you want to replace it?"),
                    file.get_basename ());

                confirmation.add_button (STOCK_CANCEL, ResponseType.CANCEL);

                var button_replace = new Button.with_label (_("Replace"));
                var icon = new Image.from_stock (STOCK_SAVE_AS, IconSize.BUTTON);
                button_replace.set_image (icon);
                confirmation.add_action_widget (button_replace, ResponseType.YES);
                button_replace.show ();

                var response = confirmation.run ();
                confirmation.destroy ();

                if (response != ResponseType.YES)
                    continue;
            }

            doc.location = file;
            break;
        }

        this.file_chooser_current_folder = file_chooser.get_current_folder ();
        file_chooser.destroy ();

        if (doc.location != null)
        {
            doc.save ();
            return true;
        }
        return false;
    }


    /*******************
     *    CALLBACKS
     ******************/

    /* File menu */

    public void on_file_new ()
    {
        create_tab (true);
    }

    public void on_new_window ()
    {
        Application.get_default ().create_window ();
    }

    // TODO improve this (see Gedit code)
    public void on_file_open ()
    {
        var file_chooser = new FileChooserDialog (_("Open File"), this,
            FileChooserAction.OPEN,
            STOCK_CANCEL, ResponseType.CANCEL,
            STOCK_OPEN, ResponseType.ACCEPT,
            null);

        if (this.file_chooser_current_folder != null)
            file_chooser.set_current_folder (this.file_chooser_current_folder);

        if (file_chooser.run () == ResponseType.ACCEPT)
            open_document (file_chooser.get_file ());

        this.file_chooser_current_folder = file_chooser.get_current_folder ();
        file_chooser.destroy ();
    }

    public void on_file_save ()
    {
        return_if_fail (active_tab != null);
        save_document (active_document, false);
    }

    public void on_file_save_as ()
    {
        return_if_fail (active_tab != null);
        save_document (active_document, true);
    }

    public void on_file_close ()
    {
        return_if_fail (active_tab != null);
        close_tab (active_tab);
    }

    public void on_quit ()
    {
    }

    /* Edit menu */

    public void on_edit_undo ()
    {
        return_if_fail (active_tab != null);
        if (active_document.can_undo)
        {
            active_document.undo ();
            active_view.scroll_to_cursor ();
            active_view.grab_focus ();
        }
    }

    public void on_edit_redo ()
    {
        return_if_fail (active_tab != null);
        if (active_document.can_redo)
        {
            active_document.redo ();
            active_view.scroll_to_cursor ();
            active_view.grab_focus ();
        }
    }

    public void on_edit_cut ()
    {
        return_if_fail (active_tab != null);
        active_view.cut_selection ();
    }

    public void on_edit_copy ()
    {
        return_if_fail (active_tab != null);
        active_view.copy_selection ();
    }

    public void on_edit_paste ()
    {
        return_if_fail (active_tab != null);
        active_view.my_paste_clipboard ();
    }

    public void on_edit_delete ()
    {
        return_if_fail (active_tab != null);
        active_view.delete_selection ();
    }

    public void on_edit_select_all ()
    {
        return_if_fail (active_tab != null);
        active_view.my_select_all ();
    }
}

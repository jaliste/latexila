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
        { "File", null, N_("_File") },
        { "FileNew", STOCK_NEW, null, null, null, on_new },
        { "FileNewWindow", null, N_("New _Window"), null,
            N_("Create a new window"), on_new_window },
        { "FileOpen", STOCK_OPEN, null, null, null, on_open },
        { "FileSave", STOCK_SAVE, null, null, null, on_save },
        { "FileSaveAs", STOCK_SAVE_AS, null, null, null, on_save_as },
        { "FileClose", STOCK_CLOSE, null, null, null, on_close },
        { "FileQuit", STOCK_QUIT, null, null, null, on_quit }
    };

    private string file_chooser_current_folder = Environment.get_home_dir ();
    private DocumentsPanel documents_panel;
    private ActionGroup action_group;

    // actions that must be insensitive if the notebook is empty
    private const string[] file_actions = { "FileSave", "FileSaveAs", "FileClose" };

    public DocumentTab? active_tab
    {
        get
        {
            int n = documents_panel.get_current_page ();
            if (n == -1)
                return null;
            return (DocumentTab) documents_panel.get_nth_page (n);
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
        documents_panel.page_removed.connect (set_file_actions_insensitive);
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
        tab.show ();

        // add the tab at the end of the notebook
        documents_panel.add_tab (tab, -1, jump_to);

        if (! this.get_visible ())
            this.present ();

        return tab;
    }

    public void close_tab (DocumentTab tab)
    {
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


    /*******************
     *    CALLBACKS
     ******************/

    public void on_new ()
    {
        create_tab (true);
    }

    public void on_new_window ()
    {
        Application.get_default ().create_window ();
    }

    // TODO improve this (see Gedit code)
    public void on_open ()
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

    public void on_save ()
    {

        if (active_document.location == null)
            this.on_save_as ();
        else
            active_document.save ();
    }

    public void on_save_as ()
    {
        return_if_fail (active_document != null);

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

            active_document.location = file;
            break;
        }

        this.file_chooser_current_folder = file_chooser.get_current_folder ();
        file_chooser.destroy ();

        if (active_document.location != null)
            active_document.save ();
    }

    public void on_close ()
    {
        return_if_fail (active_tab != null);
        close_tab (active_tab);
    }

    public void on_quit ()
    {
    }
}

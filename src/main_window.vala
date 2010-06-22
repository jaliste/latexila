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
using Gee;

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
    public DocumentsPanel documents_panel = new DocumentsPanel ();

    public MainWindow ()
    {
        this.title = "LaTeXila";
        set_default_size (700, 600);

        /* menu and toolbar */
        var action_group = new ActionGroup ("ActionGroup");
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

        var menu = ui_manager.get_widget ("/MainMenu");
        var toolbar = ui_manager.get_widget ("/MainToolbar");

        // create one document
        var doc = new Document ();
        doc.buffer.text = _("Welcome to LaTeXila!");
        documents_panel.add_document (doc);

        // packing widgets
        var main_vbox = new VBox (false, 0);
        main_vbox.pack_start (menu, false, false, 0);
        main_vbox.pack_start (toolbar, false, false, 0);
        main_vbox.pack_start (this.documents_panel, true, true, 0);

        add (main_vbox);
    }

    public void on_new ()
    {
        var doc = new Document ();
        this.documents_panel.add_document (doc);
    }

    public void on_new_window ()
    {
        Application.get_default ().create_new_window ();
    }

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
        var active_doc = this.documents_panel.active_doc;

        return_if_fail (active_doc != null);

        if (active_doc.location == null)
            this.on_save_as ();
        else
            active_doc.save ();
    }

    public void on_save_as ()
    {
        var active_doc = this.documents_panel.active_doc;

        return_if_fail (active_doc != null);

        var file_chooser = new FileChooserDialog (_("Save File"), this,
            FileChooserAction.SAVE,
            STOCK_CANCEL, ResponseType.CANCEL,
            STOCK_SAVE, ResponseType.ACCEPT,
            null);

        if (this.file_chooser_current_folder != null)
            file_chooser.set_current_folder (this.file_chooser_current_folder);

        while (file_chooser.run () == ResponseType.ACCEPT)
        {
            string filename = file_chooser.get_filename ();
            File file = file_chooser.get_file ();

            /* if the file exists, ask the user if the file can be replaced */
            if (FileUtils.test (filename, FileTest.EXISTS))
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

            active_doc.location = file;
            break;
        }

        this.file_chooser_current_folder = file_chooser.get_current_folder ();
        file_chooser.destroy ();

        if (active_doc.location != null)
            active_doc.save ();
    }

    public void on_close ()
    {
        var active_doc = this.documents_panel.active_doc;
        return_if_fail (active_doc != null);
        this.documents_panel.remove_document (active_doc);
    }

    public void on_quit ()
    {
    }

    public void open_document (File location)
    {
        /* check if the document is not already opened */
        if (Application.get_default ().find_file (location))
            return;

        var doc = new Document.with_location (location);
        this.documents_panel.add_document (doc);
        doc.load ();
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
}

using Gtk;

public class MainWindow : Window
{
    // for the menu and the toolbar
    // name, stock_id, label, accelerator, tooltip, callback
    private const ActionEntry[] action_entries =
    {
        { "File", null, "_File" },
        { "FileNew", STOCK_NEW, null, null, null, on_new },
        { "FileOpen", STOCK_OPEN, null, null, null, on_open },
        { "FileSave", STOCK_SAVE, null, null, null, on_save },
        { "FileSaveAs", STOCK_SAVE_AS, null, null, null, on_save_as },
        { "FileClose", STOCK_CLOSE, null, null, null, on_close },
        { "FileQuit", STOCK_QUIT, null, null, null, on_quit }
    };

    private Document doc;
    private string file_chooser_current_folder = Environment.get_home_dir ();

    public MainWindow ()
    {
        this.title = "LaTeXila";
        set_default_size (600, 500);

        /* menu and toolbar */
        var action_group = new ActionGroup ("ActionGroup");
        action_group.add_actions (action_entries, this);

        var ui_manager = new UIManager ();
        ui_manager.insert_action_group (action_group, 0);
        try
        {
            ui_manager.add_ui_from_file ("ui.xml");
        }
        catch (GLib.Error err)
        {
            error (err.message);
        }

        var menu = ui_manager.get_widget ("/MainMenu");
        var toolbar = ui_manager.get_widget ("/MainToolbar");

        var main_vbox = new VBox (false, 0);
        main_vbox.pack_start (menu, false, false, 0);
        main_vbox.pack_start (toolbar, false, false, 0);

        /* source view */
        this.doc = new Document ();
        this.doc.buffer.text = "Welcome to LaTeXila!";
        main_vbox.pack_start (this.doc.view, true, true, 0);

        add (main_vbox);
    }

    public void on_new ()
    {
        this.doc.location = null;
        this.doc.buffer.text = "";
    }

    public void on_open ()
    {
        var file_chooser = new FileChooserDialog ("Open File", this,
            FileChooserAction.OPEN,
            STOCK_CANCEL, ResponseType.CANCEL,
            STOCK_OPEN, ResponseType.ACCEPT,
            null);

        if (this.file_chooser_current_folder != null)
            file_chooser.set_current_folder (this.file_chooser_current_folder);

        if (file_chooser.run () == ResponseType.ACCEPT)
        {
            this.doc.location = file_chooser.get_file ();
            this.doc.load ();
        }

        this.file_chooser_current_folder = file_chooser.get_current_folder ();
        file_chooser.destroy ();
    }

    public void on_save ()
    {
        if (this.doc.location == null)
            this.on_save_as ();
        else
            this.doc.save ();
    }

    public void on_save_as ()
    {
        var file_chooser = new FileChooserDialog ("Save File", this,
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
                    "A file named \"%s\" already exists. Do you want to replace it?",
                    file.get_basename ());

                confirmation.add_button (STOCK_CANCEL, ResponseType.CANCEL);

                var button_replace = new Button.with_label ("Replace");
                var icon = new Image.from_stock (STOCK_SAVE_AS, IconSize.BUTTON);
                button_replace.set_image (icon);
                confirmation.add_action_widget (button_replace, ResponseType.YES);
                button_replace.show ();

                var response = confirmation.run ();
                confirmation.destroy ();

                if (response != ResponseType.YES)
                    continue;
            }

            this.doc.location = file;
            break;
        }

        this.file_chooser_current_folder = file_chooser.get_current_folder ();
        file_chooser.destroy ();

        if (this.doc.location != null)
            this.doc.save ();
    }

    public void on_close ()
    {
    }

    public static void on_quit ()
    {
        Gtk.main_quit ();
    }
}

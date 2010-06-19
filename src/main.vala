using Gtk;

bool option_version;
bool option_new_document;
string[] option_remaining_args;

const OptionEntry[] options =
{
    { "version", 'V', 0, OptionArg.NONE, ref option_version,
    N_("Show the application's version"), null },

    { "new-document", 'n', 0, OptionArg.NONE, ref option_new_document,
    N_("Create new document"), null },

    { "", '\0', 0, OptionArg.FILENAME_ARRAY, ref option_remaining_args,
    null, "[FILE...]" },

    { null }
};

int main (string[] args)
{
    /* internationalisation */
    Intl.bindtextdomain (Config.GETTEXT_PACKAGE, Config.LOCALE_DIR);
    Intl.bind_textdomain_codeset (Config.GETTEXT_PACKAGE, "UTF-8");
    Intl.textdomain (Config.GETTEXT_PACKAGE);

    Gtk.init (ref args);

    /* command line options */
    var context = new OptionContext (_("- Integrated LaTeX Environment for GNOME"));
    context.add_main_entries (options, Config.GETTEXT_PACKAGE);
    context.add_group (Gtk.get_option_group (false));

    try
    {
        context.parse (ref args);
    }
    catch (OptionError e)
    {
        stderr.printf ("%s\n", e.message);
        stderr.printf (_("Run '%s --help' to see a full list of available command line options.\n"),
            args[0]);
        return 1;
    }

    if (option_version)
    {
        stdout.printf ("LaTeXila %s\n", Config.APP_VERSION);
        return 0;
    }

    /* personal style */
    // make the close buttons in tabs smaller
    rc_parse_string ("""
        style "my-button-style"
        {
          GtkWidget::focus-padding = 0
          GtkWidget::focus-line-width = 0
          xthickness = 0
          ythickness = 0
        }
        widget "*.my-close-button" style "my-button-style"
        """);

    var window = new MainWindow ();
    window.destroy.connect (MainWindow.on_quit);
    window.show_all ();

    if (option_remaining_args != null)
    {
        for (int i = 0 ; option_remaining_args[i] != null ; i++)
        {
            var location = File.new_for_commandline_arg (option_remaining_args[i]);
            window.open_document (location);
        }
    }

    if (option_new_document)
        window.on_new ();

    Gtk.main ();
    return 0;
}

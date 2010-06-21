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

    /* prepare commands */
    bool command_new = false;
    bool command_open = false;
    Unique.MessageData data = new Unique.MessageData ();

    if (option_remaining_args != null)
    {
        command_open = true;

        // get URI's
        // The command line argument can be absolute or relative.
        // With URI's, that's always absolute, so no problem.
        string[] uris = {};
        for (int i = 0 ; option_remaining_args[i] != null ; i++)
        {
            File file = File.new_for_path (option_remaining_args[i]);
            uris += file.get_uri ();
        }

        data.set_uris (uris);
    }

    if (option_new_document)
        command_new = true;

    var app = new Unique.App ("org.gnome.latexila", null);
    if (app.is_running)
    {
        /* send commands */
        bool ok = true;
        if (command_open)
        {
            var resp = app.send_message (Unique.Command.OPEN, data);
            ok = resp == Unique.Response.OK;
        }
        if (ok && command_new)
        {
            var resp = app.send_message (Unique.Command.NEW, null);
            ok = resp == Unique.Response.OK;
        }
        if (! command_open && ! command_new)
        {
            var resp = app.send_message (Unique.Command.ACTIVATE, null);
            ok = resp == Unique.Response.OK;
        }

        if (! ok)
            error ("Error: communication with first instance of LaTeXila failed\n");
        return 0;
    }

    /* start a new application */
    else
    {
        var latexila = new Application ();

        /* execute commands */
        if (command_open)
            latexila.message (app, Unique.Command.OPEN, data, 0);
        if (command_new)
            latexila.message (app, Unique.Command.NEW, data, 0);

        app.message_received.connect (latexila.message);
        Gtk.main ();
    }

    return 0;
}

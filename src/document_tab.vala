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

public class DocumentTab : VBox
{
    public DocumentView view { get; private set; }
    public Document document { get; private set; }

    private bool ask_if_externally_modified = false;

    private HBox _label;
    private Label _label_text = new Label (null);
    private Label _label_mark = new Label (null);

    public HBox label
    {
        get { return _label; }
    }

    public string label_text
    {
        get { return _label_text.label; }
        private set { _label_text.label = value; }
    }

    private uint auto_save_timeout;

    private uint _auto_save_interval;
    public uint auto_save_interval
    {
        get
        {
            return _auto_save_interval;
        }

        set
        {
            return_if_fail (value > 0);

            if (_auto_save_interval == value)
                return;

            _auto_save_interval = value;

            if (! _auto_save)
                return;

            if (auto_save_timeout > 0)
            {
                return_if_fail (document.location != null);
                return_if_fail (! document.readonly);
                remove_auto_save_timeout ();
                install_auto_save_timeout ();
            }
        }
    }

    private bool _auto_save;
    public bool auto_save
    {
        get
        {
            return _auto_save;
        }

        set
        {
            if (value == _auto_save)
                return;

            _auto_save = value;

            if (_auto_save && auto_save_timeout <= 0 && document.location != null
                && ! document.readonly)
            {
                install_auto_save_timeout ();
                return;
            }

            if (! _auto_save && auto_save_timeout > 0)
            {
                remove_auto_save_timeout ();
                return;
            }

            return_if_fail ((! _auto_save && auto_save_timeout <= 0)
                || document.location == null || document.readonly);
        }
    }

    public signal void close_document ();

    public DocumentTab ()
    {
        document = new Document ();
        view = new DocumentView (document);
        initialize ();
    }

    public DocumentTab.from_location (File location)
    {
        this ();
        document.load (location);
    }

    public DocumentTab.with_view (DocumentView view)
    {
        this.view = view;
        document = (Document) view.buffer;
        initialize ();
    }

    private void initialize ()
    {
        // usefull when moving a tab to a new window
        var reparent = document.tab != null;

        document.tab = this;

        document.notify["location"].connect (() =>
        {
            update_label_text ();
            update_label_tooltip ();
        });

        document.notify["unsaved-document-n"].connect (update_label_text);

        document.modified_changed.connect ((s) =>
        {
            _label_mark.label = document.get_modified () ? "*" : "";
        });

        view.focus_in_event.connect (view_focused_in);

        // with a scrollbar
        var sw = new ScrolledWindow (null, null);
        sw.set_policy (PolicyType.AUTOMATIC, PolicyType.AUTOMATIC);

        if (reparent)
            view.reparent (sw);
        else
            sw.add (view);

        sw.show_all ();

        // pack at the end so we can display message above
        pack_end (sw, true, true, 0);

        update_label_text ();

        var close_button = new Button ();
        close_button.relief = ReliefStyle.NONE;
        close_button.focus_on_click = false;
        close_button.name = "my-close-button";
        close_button.tooltip_text = _("Close document");
        close_button.add (new Image.from_stock (STOCK_CLOSE, IconSize.MENU));
        close_button.clicked.connect (() => this.close_document ());

        _label = new HBox (false, 0);
        _label.pack_start (_label_mark, false, false, 0);
        _label.pack_start (_label_text, true, false, 0);
        _label.pack_start (close_button, false, false, 0);
        update_label_tooltip ();
        _label.show_all ();


        /* auto save */
        var settings = new GLib.Settings ("org.gnome.latexila.preferences.editor");
        auto_save = settings.get_boolean ("auto-save");
        uint tmp;
        settings.get ("auto-save-interval", "u", out tmp);
        auto_save_interval = tmp;

        install_auto_save_timeout_if_needed ();

        document.notify["location"].connect (() =>
        {
            if (auto_save_timeout <= 0)
                install_auto_save_timeout_if_needed ();
        });
    }

    public TabInfoBar add_message (string primary_msg, string secondary_msg,
        MessageType msg_type)
    {
        var infobar = new TabInfoBar (primary_msg, secondary_msg, msg_type);
        pack_start (infobar, false, false, 0);
        return infobar;
    }

    private void update_label_text ()
    {
        label_text = Utils.str_middle_truncate (
            document.get_short_name_for_display (), 42);
    }

    private void update_label_tooltip ()
    {
        if (document.location == null)
            _label.tooltip_text = "";
        else
            _label.tooltip_text = document.get_uri_for_display ();
    }

    public string get_name ()
    {
        return _label_mark.label + label_text;
    }

    public string get_menu_tip ()
    {
        return _("Activate '%s'").printf (document.get_uri_for_display ());
    }

    private bool view_focused_in ()
    {
        /* check if the document has been externally modified */

        // we already asked the user
        if (ask_if_externally_modified)
            return false;

        // if file was never saved or is remote we do not check
        if (! document.is_local ())
            return false;

        if (document.is_externally_modified ())
        {
            ask_if_externally_modified = true;

            var primary_msg = _("The file %s changed on disk.")
                .printf (document.location.get_parse_name ());

            string secondary_msg;
            if (document.get_modified ())
                secondary_msg = _("Do you want to drop your changes and reload the file?");
            else
                secondary_msg = _("Do you want to reload the file?");

            var infobar = add_message (primary_msg, secondary_msg, MessageType.WARNING);
            infobar.add_stock_button_with_text (_("Reload"), STOCK_REFRESH,
                ResponseType.OK);
            infobar.add_button (STOCK_CANCEL, ResponseType.CANCEL);

            infobar.response.connect ((response_id) =>
            {
                if (response_id == ResponseType.OK)
                {
                    document.load (document.location);
                    ask_if_externally_modified = false;
                }

                infobar.destroy ();
                view.grab_focus ();
            });
        }

        return false;
    }

    private void install_auto_save_timeout ()
    {
        return_if_fail (auto_save_timeout <= 0);
        return_if_fail (auto_save);
        return_if_fail (auto_save_interval > 0);

        auto_save_timeout = Timeout.add_seconds (auto_save_interval * 60, on_auto_save);
    }

    private bool install_auto_save_timeout_if_needed ()
    {
        return_val_if_fail (auto_save_timeout <= 0, false);

        if (auto_save && document.location != null && ! document.readonly)
        {
            install_auto_save_timeout ();
            return true;
        }

        return false;
    }

    private void remove_auto_save_timeout ()
    {
        return_if_fail (auto_save_timeout > 0);

        Source.remove (auto_save_timeout);
        auto_save_timeout = 0;
    }

    private bool on_auto_save ()
    {
        return_val_if_fail (document.location != null, false);
        return_val_if_fail (! document.readonly, false);
        return_val_if_fail (auto_save_timeout > 0, false);
        return_val_if_fail (auto_save, false);
        return_val_if_fail (auto_save_interval > 0, false);

        if (document.get_modified ())
            document.save ();

        return true;
    }
}

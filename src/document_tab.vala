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
        bool reparent = document.tab != null;

        document.tab = this;

        document.notify["location"].connect (() =>
        {
            update_label_text ();
            update_label_tooltip ();
        });

        document.notify["unsaved-document-n"].connect (update_label_text);

        document.modified_changed.connect ((s) =>
        {
            if (document.get_modified ())
                _label_mark.label = "*";
            else
                _label_mark.label = "";
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
        close_button.clicked.connect (() => { this.close_document (); });

        _label = new HBox (false, 0);
        _label.pack_start (_label_mark, false, false, 0);
        _label.pack_start (_label_text, true, false, 0);
        _label.pack_start (close_button, false, false, 0);
        update_label_tooltip ();
        _label.show_all ();
    }

    public TabInfoBar add_message (string primary_msg, string secondary_msg,
        MessageType msg_type)
    {
        TabInfoBar infobar = new TabInfoBar (primary_msg, secondary_msg, msg_type);
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
        string uri = document.get_uri_for_display ();
        return _("Activate '%s'").printf (uri);
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

            string primary_msg = _("The file %s changed on disk.")
                .printf (document.location.get_parse_name ());

            string secondary_msg;
            if (document.get_modified ())
                secondary_msg = _("Do you want to drop your changes and reload the file?");
            else
                secondary_msg = _("Do you want to reload the file?");

            TabInfoBar infobar = add_message (primary_msg, secondary_msg,
                MessageType.WARNING);
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
}

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

        view = new DocumentView (document);

        // with a scrollbar
        var sw = new ScrolledWindow (null, null);
        sw.set_policy (PolicyType.AUTOMATIC, PolicyType.AUTOMATIC);
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

    public DocumentTab.from_location (File location)
    {
        this ();
        document.load (location);
    }

    public InfoBar add_message (string primary_msg, string secondary_msg,
        MessageType msg_type)
    {
        InfoBar infobar = new InfoBar ();
        HBox content_area = (HBox) infobar.get_content_area ();

        // icon
        string stock_id;
        switch (msg_type)
        {
            case MessageType.ERROR:
                stock_id = STOCK_DIALOG_ERROR;
                break;
            case MessageType.QUESTION:
                stock_id = STOCK_DIALOG_QUESTION;
                break;
            case MessageType.WARNING:
                stock_id = STOCK_DIALOG_WARNING;
                break;
            case MessageType.INFO:
            default:
                stock_id = STOCK_DIALOG_INFO;
                break;
        }

        Widget image = new Image.from_stock (stock_id, IconSize.DIALOG);
        ((Misc) image).set_alignment ((float) 0.5, (float) 0.0);
        content_area.pack_start (image, false, false, 0);

        // text
        VBox vbox = new VBox (false, 10);
        content_area.pack_start (vbox, true, true, 10);

        Label primary_label = new Label (null);
        vbox.pack_start (primary_label, false, false, 0);
        primary_label.set_alignment ((float) 0.0, (float) 0.5);
        primary_label.set_selectable (true);
        primary_label.set_line_wrap (true);
        primary_label.set_use_markup (true);
        primary_label.set_markup ("<b>" + primary_msg + "</b>");

        Label secondary_label = new Label (null);
        vbox.pack_start (secondary_label, false, false, 0);
        secondary_label.set_alignment ((float) 0.0, (float) 0.5);
        secondary_label.set_selectable (true);
        secondary_label.set_line_wrap (true);
        secondary_label.set_use_markup (true);
        secondary_label.set_markup ("<small>" + secondary_msg + "</small>");

        infobar.set_message_type (msg_type);
        pack_start (infobar, false, false, 0);
        infobar.show_all ();

        return infobar;
    }

    public static void infobar_add_ok_button (InfoBar infobar)
    {
        infobar.add_button (STOCK_OK, ResponseType.OK);
        infobar.response.connect (() => { infobar.destroy (); });
    }

    private void update_label_text ()
    {
        if (document.location == null)
            label_text = document.get_unsaved_document_name ();
        else
        {
            string basename = document.location.get_basename ();
            // if the basename is too long, we show only the begin and the end
            label_text = Utils.str_middle_truncate (basename, 42);
        }
    }

    private void update_label_tooltip ()
    {
        if (document.location == null)
            _label.tooltip_text = "";
        else
            _label.tooltip_text = Utils.replace_home_dir_with_tilde (
                document.location.get_parse_name ());
    }
}

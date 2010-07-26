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

public class TabInfoBar : InfoBar
{
    public TabInfoBar (string primary_msg, string secondary_msg, MessageType msg_type)
    {
        var content_area = (HBox) get_content_area ();

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

        var image = new Image.from_stock (stock_id, IconSize.DIALOG);
        image.set_alignment ((float) 0.5, (float) 0.0);
        content_area.pack_start (image, false, false, 0);

        // text
        var vbox = new VBox (false, 10);
        content_area.pack_start (vbox, true, true, 0);

        var primary_label = new Label ("<b>" + primary_msg + "</b>");
        vbox.pack_start (primary_label, false, false, 0);
        primary_label.set_alignment ((float) 0.0, (float) 0.5);
        primary_label.set_selectable (true);
        primary_label.set_line_wrap (true);
        primary_label.set_use_markup (true);

        var secondary_label = new Label ("<small>" + secondary_msg + "</small>");
        vbox.pack_start (secondary_label, false, false, 0);
        secondary_label.set_alignment ((float) 0.0, (float) 0.5);
        secondary_label.set_selectable (true);
        secondary_label.set_line_wrap (true);
        secondary_label.set_use_markup (true);

        set_message_type (msg_type);
        show_all ();
    }

    public void add_ok_button ()
    {
        add_button (STOCK_OK, ResponseType.OK);
        response.connect ((response_id) =>
        {
            if (response_id == ResponseType.OK)
                destroy ();
        });
    }

    public void add_stock_button_with_text (string text, string stock_id, int response_id)
    {
        var button = (Button) add_button (text, response_id);
        var image = new Image.from_stock (stock_id, IconSize.BUTTON);
        button.set_image (image);
    }
}

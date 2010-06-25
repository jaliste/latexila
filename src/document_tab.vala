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
        document.notify["location"].connect (update_label_text);
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
        pack_start (sw, true, true, 0);

        update_label_text ();

        var close_button = new Button ();
        close_button.relief = ReliefStyle.NONE;
        close_button.focus_on_click = false;
        close_button.name = "my-close-button";
        close_button.add (new Image.from_stock (STOCK_CLOSE, IconSize.MENU));
        close_button.clicked.connect (() => { this.close_document (); });

        _label = new HBox (false, 0);
        _label.pack_start (_label_mark, false, false, 0);
        _label.pack_start (_label_text, false, false, 0);
        _label.pack_start (close_button, false, false, 2);
        _label.show_all ();
    }

    public DocumentTab.from_location (File location)
    {
        this ();
        document.load (location);
    }

    private void update_label_text ()
    {
        if (document.location == null)
            label_text = Document.doc_name_without_location;
        else
        {
            string basename = document.location.get_basename ();
            // if the basename is too long, we show only the begin and the end
            label_text = Utils.str_middle_truncate (basename, 42);
        }
    }
}

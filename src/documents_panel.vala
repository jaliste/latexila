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

public class DocumentsPanel : Notebook
{
    public Document active_doc { get; private set; }
    private ArrayList<Document> documents = new ArrayList<Document> ();

    public DocumentsPanel ()
    {
        this.switch_page.connect ((notebook, page, page_num) =>
        {
            this.active_doc = this.documents [(int) page_num];
        });

        this.page_reordered.connect ((notebook, child, page_num) =>
        {
            documents.remove (active_doc);
            documents.insert ((int) page_num, active_doc);
        });
    }

    public void add_document (Document doc)
    {
        this.documents.add (doc);
        this.active_doc = doc;

        // with a scrollbar
        var sw = new ScrolledWindow (null, null);
        sw.set_policy (PolicyType.AUTOMATIC, PolicyType.AUTOMATIC);
        sw.add (doc.view);
        sw.show_all ();

        int i = this.append_page (sw, doc.tab_label);
        this.set_tab_reorderable (sw, true);
        this.set_current_page (i);
        doc.close_document.connect ((t) => { remove_document (t); });
    }

    public void remove_document (Document doc)
    {
        int num = documents.index_of (doc);
        remove_page (num);
        this.documents.remove_at (num);

        num = get_current_page ();
        if (num != -1)
            this.active_doc = this.documents [num];
        else
            this.active_doc = null;
    }
}

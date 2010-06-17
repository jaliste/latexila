using Gtk;
using Gee;

public class DocumentsPanel : Notebook
{
    public Document active_doc { get; private set; }
    private ArrayList<Document> documents = new ArrayList<Document> ();

    public DocumentsPanel ()
    {
        this.switch_page.connect ((notebook, page, num_page) =>
        {
            this.active_doc = this.documents [(int) num_page];
        });
    }

    public void add_document (Document doc)
    {
        this.documents.add (doc);
        this.active_doc = doc;
        int i = this.append_page (doc.view, doc.tab_label);
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

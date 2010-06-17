using Gtk;

public class Document : GLib.Object
{
    public File location { get; set; }
    public Gtk.SourceBuffer buffer { get; set; }
    public Gtk.SourceView view { get; set; }

    private HBox _tab_label;
    private Label _tab_text = new Label (null);
    private Label _tab_mark = new Label (null);

    public HBox tab_label
    {
        get { return _tab_label; }
    }

    public string tab_text
    {
        get { return _tab_text.label; }
        private set { _tab_text.label = value; }
    }

    public bool saved
    {
        get { return _tab_mark.label != "*"; }
        set { _tab_mark.label = value ? "" : "*"; }
    }

    public signal void close_document ();

    public Document ()
    {
        var text_tag_table = new TextTagTable ();
        buffer = new Gtk.SourceBuffer (text_tag_table);

        view = new Gtk.SourceView.with_buffer (buffer);
        view.show_line_numbers = true;

        saved = true;
        update_tab_text ();

        var close_button = new Button ();
        close_button.relief = ReliefStyle.NONE;
        close_button.focus_on_click = false;
        close_button.name = "my-close-button";
        close_button.add (new Image.from_stock (STOCK_CLOSE, IconSize.MENU));
        close_button.clicked.connect (() => { this.close_document (); });
        
        _tab_label = new HBox (false, 3);
        _tab_label.pack_start (_tab_mark, false, false, 0);
        _tab_label.pack_start (_tab_text, false, false, 0);
        _tab_label.pack_start (close_button, false, false, 0);
        _tab_label.show_all ();

        this.notify["location"].connect (update_tab_text);
    }

    public Document.with_location (File location)
    {
        this ();
        this.location = location;
    }

    public void load ()
    {
        if (location == null)
        {
            buffer.text = "";
            return;
        }

        try
        {
            string text;
            FileUtils.get_contents (location.get_path (), out text, null);
            buffer.text = text;
        }
        catch (Error e)
        {
            stderr.printf ("Error: %s\n", e.message);
        }
    }

    public void save ()
    {
        assert (location != null);

        // we use get_text () to exclude undisplayed text
        TextIter start, end;
        buffer.get_bounds (out start, out end);
        string text = buffer.get_text (start, end, false);

        try
        {
            FileUtils.set_contents (location.get_path (), text);
        }
        catch (FileError e)
        {
            stderr.printf ("Error: %s\n", e.message);
        }
    }

    private void update_tab_text ()
    {
        if (location == null)
            tab_text = "New document";
        else
        {
            string basename = location.get_basename ();
            var n = basename.length;
            if (n >= 42)
                tab_text = basename[0:19] + "..." + basename[n-19:n];
            else
                tab_text = basename;
        }
    }
}

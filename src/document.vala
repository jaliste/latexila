using Gtk;

public class Document : GLib.Object
{
    public File location { get; set; }
    public Gtk.SourceBuffer buffer { get; set; }
    public Gtk.SourceView view { get; set; }

    public Document ()
    {
        var text_tag_table = new TextTagTable ();
        this.buffer = new Gtk.SourceBuffer (text_tag_table);

        this.view = new Gtk.SourceView.with_buffer (this.buffer);
        this.view.show_line_numbers = true;
    }

    public Document.with_location (File location)
    {
        this ();
        this.location = location;
    }

    public void load ()
    {
        if (this.location == null)
        {
            this.buffer.text = "";
            return;
        }

        try
        {
            string text;
            FileUtils.get_contents (this.location.get_path (), out text, null);
            this.buffer.text = text;
        }
        catch (Error e)
        {
            stderr.printf ("Error: %s\n", e.message);
        }
    }

    public void save ()
    {
        assert (this.location != null);

        // we use get_text () to exclude undisplayed text
        TextIter start, end;
        this.buffer.get_bounds (out start, out end);
        string text = this.buffer.get_text (start, end, false);

        try
        {
            FileUtils.set_contents (this.location.get_path (), text);
        }
        catch (FileError e)
        {
            stderr.printf ("Error: %s\n", e.message);
        }
    }
}

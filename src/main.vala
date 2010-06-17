using Gtk;

int main (string[] args)
{
    Gtk.init (ref args);

    /* personal style */
    // make the close buttons in tabs smaller
    rc_parse_string ("""
        style "my-button-style"
        {
          GtkWidget::focus-padding = 0
          GtkWidget::focus-line-width = 0
          xthickness = 0
          ythickness = 0
        }
        widget "*.my-close-button" style "my-button-style"
        """);

    var window = new MainWindow ();
    window.destroy.connect (MainWindow.on_quit);
    window.show_all ();
    Gtk.main ();
    return 0;
}

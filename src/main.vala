using Gtk;

int main (string[] args)
{
    Gtk.init (ref args);
    var window = new MainWindow ();
    window.destroy.connect (MainWindow.on_quit);
    window.show_all ();
    Gtk.main ();
    return 0;
}

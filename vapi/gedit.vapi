[CCode (cprefix = "Gedit.Utils", lower_case_cprefix = "gedit_utils_", cheader_filename = "gedit-utils.h")]
namespace Gedit.Utils
{
    [CCode (cprefix = "GEDIT_")]
    public enum Workspace { ALL_WORKSPACES }
    public static uint get_window_workspace (Gtk.Window gtkwindow);
}

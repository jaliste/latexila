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

public class MainWindow : Window
{
    // for the menu and the toolbar
    // name, stock_id, label, accelerator, tooltip, callback
    private const ActionEntry[] action_entries =
    {
        // File
        { "File", null, N_("_File") },
        { "FileNew", STOCK_NEW, null, null,
            N_("New file"), on_file_new },
        { "FileNewWindow", null, N_("New _Window"), null,
            N_("Create a new window"), on_new_window },
        { "FileOpen", STOCK_OPEN, null, null,
            N_("Open a file"), on_file_open },
        { "FileSave", STOCK_SAVE, null, null,
            N_("Save the current file"), on_file_save },
        { "FileSaveAs", STOCK_SAVE_AS, null, null,
            N_("Save the current file with a different name"), on_file_save_as },
        { "FileClose", STOCK_CLOSE, null, null,
            N_("Close the current file"), on_file_close },
        { "FileQuit", STOCK_QUIT, null, null,
            N_("Quit the program"), on_quit },

        // Edit
        { "Edit", null, N_("_Edit") },
        { "EditUndo", STOCK_UNDO, null, "<Control>Z",
            N_("Undo the last action"), on_edit_undo },
        { "EditRedo", STOCK_REDO, null, "<Shift><Control>Z",
            N_("Redo the last undone action"), on_edit_redo },
        { "EditCut", STOCK_CUT, null, null,
            N_("Cut the selection"), on_edit_cut },
        { "EditCopy", STOCK_COPY, null, null,
            N_("Copy the selection"), on_edit_copy },
        { "EditPaste", STOCK_PASTE, null, null,
            N_("Paste the clipboard"), on_edit_paste },
        { "EditDelete", STOCK_DELETE, null, null,
            N_("Delete the selected text"), on_edit_delete },
        { "EditSelectAll", STOCK_SELECT_ALL, null, "<Control>A",
            N_("Select the entire document"), on_edit_select_all },
        { "EditComment", null, N_("_Comment"), "<Control>D",
            N_("Comment the selected lines (add the character \"%\")"),
            on_edit_comment },
        { "EditUncomment", null, N_("_Uncomment"), "<Shift><Control>D",
            N_("Uncomment the selected lines (remove the character \"%\")"),
            on_edit_uncomment },
        { "EditPreferences", STOCK_PREFERENCES, null, null,
            N_("Configure the application"), on_open_preferences },

        // View
        { "View", null, N_("_View") },
        { "ViewZoomIn", STOCK_ZOOM_IN, N_("Zoom _In"), "<Control>plus",
            N_("Enlarge the font"), on_view_zoom_in },
        { "ViewZoomOut", STOCK_ZOOM_OUT, N_("Zoom _Out"), "<Control>minus",
            N_("Shrink the font"), on_view_zoom_out },
        { "ViewZoomReset", STOCK_ZOOM_100, N_("_Reset Zoom"), "<Control>0",
            N_("Reset the size of the font"), on_view_zoom_reset },

        // Search
        { "Search", null, N_("_Search") },
        { "SearchFind", STOCK_FIND, null, null,
            N_("Search for text"), on_search_find },
        { "SearchReplace", STOCK_FIND_AND_REPLACE, null, null,
            N_("Search for and replace text"), on_search_replace },
        { "SearchGoToLine", STOCK_JUMP_TO, N_("_Go to Line..."), "<Control>G",
            N_("Go to a specific line"), on_search_goto_line },

        // Documents
        { "Documents", null, N_("_Documents") },
        { "DocumentsSaveAll", STOCK_SAVE, N_("_Save All"), "<Shift><Control>L",
            N_("Save all open files"), on_documents_save_all },
        { "DocumentsCloseAll", STOCK_CLOSE, N_("_Close All"), "<Shift><Control>W",
            N_("Close all open files"), on_documents_close_all },
        { "DocumentsPrevious", STOCK_GO_BACK, N_("_Previous Document"),
            "<Control><Alt>Page_Up", N_("Activate previous document"),
            on_documents_previous },
        { "DocumentsNext", STOCK_GO_FORWARD, N_("_Next Document"),
            "<Control><Alt>Page_Down", N_("Activate next document"),
            on_documents_next },
        { "DocumentsMoveToNewWindow", null, N_("_Move to New Window"), null,
            N_("Move the current document to a new window"),
            on_documents_move_to_new_window },

        // Help
        { "Help", null, N_("_Help") },
        { "HelpAbout", STOCK_ABOUT, null, null,
            N_("About LaTeXila"), on_about_dialog }
    };

    private const ActionEntry[] latex_action_entries =
    {
        // LaTeX
        { "Latex", null, "_LaTeX" },

        // LaTeX: Sectioning
	    { "Sectioning", "sectioning-section", N_("_Sectioning") },
	    { "SectioningPart", "sectioning-part", N_("_part"), null,
		    N_("part"), on_sectioning_part },
	    { "SectioningChapter", "sectioning-chapter", N_("_chapter"), null,
		    N_("chapter"), on_sectioning_chapter },
	    { "SectioningSection", "sectioning-section", N_("_section"), null,
		    N_("section"), on_sectioning_section },
	    { "SectioningSubsection", "sectioning-subsection", N_("s_ubsection"), null,
		    N_("subsection"), on_sectioning_subsection },
	    { "SectioningSubsubsection", "sectioning-subsubsection", N_("su_bsubsection"), null,
		    N_("subsubsection"), on_sectioning_subsubsection },
	    { "SectioningParagraph", "sectioning-paragraph", N_("p_aragraph"), null,
		    N_("paragraph"), on_sectioning_paragraph },
	    { "SectioningSubparagraph", "sectioning-paragraph", N_("subpa_ragraph"), null,
		    N_("subparagraph"), on_sectioning_subparagraph },

        // LaTeX: References
	    { "References", "references", N_("_References"), null, null, null },
	    { "ReferencesLabel", null, "_label", null, "label", on_ref_label },
	    { "ReferencesRef", null, "_ref", null, "ref", on_ref_ref },
	    { "ReferencesPageref", null, "_pageref", null, "pageref", on_ref_pageref },
	    { "ReferencesIndex", null, "_index", null, "index", on_ref_index },
	    { "ReferencesFootnote", null, "_footnote", null, "footnote", on_ref_footnote },
	    { "ReferencesCite", null, "_cite", null, "cite", on_ref_cite },

        // LaTeX: Environments
	    { "Environments", STOCK_JUSTIFY_CENTER, N_("_Environments"), null, null, null },
	    { "EnvironmentCenter", STOCK_JUSTIFY_CENTER, N_("_Center - \\begin{ center }"), null,
		    N_("Center - \\begin{ center }"), on_env_center },
	    { "EnvironmentLeft", STOCK_JUSTIFY_LEFT, N_("Align _Left - \\begin{ flushleft }"), null,
		    N_("Align Left - \\begin{ flushleft }"), on_env_left },
	    { "EnvironmentRight", STOCK_JUSTIFY_RIGHT, N_("Align _Right - \\begin{ flushright }"), null,
		    N_("Align Right - \\begin{ flushright }"), on_env_right },
	    { "EnvironmentMinipage", null, N_("_Minipage - \\begin{ minipage }"), null,
		    N_("Minipage - \\begin{ minipage }"), on_env_minipage },
	    { "EnvironmentQuote", null, N_("_Quote - \\begin{ quote }"), null,
		    N_("Quote - \\begin{ quote }"), on_env_quote },
	    { "EnvironmentQuotation", null, N_("Qu_otation - \\begin{ quotation }"), null,
		    N_("Quotation - \\begin{ quotation }"), on_env_quotation },
	    { "EnvironmentVerse", null, N_("_Verse - \\begin{ verse }"), null,
		    N_("Verse - \\begin{ verse }"), on_env_verse },

        // LaTeX: list environments
	    { "ListEnvironments", "list-enumerate", N_("_List Environments"), null, null, null },
	    { "ListEnvItemize", "list-itemize", N_("_Bulleted List - \\begin{ itemize }"), null,
		    N_("Bulleted List - \\begin{ itemize }"), on_list_env_itemize },
	    { "ListEnvEnumerate", "list-enumerate", N_("_Enumeration - \\begin{ enumerate }"), null,
		    N_("Enumeration - \\begin{ enumerate }"), on_list_env_enumerate },
	    { "ListEnvDescription", "list-description", N_("_Description - \\begin{ description }"), null,
		    N_("Description - \\begin{ description }"), on_list_env_description },
	    { "ListEnvItem", "list-item", "\\_item", null,
		    "\\item", on_list_env_item },

        // LaTeX: character sizes
	    { "CharacterSize", "character-size", N_("_Characters Sizes"), null, null, null },
	    { "CharacterSizeTiny", null, "_tiny", null,
		    "\\tiny", on_size_tiny },
	    { "CharacterSizeScriptsize", null, "_scriptsize", null,
		    "\\scriptsize", on_size_scriptsize },
	    { "CharacterSizeFootnotesize", null, "_footnotesize", null,
		    "\\footnotesize", on_size_footnotesize },
	    { "CharacterSizeSmall", null, "s_mall", null,
		    "\\small", on_size_small },
	    { "CharacterSizeNormalsize", null, "_normalsize", null,
		    "\\normalsize", on_size_normalsize },
	    { "CharacterSizelarge", null, "_large", null,
		    "\\large", on_size_large },
	    { "CharacterSizeLarge", null, "L_arge", null,
		    "\\Large", on_size_Large },
	    { "CharacterSizeLARGE", null, "LA_RGE", null,
		    "\\LARGE", on_size_LARGE },
	    { "CharacterSizehuge", null, "_huge", null,
		    "\\huge", on_size_huge },
	    { "CharacterSizeHuge", null, "H_uge", null,
		    "\\Huge", on_size_Huge },

        // LaTeX: font styles
	    { "FontStyles", "bold", N_("_Font Styles"), null, null, null },
	    { "Bold", "bold", N_("_Bold - \\textbf{  }"), null,
		    N_("Bold - \\textbf{  }"), on_text_bold },
	    { "Italic", "italic", N_("_Italic - \\textit{  }"), null,
		    N_("Italic - \\textit{  }"), on_text_italic },
	    { "Typewriter", "typewriter", N_("_Typewriter - \\texttt{  }"), null,
		    N_("Typewriter - \\texttt{  }"), on_text_typewriter },
	    { "Underline", "underline", N_("_Underline - \\underline{  }"), null,
		    N_("Underline - \\underline{  }"), on_text_underline },
	    { "Slanted", null, N_("_Slanted - \\textsl{  }"), null,
		    N_("Slanted - \\textsl{  }"), on_text_slanted },
	    { "SmallCaps", null, N_("Small _Capitals - \\textsc{  }"), null,
		    N_("Small Capitals - \\textsc{  }"), on_text_small_caps },
	    { "Emph", null, N_("_Emphasized - \\emph{  }"), null,
		    N_("Emphasized - \\emph{  }"), on_text_emph },
	    { "FontFamily", null, N_("_Font Family"), null, null, null },
	    { "FontFamilyRoman", null, N_("_Roman - \\rmfamily"), null,
		    N_("Roman - \\rmfamily"), on_text_font_family_roman },
	    { "FontFamilySansSerif", null, N_("_Sans Serif - \\sffamily"), null,
		    N_("Sans Serif - \\sffamily"), on_text_font_family_sans_serif },
	    { "FontFamilyMonospace", null, N_("_Monospace - \\ttfamily"), null,
		    N_("Monospace - \\ttfamily"), on_text_font_family_monospace },
	    { "FontSeries", null, N_("F_ont Series"), null, null, null },
	    { "FontSeriesMedium", null, N_("_Medium - \\mdseries"), null,
		    N_("Medium - \\mdseries"), on_text_font_series_medium },
	    { "FontSeriesBold", null, N_("_Bold - \\bfseries"), null,
		    N_("Bold - \\bfseries"), on_text_font_series_bold },
	    { "FontShape", null, N_("Fo_nt Shape"), null, null, null },
	    { "FontShapeUpright", null, N_("_Upright - \\upshape"), null,
		    N_("Upright - \\upshape"), on_text_font_shape_upright },
	    { "FontShapeItalic", null, N_("_Italic - \\itshape"), null,
		    N_("Italic - \\itshape"), on_text_font_shape_italic },
	    { "FontShapeSlanted", null, N_("_Slanted - \\slshape"), null,
		    N_("Slanted - \\slshape"), on_text_font_shape_slanted },
	    { "FontShapeSmallCaps", null, N_("Small _Capitals - \\scshape"), null,
		    N_("Small Capitals - \\scshape"), on_text_font_shape_small_caps },

        // LaTeX: math
	    { "Math", "math", N_("_Math"), null, null, null },
	    { "MathEnvironments", null, N_("_Math Environments"), null, null, null },
	    { "MathEnvNormal", "math", N_("_Mathematical Environment - $...$"), null,
		    N_("Mathematical Environment - $...$"), on_math_env_normal },
	    { "MathEnvCentered", "math-centered", N_("_Centered Formula - $$...$$"), null,
		    N_("Centered Formula - $$...$$"), on_math_env_centered },
	    { "MathEnvNumbered", "math-numbered", N_("_Numbered Equation - \\begin{ equation }"), null,
		    N_("Numbered Equation - \\begin{ equation }"), on_math_env_numbered },
	    { "MathEnvArray", "math-array", N_("_Array of Equations - \\begin{ align* }"), null,
		    N_("Array of Equations - \\begin{ align* }"), on_math_env_array },
	    { "MathEnvNumberedArray", "math-numbered-array", N_("Numbered Array of _Equations - \\begin{ align }"), null,
		    N_("Numbered Array of Equations - \\begin{ align }"), on_math_env_numbered_array },
	    { "MathSuperscript", "math-superscript", N_("_Superscript - ^{  }"), null,
		    N_("Superscript - ^{  }"), on_math_superscript },
	    { "MathSubscript", "math-subscript", N_("Su_bscript - __{  }"), null,
		    N_("Subscript - _{  }"), on_math_subscript },
	    { "MathFrac", "math-frac", N_("_Fraction - \\frac{  }{  }"), null,
		    N_("Fraction - \\frac{  }{  }"), on_math_frac },
	    { "MathSquareRoot", "math-square-root", N_("Square _Root - \\sqrt{  }"), null,
		    N_("Square Root - \\sqrt{  }"), on_math_square_root },
	    { "MathNthRoot", "math-nth-root", N_("_N-th Root - \\sqrt[]{  }"), null,
		    N_("N-th Root - \\sqrt[]{  }"), on_math_nth_root },
	    { "MathLeftDelimiters", "delimiters-left", N_("_Left Delimiters"), null, null, null },
	    { "MathLeftDelimiter1", null, N_("left ("), null,
		    null, on_math_left_delimiter_1 },
	    { "MathLeftDelimiter2", null, N_("left ["), null,
		    null, on_math_left_delimiter_2 },
	    { "MathLeftDelimiter3", null, N_("left { "), null,
		    null, on_math_left_delimiter_3 },
	    { "MathLeftDelimiter4", null, N_("left <"), null,
		    null, on_math_left_delimiter_4 },
	    { "MathLeftDelimiter5", null, N_("left )"), null,
		    null, on_math_left_delimiter_5 },
	    { "MathLeftDelimiter6", null, N_("left ]"), null,
		    null, on_math_left_delimiter_6 },
	    { "MathLeftDelimiter7", null, N_("left  }"), null,
		    null, on_math_left_delimiter_7 },
	    { "MathLeftDelimiter8", null, N_("left >"), null,
		    null, on_math_left_delimiter_8 },
	    { "MathLeftDelimiter9", null, N_("left ."), null,
		    null, on_math_left_delimiter_9 },
	    { "MathRightDelimiters", "delimiters-right", N_("Right _Delimiters"), null, null, null },
	    { "MathRightDelimiter1", null, N_("right )"), null,
		    null, on_math_right_delimiter_1 },
	    { "MathRightDelimiter2", null, N_("right ]"), null,
		    null, on_math_right_delimiter_2 },
	    { "MathRightDelimiter3", null, N_("right  }"), null,
		    null, on_math_right_delimiter_3 },
	    { "MathRightDelimiter4", null, N_("right >"), null,
		    null, on_math_right_delimiter_4 },
	    { "MathRightDelimiter5", null, N_("right ("), null,
		    null, on_math_right_delimiter_5 },
	    { "MathRightDelimiter6", null, N_("right ["), null,
		    null, on_math_right_delimiter_6 },
	    { "MathRightDelimiter7", null, N_("right { "), null,
		    null, on_math_right_delimiter_7 },
	    { "MathRightDelimiter8", null, N_("right <"), null,
		    null, on_math_right_delimiter_8 },
	    { "MathRightDelimiter9", null, N_("right ."), null,
		    null, on_math_right_delimiter_9 }
    };

    private string file_chooser_current_folder = Environment.get_home_dir ();
    private DocumentsPanel documents_panel;
    private CustomStatusbar statusbar;
    private GotoLine goto_line;
    private SearchAndReplace search_and_replace;

    private UIManager ui_manager;
    private ActionGroup action_group;
    private ActionGroup latex_action_group;
    private ActionGroup documents_list_action_group;
    private uint documents_list_menu_ui_id;

    // context id for the statusbar
    private uint tip_message_cid;

    public DocumentTab? active_tab
    {
        get
        {
            if (documents_panel.get_n_pages () == 0)
                return null;
            return documents_panel.active_tab;
        }

        set
        {
            int n = documents_panel.page_num (value);
            if (n != -1)
                documents_panel.set_current_page (n);
        }
    }

    public DocumentView? active_view
    {
        get
        {
            if (active_tab == null)
                return null;
            return active_tab.view;
        }
    }

    public Document? active_document
    {
        get
        {
            if (active_tab == null)
                return null;
            return active_tab.document;
        }
    }

    public MainWindow ()
    {
        this.title = "LaTeXila";

        /* restore window state */
        GLib.Settings settings = new GLib.Settings ("org.gnome.latexila.state.window");

        int w, h;
        settings.get ("size", "(ii)", out w, out h);
        set_default_size (w, h);

        Gdk.WindowState state = (Gdk.WindowState) settings.get_int ("state");
        if (Gdk.WindowState.MAXIMIZED in state)
            maximize ();
        else
            unmaximize ();

        if (Gdk.WindowState.STICKY in state)
            stick ();
        else
            unstick ();

        /* components */
        initialize_menubar_and_toolbar ();
        var menu = ui_manager.get_widget ("/MainMenu");

        Toolbar toolbar = (Toolbar) ui_manager.get_widget ("/MainToolbar");
        toolbar.set_style (ToolbarStyle.ICONS);
        setup_toolbar_open_button (toolbar);

        Toolbar edit_toolbar = (Toolbar) ui_manager.get_widget ("/EditToolbar");
        edit_toolbar.set_style (ToolbarStyle.ICONS);

        documents_panel = new DocumentsPanel ();
        documents_panel.right_click.connect ((event) =>
        {
            Menu popup_menu = (Menu) ui_manager.get_widget ("/NotebookPopup");
            popup_menu.popup (null, null, null, event.button, event.time);
        });

        statusbar = new CustomStatusbar ();
        tip_message_cid = statusbar.get_context_id ("tip_message");
        goto_line = new GotoLine (this);
        search_and_replace = new SearchAndReplace (this);

        /* signal handlers */

        delete_event.connect (() =>
        {
            on_quit ();

            // the destroy signal is not emitted
            return true;
        });

        documents_panel.page_added.connect (() =>
        {
            int nb_pages = documents_panel.get_n_pages ();

            // actions for which there must be 1 document minimum
            if (nb_pages == 1)
                set_file_actions_sensitivity (true);

            // actions for which there must be 2 documents minimum
            else if (nb_pages == 2)
                set_documents_move_to_new_window_sensitivity (true);

            update_documents_list_menu ();
        });

        documents_panel.page_removed.connect (() =>
        {
            int nb_pages = documents_panel.get_n_pages ();

            // actions for which there must be 1 document minimum
            if (nb_pages == 0)
            {
                statusbar.set_cursor_position (-1, -1);
                set_file_actions_sensitivity (false);
                goto_line.hide ();
                search_and_replace.hide ();
            }

            // actions for which there must be 2 documents minimum
            else if (nb_pages == 1)
                set_documents_move_to_new_window_sensitivity (false);

            my_set_title ();
            update_documents_list_menu ();
        });

        documents_panel.switch_page.connect ((pg, page_num) =>
        {
            set_undo_sensitivity ();
            set_redo_sensitivity ();
            update_next_prev_doc_sensitivity ();
            my_set_title ();
            update_cursor_position_statusbar ();

            /* activate the right item in the documents menu */
            string action_name = "Tab_%u".printf (page_num);
            RadioAction action =
                (RadioAction) documents_list_action_group.get_action (action_name);

            // sometimes the action doesn't exist yet, and the proper action is set
            // active during the documents list menu creation
            if (action != null)
                action.set_active (true);

            notify_property ("active-tab");
            notify_property ("active-document");
            notify_property ("active-view");
        });

        documents_panel.page_reordered.connect (() =>
        {
            update_next_prev_doc_sensitivity ();
            update_documents_list_menu ();
        });

        set_file_actions_sensitivity (false);
        set_documents_move_to_new_window_sensitivity (false);

        /* packing widgets */
        var main_vbox = new VBox (false, 0);
        main_vbox.pack_start (menu, false, false, 0);
        main_vbox.pack_start (toolbar, false, false, 0);
        main_vbox.pack_start (edit_toolbar, false, false, 0);
        main_vbox.pack_start (documents_panel, true, true, 0);
        main_vbox.pack_start (goto_line, false, false, 1);
        main_vbox.pack_start (search_and_replace.search_and_replace, false, false, 1);
        main_vbox.pack_end (statusbar, false, false, 0);

        add (main_vbox);
        show_all ();
        goto_line.hide ();
        search_and_replace.hide ();
    }

    public List<Document> get_documents ()
    {
        List<Document> res = null;
        int nb = documents_panel.get_n_pages ();
        for (int i = 0 ; i < nb ; i++)
        {
            DocumentTab tab = (DocumentTab) documents_panel.get_nth_page (i);
            res.append (tab.document);
        }
        return res;
    }

    public List<Document> get_unsaved_documents ()
    {
        List<Document> list = null;
        foreach (Document doc in get_documents ())
        {
            if (doc.get_modified ())
                list.append (doc);
        }
        return list;
    }

    public List<DocumentView> get_views ()
    {
        List<DocumentView> res = null;
        int nb = documents_panel.get_n_pages ();
        for (int i = 0 ; i < nb ; i++)
        {
            DocumentTab tab = (DocumentTab) documents_panel.get_nth_page (i);
            res.append (tab.view);
        }
        return res;
    }

    private void initialize_menubar_and_toolbar ()
    {
        // recent documents
        Action recent_action = new RecentAction ("FileOpenRecent", _("Open _Recent"),
            _("Open recently used files"), "");
        configure_recent_chooser ((RecentChooser) recent_action);

        // menus under toolitems
        Action sectioning = new MenuToolAction ("SectioningToolItem", _("Sectioning"),
            _("Sectioning"), "sectioning-section");
        var sectioning_mtb = new MenuToolButton (null, null);
        ((Activatable) sectioning_mtb).set_related_action (sectioning);

        Action sizes = new MenuToolAction ("CharacterSizeToolItem", _("Characters Sizes"),
            _("Characters Sizes"), "character-size");
        var sizes_mtb = new MenuToolButton (null, null);
        ((Activatable) sizes_mtb).set_related_action (sizes);

        Action references = new MenuToolAction ("ReferencesToolItem", _("References"),
            _("References"), "references");
        var references_mtb = new MenuToolButton (null, null);
        ((Activatable) references_mtb).set_related_action (references);

        Action math_env = new MenuToolAction ("MathEnvironmentsToolItem",
            _("Math Environments"), _("Math Environments"), "math");
        var math_env_mtb = new MenuToolButton (null, null);
        ((Activatable) math_env_mtb).set_related_action (math_env);

        Action math_left_del = new MenuToolAction ("MathLeftDelimitersToolItem",
			_("Left Delimiters"), _("Left Delimiters"), "delimiters-left");
		var math_left_del_mtb = new MenuToolButton (null, null);
		((Activatable) math_left_del_mtb).set_related_action (math_left_del);

		Action math_right_del = new MenuToolAction ("MathRightDelimitersToolItem",
			_("Right Delimiters"), _("Right Delimiters"), "delimiters-right");
		var math_right_del_mtb = new MenuToolButton (null, null);
		((Activatable) math_right_del_mtb).set_related_action (math_right_del);

        action_group = new ActionGroup ("ActionGroup");
        action_group.set_translation_domain (Config.GETTEXT_PACKAGE);
        action_group.add_actions (action_entries, this);
        action_group.add_action (recent_action);

        latex_action_group = new ActionGroup ("LatexActionGroup");
        latex_action_group.set_translation_domain (Config.GETTEXT_PACKAGE);
        latex_action_group.add_actions (latex_action_entries, this);
        latex_action_group.add_action (sectioning);
        latex_action_group.add_action (sizes);
        latex_action_group.add_action (references);
        latex_action_group.add_action (math_env);
        latex_action_group.add_action (math_left_del);
        latex_action_group.add_action (math_right_del);

        ui_manager = new UIManager ();
        ui_manager.insert_action_group (action_group, 0);
        ui_manager.insert_action_group (latex_action_group, 0);

        try
        {
            var path = Path.build_filename (Config.DATA_DIR, "ui", "ui.xml");
            ui_manager.add_ui_from_file (path);
        }
        catch (GLib.Error err)
        {
            error ("%s", err.message);
        }

        add_accel_group (ui_manager.get_accel_group ());

        // show tooltips in the statusbar
        ui_manager.connect_proxy.connect ((action, p) =>
        {
            if (p is MenuItem)
            {
                MenuItem proxy = (MenuItem) p;
                proxy.select.connect (on_menu_item_select);
                proxy.deselect.connect (on_menu_item_deselect);
            }
        });

        ui_manager.disconnect_proxy.connect ((action, p) =>
        {
            if (p is MenuItem)
            {
                MenuItem proxy = (MenuItem) p;
                proxy.select.disconnect (on_menu_item_select);
                proxy.deselect.disconnect (on_menu_item_deselect);
            }
        });

        // list of open documents menu
        documents_list_action_group = new ActionGroup ("DocumentsListActions");
        ui_manager.insert_action_group (documents_list_action_group, 0);
    }

    private void on_menu_item_select (Item proxy)
    {
        Action action = ((MenuItem) proxy).get_related_action ();
        return_if_fail (action != null);
        if (action.tooltip != null)
            statusbar.push (tip_message_cid, action.tooltip);
    }

    private void on_menu_item_deselect (Item proxy)
    {
        statusbar.pop (tip_message_cid);
    }

    public void open_document (File location)
    {
        /* check if the document is already opened */
        foreach (MainWindow w in Application.get_default ().windows)
        {
            foreach (Document doc in w.get_documents ())
            {
                if (doc.location != null && location.equal (doc.location))
                {
                    /* the document is already opened in this window */
                    if (this == w)
                    {
                        active_tab = doc.tab;
                        return;
                    }

                    /* the document is already opened in another window */
                    DocumentTab tab = create_tab_from_location (location, true);
                    tab.document.readonly = true;
                    string primary_msg = _("This file (%s) is already opened in another LaTeXila window.")
                        .printf (location.get_parse_name ());
                    string secondary_msg = _("LaTeXila opened this instance of the file in a non-editable way. Do you want to edit it anyway?");
                    InfoBar infobar = tab.add_message (primary_msg, secondary_msg,
                        MessageType.WARNING);
                    infobar.add_button (_("Edit Anyway"), ResponseType.YES);
                    infobar.add_button (_("Don't Edit"), ResponseType.NO);
                    infobar.response.connect ((response_id) =>
                    {
                        if (response_id == ResponseType.YES)
                            tab.document.readonly = false;
                        infobar.destroy ();
                        tab.view.grab_focus ();
                    });
                    return;
                }
            }
        }

        create_tab_from_location (location, true);
    }

    public DocumentTab? create_tab (bool jump_to)
    {
        var tab = new DocumentTab ();

        /* get unsaved document number */
        uint[] all_nums = {};
        foreach (Document doc in Application.get_default ().get_documents ())
        {
            if (doc.location == null)
                all_nums += doc.unsaved_document_n;
        }

        uint num;
        for (num = 1 ; num in all_nums ; num++);
        tab.document.unsaved_document_n = num;

        return process_create_tab (tab, jump_to);
    }

    public DocumentTab? create_tab_from_location (File location, bool jump_to)
    {
        var tab = new DocumentTab.from_location (location);
        return process_create_tab (tab, jump_to);
    }

    public void create_tab_with_view (DocumentView view)
    {
        var tab = new DocumentTab.with_view (view);
        process_create_tab (tab, true);
    }

    private DocumentTab? process_create_tab (DocumentTab? tab, bool jump_to)
    {
        if (tab == null)
            return null;

        tab.close_document.connect (() => { close_tab (tab); });

        /* sensitivity of undo and redo */
        tab.document.notify["can-undo"].connect (() =>
        {

            if (tab != active_tab)
                return;
            set_undo_sensitivity ();
        });

        tab.document.notify["can-redo"].connect (() =>
        {
            if (tab != active_tab)
                return;
            set_redo_sensitivity ();
        });

        /* sensitivity of cut/copy/delete */
        tab.document.notify["has-selection"].connect (() =>
        {
            if (tab != active_tab)
                return;
            selection_changed ();
        });

        tab.document.notify["location"].connect (() => { sync_name (tab); });
        tab.document.modified_changed.connect (() => { sync_name (tab); });
        tab.document.cursor_moved.connect (update_cursor_position_statusbar);

        tab.show ();

        // add the tab at the end of the notebook
        documents_panel.add_tab (tab, -1, jump_to);

        set_undo_sensitivity ();
        set_redo_sensitivity ();
        selection_changed ();

        if (! this.get_visible ())
            this.present ();

        return tab;
    }

    // return true if the tab was closed
    public bool close_tab (DocumentTab tab, bool force_close = false)
    {
        /* If document not saved
         * Ask the user if he wants to save the file, or close without saving, or cancel
         */
        if (! force_close && tab.document.get_modified ())
        {
            var dialog = new MessageDialog (this,
                DialogFlags.DESTROY_WITH_PARENT,
                MessageType.QUESTION,
                ButtonsType.NONE,
                _("Save changes to document \"%s\" before closing?"),
                tab.label_text);

            dialog.add_buttons (_("Close without Saving"), ResponseType.CLOSE,
                STOCK_CANCEL, ResponseType.CANCEL);

            if (tab.document.location == null)
                dialog.add_button (STOCK_SAVE_AS, ResponseType.ACCEPT);
            else
                dialog.add_button (STOCK_SAVE, ResponseType.ACCEPT);

            while (true)
            {
                int res = dialog.run ();
                // Close without Saving
                if (res == ResponseType.CLOSE)
                    break;

                // Save or Save As
                else if (res == ResponseType.ACCEPT)
                {
                    if (save_document (tab.document, false))
                        break;
                    continue;
                }

                // Cancel
                else
                {
                    dialog.destroy ();
                    return false;
                }
            }

            dialog.destroy ();
        }

        documents_panel.remove_tab (tab);
        return true;
    }

    public DocumentTab? get_tab_from_location (File location)
    {
        foreach (Document doc in get_documents ())
        {
            if (location.equal (doc.location))
                return doc.tab;
        }

        // not found
        return null;
    }

    public bool is_on_workspace_screen (Gdk.Screen? screen, uint workspace)
    {
        if (screen != null)
        {
            var cur_name = screen.get_display ().get_name ();
            var cur_n = screen.get_number ();
            Gdk.Screen s = this.get_screen ();
            var name = s.get_display ().get_name ();
            var n = s.get_number ();

            if (cur_name != name || cur_n != n)
                return false;
        }

        if (! this.get_realized ())
            this.realize ();

        uint ws = Utils.get_window_workspace (this);
        return ws == workspace || ws == Utils.ALL_WORKSPACES;
    }


    /*****************************
     *    ACTIONS SENSITIVITY    *
     *****************************/

    private void set_file_actions_sensitivity (bool sensitive)
    {
        // actions that must be insensitive if the notebook is empty
        string[] file_actions =
        {
            "FileSave", "FileSaveAs", "FileClose", "EditUndo", "EditRedo", "EditCut",
            "EditCopy", "EditPaste", "EditDelete", "EditSelectAll", "EditComment",
            "EditUncomment", "ViewZoomIn", "ViewZoomOut", "ViewZoomReset",
            "DocumentsSaveAll", "DocumentsCloseAll", "DocumentsPrevious", "DocumentsNext",
            "SearchFind", "SearchReplace", "SearchGoToLine"
        };

        foreach (string file_action in file_actions)
        {
            Action action = action_group.get_action (file_action);
            action.set_sensitive (sensitive);
        }

        latex_action_group.set_sensitive (sensitive);
    }

    private void set_undo_sensitivity ()
    {
        if (active_tab != null)
        {
            Action action = action_group.get_action ("EditUndo");
            action.set_sensitive (active_document.can_undo);
        }
    }

    private void set_redo_sensitivity ()
    {
        if (active_tab != null)
        {
            Action action = action_group.get_action ("EditRedo");
            action.set_sensitive (active_document.can_redo);
        }
    }

    private void set_documents_move_to_new_window_sensitivity (bool sensitive)
    {
        Action action = action_group.get_action ("DocumentsMoveToNewWindow");
        action.set_sensitive (sensitive);
    }

    private void update_next_prev_doc_sensitivity ()
    {
        if (active_tab != null)
        {
            Action action_previous = action_group.get_action ("DocumentsPrevious");
            Action action_next = action_group.get_action ("DocumentsNext");

            int current_page = documents_panel.page_num (active_tab);
            action_previous.set_sensitive (current_page > 0);

            int nb_pages = documents_panel.get_n_pages ();
            action_next.set_sensitive (current_page < nb_pages - 1);
        }
    }

    private void selection_changed ()
    {
        if (active_tab != null)
        {
            bool has_selection = active_document.has_selection;

            // actions that must be insensitive if there is no selection
            string[] selection_actions = { "EditCut", "EditCopy", "EditDelete" };

            foreach (string selection_action in selection_actions)
            {
                Action action = action_group.get_action (selection_action);
                action.set_sensitive (has_selection);
            }
        }
    }


    private void sync_name (DocumentTab tab)
    {
        if (tab == active_tab)
            my_set_title ();

        // sync the item in the documents list menu
        int page_num = documents_panel.page_num (tab);
        string action_name = "Tab_%d".printf (page_num);
        Action action = documents_list_action_group.get_action (action_name);
        return_if_fail (action != null);
        action.label = tab.get_name ().replace ("_", "__");
        action.tooltip = tab.get_menu_tip ();
    }

    private void my_set_title ()
    {
        if (active_tab == null)
        {
            this.title = "LaTeXila";
            return;
        }

        uint max_title_length = 100;
        string title = null;
        string dirname = null;

        File loc = active_document.location;
        if (loc == null)
            title = active_document.get_short_name_for_display ();
        else
        {
            string basename = loc.get_basename ();
            if (basename.length > max_title_length)
                title = Utils.str_middle_truncate (basename, max_title_length);
            else
            {
                title = basename;
                dirname = Utils.str_middle_truncate (
                    Utils.get_dirname_for_display (loc),
                    (uint) long.max (20, max_title_length - basename.length));
            }
        }

        this.title = (active_document.get_modified () ? "*" : "") +
                     title +
                     (active_document.readonly ? " [" + _("Read-Only") + "]" : "") +
                     (dirname != null ? " (" + dirname + ")" : "") +
                     " - LaTeXila";
    }

    // return true if the document has been saved
    public bool save_document (Document doc, bool force_save_as)
    {
        if (! force_save_as && doc.location != null)
        {
            doc.save ();
            return true;
        }

        var file_chooser = new FileChooserDialog (_("Save File"), this,
            FileChooserAction.SAVE,
            STOCK_CANCEL, ResponseType.CANCEL,
            STOCK_SAVE, ResponseType.ACCEPT,
            null);

        file_chooser.set_current_name (doc.tab.label_text);
        if (this.file_chooser_current_folder != null)
            file_chooser.set_current_folder (this.file_chooser_current_folder);

        if (doc.location != null)
        {
            try
            {
                // override the current name and current folder
                file_chooser.set_file (doc.location);
            }
            catch (Error e) {}
        }

        while (file_chooser.run () == ResponseType.ACCEPT)
        {
            File file = file_chooser.get_file ();

            /* if the file exists, ask the user if the file can be replaced */
            if (file.query_exists (null))
            {
                var confirmation = new MessageDialog (this,
                    DialogFlags.DESTROY_WITH_PARENT,
                    MessageType.QUESTION,
                    ButtonsType.NONE,
                    _("A file named \"%s\" already exists. Do you want to replace it?"),
                    file.get_basename ());

                confirmation.add_button (STOCK_CANCEL, ResponseType.CANCEL);

                var button_replace = new Button.with_label (_("Replace"));
                var icon = new Image.from_stock (STOCK_SAVE_AS, IconSize.BUTTON);
                button_replace.set_image (icon);
                confirmation.add_action_widget (button_replace, ResponseType.YES);
                button_replace.show ();

                var response = confirmation.run ();
                confirmation.destroy ();

                if (response != ResponseType.YES)
                    continue;
            }

            doc.location = file;
            break;
        }

        this.file_chooser_current_folder = file_chooser.get_current_folder ();
        file_chooser.destroy ();

        if (doc.location != null)
        {
            doc.save (false);
            return true;
        }
        return false;
    }

    // return true if all the documents are closed
    private bool close_all_documents ()
    {
        List<Document> unsaved_documents = get_unsaved_documents ();

        /* no unsaved document */
        if (unsaved_documents == null)
        {
            documents_panel.remove_all_tabs ();
            return true;
        }

        /* only one unsaved document */
        else if (unsaved_documents.next == null)
        {
            Document doc = unsaved_documents.data;
            active_tab = doc.tab;
            if (close_tab (doc.tab))
            {
                documents_panel.remove_all_tabs ();
                return true;
            }
        }

        /* more than one unsaved document */
        else
        {
            Dialogs.close_several_unsaved_documents (this, unsaved_documents);
            if (documents_panel.get_n_pages () == 0)
                return true;
        }

        return false;
    }

    public void remove_all_tabs ()
    {
        documents_panel.remove_all_tabs ();
    }

    private void update_cursor_position_statusbar ()
    {
        TextIter iter;
        active_document.get_iter_at_mark (out iter, active_document.get_insert ());
        int row = (int) iter.get_line ();
        int col = (int) active_view.my_get_visual_column (iter);
        statusbar.set_cursor_position (row + 1, col + 1);
    }

    private void setup_toolbar_open_button (Toolbar toolbar)
    {
        RecentManager recent_manager = RecentManager.get_default ();
        Widget toolbar_recent_menu = new RecentChooserMenu.for_manager (recent_manager);
        configure_recent_chooser ((RecentChooser) toolbar_recent_menu);

        MenuToolButton open_button = new MenuToolButton.from_stock (STOCK_OPEN);
        open_button.set_menu (toolbar_recent_menu);
        open_button.set_tooltip_text (_("Open a file"));
        open_button.set_arrow_tooltip_text (_("Open a recently used file"));

        Action action = action_group.get_action ("FileOpen");
        open_button.set_related_action (action);

        toolbar.insert (open_button, 1);
    }

    private void configure_recent_chooser (RecentChooser recent_chooser)
    {
        recent_chooser.set_local_only (false);
        recent_chooser.set_sort_type (RecentSortType.MRU);

        RecentFilter filter = new RecentFilter ();
        filter.add_application ("latexila");
        recent_chooser.set_filter (filter);

        recent_chooser.item_activated.connect ((chooser) =>
        {
            string uri = chooser.get_current_uri ();
            open_document (File.new_for_uri (uri));
        });
    }

    public void save_state (bool sync = false)
    {
        GLib.Settings settings = new GLib.Settings ("org.gnome.latexila.state.window");

        // state of the window
        Gdk.WindowState state = get_window ().get_state ();
        settings.set_int ("state", state);

        // get width and height of the window
        int w, h;
        get_size (out w, out h);

        // If window is maximized, store sizes that are a bit smaller than full screen,
        // else making window non-maximized the next time will have no effect.
        if (Gdk.WindowState.MAXIMIZED in state)
        {
            w -= 100;
            h -= 100;
        }

        settings.set ("size", "(ii)", w, h);

        if (sync)
            settings.sync ();
    }

    private void move_tab_to_new_window (DocumentTab tab)
    {
        MainWindow new_window = Application.get_default ().create_window ();
        DocumentView view = tab.view;
        documents_panel.remove_tab (tab);

        // we create a new tab with the same view, so we avoid headache with signals
        // the user see nothing, muahahaha
        new_window.create_tab_with_view (view);
    }

    private void update_documents_list_menu ()
    {
        return_if_fail (documents_list_action_group != null);

        if (documents_list_menu_ui_id != 0)
            ui_manager.remove_ui (documents_list_menu_ui_id);

        foreach (Action action in documents_list_action_group.list_actions ())
        {
            action.activate.disconnect (documents_list_menu_activate);
            documents_list_action_group.remove_action (action);
        }

        int n = documents_panel.get_n_pages ();
        uint id = n > 0 ? ui_manager.new_merge_id () : 0;

        unowned SList<RadioAction> group = null;

        for (int i = 0 ; i < n ; i++)
        {
            DocumentTab tab = (DocumentTab) documents_panel.get_nth_page (i);
            string action_name = "Tab_%d".printf (i);
            string name = tab.get_name ().replace ("_", "__");
            string tip = tab.get_menu_tip ();
            string accel = i < 10 ? "<alt>%d".printf ((i + 1) % 10) : null;

            RadioAction action = new RadioAction (action_name, name, tip, null, i);
            if (group != null)
                action.set_group (group);

            /* group changes each time we add an action, so it must be updated */
            group = action.get_group ();

            documents_list_action_group.add_action_with_accel (action, accel);

            action.activate.connect (documents_list_menu_activate);

            ui_manager.add_ui (id, "/MainMenu/DocumentsMenu/DocumentsListPlaceholder",
                action_name, action_name, UIManagerItemType.MENUITEM, false);

            if (tab == active_tab)
                action.set_active (true);
        }

        documents_list_menu_ui_id = id;
    }

    private void documents_list_menu_activate (Action action)
    {
        RadioAction radio_action = (RadioAction) action;
        if (! radio_action.get_active ())
            return;

        documents_panel.set_current_page (radio_action.get_current_value ());
    }


    /*******************
     *    CALLBACKS
     ******************/

    /* File menu */

    public void on_file_new ()
    {
        create_tab (true);
    }

    public void on_new_window ()
    {
        Application.get_default ().create_window ();
    }

    public void on_file_open ()
    {
        FileChooserDialog file_chooser = new FileChooserDialog (_("Open Files"), this,
            FileChooserAction.OPEN,
            STOCK_CANCEL, ResponseType.CANCEL,
            STOCK_OPEN, ResponseType.ACCEPT,
            null);

        if (this.file_chooser_current_folder != null)
            file_chooser.set_current_folder (this.file_chooser_current_folder);

        file_chooser.select_multiple = true;

        SList<File> files_to_open = null;
        if (file_chooser.run () == ResponseType.ACCEPT)
            files_to_open = file_chooser.get_files ();

        this.file_chooser_current_folder = file_chooser.get_current_folder ();
        file_chooser.destroy ();

        // We open the files after closing the dialog, because open a lot of documents can
        // take some time (this is not async).
        foreach (File file in files_to_open)
            open_document (file);
    }

    public void on_file_save ()
    {
        return_if_fail (active_tab != null);
        save_document (active_document, false);
    }

    public void on_file_save_as ()
    {
        return_if_fail (active_tab != null);
        save_document (active_document, true);
    }

    public void on_file_close ()
    {
        return_if_fail (active_tab != null);
        close_tab (active_tab);
    }

    public void on_quit ()
    {
        // save documents list
        string[] list_uris = {};
        foreach (Document doc in get_documents ())
        {
            if (doc.location != null)
                list_uris += doc.location.get_uri ();
        }

        GLib.Settings settings = new GLib.Settings ("org.gnome.latexila.state.window");
        // TODO use set_strv() when vapi is fixed upstream
        //settings.set_strv ("documents", list_uris);
        settings.set_value ("documents", new Variant.strv (list_uris));

        if (close_all_documents ())
        {
            save_state ();
            destroy ();
        }
    }

    /* Edit menu */

    public void on_edit_undo ()
    {
        return_if_fail (active_tab != null);
        if (active_document.can_undo)
        {
            active_document.undo ();
            active_view.scroll_to_cursor ();
            active_view.grab_focus ();
        }
    }

    public void on_edit_redo ()
    {
        return_if_fail (active_tab != null);
        if (active_document.can_redo)
        {
            active_document.redo ();
            active_view.scroll_to_cursor ();
            active_view.grab_focus ();
        }
    }

    public void on_edit_cut ()
    {
        return_if_fail (active_tab != null);
        active_view.cut_selection ();
    }

    public void on_edit_copy ()
    {
        return_if_fail (active_tab != null);
        active_view.copy_selection ();
    }

    public void on_edit_paste ()
    {
        return_if_fail (active_tab != null);
        active_view.my_paste_clipboard ();
    }

    public void on_edit_delete ()
    {
        return_if_fail (active_tab != null);
        active_view.delete_selection ();
    }

    public void on_edit_select_all ()
    {
        return_if_fail (active_tab != null);
        active_view.my_select_all ();
    }

    public void on_edit_comment ()
    {
        return_if_fail (active_tab != null);
        active_document.comment_selected_lines ();
    }

    public void on_edit_uncomment ()
    {
        return_if_fail (active_tab != null);
        active_document.uncomment_selected_lines ();
    }

    public void on_open_preferences ()
    {
        PreferencesDialog.show_me (this);
    }

    /* View */

    public void on_view_zoom_in ()
    {
        return_if_fail (active_tab != null);
        active_view.enlarge_font ();
    }

    public void on_view_zoom_out ()
    {
        return_if_fail (active_tab != null);
        active_view.shrink_font ();
    }

    public void on_view_zoom_reset ()
    {
        return_if_fail (active_tab != null);
        active_view.set_font_from_settings ();
    }

    /* Search */

    public void on_search_find ()
    {
        return_if_fail (active_tab != null);
        search_and_replace.show_search ();
    }

    public void on_search_replace ()
    {
        return_if_fail (active_tab != null);
        search_and_replace.show_search_and_replace ();
    }

    public void on_search_goto_line ()
    {
        return_if_fail (active_tab != null);
        goto_line.show ();
    }

    /* Documents */

    public void on_documents_save_all ()
    {
        return_if_fail (active_tab != null);
        foreach (Document doc in get_unsaved_documents ())
        {
            active_tab = doc.tab;
            doc.save ();
        }
    }

    public void on_documents_close_all ()
    {
        return_if_fail (active_tab != null);
        close_all_documents ();
    }

    public void on_documents_previous ()
    {
        return_if_fail (active_tab != null);
        documents_panel.prev_page ();
    }

    public void on_documents_next ()
    {
        return_if_fail (active_tab != null);
        documents_panel.next_page ();
    }

    public void on_documents_move_to_new_window ()
    {
        return_if_fail (active_tab != null);
        move_tab_to_new_window (active_tab);
    }

    /* Help */

    public void on_about_dialog ()
    {
        string comments =
            _("LaTeXila is an Integrated LaTeX Environment for the GNOME desktop");
        string copyright = "Copyright (C) 2009, 2010 Sébastien Wilmet";
        string licence =
"""LaTeXila is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

LaTeXila is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with LaTeXila.  If not, see <http://www.gnu.org/licenses/>.""";

		string website = "http://latexila.sourceforge.net/";

		string[] authors =
		{
		    "Sébastien Wilmet <sebastien.wilmet@gmail.com>",
		    null
		};

		string[] artists =
		{
		    "Eric Forgeot <e.forgeot@laposte.net>",
		    "Sébastien Wilmet <sebastien.wilmet@gmail.com>",
		    "The Kile Team: http://kile.sourceforge.net/",
		    "Gedit LaTeX Plugin: http://www.michaels-website.de/gedit-latex-plugin/",
		    null
		};

        Gdk.Pixbuf logo = null;
        try
        {
		    logo = new Gdk.Pixbuf.from_file (Config.DATA_DIR + "/images/app/logo.png");
		}
		catch (Error e)
		{
		    stderr.printf ("Error with the logo: %s\n", e.message);
		}

		show_about_dialog (this,
		    "program-name", "LaTeXila",
		    "version", Config.APP_VERSION,
		    "authors", authors,
		    "artists", artists,
		    "comments", comments,
		    "copyright", copyright,
		    "license", licence,
		    "title", _("About LaTeXila"),
		    "translator-credits", _("translator-credits"),
		    "website", website,
		    "logo", logo,
		    null);
    }


    /***********************
     *    LaTeX actions    *
     ***********************/

    private void text_buffer_insert (string text_before, string text_after,
        string? text_if_no_selection)
    {
        return_if_fail (active_tab != null);

	    // we do not use the insert and selection_bound marks because we don't
	    // know the order. With gtk_text_buffer_get_selection_bounds, we are certain
	    // that "start" points to the start of the selection, where we must insert
	    // "text_before".

	    TextIter start, end;
        bool text_selected = active_document.get_selection_bounds (out start, out end);

        active_document.begin_user_action ();

	    // insert around the selected text
	    // move the cursor to the end
	    if (text_selected)
	    {
	        TextMark mark_end = active_document.create_mark (null, end, false);
            active_document.insert (start, text_before, -1);
            active_document.get_iter_at_mark (out end, mark_end);
            active_document.insert (end, text_after, -1);

            active_document.get_iter_at_mark (out end, mark_end);
		    active_document.select_range (end, end);
	    }

	    // no selection
	    else if (text_if_no_selection != null)
	        active_document.insert_at_cursor (text_if_no_selection, -1);

	    // no selection
	    // move the cursor between the 2 texts inserted
	    else
	    {
	        active_document.insert_at_cursor (text_before, -1);

		    TextIter between;
		    active_document.get_iter_at_mark (out between, active_document.get_insert ());
		    TextMark mark = active_document.create_mark (null, between, true);

            active_document.insert_at_cursor (text_after, -1);

            active_document.get_iter_at_mark (out between, mark);
		    active_document.select_range (between, between);
	    }

        active_document.end_user_action ();
    }

    /* sectioning */

    public void on_sectioning_part ()
    {
        text_buffer_insert ("\\part{", "}", null);
    }

    public void on_sectioning_chapter ()
    {
        text_buffer_insert ("\\chapter{", "}", null);
    }

    public void on_sectioning_section ()
    {
        text_buffer_insert ("\\section{", "}", null);
    }

    public void on_sectioning_subsection ()
    {
        text_buffer_insert ("\\subsection{", "}", null);
    }

    public void on_sectioning_subsubsection ()
    {
        text_buffer_insert ("\\subsubsection{", "}", null);
    }

    public void on_sectioning_paragraph ()
    {
        text_buffer_insert ("\\paragraph{", "}", null);
    }

    public void on_sectioning_subparagraph ()
    {
        text_buffer_insert ("\\subparagraph{", "}", null);
    }

    /* References */

    public void on_ref_label ()
    {
        text_buffer_insert ("\\label{", "} ", null);
    }

    public void on_ref_ref ()
    {
        text_buffer_insert ("\\ref{", "} ", null);
    }

    public void on_ref_pageref ()
    {
        text_buffer_insert ("\\pageref{", "} ", null);
    }

    public void on_ref_index ()
    {
        text_buffer_insert ("\\index{", "} ", null);
    }

    public void on_ref_footnote ()
    {
        text_buffer_insert ("\\footnote{", "} ", null);
    }

    public void on_ref_cite ()
    {
        text_buffer_insert ("\\cite{", "} ", null);
    }

    /* environments */

    public void on_env_center ()
    {
        text_buffer_insert ("\\begin{center}\n", "\n\\end{center}", null);
    }

    public void on_env_left ()
    {
        text_buffer_insert ("\\begin{flushleft}\n", "\n\\end{flushleft}", null);
    }

    public void on_env_right ()
    {
        text_buffer_insert ("\\begin{flushright}\n", "\n\\end{flushright}", null);
    }

    public void on_env_minipage ()
    {
        text_buffer_insert ("\\begin{minipage}\n", "\n\\end{minipage}", null);
    }

    public void on_env_quote ()
    {
        text_buffer_insert ("\\begin{quote}\n", "\n\\end{quote}", null);
    }

    public void on_env_quotation ()
    {
        text_buffer_insert ("\\begin{quotation}\n", "\n\\end{quotation}", null);
    }

    public void on_env_verse ()
    {
        text_buffer_insert ("\\begin{verse}\n", "\n\\end{verse}", null);
    }

    /* List Environments */

    public void on_list_env_itemize ()
    {
        text_buffer_insert ("\\begin{itemize}\n  \\item ", "\n\\end{itemize}",
                null);
    }

    public void on_list_env_enumerate ()
    {
        text_buffer_insert ("\\begin{enumerate}\n  \\item ", "\n\\end{enumerate}",
                null);
    }

    public void on_list_env_description ()
    {
        text_buffer_insert ("\\begin{description}\n  \\item[",
                "] \n\\end{description}", null);
    }

    public void on_list_env_item ()
    {
        text_buffer_insert ("\\item ", "", null);
    }


    /* Characters sizes */

    public void on_size_tiny ()
    {
        text_buffer_insert ("{\\tiny ", "}", "\\tiny ");
    }

    public void on_size_scriptsize ()
    {
        text_buffer_insert ("{\\scriptsize ", "}", "\\scriptsize ");
    }

    public void on_size_footnotesize ()
    {
        text_buffer_insert ("{\\footnotesize ", "}", "\\footnotesize ");
    }

    public void on_size_small ()
    {
        text_buffer_insert ("{\\small ", "}", "\\small ");
    }

    public void on_size_normalsize ()
    {
        text_buffer_insert ("{\\normalsize ", "}", "\\normalsize ");
    }

    public void on_size_large ()
    {
        text_buffer_insert ("{\\large ", "}", "\\large ");
    }

    public void on_size_Large ()
    {
        text_buffer_insert ("{\\Large ", "}", "\\Large ");
    }

    public void on_size_LARGE ()
    {
        text_buffer_insert ("{\\LARGE ", "}", "\\LARGE ");
    }

    public void on_size_huge ()
    {
        text_buffer_insert ("{\\huge ", "}", "\\huge ");
    }

    public void on_size_Huge ()
    {
        text_buffer_insert ("{\\Huge ", "}", "\\Huge ");
    }

    /* Font styles */

    public void on_text_bold ()
    {
        text_buffer_insert ("\\textbf{", "}", null);
    }

    public void on_text_italic ()
    {
        text_buffer_insert ("\\textit{", "}", null);
    }

    public void on_text_typewriter ()
    {
        text_buffer_insert ("\\texttt{", "}", null);
    }

    public void on_text_underline ()
    {
        text_buffer_insert ("\\underline{", "}", null);
    }

    public void on_text_slanted ()
    {
        text_buffer_insert ("\\textsl{", "}", null);
    }

    public void on_text_small_caps ()
    {
        text_buffer_insert ("\\textsc{", "}", null);
    }

    public void on_text_emph ()
    {
        text_buffer_insert ("\\emph{", "}", null);
    }

    public void on_text_font_family_roman ()
    {
        text_buffer_insert ("{\\rmfamily ", "}", "\\rmfamily ");
    }

    public void on_text_font_family_sans_serif ()
    {
        text_buffer_insert ("{\\sffamily ", "}", "\\sffamily ");
    }

    public void on_text_font_family_monospace ()
    {
        text_buffer_insert ("{\\ttfamily ", "}", "\\ttfamily ");
    }

    public void on_text_font_series_medium ()
    {
        text_buffer_insert ("{\\mdseries ", "}", "\\mdseries ");
    }

    public void on_text_font_series_bold ()
    {
        text_buffer_insert ("{\\bfseries ", "}", "\\bfseries ");
    }

    public void on_text_font_shape_upright ()
    {
        text_buffer_insert ("{\\upshape ", "}", "\\upshape ");
    }

    public void on_text_font_shape_italic ()
    {
        text_buffer_insert ("{\\itshape ", "}", "\\itshape ");
    }

    public void on_text_font_shape_slanted ()
    {
        text_buffer_insert ("{\\slshape ", "}", "\\slshape ");
    }

    public void on_text_font_shape_small_caps ()
    {
        text_buffer_insert ("{\\scshape ", "}", "\\scshape ");
    }

    public void on_math_env_normal ()
    {
        text_buffer_insert ("$ ", " $", null);
    }

    public void on_math_env_centered ()
    {
        text_buffer_insert ("$$ ", " $$", null);
    }

    public void on_math_env_numbered ()
    {
        text_buffer_insert ("\\begin{equation}\n", "\n\\end{equation}", null);
    }

    public void on_math_env_array ()
    {
        text_buffer_insert ("\\begin{align*}\n", "\n\\end{align*}", null);
    }

    public void on_math_env_numbered_array ()
    {
        text_buffer_insert ("\\begin{align}\n", "\n\\end{align}", null);
    }

    public void on_math_superscript ()
    {
        text_buffer_insert ("^{", "}", null);
    }

    public void on_math_subscript ()
    {
        text_buffer_insert ("_{", "}", null);
    }

    public void on_math_frac ()
    {
        text_buffer_insert ("\\frac{", "}{}", null);
    }

    public void on_math_square_root ()
    {
        text_buffer_insert ("\\sqrt{", "}", null);
    }

    public void on_math_nth_root ()
    {
        text_buffer_insert ("\\sqrt[]{", "}", null);
    }

    public void on_math_left_delimiter_1 ()
    {
        text_buffer_insert ("\\left( ", "", null);
    }

    public void on_math_left_delimiter_2 ()
    {
        text_buffer_insert ("\\left[ ", "", null);
    }

    public void on_math_left_delimiter_3 ()
    {
        text_buffer_insert ("\\left\\lbrace ", "", null);
    }

    public void on_math_left_delimiter_4 ()
    {
        text_buffer_insert ("\\left\\langle ", "", null);
    }

    public void on_math_left_delimiter_5 ()
    {
        text_buffer_insert ("\\left) ", "", null);
    }

    public void on_math_left_delimiter_6 ()
    {
        text_buffer_insert ("\\left] ", "", null);
    }

    public void on_math_left_delimiter_7 ()
    {
        text_buffer_insert ("\\left\\rbrace ", "", null);
    }

    public void on_math_left_delimiter_8 ()
    {
        text_buffer_insert ("\\left\\rangle ", "", null);
    }

    public void on_math_left_delimiter_9 ()
    {
        text_buffer_insert ("\\left. ", "", null);
    }

    public void on_math_right_delimiter_1 ()
    {
        text_buffer_insert ("\\right( ", "", null);
    }

    public void on_math_right_delimiter_2 ()
    {
        text_buffer_insert ("\\right[ ", "", null);
    }

    public void on_math_right_delimiter_3 ()
    {
        text_buffer_insert ("\\right\\rbrace ", "", null);
    }

    public void on_math_right_delimiter_4 ()
    {
        text_buffer_insert ("\\right\\rangle ", "", null);
    }

    public void on_math_right_delimiter_5 ()
    {
        text_buffer_insert ("\\right) ", "", null);
    }

    public void on_math_right_delimiter_6 ()
    {
        text_buffer_insert ("\\right] ", "", null);
    }

    public void on_math_right_delimiter_7 ()
    {
        text_buffer_insert ("\\right\\lbrace ", "", null);
    }

    public void on_math_right_delimiter_8 ()
    {
        text_buffer_insert ("\\right\\langle ", "", null);
    }

    public void on_math_right_delimiter_9 ()
    {
        text_buffer_insert ("\\right. ", "", null);
    }
}

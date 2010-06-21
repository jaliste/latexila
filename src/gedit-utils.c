/*
 * gedit-utils.c
 * This file is part of gedit
 *
 * Copyright (C) 1998, 1999 Alex Roberts, Evan Lawrence
 * Copyright (C) 2000, 2002 Chema Celorio, Paolo Maggi 
 * Copyright (C) 2003-2005 Paolo Maggi 
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, 
 * Boston, MA 02111-1307, USA. 
 */
 
#include <gdk/gdkx.h>
#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <X11/Xatom.h>

#include "gedit-utils.h"

/**
 * gedit_utils_get_window_workspace:
 *
 * Get the workspace the window is on
 *
 * This function gets the workspace that the #GtkWindow is visible on,
 * it returns GEDIT_ALL_WORKSPACES if the window is sticky, or if
 * the window manager doesn support this function
 */
guint
gedit_utils_get_window_workspace (GtkWindow *gtkwindow)
{
	GdkWindow *window;
	GdkDisplay *display;
	Atom type;
	gint format;
	gulong nitems;
	gulong bytes_after;
	guint *workspace;
	gint err, result;
	guint ret = GEDIT_ALL_WORKSPACES;

	g_return_val_if_fail (GTK_IS_WINDOW (gtkwindow), 0);
	g_return_val_if_fail (gtk_widget_get_realized (GTK_WIDGET (gtkwindow)), 0);

	window = gtk_widget_get_window (GTK_WIDGET (gtkwindow));
	display = gdk_drawable_get_display (window);

	gdk_error_trap_push ();
	result = XGetWindowProperty (GDK_DISPLAY_XDISPLAY (display), GDK_WINDOW_XID (window),
				     gdk_x11_get_xatom_by_name_for_display (display, "_NET_WM_DESKTOP"),
				     0, G_MAXLONG, False, XA_CARDINAL, &type, &format, &nitems,
				     &bytes_after, (gpointer) &workspace);
	err = gdk_error_trap_pop ();

	if (err != Success || result != Success)
		return ret;

	if (type == XA_CARDINAL && format == 32 && nitems > 0)
		ret = workspace[0];

	XFree (workspace);
	return ret;
}

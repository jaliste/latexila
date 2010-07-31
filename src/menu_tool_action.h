/*
 * This file is part of LaTeXila.
 *
 * Copyright © 2009 Sébastien Wilmet
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

#ifndef __MENU_TOOL_ACTION_H__
#define __MENU_TOOL_ACTION_H__

#include <gtk/gtkaction.h>

G_BEGIN_DECLS

#define TYPE_MENU_TOOL_ACTION				(menu_tool_action_get_type ())
#define MENU_TOOL_ACTION(obj)				(G_TYPE_CHECK_INSTANCE_CAST ((obj), TYPE_MENU_TOOL_ACTION, ToolMenuAction))
#define MENU_TOOL_ACTION_CLASS(klass)		(G_TYPE_CHECK_CLASS_CAST ((klass), TYPE_MENU_TOOL_ACTION, ToolMenuActionClass))
#define IS_MENU_TOOL_ACTION(obj)			(G_TYPE_CHECK_INSTANCE_TYPE ((obj), TYPE_MENU_TOOL_ACTION))
#define IS_MENU_TOOL_ACTION_CLASS(klass)	(G_TYPE_CHECK_CLASS_TYPE ((klass), TYPE_MENU_TOOL_ACTION))

typedef struct _ToolMenuAction		ToolMenuAction;
typedef struct _ToolMenuActionClass	ToolMenuActionClass;

struct _ToolMenuAction
{
	GtkAction parent_instance;
};

struct _ToolMenuActionClass
{
	GtkActionClass parent_class;
};

GType menu_tool_action_get_type (void);
GtkAction * menu_tool_action_new (const gchar *name, const gchar *label,
		const gchar *tooltip, const gchar *stock_id);

G_END_DECLS

#endif /* __MENU_TOOL_ACTION_H__ */

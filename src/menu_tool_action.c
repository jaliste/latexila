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

#include <gtk/gtkmenutoolbutton.h>
#include "menu_tool_action.h"

static void menu_tool_action_init (ToolMenuAction *tma);
static void menu_tool_action_class_init (ToolMenuActionClass *klass);

GType
menu_tool_action_get_type (void)
{
	static GType type = 0;
	if (! type)
	{
		static const GTypeInfo type_info =
		{
			sizeof (ToolMenuActionClass),
			NULL,
			NULL,
			(GClassInitFunc) menu_tool_action_class_init,
			NULL,
			NULL,
			sizeof (ToolMenuAction),
			0,
			(GInstanceInitFunc) menu_tool_action_init,
			NULL
		};

		type = g_type_register_static (GTK_TYPE_ACTION, "ToolMenuAction",
				&type_info, 0);
	}
	
	return type;
}

static void
menu_tool_action_class_init (ToolMenuActionClass *klass)
{
	GtkActionClass *action_class = GTK_ACTION_CLASS (klass);
	action_class->toolbar_item_type = GTK_TYPE_MENU_TOOL_BUTTON;
}

static void
menu_tool_action_init (ToolMenuAction *tma)
{
}

GtkAction *
menu_tool_action_new (const gchar *name, const gchar *label,
		const gchar *tooltip, const gchar *stock_id)
{
	g_return_val_if_fail (name != NULL, NULL);

	return g_object_new (TYPE_MENU_TOOL_ACTION,
			"name", name,
			"label", label,
			"tooltip", tooltip,
			"stock-id", stock_id,
			NULL);
}

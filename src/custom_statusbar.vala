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

public class CustomStatusbar : Statusbar
{
    private Statusbar cursor_position;

    public CustomStatusbar ()
    {
        cursor_position = new Statusbar ();
        cursor_position.has_resize_grip = false;
        cursor_position.set_size_request (150, -1);
        pack_end (cursor_position, false, true, 0);
    }

    public void set_cursor_position (int line, int col)
    {
        cursor_position.pop (0);
        if (line == -1 && col == -1)
            return;
        cursor_position.push (0, _("Ln %d, Col %d").printf (line, col));
    }
}

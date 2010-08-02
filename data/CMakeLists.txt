install (FILES "org.gnome.latexila.gschema.xml"
	DESTINATION "${CMAKE_INSTALL_PREFIX}/share/glib-2.0/schemas")
install (SCRIPT "cmake-compile-schemas")

add_subdirectory ("templates")
add_subdirectory ("images/app")
add_subdirectory ("images/icons")
add_subdirectory ("images/templates")

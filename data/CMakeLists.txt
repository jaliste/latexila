configure_file ("${latexila_SOURCE_DIR}/data/org.gnome.latexila.gschema.xml.in"
	"${latexila_BINARY_DIR}/data/org.gnome.latexila.gschema.xml")
install (FILES "${latexila_BINARY_DIR}/data/org.gnome.latexila.gschema.xml"
	DESTINATION "${CMAKE_INSTALL_PREFIX}/share/glib-2.0/schemas/")

install (SCRIPT "cmake-compile-schemas")

add_subdirectory ("templates")
add_subdirectory ("images/app")
add_subdirectory ("images/icons")
add_subdirectory ("images/templates")
add_subdirectory ("images/arrows")
add_subdirectory ("images/delimiters")
add_subdirectory ("images/greek")
add_subdirectory ("images/misc-math")
add_subdirectory ("images/misc-text")
add_subdirectory ("images/operators")
add_subdirectory ("images/relations")

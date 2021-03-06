cmake_minimum_required (VERSION 2.6.4)

project ("latexila" C)

set (APP_NAME "LaTeXila")
set (APP_VERSION "1.98.0")

message (STATUS "*** Building ${APP_NAME} ${APP_VERSION} ***")

set (DATA_DIR "${CMAKE_INSTALL_PREFIX}/share/latexila"
	CACHE PATH "The directory where the data is")

# for debugging
#set (CMAKE_C_FLAGS "-ggdb")

# Native Language Support
set (GETTEXT_PACKAGE "latexila")
set (LOCALE_DIR "${CMAKE_INSTALL_PREFIX}/share/locale")
find_package (Gettext REQUIRED)
file (GLOB latexila_PO_FILES ${latexila_SOURCE_DIR}/po/*.po)
gettext_create_translations (po/latexila.pot ALL ${latexila_PO_FILES})

set (SCHEMA_DIR "${CMAKE_INSTALL_PREFIX}/share")
set (ICONS_DIR "${CMAKE_INSTALL_PREFIX}/share/icons/hicolor")
configure_file (${latexila_SOURCE_DIR}/src/config.h.in
	${latexila_BINARY_DIR}/src/config.h)
add_definitions (-include config.h)

list (APPEND CMAKE_MODULE_PATH "${latexila_SOURCE_DIR}/cmake/vala")
include (ValaPrecompile)
include (ValaVersion)
find_package (Vala REQUIRED)
ensure_vala_version ("0.9.4" MINIMUM)

find_package (PkgConfig)
pkg_check_modules (GTK REQUIRED "gtk+-2.0 >= 2.16")
pkg_check_modules (GTKSOURCEVIEW REQUIRED "gtksourceview-2.0 >= 2.4")
#pkg_check_modules (GEE REQUIRED "gee-1.0")
pkg_check_modules (GIO REQUIRED "gio-2.0 >= 2.25.10")
pkg_check_modules (UNIQUE REQUIRED "unique-1.0")
pkg_check_modules (GDK-X11 REQUIRED "gdk-x11-2.0")
pkg_check_modules (X11 REQUIRED "x11")

add_definitions (
	${GTK_CFLAGS}
	${GTKSOURCEVIEW_CFLAGS}
	#${GEE_CFLAGS}
	${GIO_CFLAGS}
	${UNIQUE_CFLAGS}
	${GDK-X11_CFLAGS}
	${X11_CFLAGS}
)

link_libraries (
	${GTK_LIBRARIES}
	${GTKSOURCEVIEW_LIBRARIES}
	#${GEE_LIBRARIES}
	${GIO_LIBRARIES}
	${UNIQUE_LIBRARIES}
	${GDK-X11_LIBRARIES}
	${X11_LIBRARIES}
)

set (COMMAND_LATEX "latex")
set (COMMAND_PDFLATEX "pdflatex")
set (COMMAND_DVIPDF "dvipdf")
set (COMMAND_DVIPS "dvips")
set (COMMAND_BIBTEX "bibtex")
set (COMMAND_MAKEINDEX "makeindex")

find_package (LATEX)

if (LATEX_COMPILER)
  set (COMMAND_LATEX ${LATEX_COMPILER})
endif (LATEX_COMPILER)

if (PDFLATEX_COMPILER)
  set (COMMAND_PDFLATEX ${PDFLATEX_COMPILER})
endif (PDFLATEX_COMPILER)

if (DVIPDF_CONVERTER)
  set (COMMAND_DVIPDF ${DVIPDF_CONVERTER})
endif (DVIPDF_CONVERTER)

if (DVIPS_CONVERTER)
  set (COMMAND_DVIPS ${DVIPS_CONVERTER})
endif (DVIPS_CONVERTER)

if (BIBTEX_COMPILER)
  set (COMMAND_BIBTEX ${BIBTEX_COMPILER})
endif (BIBTEX_COMPILER)

if (MAKEINDEX_COMPILER)
  set (COMMAND_MAKEINDEX ${MAKEINDEX_COMPILER})
endif (MAKEINDEX_COMPILER)

message (STATUS "Commands: " ${COMMAND_LATEX} " ; " ${COMMAND_PDFLATEX} " ; "
	${COMMAND_DVIPDF} " ; " ${COMMAND_DVIPS} " ; " ${COMMAND_BIBTEX} " ; "
	${COMMAND_MAKEINDEX})

include_directories (vapi src)
add_subdirectory (src)
add_subdirectory (data)

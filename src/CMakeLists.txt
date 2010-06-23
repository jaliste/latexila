file (GLOB VALA_SOURCES RELATIVE "${latexila_SOURCE_DIR}/src/" "*.vala")
file (GLOB VAPI "${latexila_SOURCE_DIR}/vapi/*.vapi")

vala_precompile (
	VALA_C
		${VALA_SOURCES}
	PACKAGES
		gtk+-2.0
		gtksourceview-2.0
		#gee-1.0
		unique-1.0
		gdk-x11-2.0
		x11
	CUSTOM_VAPIS
		${latexila_SOURCE_DIR}/vapi/config.vapi
		${latexila_SOURCE_DIR}/vapi/gedit.vapi
)

add_executable (latexila ${VALA_C} gedit-utils.c gedit-utils.h)
install (TARGETS latexila DESTINATION "bin")
install (FILES ui.xml DESTINATION ${DATA_DIR}/ui)


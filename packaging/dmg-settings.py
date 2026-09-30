# dmgbuild settings for the Orbix installer (adapted from ModelNap, MIT). Paths come in with -D
# from Scripts/make-dmg.sh.
import os.path

app = defines["app"]  # noqa: F821 (dmgbuild injects `defines`)
app_name = os.path.basename(app)

format = "UDZO"
filesystem = "HFS+"
size = None

files = [app]
symlinks = {"Aplicaciones": "/Applications"}
icon = defines["icon"]  # noqa: F821

background = defines["background"]  # noqa: F821
show_status_bar = False
show_tab_view = False
show_toolbar = False
show_pathbar = False
show_sidebar = False
default_view = "icon-view"

# 660x440 of content; Finder adds the title bar itself.
window_rect = ((200, 160), (660, 440))
icon_size = 104
text_size = 12
arrange_by = None
label_pos = "bottom"

# Must match the arrow drawn by Tools/dmgbackground/main.swift.
icon_locations = {
    app_name: (170, 200),
    "Aplicaciones": (490, 200),
}

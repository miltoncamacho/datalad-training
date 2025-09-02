# -- Project information -----------------------------------------------------
project = "BIDS + DataLad + PyBIDS Tutorial"
author = "Milton Camacho"
release = "1.0"

# -- General configuration ---------------------------------------------------
extensions = [
    "sphinx.ext.autosectionlabel",  # allows :ref:`Section title` links
    "sphinx.ext.todo",              # .. todo:: support (enable below)
    "sphinx.ext.intersphinx",       # link to external docs (Python)
    "sphinx_copybutton",      # add copy button to code blocks
]

# If you use :ref:`section` across files with identical headings, this helps avoid collisions.
autosectionlabel_prefix_document = True

# Enable rendering of TODOs (set to False for release builds)
todo_include_todos = True

# Intersphinx: so you can link to Python docs like :py:class:`pathlib.Path`
intersphinx_mapping = {
    "python": ("https://docs.python.org/3", None),
}

# Sphinx searches for source files here (relative to conf.py)
# Usually "." is fine when your .rst files live alongside conf.py.
templates_path = ["_templates"]
exclude_patterns = ["_build", "Thumbs.db", ".DS_Store"]

# -- Options for HTML output -------------------------------------------------
try:
    import sphinx_rtd_theme  # type: ignore
    html_theme = "sphinx_rtd_theme"
    html_theme_path = [sphinx_rtd_theme.get_html_theme_path()]  # not strictly required
except Exception:
    html_theme = "alabaster"  # fallback theme included with Sphinx

# If you have static assets (CSS/images) put them in _static/
html_static_path = ["_static"]

# Make code blocks default to bash when you write .. code-block:: bash (kept explicit)
# You can also set a global default language (optional):
# highlight_language = "none"

# Optional: nicer titles for sidebar, etc.
html_title = project
html_show_sourcelink = False

# Optional: consistent section label formatting in links
# (useful if your section titles have punctuation)
# nitpicky = True  # turn on to find broken references during build

# -- RST conveniences --------------------------------------------------------
# You can define common substitutions usable in all .rst files, e.g., |proj|
rst_epilog = """
.. |proj| replace:: BIDS + DataLad + PyBIDS Tutorial
"""



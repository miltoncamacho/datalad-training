==============================
Using DataLad & PyBIDS with BIDS
==============================

.. contents::
   :local:
   :depth: 2

This tutorial is a **gentle, end-to-end guide** that shows you how to:

- install the right tools (**DataLad**, **git-annex**, and Python packages)
- **clone** (download) a BIDS dataset with DataLad
- **retrieve** only the files you need (on demand)
- use **PyBIDS** to run practical queries (subjects, sessions, files, metadata, events)
- optionally interact with **derivatives** (e.g., preprocessed fMRI)

It assumes **very little prior knowledge** of Git, DataLad, or BIDS. You can copy-paste commands as you go.


Prerequisites & Installation
===========================

You’ll need three things:

1) **Git** and **git-annex** (DataLad uses these under the hood)  
2) **DataLad** (command-line tool for versioned data)  
3) **Python** with **PyBIDS** (to query BIDS), plus a few helpers (**pandas**, **numpy**, **nibabel**)

Choose your platform below.

Linux (Debian/Ubuntu)
---------------------

.. code-block:: bash

   sudo apt-get update
   sudo apt-get install -y git git-annex
   # DataLad from apt (OK) or from pip/conda (often newer)
   sudo apt-get install -y datalad

   # Create/activate a clean Python environment (recommended)
   sudo apt-get install -y python3-venv
   python3 -m venv ~/envs/bids
   source ~/envs/bids/bin/activate
   python -m pip install --upgrade pip
   python -m pip install pybids pandas numpy nibabel

Linux (RHEL/CentOS/Fedora)
--------------------------

.. code-block:: bash

   sudo dnf install -y git git-annex
   # Install/upgrade Python venv tools if needed
   python3 -m venv ~/envs/bids
   source ~/envs/bids/bin/activate
   python -m pip install --upgrade pip
   python -m pip install datalad pybids pandas numpy nibabel

macOS (Homebrew + Python venv)
------------------------------

.. code-block:: bash

   # Install Homebrew from https://brew.sh if you don't have it
   brew update
   brew install git git-annex datalad

   python3 -m venv ~/envs/bids
   source ~/envs/bids/bin/activate
   python -m pip install --upgrade pip
   python -m pip install pybids pandas numpy nibabel

Conda (any OS)
--------------

.. code-block:: bash

   conda create -n bids python=3.11 -y
   conda activate bids
   conda install -c conda-forge git git-annex datalad -y
   pip install pybids pandas numpy nibabel

.. tip::

   **Alpine Linux users:** packaging for ``git-annex`` can be tricky. Using **conda** (above) is often the simplest path.

Verify installs
---------------

.. code-block:: bash

   git --version
   git-annex version
   datalad --version
   python -c "import bids, pandas, numpy, nibabel; print('OK')"


Key Concepts (Plain Language)
=============================

- **BIDS** is a standard folder layout and naming scheme for MRI/MEG/EEG datasets.
  Example: ``sub-XXXX/ses-YY/anat/*T1w.nii.gz``, ``func/*_bold.nii.gz``.
  Each image typically has a matching ``.json`` with metadata.

- **DataLad** adds version control for *data*. It builds on **Git** (for small text files)
  and **git-annex** (for large data). With DataLad you can:
  
  - **clone** a dataset quickly (you get metadata and file names first)
  - **get** the actual large files *on demand*
  - **drop** files you don’t need (save space; you can get them again later)

- **PyBIDS** lets Python **understand** BIDS. You can ask questions like:
  
  - “Which subjects do I have?”
  - “List all BOLD files for task ‘rest’.”
  - “Give me the metadata (TR, EchoTime) for this file.”
  - “Where are the events TSVs for each run?”


Create a Workspace
==================

Pick a working directory (anywhere you have space):

.. code-block:: bash

   mkdir -p ~/work/bids-demo
   cd ~/work/bids-demo


Clone a BIDS Dataset with DataLad
=================================

You need a **dataset URL**. This can be an SSH/HTTPS Git URL, a local path, or an open-data URL.  
Replace ``<BIDS_DATASET_URL>`` with your dataset:

.. code-block:: bash

   datalad clone <BIDS_DATASET_URL> bids-ds
   cd bids-ds

What happened?

- You now have the **directory tree and file names**, but many large files are **annexed** (placeholders).
- That means the dataset cloned fast and uses little disk space initially.

Explore structure:

.. code-block:: bash

   datalad status
   # If 'tree' is installed:
   tree -L 3
   # Otherwise:
   find . -maxdepth 3 -type d -print

List subdatasets (e.g., derivatives as nested datasets):

.. code-block:: bash

   datalad subdatasets


Get Only What You Need
======================

To actually download file *content*, use ``datalad get``. You can be selective.

Example 1 — get a single file:

.. code-block:: bash

   datalad get sub-0001/anat/sub-0001_T1w.nii.gz

Example 2 — get all T1w images:

.. code-block:: bash

   datalad get 'sub-*/anat/*T1w.nii.gz'

Example 3 — get BOLD NIfTIs for a task:

.. code-block:: bash

   datalad get 'sub-*/func/*task-rest*_bold.nii.gz'
   datalad get 'sub-*/func/*task-rest*_bold.json'

Check where content lives (advanced, optional):

.. code-block:: bash

   git annex whereis sub-0001/func/sub-0001_task-rest_bold.nii.gz

Free space later (optional):

.. code-block:: bash

   datalad drop 'sub-*/func/*_bold.nii.gz'  # files can be re-fetched any time


(Recommended) Set Up a Python Script for Queries
===============================================

Create a small Python script as you go. In the **dataset root** (``bids-ds``), create ``queries.py``:

.. code-block:: python

   # queries.py

   from bids import BIDSLayout
   import pandas as pd

   # 1) Point to the dataset root. Set validate=True if you have a bids-valid repository.
   # do not fret over this, you can still take advantage of the bids structure even if your bids data is not fully bids.
   layout = BIDSLayout(".", validate=False)  # change to True if validator is available

   # 2) Basic inventory
   subjects = layout.get_subjects()
   sessions = layout.get_sessions()
   tasks = layout.get_tasks()

   print(f"Subjects ({len(subjects)}):", subjects)
   print(f"Sessions ({len(sessions)}):", sessions)
   print(f"Tasks ({len(tasks)}):", tasks)

   # 3) List all BOLD files (functional MRI time series)
   bold_files = layout.get(suffix="bold", extension=[".nii", ".nii.gz"])
   print(f"Found {len(bold_files)} BOLD files")
   for bf in bold_files[:5]:
       print("BOLD:", bf.path)
      
      # bf.path will give you the full absolute path to the file
   
      # 3.5) You can also just get the file name directly
      print("BOLD:", bf.filename)

   # 4) Get BOLD for a specific task (e.g., 'rest')
   rest_bolds = layout.get(suffix="bold", task="rest", extension=[".nii", ".nii.gz"])
   print(f"REST BOLD count: {len(rest_bolds)}")

   # 5) Pick one file and read its metadata (TR, EchoTime, etc.)
   if rest_bolds:
       f = rest_bolds[0]
       meta = layout.get_metadata(f.path)
       print("Example metadata for:", f.path)
       for k in ("RepetitionTime", "EchoTime", "TaskName", "PhaseEncodingDirection"):
           print(f"  {k}: {meta.get(k)}")

   # 6) Find events TSVs (behavioral timings)
   events = layout.get(suffix="events", extension=".tsv")
   print(f"Events files: {len(events)}")
   if events:
       e0 = events[0].path
       print("First events TSV:", e0)
       df = pd.read_csv(e0, sep="\t")
       print("Events columns:", list(df.columns))
       print(df.head())

Run it:

.. code-block:: bash

   # Ensure your Python env is active if you created one earlier
   python queries.py

If you see outputs listing subjects, tasks, BOLD files, and event columns, you’re golden.


Common PyBIDS Queries (Copy-Paste Snippets)
===========================================

Initialize a Layout
-------------------

.. code-block:: python

   from bids import BIDSLayout
   layout = BIDSLayout("path/to/bids-ds", validate=False)  # or True if validator installed

.. tip:: The first run builds an index; subsequent runs are faster.

List Subjects, Sessions, Tasks
------------------------------

.. code-block:: python

   subs = layout.get_subjects()
   sess = layout.get_sessions()       # may be [] if dataset has no sessions
   tasks = layout.get_tasks()

   print(subs)
   print(sess)
   print(tasks)

List BOLD Files (All or Filtered)
---------------------------------

.. code-block:: python

   # all BOLD (NIfTI)
   bold = layout.get(suffix="bold", extension=[".nii", ".nii.gz"])

   # BOLD for a particular subject & task
   bold_ses = layout.get(
       subject="0003",
       task="rest",
       suffix="bold",
       extension=[".nii", ".nii.gz"]
   )

   # Loop and print file paths + entities
   for f in bold_ses:
       print(f.path, f.entities)

Get Metadata for a File
-----------------------

.. code-block:: python

   f = bold[0]
   meta = layout.get_metadata(f.path)
   print(meta.get("RepetitionTime"), meta.get("EchoTime"))

You can also do this:

.. code-block:: python

   f = bold[0]
   RepetitionTime = f.entities.get("RepetitionTime")
   EchoTime = f.entities.get("EchoTime")
   print(RepetitionTime, EchoTime)

Find Events Files and Read Them with pandas
-------------------------------------------

.. code-block:: python

   import pandas as pd

   events = layout.get(suffix="events", extension=".tsv", subject="0003", task="rest")
   for ev in events:
       df = pd.read_csv(ev.path, sep="\t")
       print(ev.path, df.shape, df.columns.tolist())
       # Example: filter a condition called 'trial_type'
       if "trial_type" in df.columns:
           print(df["trial_type"].value_counts())

List Anatomy (e.g., T1w)
------------------------

.. code-block:: python

   t1s = layout.get(suffix="T1w", extension=[".nii", ".nii.gz"])
   print(len(t1s))
   for t in t1s[:5]:
       print(t.path)

Count Runs per Task (Simple Report)
-----------------------------------

.. code-block:: python

   import collections
   counts = collections.Counter()

   bold = layout.get(suffix="bold", extension=[".nii", ".nii.gz"])
   for f in bold:
       task = f.entities.get("task", "NA")
       run = f.entities.get("run", "NA")
       sub = f.entities.get("subject", "NA")
       counts[(sub, task)] += 1

   for (sub, task), n in sorted(counts.items()):
       print(f"sub-{sub}, task-{task}: {n} runs")

Working with Derivatives (Optional)
-----------------------------------

If your dataset includes BIDS **derivatives** (e.g., fMRIPrep output), enable them:

.. code-block:: python

   layout = BIDSLayout("path/to/bids-ds", derivatives=True, validate=False)

   # Example: preprocessed BOLD in MNI space (nifti)
   prebids = layout.get(suffix="bold", space="MNI152NLin2009cAsym",
                        extension=[".nii", ".nii.gz"])
   print(len(prebids))

   # Example: confounds TSVs (fMRIPrep)
   confounds = layout.get(suffix="regressors", extension=".tsv")
   for c in confounds[:5]:
       print(c.path)


Practical Workflow Tips
=======================

1) Don’t “download everything” by default
-----------------------------------------

Use DataLad **selectively**:

.. code-block:: bash

   # Only get JSON sidecars (metadata) for functional runs
   datalad get 'sub-*/func/*_bold.json'

   # Only get events TSVs for “stroop” task
   datalad get 'sub-*/func/*task-stroop*events.tsv'

This is especially helpful for very large datasets.

2) Keep the BIDS dataset read-only
----------------------------------

Treat the dataset as **pristine input**. Do your analysis in a separate directory (e.g., ``analysis/``).  
If you need persistent, reproducible steps, learn ``datalad run`` later—it records the exact command and inputs/outputs.

3) Speed up PyBIDS indexing (optional)
--------------------------------------

- Point PyBIDS to a **temporary cache directory** with enough space.
- Disable validation (``validate=False``) when you trust the dataset.
- Index once; reuse the same layout object in a script.


Minimal “End-to-End” Example
============================

This single script:

1. clones a dataset (if not already present)
2. gets only minimal files (metadata + events)
3. runs basic PyBIDS queries
4. prints a concise report

Save as ``demo.py`` in ``~/work/bids-demo`` (replace the URL):

.. code-block:: python

   import os
   import subprocess
   from pathlib import Path
   from bids import BIDSLayout
   import pandas as pd

   # --- 1) Clone if needed
   url = "<BIDS_DATASET_URL>"
   ds = Path("bids-ds")
   if not ds.exists():
       print("[INFO] Cloning dataset…")
       subprocess.run(["datalad", "clone", url, "bids-ds"], check=True)

   os.chdir(ds)

   # --- 2) Get just what we need (metadata + events)
   subprocess.run(["datalad", "get", "sub-*/func/*_bold.json"], check=False)
   subprocess.run(["datalad", "get", "sub-*/func/*_events.tsv"], check=False)

   # --- 3) PyBIDS queries
   layout = BIDSLayout(".", validate=False)

   subs = layout.get_subjects()
   tasks = layout.get_tasks()
   print(f"Subjects ({len(subs)}): {subs}")
   print(f"Tasks ({len(tasks)}): {tasks}")

   # Count runs per (subject, task)
   from collections import Counter
   counts = Counter()
   for f in layout.get(suffix="bold", extension=[".nii", ".nii.gz"]):
       counts[(f.entities.get("subject"), f.entities.get("task"))] += 1

   print("\nRuns per subject, per task:")
   for (sub, task), n in sorted(counts.items()):
       print(f"  sub-{sub} | task-{task}: {n} runs")

   # --- 4) Show example metadata + first rows of events
   bold = layout.get(suffix="bold", extension=[".nii", ".nii.gz"])
   if bold:
       f = bold[0]
       meta = layout.get_metadata(f.path)
       print("\nExample metadata:")
       for k in ("RepetitionTime", "EchoTime", "TaskName", "SliceTiming"):
           print(f"  {k}: {meta.get(k)}")

   events = layout.get(suffix="events", extension=".tsv")
   if events:
       e0 = events[0].path
       df = pd.read_csv(e0, sep="\t")
       print(f"\nFirst events file: {e0}")
       print(df.head())

Run it:

.. code-block:: bash

   cd ~/work/bids-demo
   # ensure your env is active
   python demo.py


Troubleshooting
===============

“git: command not found” / “git-annex not found”
------------------------------------------------

Install them (see installation section). On Linux you often need ``sudo``.

“datalad: command not found”
----------------------------

Install DataLad via your package manager or pip/conda (see above).

“datalad get … failed”
----------------------

- Check that you’re online and the dataset’s remote is reachable.  
- Try ``git annex whereis <path>`` to see available remotes.  
- If behind a proxy/firewall, configure Git accordingly.

“Permission denied” (on clone or get)
-------------------------------------

- Ensure the URL is public or that you have credentials (for private repos).  
- For SSH URLs, set up your SSH key and agent.

Windows issues
--------------

- Prefer **WSL2** (Ubuntu on Windows) for best compatibility, especially with symlinks used by git-annex.

PyBIDS indexing seems slow
--------------------------

- First run builds an index; later runs are faster.  
- Use ``validate=False`` if you don’t need full validation.  
- Limit queries (e.g., filter by subject/task) to avoid scanning everything.


Next Steps
==========

- Learn ``datalad run`` to **record analysis provenance** (exact commands + inputs/outputs).  
- Explore **BIDS Derivatives** deeply (e.g., confounds, spaces, ``desc`` labels).  
- Add **bids-validator** to catch BIDS issues early:

  .. code-block:: bash

     sudo npm install -g bids-validator   # requires Node.js
     bids-validator .

- Use PyBIDS **BIDS-StatsModels** (advanced) for standardized statistical model specifications.


Quick Reference (Cheat Sheet)
=============================

**DataLad**

- Clone: ``datalad clone <URL> <DIR>``  
- Get content: ``datalad get <path-pattern>``  
- Drop content: ``datalad drop <path-pattern>``  
- Status: ``datalad status``  
- Subdatasets: ``datalad subdatasets``

**PyBIDS**

.. code-block:: python

   from bids import BIDSLayout
   layout = BIDSLayout("bids-ds", validate=False)

   layout.get_subjects()
   layout.get_sessions()
   layout.get_tasks()

   layout.get(suffix="bold", extension=[".nii", ".nii.gz"])
   layout.get(suffix="events", extension=".tsv")
   layout.get_metadata("/full/path/to/file.nii.gz")

You’ve now got a complete workflow: **clone** a BIDS dataset with DataLad, **fetch** only what you need, and **query** it with PyBIDS. From here, you can plug the queried file paths and metadata straight into your analysis pipeline.

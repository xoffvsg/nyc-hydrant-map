#!/usr/bin/env bash
# Reusable per-project environment setup.
# Run this from inside a project folder that already contains requirements.txt
# Usage (in Git Bash): bash setup_env.sh

set -e  # stop on first error, so a failed install doesn't get silently skipped

# --- Conda guard ---------------------------------------------------------
# If a conda environment (base or otherwise) is currently active in this
# shell, its Python/pip will shadow the venv's on PATH even after the venv
# is "activated" below, causing installs to silently land in the conda env
# instead of .venv. Deactivate any active conda env first. This is safe to
# run even if conda isn't installed or nothing is active — it just no-ops.
if [ -n "$CONDA_DEFAULT_ENV" ]; then
    echo "Conda environment '$CONDA_DEFAULT_ENV' is active — deactivating before setup ..."
    # Loop in case of nested activations (base -> env -> env ...)
    while [ -n "$CONDA_DEFAULT_ENV" ]; do
        conda deactivate
    done
fi
# --------------------------------------------------------------------------

if [ ! -f "requirements.txt" ]; then
    echo "No requirements.txt found in this folder. Copy one in first, then re-run."
    exit 1
fi

echo "Creating virtual environment in .venv ..."
python -m venv .venv

echo "Activating .venv ..."
source .venv/Scripts/activate   # Windows layout (Git Bash)

echo "Upgrading pip ..."
python -m pip install --upgrade pip

echo "Installing requirements.txt ..."
pip install -r requirements.txt

echo "Registering this venv as a Jupyter kernel ..."
python -m ipykernel install --user --name="$(basename "$PWD")" --display-name "Python (.venv: $(basename "$PWD"))"

echo ""
echo "Done. In VS Code: Ctrl+Shift+P -> Python: Select Interpreter -> choose .venv in this folder."
echo "In the notebook's kernel picker, choose the kernel named after this folder."

# --- Sanity check ----------------------------------------------------------
# Confirm the venv's own python is what's actually active before finishing,
# so a silent fallback to a conda/base interpreter doesn't go unnoticed.
ACTUAL_PYTHON="$(python -c 'import sys; print(sys.executable)')"
case "$ACTUAL_PYTHON" in
    *".venv"*) echo "Verified: using $ACTUAL_PYTHON" ;;
    *)
        echo "WARNING: active python does not appear to be inside .venv:"
        echo "  $ACTUAL_PYTHON"
        echo "  Something may have shadowed the venv on PATH — check manually."
        ;;
esac

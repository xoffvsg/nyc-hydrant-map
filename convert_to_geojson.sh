#!/usr/bin/env bash
# convert_to_geojson.sh
# ---------------------------------------------------------------------------
# Converts the hydrant density Parquet file into a GeoJSON file.
#
# Note: ogr2ogr is normally the go-to tool for this, but it requires GDAL
# to be built with Arrow/Parquet support. The installed GDAL (3.6.2) does
# not have that driver (confirmed via `ogrinfo --formats`), so this script
# uses Python's geopandas/pyarrow instead, which read GeoParquet natively.
#
# Input:   Data/hydrant_density.parquet
# Output:  Data/hydrant_density.geojson
#
# Prerequisites:
#   - python3 with geopandas and pyarrow installed
#     pip install geopandas pyarrow
#
# Usage:   bash convert_to_geojson.sh
# ---------------------------------------------------------------------------

set -e

INPUT="Data/hydrant_density.parquet"
OUTPUT="Data/hydrant_density.geojson"

# --- Check prerequisites --------------------------------------------------
if ! command -v python &> /dev/null; then
    echo "❌ python is not installed."
    exit 1
fi

if ! python -c "import geopandas" &> /dev/null; then
    echo "❌ geopandas is not installed."
    echo "   Install it: pip install geopandas pyarrow"
    exit 1
fi

# --- Check input file -----------------------------------------------------
if [ ! -f "$INPUT" ]; then
    echo "❌ Input file not found: $INPUT"
    exit 1
fi

echo "📁 Input:  $INPUT"
echo "📦 Output: $OUTPUT"
echo ""

# --- Convert to GeoJSON ----------------------------------------------------
echo "🔄 Converting with geopandas..."

python - "$INPUT" "$OUTPUT" <<'PYEOF'
import sys
import geopandas as gpd

input_path, output_path = sys.argv[1], sys.argv[2]
gdf = gpd.read_parquet(input_path)
gdf.to_file(output_path, driver="GeoJSON")
print(f"   {len(gdf)} features written")
PYEOF

# --- Verify ---------------------------------------------------------------
echo ""
FILE_SIZE=$(wc -c < "$OUTPUT" | tr -d ' ')
echo "✅ Created $OUTPUT ($FILE_SIZE bytes)"

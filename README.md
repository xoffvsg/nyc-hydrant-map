### PMTiles + MapLibre


## Summary
This is the continuation of the nyc-hydrant-analysis project.<br><br>
The **`hydrant_density.parquet`** file is converted to a **`hydrant_density.geojson`** file by the `convert_to_geojson.sh` script. 
The resulting file is then used to generate PMTiles with `tippecanoe` by the `create_pmtiles.sh` script.
The **`neighborhood_density.pmtiles`** file is uploaded to github and the URL to its binary file is delivered to `MapLibre` via `cdn.jsdelivr.net` in **`index.html`**.

## What you get

- **`index.html`.** A complete working web map with Choropleth fill, click popups, legend, mobile-responsive layout, available to the public on https://xoffvsg.github.io/nyc-hydrant-map/
- **No build step.** All dependencies load from CDN. Open `index.html` in a browser, or go to the website, and it works.

<img width="1600" alt="Webpage_landing" src="https://github.com/xoffvsg/nyc-hydrant-map/blob/main/MapScreenshot.JPG">

## The mental model

Three concepts hold the whole library together:

- **Source.** Where the data lives. For PMTiles, it's the URL prefixed with `pmtiles://`.
- **Layer.** How a chunk of the source data is drawn. One source can feed many layers. Layer types: `fill`, `line`, `circle`, `symbol`, `raster`.
- **Style (paint).** The visual properties of a layer. Expressed as expressions like `["step", ["get", "column"], color, break, color, ...]`.


## What I learned

- Using Geopanda to convert a `.parquet` file into a `.geojson` file when the version of `ogr2ogr` in the environment doesn't have the driver for .parquet.
- Adjusting the flags in `tippecanoe` to generate the .pmtiles file meeting the requirements.
- Delivering the pmtiles via a robust CDN supporting HTTP range requests.
- Using `Claude Code` to tweak the features and visual aspect of the map.
- Publish a "dynamic" map from a "static" webpage posted on github.



## License

MIT.

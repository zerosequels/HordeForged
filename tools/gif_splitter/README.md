# GIF Splitter Tool

Use this tool to convert your animated GIFs into individual PNG frames for Xcode.

## Setup (One Time)
1.  Open Terminal.
2.  Navigate to the tool folder: `cd tools/gif_splitter`
3.  Install dependencies: `npm install`

## How to Use
1.  **Drop your GIFs** into the `tools/gif_splitter/input` folder.
    *   *Naming Tip*: Name your GIF exactly what you want the frames to be called.
    *   Example: `survivor_walk_down.gif` $\rightarrow$ `survivor_walk_down_0.png`, `survivor_walk_down_1.png`...
2.  Run the script: `node split.js`
3.  Check the `tools/gif_splitter/output` folder.
4.  **Drag the folder** from "output" directly into your Xcode Asset Catalog to create a Sprite Atlas.

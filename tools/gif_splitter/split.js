const gifFrames = require('gif-frames');
const fs = require('fs-extra');
const path = require('path');

const INPUT_DIR = path.join(__dirname, 'input');
const OUTPUT_DIR = path.join(__dirname, 'output');

// Ensure directories exist
fs.ensureDirSync(INPUT_DIR);
fs.ensureDirSync(OUTPUT_DIR);

async function processGif(filename) {
    const nameWithoutExt = path.basename(filename, '.gif');
    const fileOutputFolder = path.join(OUTPUT_DIR, nameWithoutExt);

    // Create folder for this GIF's frames
    await fs.ensureDir(fileOutputFolder);
    await fs.emptyDir(fileOutputFolder);

    console.log(`Processing: ${filename} -> ${fileOutputFolder}`);

    try {
        const frameData = await gifFrames({ url: path.join(INPUT_DIR, filename), frames: 'all', outputType: 'png', cumulative: false });

        for (let i = 0; i < frameData.length; i++) {
            const frame = frameData[i];
            const stream = frame.getImage();

            // Determine filename based on Grid Logic
            const customName = getCustomName(nameWithoutExt, i);
            const outputFilename = customName ? `${customName}.png` : `${nameWithoutExt}_${i}.png`;
            const outputPath = path.join(fileOutputFolder, outputFilename);

            const writeStream = fs.createWriteStream(outputPath);
            stream.pipe(writeStream);

            await new Promise((resolve) => writeStream.on('finish', resolve));
        }

        console.log(`✅ Extracted ${frameData.length} frames to ${fileOutputFolder}`);

    } catch (err) {
        console.error(`❌ Error processing ${filename}:`, err);
    }
}

async function main() {
    try {
        const files = await fs.readdir(INPUT_DIR);
        const gifs = files.filter(f => f.toLowerCase().endsWith('.gif'));

        if (gifs.length === 0) {
            console.log("⚠️  No GIFs found in 'input' folder.");
            return;
        }

        for (const gif of gifs) {
            await processGif(gif);
        }

        console.log("\n🎉 All done! Check the 'output' folder.");

    } catch (err) {
        console.error("Fatal Error:", err);
    }
}

main();

function getCustomName(baseName, index) {
    // Only apply to Survivor assets
    if (!baseName.toLowerCase().includes('survivor')) return null;

    // Grid Assumptions: 16 Frames (4 columns x 4 rows)
    // Row 0 (0-3): Up
    // Row 1 (4-7): Right
    // Row 2 (8-11): Down
    // Row 3 (12-15): Left

    // 4 Columns per row
    const row = Math.floor(index / 4);
    const col = index % 4;

    let direction = "";
    if (row === 0) direction = "up";
    else if (row === 1) direction = "right";
    else if (row === 2) direction = "down";
    else if (row === 3) direction = "left";
    else return null; // Out of bounds

    // Simply map 0-3 to walk frames
    // Use the actual filename (e.g. survivor_paladin) as the prefix
    return `${baseName}_walk_${direction}_${col}`;
}

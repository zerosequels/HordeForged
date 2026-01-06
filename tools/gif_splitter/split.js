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
        const frameData = await gifFrames({ url: path.join(INPUT_DIR, filename), frames: 'all', outputType: 'png', cumulative: true });

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

    // Grid Assumptions: 20 Frames (5 columns x 4 rows) or similar
    // Row 0 (0-4): Down
    // Row 1 (5-9): Left
    // Row 2 (10-14): Right
    // Row 3 (15-19): Up

    // Column 0: Idle
    // Column 1-4: Walk

    const row = Math.floor(index / 5);
    const col = index % 5;

    let direction = "";
    if (row === 0) direction = "down";
    else if (row === 1) direction = "right"; // Visual check: Row 1 is Side (Right)
    else if (row === 2) direction = "up";    // Visual check: Row 2 is Back (Up)
    else if (row === 3) direction = "left";  // Visual check: Row 3 is Side (Left)
    else return null; // Out of bounds

    if (col === 0) {
        return `survivor_idle_${direction}_0`;
    } else {
        // Walk frames 0, 1, 2, 3
        return `survivor_walk_${direction}_${col - 1}`;
    }
}

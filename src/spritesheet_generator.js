// Huge thanks to @TransparentLC on Github for this script

import fs from "fs";
import path from "path";
import sharp from "sharp";
import { globbyStream } from "globby";
import { MaxRectsPacker } from "maxrects-packer";

// One sheet per scale: <theme>/*.png is 1x, <theme>/scale-NNN/*.png is NNN% (see scale_sprites.py).
const variants = [];
for (const theme of ["dark", "light"]) {
  variants.push({ theme, glob: `${theme}/*.png`, suffix: "" });
  for (const dir of fs.readdirSync(theme).sort()) {
    const match = dir.match(/^scale-(\d+)$/);
    if (match) variants.push({ theme, glob: `${theme}/${dir}/*.png`, suffix: `_${match[1]}` });
  }
}

for (const { theme, glob, suffix } of variants) {
  const packer = new MaxRectsPacker(Infinity, Infinity, 0, {
    pot: false,
    square: false,
  });

  let images = [];

  for await (const path of globbyStream(glob)) {
    images.push(path);
  }

  packer.addArray(
    await Promise.all(
      images.map(async (f) => {
        const p = f;
        const { width, height } = await sharp(p).metadata();
        const imagePath = f;
        return { width, height, imagePath };
      })
    )
  );

  const packedBin = packer.bins[0];

  const packedImage = await sharp({
    create: {
      width: packedBin.width,
      height: packedBin.height,
      channels: 4,
      background: "transparent",
    },
  })
    .composite(
      packedBin.rects.map((e) => ({
        input: e.imagePath,
        left: e.x,
        top: e.y,
      }))
    )
    .png({
      compressionLevel: 9,
      // colors: 70, // pallette mapped mode, would even fit into 60; removing it doesn't seem to fix #100
    })
    .toBuffer();

  fs.writeFileSync(`../sv_ttk/theme/spritesheet_${theme}${suffix}.png`, packedImage);
  fs.writeFileSync(
    `../sv_ttk/theme/sprites_${theme}${suffix}.tcl`,
    `set ::spriteinfo [list \\\n  ${packedBin.rects
      .map(
        (e) =>
          `${path.parse(e.imagePath).name} ${e.x} ${e.y} ${e.width} ${e.height}`
      )
      .join(" \\\n  ")} \\\n]\n`
  );
}

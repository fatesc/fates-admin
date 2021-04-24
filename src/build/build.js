const { readFileSync, writeFileSync } = require("fs");
const { join } = require("path");

const option = process.argv.slice(2)[0]

const file = join(__dirname, "../lua/admin");
const main = ".main.lua"
const out = join(__dirname + "../../output.lua");

console.log("preparing...");
const script = readFileSync(file + main, "utf8");

const reg = /--\[\[\r?\n(.*?)\]\]/gis

const matches = ([...script.matchAll(reg)]);
let output = script
for (const match of matches) {
    const module = match[1].split("-")[1].trim();
    output = output.replace(/--\[\[\r?\n(.*?)\]\]/is, readFileSync(`${file}.${module}.lua`, "utf8"));
    console.log(`added ${module}`);
}
writeFileSync(out, output);
console.log(`script built: ${out}`);
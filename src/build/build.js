const { readFileSync, writeFileSync } = require("fs");
const { join } = require("path");

const option = process.argv.slice(2)[0]

const file = join(__dirname, "../lua/admin");
const main = ".main.lua"
const out = join(__dirname + "../../../main.lua");

console.log("preparing...");
const script = readFileSync(file + main, "utf8");

const reg = /--\[\[\r?\n(.*?)\]\]/gis

const matches = ([...script.matchAll(reg)]);
let output = script
for (const match of matches) {
    const module = match[1].split("-")[1].trim();
    let fileR = readFileSync(`${file}.${module}.lua`, "utf8")
    let writeOut = `--IMPORT [${module}]\n${fileR}\n--END IMPORT [${module}]\n`
    output = output.replace(/--\[\[\r?\n(.*?)\]\]/is, writeOut);

    console.log(`added ${module}`);
}
writeFileSync(out, `--[[\n\n\t${ [
    "Fate's admin",
    "Build Date: "+new Date().toLocaleString('en-gb',{hour12:true}),
    "Authored by: "+ require('child_process').execSync('git config --get user.name').toString()

].join('\n\t') }\n]]\n\n` + output.replace(/-.*\n.*\n.*\]/, "").trim());
console.log(`script built: ${out}`);

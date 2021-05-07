const { readFileSync, writeFileSync } = require("fs");
const { join } = require("path");
const { Minify } = require("./luamin");

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
    let fileR = readFileSync(`${file}.${module}.lua`, "utf8")
    let writeOut = `--IMPORT [${module}]\n${fileR}\n--END IMPORT [${module}]\n`
    output = output.replace(/--\[\[\r?\n(.*?)\]\]/is, writeOut);

    console.log(`added ${module}`);
}
writeFileSync(out, output);
console.log(`script built: ${out}`);

const Min = Minify(output, {RenameVariables:true, RenameGlobals: false, SolveMath: false});
const mainFile = join(__dirname, "../../main.lua");
writeFileSync(mainFile, `--[[\n\tfates admin - ${new Date().getDate()}/${new Date().getMonth() + 1}/${new Date().getFullYear()}\n]]\n\n` + Min.replace(/-.*\n.*\n.*\]/, "").trimStart());
console.log(`minified output build: ${mainFile}`);
import * as readline from "node:readline";
import * as fs from "node:fs";
import * as path from "node:path";

// Raw mode inputs
readline.emitKeypressEvents(process.stdin);
process.stdin.setRawMode(true);

const makeBold = text => `\x1b[4m${text}\x1b[0m`
const fileToLines = filePath => fs.readFileSync()

const search = (query, active, maxResults = 5) =>
    (new Promise((resolve, reject) => {
        const results = [];

        const finishSearch = () => {
                const realActive = Math.min(active, results.length - 1)
                resolve(results, realActive)
            }


        const addResult = (location, contents) => {
            if (results.length >= maxResults) {
                finishSearch()
                return
            }

            console.log(results.length === active ? makeBold(contents) : contents);
            results.push(location);
        };

        const traverse = (dir = ".") => {
            const entries = fs.readdirSync(dir);
            entries
                .filter(entryPath => entryPath.endsWith(".mjs"))
                .forEach(async (entry) => {
                    const entryPath = path.join(dir, entry);
                    const stat = fs.statSync(entryPath);
                    const isDirectory = stat.isDirectory();
                    if (isDirectory) {
                        traverse(entryPath);
                        return
                    }

                    const fileStream = fs.createReadStream(entryPath);

                    const rl = readline.createInterface({
                        input: fileStream,
                        crlfDelay: Infinity
                    });

                    let lineNumber = 1
                    for await (const line of rl) {
                        if (line.includes(query)) {
                            const location = `${entryPath}:${lineNumber++}`
                            addResult(location, `${location}\t${line}`)
                        }
                    }
                });
        };

        setTimeout(() => traverse("."), 1);

        setTimeout(() => {
            finishSearch()
        }, 500)
    }));

const writeInPlace = (text) => process.stdout.write(`\r${text}`);

let query = ""
let active = 0

process.stdin.on("keypress", async (str, {sequence}) => {
    writeInPlace(query);
    switch (sequence) {
        case '\x10': // ctrlp
            active = Math.max(active - 1, 0)
            break;
        case '\x0E': // ctrln
            active = active
            break;
        case '\x7F': // backspace
            query = query.slice(0, -1)
            break;
        case "\r":
            process.exit();
            break;
        default:
            query += str
    }

    const [res, realActive] = await search(query, active);
    active = realActive
});

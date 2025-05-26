const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const { exec } = require('child_process');
const fs = require('fs');
const path = require('path');

const app = express();
const port = 3000;

app.use(cors());
app.use(bodyParser.json());
app.use(express.static(__dirname));

app.post('/compile', (req, res) => {
    const { code } = req.body;
    if (!code) return res.status(400).send('No code provided.');

    const tempInputFile = path.join(__dirname, 'temp_input.txt');
    const compilerExecutable = path.join(__dirname, 'compiler');
    const asmOutputPath = path.join(__dirname, 'output.asm');

    fs.writeFile(tempInputFile, code, (err) => {
        if (err) {
            console.error('Error writing input file:', err);
            return res.status(500).send('Failed to write input file.');
        }

        const command = `${compilerExecutable} ${tempInputFile}`;
        exec(command, (error, stdout, stderr) => {
            fs.unlink(tempInputFile, () => {});

            fs.readFile(asmOutputPath, 'utf8', (readErr, asmCode) => {
                let output = stdout;
                if (stderr) output += `\nSTDERR:\n${stderr}`;

                if (readErr) {
                    output += `\n\nFailed to read 8086 output: ${readErr.message}`;
                } else {
                    output += `\n\n--- 8086 Assembly Output ---\n${asmCode}`;
                }

                res.send(output);
            });
        });
    });
});

app.listen(port, () => {
    console.log(`Server running at http://localhost:${port}`);
});


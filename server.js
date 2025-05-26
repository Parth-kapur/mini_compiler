const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const { exec } = require('child_process');
const fs = require('fs');
const path = require('path');

const app = express();
const port = 3000;

// Middleware
app.use(cors());
app.use(bodyParser.json());

// --- ADDED THIS LINE ---
// This tells Express to serve any static files (like index.html, style.css, script.js)
// from the project's root directory (__dirname).
app.use(express.static(__dirname));
// --------------------

// API endpoint to handle compilation
app.post('/compile', (req, res) => {
    const { code } = req.body;
    if (!code) {
        return res.status(400).send('No code provided.');
    }

    // Define the paths for the temporary input file and the C++ executable
    const tempInputFile = path.join(__dirname, 'temp_input.txt');
    const compilerExecutable = path.join(__dirname, 'compiler'); // Assumes 'compiler' is in the root

    // 1. Save the received code to a temporary file
    fs.writeFile(tempInputFile, code, (err) => {
        if (err) {
            console.error('Error writing temp file:', err);
            return res.status(500).send('Error writing temporary file.');
        }

        // 2. Execute the C++ compiler with the temporary file as an argument
        const command = `${compilerExecutable} ${tempInputFile}`;

        exec(command, (error, stdout, stderr) => {
            // Clean up the temporary file after execution
            fs.unlink(tempInputFile, (unlinkErr) => {
                if (unlinkErr) console.error('Error deleting temp file:', unlinkErr);
            });

            if (error) {
                // This 'error' usually means the process exited with a non-zero code
                console.error(`Execution error: ${error.message}`);
                // Send back both stdout and stderr for debugging
                const output = `Execution Error:\n${error.message}\n\nSTDOUT:\n${stdout}\n\nSTDERR:\n${stderr}`;
                return res.status(500).send(output);
            }
            
            // 3. Send the standard output from the compiler back to the front-end
            // We combine stdout and stderr to show all messages
            const output = stdout + (stderr ? `\nSTDERR:\n${stderr}` : '');
            res.send(output);
        });
    });
});

app.listen(port, () => {
    console.log(`Compiler backend listening at http://localhost:${port}`);
    console.log(`Frontend should be accessible at http://localhost:${port}`); // Added this line for clarity
});


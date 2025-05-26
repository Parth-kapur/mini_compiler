document.getElementById('compileButton').addEventListener('click', () => {
    const inputCode = document.getElementById('inputCode').value;
    const outputCodeElement = document.getElementById('outputCode');
    outputCodeElement.textContent = 'Compiling...';

    fetch('http://localhost:3000/compile', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ code: inputCode }),
    })
    .then(response => response.text().then(text => ({ ok: response.ok, text })))
    .then(({ ok, text }) => {
        outputCodeElement.textContent = text;
    })
    .catch(error => {
        console.error('Fetch error:', error);
        outputCodeElement.textContent = `Error: ${error.message}`;
    });
});


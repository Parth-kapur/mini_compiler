document.getElementById('compileButton').addEventListener('click', () => {
    const inputCode = document.getElementById('inputCode').value;
    const outputCodeElement = document.getElementById('outputCode');

    outputCodeElement.textContent = 'Compiling...';

    // Make a real API call to our Node.js backend
    fetch('http://localhost:3000/compile', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({ code: inputCode }),
    })
    .then(response => {
        // Get the response text, whether the request was successful or not
        return response.text().then(text => ({
            ok: response.ok,
            status: response.status,
            text: text
        }));
    })
    .then(data => {
        // Display the text from the server, which is the compiler's output
        outputCodeElement.textContent = data.text;
    })
    .catch((error) => {
        console.error('Network or Fetch Error:', error);
        outputCodeElement.textContent = `An error occurred while connecting to the server: ${error.message}`;
    });
});

const textInput = document.getElementById('text-input');
const wordCountInput = document.getElementById('word-count');
const wordCountOutput = document.getElementById('word-count-output');
const timeResult = document.getElementById('time-result');
const subtitleTable = document.getElementById('subtitle-table');

function calculateDisplayTime() {
    // Get word count from both input methods
    const textWords = textInput.value.trim().split(/\s+/).filter(word => word.length > 0).length;
    const manualWords = parseInt(wordCountInput.value) || 0;
    
    // Calculate total words
    const totalWords = textWords + manualWords;
    
    // Update word count display
    wordCountOutput.textContent = totalWords;
    
    // Calculate display time ( (words / 160) * 60 )
    const displayTime = (totalWords / 160) * 60;
    
    // Format time display
    const seconds = displayTime.toFixed(2);
    const minutes = Math.floor(displayTime / 60);
    const remainingSeconds = (displayTime % 60).toFixed(2);
    
    timeResult.textContent = `${seconds}s (${minutes}m ${remainingSeconds}s)`;

    // Update the subtitle table
    updateSubtitleTable();
}

function updateSubtitleTable() {
    let tableHTML = '';
    for (let i = 1; i <= 20; i++) {
        const displayTime = ((i / 160) * 60).toFixed(2);
        tableHTML += `
            <tr>
                <td>${i}</td>
                <td>${displayTime}s</td>
            </tr>
        `;
    }
    subtitleTable.innerHTML = tableHTML;
}

// Event listeners for real-time calculation
textInput.addEventListener('input', calculateDisplayTime);
wordCountInput.addEventListener('input', calculateDisplayTime);

// Initial calculation and table generation
calculateDisplayTime();
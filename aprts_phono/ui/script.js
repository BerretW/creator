// Mapa: handle => HTMLAudioElement
const players = {};  // Uchovává aktivní přehrávače

window.addEventListener('message', (event) => {
    const data = event.data;
    if (!data || !data.type) return;

    switch (data.type) {
        case 'init': {
            const handle = data.handle;
            if (players[handle]) {
                return;
            }
            const audio = document.createElement('audio');
            audio.id = 'phonograph_' + handle.toString();
            audio.src = data.url;
            audio.crossOrigin = 'anonymous';
            audio.volume = (data.volume || 50) / 100.0;
            audio.loop = false; // Hudba se NESMÍ opakovat

            // Automatické odstranění po skončení přehrávání
            audio.onended = function () {
                stopAndRemoveAudio(handle);
            };

            document.body.appendChild(audio);
            players[handle] = audio;
            break;
        }
        case 'play': {
            const handle = data.handle;
            const audio = players[handle];
            if (audio) {
                audio.currentTime = 0;
                audio.play().catch(() => {});
            }
            break;
        }
        case 'stop': {
            const handle = data.handle;
            stopAndRemoveAudio(handle);
            break;
        }
        case 'distanceVolume': {
            const handle = data.handle;
            const audio = players[handle];
            if (audio) {
                audio.volume = data.volume;
            }
            break;
        }
    }
});

// ✅ Funkce pro správné zastavení a odstranění zvuku
function stopAndRemoveAudio(handle) {
    if (!players[handle]) return;
    
    const audio = players[handle];
    audio.pause();
    audio.currentTime = 0;
    audio.remove(); // Odstraní audio prvek z DOM
    delete players[handle]; // Odebere přehrávač ze seznamu

    console.log(`Phonograph ${handle} stopped and removed.`);
}

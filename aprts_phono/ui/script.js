// Mapa: handle => HTMLAudioElement
const players = {}

window.addEventListener('message', (event) => {
    const data = event.data
    if (!data || !data.type) return

    switch (data.type) {
        case 'init': {
            const handle = data.handle
            if (players[handle]) {
                return
            }
            const audio = document.createElement('audio')
            audio.id = 'phonograph_' + handle.toString()
            audio.src = data.url
            audio.loop = true
            audio.crossOrigin = 'anonymous'
            audio.volume = (data.volume || 50) / 100.0

            // offset? => audio.currentTime = parseFloat(data.offset || 0)

            document.body.appendChild(audio)
            players[handle] = audio
            break
        }
        case 'play': {
            const handle = data.handle
            const audio = players[handle]
            if (audio) {
                audio.currentTime = 0
                audio.play().catch(() => {})
            }
            break
        }
        case 'stop': {
            const handle = data.handle
            const audio = players[handle]
            if (audio) {
                audio.pause()
                audio.remove()
                delete players[handle]
            }
            break
        }
        case 'distanceVolume': {
            const handle = data.handle
            const audio = players[handle]
            if (audio) {
                audio.volume = data.volume
            }
            break
        }
    }
})

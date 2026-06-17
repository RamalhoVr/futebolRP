window.addEventListener('message', function(event) {
    const data = event.data;
    
    if (data.type === 'showHUD') {
        document.getElementById('hud-container').style.display = data.show ? 'block' : 'none';
    } 
    else if (data.type === 'updateScore') {
        document.getElementById('home-score').innerText = data.home || 0;
        document.getElementById('away-score').innerText = data.away || 0;
        if(data.homeName) document.getElementById('home-team').innerText = data.homeName;
        if(data.awayName) document.getElementById('away-team').innerText = data.awayName;
    } 
    else if (data.type === 'updateTime') {
        document.getElementById('match-time').innerText = data.time || "00:00";
    } 
    else if (data.type === 'updateStamina') {
        // assume stamina from 0 to 100
        const percentage = Math.max(0, Math.min(100, data.stamina));
        document.getElementById('stamina-bar').style.width = percentage + '%';
        
        // muda de cor caso esteja muito baixa
        if(percentage < 20) {
            document.getElementById('stamina-bar').style.background = 'linear-gradient(90deg, #b30000, #ff0000)';
        } else {
            document.getElementById('stamina-bar').style.background = 'linear-gradient(90deg, #00b300, #00ff00)';
        }
    } 
    else if (data.type === 'updatePossession') {
        const circle = document.getElementById('possession-indicator');
        if (data.hasPossession) {
            circle.classList.add('has-possession');
        } else {
            circle.classList.remove('has-possession');
        }
    } 
    else if (data.type === 'showGoal') {
        triggerAnnouncement('GOL!', 3000);
    } 
    else if (data.type === 'showAction') {
        triggerAnnouncement(data.actionText, 2000);
    }
});

let hideTimeout;
function triggerAnnouncement(text, duration) {
    const el = document.getElementById('event-announcement');
    el.innerText = text;
    el.classList.remove('hidden');
    
    if(hideTimeout) clearTimeout(hideTimeout);
    
    hideTimeout = setTimeout(() => {
        el.classList.add('hidden');
    }, duration);
}
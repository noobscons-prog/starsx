console.log("🕵️ Canvas Extractor Loaded. Click Play!");

window.flyEnabled = false;
window.toggleFly = function(state) {
    window.flyEnabled = state;
    console.log("Fly Hack:", state ? "ON" : "OFF");
};

let gameScene = null;

let scanInterval = setInterval(() => {
    if (gameScene) return;

    const canvas = document.getElementById('viewport');
    if (!canvas) return;

    // Babylon.js attaches the engine to the canvas. 
    // We scan the canvas properties to find the engine.
    for (let key in canvas) {
        try {
            const obj = canvas[key];
            // The Babylon Engine object usually has a 'scenes' array
            if (obj && obj.scenes && Array.isArray(obj.scenes) && obj.scenes.length > 0) {
                gameScene = obj.scenes[0];
                console.log("✅ SUCCESS! Found Babylon Scene inside the Canvas!");
                break;
            }
        } catch(e) {}
    }

    if (gameScene) {
        clearInterval(scanInterval);
        
        // Hijack the render loop
        const originalRender = gameScene.render;
        gameScene.render = function() {
            if (window.flyEnabled && gameScene.activeCamera) {
                // Move the camera up smoothly
                gameScene.activeCamera.position.y += 0.5;
            }
            return originalRender.apply(this, arguments);
        };
        
        console.log("🚀 Fly hack is ready! Type window.toggleFly(true) to fly.");
    }
}, 2000);

document.addEventListener('DOMContentLoaded', event => {
    const link = document.getElementById("start");

    if (link != null) {
        link.addEventListener('keydown', (e) => {
            if (e.key === ' ' || e.key === 'Spacebar' || e.keyCode === 32) { // space key
                e.preventDefault();
                link.click();
            }
        })
    }
});
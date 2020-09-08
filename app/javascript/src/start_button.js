$(document).ready(function(){
    const link = document.getElementById("start");

    link.onkeydown = function (e) {
        if (e.keyCode == 32) {
            link.click();
        }
    };
});

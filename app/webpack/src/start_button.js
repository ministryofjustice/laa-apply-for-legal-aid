import { addSpaceEvent } from "./helpers";

document.addEventListener('DOMContentLoaded', event => {
    const startLink = document.getElementById("start");
    const continueLink = document.getElementById("continue");

    // enable link click using space key
    if (startLink != null) { addSpaceEvent(startLink) }
    if (continueLink != null) { addSpaceEvent(continueLink) }
});
export function hide(elem) { elem.style.display = "none" }
export function show(elem) { elem.style.display = "block" }

export function pluralize(val, word, plural = word + 's') {
    const _pluralize = (num, word, plural = word + 's') =>
        [1, -1].includes(Number(num)) ? word : plural;
    if (typeof val === 'object') return (num, word) => _pluralize(num, word, val[word]);
    return _pluralize(val, word, plural);
}
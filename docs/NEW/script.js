// i wanna die
let tooltip = document.querySelector('.tooltip');
let tText = tooltip.querySelector('p');

// at first i was going to make the tooltips triggered when the mouse overlaps an "a" element but it was bad.

document.querySelectorAll('.tooltip-trigger').forEach(trigger => {
    trigger.addEventListener('mouseover', (e) => {
        tText.textContent = trigger.getAttribute('data-tooltip');
        tooltip.style.opacity = 1;
    });

    trigger.addEventListener('mousemove', (e) => {
        let tX = e.pageX + 10;
        let tY = e.pageY + 10;
        
        let tWidth = tooltip.offsetWidth;
        let tHeight = tooltip.offsetHeight;

        if (tX + tWidth > window.innerWidth)
            tX = window.innerWidth - tWidth - 10;

        if (tY + tHeight > window.innerHeight)
            tY = window.innerHeight - tHeight - 10;

        tooltip.style.left = `${tX}px`;
        tooltip.style.top = `${tY}px`;
    });

    trigger.addEventListener('mouseout', () => {
        tooltip.style.opacity = 0;
    });
});
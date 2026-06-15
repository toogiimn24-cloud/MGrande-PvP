window.addEventListener('message', (event) => {
    const data = event.data;
    const container = document.getElementById('widget-container');
    
    switch(data.action) {
        case 'show':
            document.getElementById('admin-name').textContent = data.admin || 'N/A';
            document.getElementById('amount-text').textContent = data.amount;
            document.getElementById('reason-text').textContent = data.reason || 'N/A';
            container.classList.add('show');
            break;
        case 'hide':
            container.classList.remove('show');
            break;
        case 'updateTasks':
            document.getElementById('amount-text').textContent = data.remaining;
            break;
    }
});

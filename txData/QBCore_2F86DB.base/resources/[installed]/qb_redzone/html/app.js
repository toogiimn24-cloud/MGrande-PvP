window.addEventListener('message', function(event) {
    var v = event.data

    switch(v.action) {
        case 'show': 
            $('#mykills').text(v.kills)
            $('#mymoney').text('$'+v.money)
            $('.Container').show(500)
        break;

        case 'hide': 
            $('.Container').hide(500)
        break;
    }
})

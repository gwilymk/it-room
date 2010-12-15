function submitForms() {
  $('#booking-form').submit();
}

$(document).ready(function() {
  $('#error_explanation, #notice-dialog').dialog({
    modal: true,
    width: '50%',

    buttons: {
      "Ok": function() {
        $(this).dialog('close');
      }
    }
  });

  $('.confirm').hide();

  $('#dialog_space').dialog({
    modal: true,
    autoOpen: false
  });

  $('.confirmation_needed').click(function(e) {
    $('#confirm_form').attr('action', this.href);

    $('.confirm').dialog({
      modal: true,
      autoOpen: false,
      buttons: {
        'Yes': function() {
          $('#confirm_form').submit();
        },

        'No': function() {
          $(this).dialog('close');
        }
      }
    });

    $('.confirm').dialog('open');

    return false;
  });

  $('.button').button();

  $('#nop-slider').slider({
    min: 1,
    max: 58,
    animate: "slow",
    value: 10,
    slide: function(event, ui) {
        $('.nop').val($('#nop-slider').slider("value"));
    },
    change: function(event, ui) {
        $('.nop').val($('#nop-slider').slider("value"));
    }
  });

  $('.nop').val($('#nop-slider').slider("value"));

  $('.nop').change(function() {
    if($('#nop-slider').slider('value') != $(this).val()) {
      $('#nop-slider').slider("option", "value", $('.nop').val());
    }
  });

  $('#date-select').datepicker({
    showAnim: "slideDown",
    minDate: 0,
    maxDate: end,
    dayNamesMin: day_names,
    monthNames: month_names,
    dateFormat: 'dd/mm/yy',
    beforeShowDay: function(date) {
      var day = date.getDay(), Sunday = 0, Monday = 1, Tuesday = 2, Wednesday = 3, Thursday = 4, Friday = 5, Saterday = 6;
      var closedDays = [[Saterday], [Sunday]];

      for(var i = 0 ; i < closedDays.length ; i++) {
        if(day == closedDays[i][0]) {
          return [false];
        }
      }

      return [true];
    },
    onSelect: function(dateText, inst) {
    }
  });

  $('#change_password_dialog').dialog({
    modal: true,
    autoOpen: false
  });

  $('#change_password').click(function(e) {
     $('#change_password_dialog').dialog('open');
  });
});


$(function () {

  $('#publish_btn').click(function () {
    $('#publish').fadeIn();
  });

  $('#close_btn').click(function () {
    $('#publish').fadeOut();
  });
  
  $(".fav-button").click(function(e){
    
    let id = $(this).attr("id");
    id = parseInt(id);
    
    let tempThis = $(this);
    
    $.ajax("/favorite/" + id.toString(), {
      type: "POST",
      data: {
        id: id.toString(),
      }
    }).success(function(){
      if (tempThis.attr("class") == "fas fa-heart fav-button favorite"){
        tempThis.attr("class", "far fa-heart fav-button favorite");
      } else if (tempThis.attr("class") == "far fa-heart fav-button favorite"){
        tempThis.attr("class", "fas fa-heart fav-button favorite");
      }
    });
  });

});
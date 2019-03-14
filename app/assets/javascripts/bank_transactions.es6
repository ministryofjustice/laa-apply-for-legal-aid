$(document).ready(function(){
    document.body.addEventListener('ajax:success', function(event) {
      var row = $(event.srcElement).parents("tr");
      row.css("height",row.height()); //we fix the row height to stop it collapsing straight away
      row.children("td").css("display","none"); //we remove the row innards to allow the row to collapse to zero height
      row.slideUp(); //invoke collapse
    })

    document.body.addEventListener('ajax:error', function(event){
      console.log("Remove failed for unknown reason.  Page reloading.") //placeholder for any error message
      location.reload(); //reloads page - because if it has failed, the row might've been removed behind the scenes
    });
});

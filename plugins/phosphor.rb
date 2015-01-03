module Jekyll
  class Phosphor < Liquid::Tag

    def initialize(name, id, tokens)
      super
      @id = id.strip
      @url = "source/assets/phosphor/" + @id + "/*_atlas*.jpg"
	  @images = []

	  for image in Dir.glob(@url)
	  	@images.push(File.basename(image))
	  end

    end
    def render(context)
      %(<script type="text/javascript" src="/javascripts/phosphorframework.js"></script><script>

function pad(n, width, z) {
  z = z || '0';
  n = n + '';
  return n.length >= width ? n : new Array(width - n.length + 1).join(z) + n;
}

  window = {}

  window["player_" + "#{@id.strip}"] = null;
  window["player_" + "#{@id.strip}" + "_path"] = "/assets/phosphor/#{@id}/"; // path to Phosphor files on your server
  window["#{@id}" + "_framecount"] = 0;


  /**
   * After the page has loaded, we register a callback which will be triggered by the jsonp file.
   * Once the callback is registered, we inject the jsonp script file into the page's HEAD block.
   * An alternative method is to use AJAX (getJSON, etc) to load the corresponding json file.  After loading the
   * data, instantiate the player in the same way.
   */

   $(document).ready(function(){
    window["player_" + "#{@id}"] = new PhosphorPlayer('anim_target_#{@id}');
    window["phosphorCallback_" + "#{@id}"] = function(data) {

      /**
       * Instantiate the player.  The player supports a variate of callbacks for deeper integration into your site.
       */

       window["#{@id}" + "_framecount"] = data.frames.length;
       window["player_" + "#{@id}"].load_animation({
        imageArray:#{@images},
        imagePath: window["player_" + "#{@id}" + "_path"],
        animationData: data,
        loop: true,
        onLoad: function() {
          window["player_" + "#{@id}"].play();

          /**
           * If your Phosphor composition was created with the "interactive" mode set, the code below enables that
           * interation.  Handlers are registered for both mouse drag and touch events.
           */

           var trappedMouse = false;
           var trappedXPos;

           var enableInteractivity = false;

           if(enableInteractivity) {
            $("#anim_target_#{@id}").mousedown(function(e){
              e.preventDefault();
              window["player_" + "#{@id}"].stop();
              trappedMouse = true;
              trappedXPos = e.pageX;
              $(document).bind('mousemove',function(event) {
                if(trappedMouse){
                  var pos =  (event.pageX - trappedXPos) / 5;
                  var seekTime = (window["#{@id}" + "_framecount"] + window["player_" + "#{@id}"].currentFrameNumber() + parseInt(pos)) % window["#{@id}" + "_framecount"];
                  window["player_" + "#{@id}"].setCurrentFrameNumber(seekTime);
                  trappedXPos = event.pageX;
                }

              });

            });

            $(document).mouseup(function(e){
              trappedMouse = false;
              $(document).unbind('mousemove');
            });

          

            $("#anim_target_#{@id}").bind("touchstart",function(event){
             var e = event.originalEvent;
             e.preventDefault();
             window["player_" + "#{@id}"].stop();
             trappedMouse = true;
             trappedXPos = e.pageX;
             $(document).bind('touchmove', function(e) {
              if(trappedMouse){
                var e = e.originalEvent;
                e.preventDefault();
                var pos =  (e.pageX - trappedXPos) / 5;
                var seekTime = (window["#{@id}" + "_framecount"] + window["player_" + "#{@id}"].currentFrameNumber() + parseInt(pos)) % window["#{@id}" + "_framecount"];
                window["player_" + "#{@id}"].setCurrentFrameNumber(seekTime);
                trappedXPos = e.pageX;
              }
             });
           });

            $("#anim_target_#{@id}").bind("touchend",function(event){
             var e = event.originalEvent;
             e.preventDefault();
             trappedMouse = false;
             window["player_" + "#{@id}"].play(true);
             $(document).unbind('touchmove');
           });

          }

        }
      });
     };
     var jsonpScript = document.createElement("script");
     jsonpScript.type = "text/javascript";
     jsonpScript.id = "jsonPinclude_" + "#{@id}";
     jsonpScript.src = window["player_" + "#{@id}" + "_path"] + "#{@id}_animationData.jsonp";
     document.getElementsByTagName("head")[0].appendChild(jsonpScript);


});

  /**
   * These functions demonstrate some of the ways you can control the Phosphor player.
   * If you simply wish to play a Phosphor composition on your page, none of these need to be
   * defined.
   */

   function toggleDebug(){
    window["player_" + "#{@id}"].debug(document.getElementById("debugCheckbox").checked);
  };

  function playPhosphor(){
    window["player_" + "#{@id}"].play(true);
  };

  function pausePhosphor(){
    window["player_" + "#{@id}"].stop();
  };

  function jumpForwardPhosphor(){
    window["player_" + "#{@id}"].stop();

    var seekTime = (window["player_" + "#{@id}"].currentFrameNumber() + 1) % window["#{@id}" + "_framecount"];
    window["player_" + "#{@id}"].setCurrentFrameNumber(seekTime);
  };

  function jumpBackwardPhosphor(){
    window["player_" + "#{@id}"].stop();

    var seekTime = (window["#{@id}" + "_framecount"] + window["player_" + "#{@id}"].currentFrameNumber() - 1) % window["#{@id}" + "_framecount"];
    window["player_" + "#{@id}"].setCurrentFrameNumber(seekTime);
  };

  </script><img id="anim_target_#{@id}" src="/assets/phosphor/#{@id}/#{@id}.jpg"/>) 
    end  
  end
end

Liquid::Template.register_tag('phosphor', Jekyll::Phosphor)

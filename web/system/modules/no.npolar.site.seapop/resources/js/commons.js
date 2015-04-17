/**
 * Common javascript funtions, used throughout the site.
 * Dependency: jQuery (must be loaded before this script)
 * Dependency: Highslide (must be loaded before this script)
 */

/*
 * jQuery hover delay plugin. 
 * http://ronency.github.io/hoverDelay/
 * https://github.com/ronency/hoverDelay
 * Function license: MIT.
 * 
 * The MIT License (MIT)
 * 
 * Copyright (c) 2014 ronency
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy of
 * this software and associated documentation files (the "Software"), to deal in
 * the Software without restriction, including without limitation the rights to
 * use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
 * the Software, and to permit persons to whom the Software is furnished to do so,
 * subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
 * FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
 * COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
 * IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
$.fn.hoverDelay = function(options) {
    var defaultOptions = {
        delayIn: 300,
        delayOut: 300,
        handlerIn: function($element){},
        handlerOut: function($element){}
    };
    options = $.extend(defaultOptions, options);
    return this.each(function() {
        var timeoutIn, timeoutOut;
        var $element = $(this);
        $element.hover(
            function() {
                if (timeoutOut){
                    clearTimeout(timeoutOut);
                }
                timeoutIn = setTimeout(function(){options.handlerIn($element);}, options.delayIn);
            },
            function() {
                if (timeoutIn){
                    clearTimeout(timeoutIn);
                }
                timeoutOut = setTimeout(function(){options.handlerOut($element);}, options.delayOut);
            }
        );
    });
};

/**
 * Handle hash (fragment) change.
 */
function highlightReference() {
    setTimeout(
        function() {
            if(document.location.hash) {
                var hash = document.location.hash.substring(1); // Get fragment (without the leading # character)
                try {
                    $(".highlightable").css("background-color", "transparent");
                    $("#" + hash + ".highlightable").css("background-color", "#feff9f");
                    //alert (hash);
                } catch (jsErr) {}
            }
            else {
                //alert("No hash");
            }
        },
        100
    );
}

/**
 * Helper function for browser sniffing.
 * Example result: 'Firefox 31'
 * See http://stackoverflow.com/questions/5916900/how-can-you-detect-the-version-of-a-browser
 */
navigator.sayswho = (function() {
    var N = navigator.appName, ua = navigator.userAgent, tem;
    var M = ua.match(/(opera|chrome|safari|firefox|msie)\/?\s*(\.?\d+(\.\d+)*)/i);
    tem = ua.match(/version\/([\.\d]+)/i);
    if (M && tem !== null) M[2] = tem[1];
    M = M ? [M[1], M[2]] : [N, navigator.appVersion, '-?'];

    return M;
})();

function initToggleables() {
    $('.toggleable.collapsed > .toggletarget').slideUp(1); // Hide normally-closed ("collapsed") accordion content		
    $('.toggleable.collapsed > .toggletrigger').prepend('<em class="icon-down-open-big"></em> '); // Append arrow icon to "show accordion content" triggers
    $('.toggleable.open > .toggletrigger').prepend('<em class="icon-up-open-big"></em> '); // Append arrow icon to "hide accordion content" triggers
    $('.toggleable > .toggletrigger').click(function() {
        $(this).next('.toggletarget').slideToggle(500); // Slide up/down the next toggle target ...
        $(this).children('em').first().toggleClass('icon-up-open-big icon-down-open-big'); // ... and toggle the icon class, so the arrows change corresponding to the slide up/down
    });
}

function showOutlines() {
    try {
        document.getElementById("_outlines").innerHTML = 
                "a:focus, input:focus, button:focus, select:focus { outline:thin dotted; outline:2px solid orange; }";
    } catch (err) {}
}
function hideOutlines() {
    try {
        document.getElementById("_outlines").innerHTML = 
                "a, a:focus, input:focus, select:focus { outline:none !important; } /*a:focus { border:none !important; }*/";
    } catch (err) {}
}

/**
 * Things to do when the document is ready
 */
$(document).ready( function() {
    // Begin responsive tables - http://zurb.com/playground/responsive-tables
    var switched=false;var updateTables=function(){if(($(window).width()<767)&&!switched){switched=true;$("table.responsive").each(function(i,element){splitTable($(element));});return true;}
    else if(switched&&($(window).width()>767)){switched=false;$("table.responsive").each(function(i,element){unsplitTable($(element));});}};$(window).load(updateTables);$(window).bind("resize",updateTables);function splitTable(original)
    {original.wrap("<div class='table-wrapper' />");var copy=original.clone();copy.find("td:not(:first-child), th:not(:first-child)").css("display","none");copy.removeClass("responsive");original.closest(".table-wrapper").append(copy);copy.wrap("<div class='pinned' />");original.wrap("<div class='scrollable' />");}
    function unsplitTable(original){original.closest(".table-wrapper").find(".pinned").remove();original.unwrap();original.unwrap();}
    // End responsive tables

    /*
    // Add style definition for links: No outlines for mouse navigation, dotted outlines for keyboard navigation
    $('head').append('<style id="_outlines" />');
    $('body').attr('onmousedown', 'hideOutlines()');
    $('body').attr('onkeydown', 'showOutlines()');
    */
	
    //
    // qTip: Load it async'ly (vital for IE8, which hangs on load)
    //
    $.ajax({
        url: '/system/modules/no.npolar.common.jquery/resources/jquery.qtip.min.js',
        dataType: 'script',
        cache: true, // otherwise will get fresh copy every page load
        success: function() {
            // qTip script loaded, init tooltips
            $('[data-tooltip]').each(function() { 
                $(this).qtip({ 
                    content: $(this).attr('data-tooltip'), 
                    style: {
                        classes:'qtip-tipsy qtip-shadow'
                    },
                    position: {
                        my:'bottom center',
                        at:'top center',
                        viewport: $(window)
                    }
                }); 
            });
            $('[data-hoverbox]').each(function() {
                var showDelay = $(this).hasClass('featured-link') ? 1000 : 250; // Long delay on "card links" in portal pages, short delay on the rest
                $(this).qtip({
                    content: $(this).attr('data-hoverbox'), 
                    title: $(this).attr('data-hoverbox-title'),
                    style: {
                        classes:'qtip-light qtip-shadow'
                    },
                    position: {
                        my: 'bottom center',
                        at: 'top center',
                        viewport: $(window)
                    },
                    show: {
                        event: 'focus mouseenter',
                        delay: showDelay,
                        effect: function() {
                                $(this).fadeTo(400, 1);
                        }
                    },
                    hide: {
                        event: 'blur mouseleave',
                        fixed: true,
                        delay: 400,
                        effect: function() {
                                $(this).fadeTo(400, 0);
                        }
                    }
                });
            });
        }
    });
    
	
    // Animated verical scrolling to on-page locations
    //$('a[href*=#]:not([href=#])').click(function() { // Apply to all on-page links
    $('.reflink, .scrollto').click(function() {
        if (location.pathname.replace(/^\//,'') === this.pathname.replace(/^\//,'') || location.hostname === this.hostname) {
            var hashStr = this.hash.slice(1);
            var target = $(this.hash);
            target = target.length ? target : $('[name=' + hashStr +']');

            if (target.length) {
                $('html,body').animate({ scrollTop: target.offset().top - 20}, 500);
                window.location.hash = hashStr;
                return false;
            }
        }
    });
	
    // Add facebook-necessary attribute to the html element
    $("html").attr('xmlns:fb', 'http://ogp.me/ns/fb#"');
	
    // Fragment-based highlighting
    //$(".reflink").click(function() { highlightReference(); }); // On click 
    $("a").click(function() { highlightReference(); }); // On click (it's not sufficient to track only .reflink clicks - that will cause any previous highlighting to stick "forever")
    highlightReference(); // On page load
	
    // "Read more"-links
    // Reg. version: a full-width bar button
    $(".cta.more").append('<i class="icon-right-open-big"></i>');
	
    // Initialize toggleable content
    initToggleables();
});


/**
 * Highslide settings.
 */
try {
    //hs.align = 'center';
    //hs.marginBottom = 10;
    //hs.marginTop = 10;
    hs.marginBottom = 50; // Make room for the "Share" widget
    hs.marginTop = 50; // Make room for the thumbstrip
    hs.marginLeft = 50;
    hs.marginRight = 50; 
    //hs.maxHeight = 600;
    //hs.outlineType = 'rounded-white';
    hs.outlineType = 'drop-shadow';
	
    hs.lang = {
        loadingText :     'Laster...',
        loadingTitle :    'Klikk for å avbryte',
        focusTitle :      'Klikk for å flytte fram',
        fullExpandText :  'Full størrelse',
        fullExpandTitle : 'Utvid til full størrelse',
        creditsText :     'Drevet av <i>Highslide JS</i>',
        creditsTitle :    'Gå til hjemmesiden til Highslide JS',
        previousText :    'Forrige',
        previousTitle :   'Forrige (pil venstre)',
        nextText :        'Neste',
        nextTitle :       'Neste (pil høyre)',
        moveText :        'Flytt',
        moveTitle :       'Flytt',
        closeText :       'Lukk',
        closeTitle :      'Lukk (esc)',
        resizeTitle :     'Endre størrelse',
        playText :        'Spill av',
        playTitle :       'Vis bildeserie (mellomrom)',
        pauseText :       'Pause',
        pauseTitle :      'Pause (mellomrom)',
        number :          'Bilde %1 av %2',
        restoreTitle :    'Klikk for å lukke bildet, klikk og dra for å flytte. Bruk piltastene for forrige og neste.'
    };
} catch (err) {
    // Highslide probably undefined
}
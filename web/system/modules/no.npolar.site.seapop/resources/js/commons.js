/**
 * Common javascript funtions, used throughout the site.
 * Dependencies (must/should be loaded before this script):
 *  - jQuery 
 *  - Modernizr (loose dependecy)
 *  
 * Highslide should also be loaded before this script.
 */

//var $, Modernizr, hs, stackBlurCanvasRGBA;

/** Global variable used to detect changes in the viewport width. */
var lastDetectedWidth = $(window).width();

var SPECIES = {
    alca_torda : "Razorbill", // Alke
    alle_alle : "Little auk", // Alkekonge
    cepphus_grylle : "Black guillemot", // Teist
    chroicocephalus_ridibundus : "Black-headed gull", // Hettemåke
    clangula_hyemalis : "Long-tailed duck", // Havelle
    fratercula_arctica : "Atlantic puffin", // Lunde
    fulmarus_glacialis : "Northern fulmar", // Havhest
    gavia_adamsii : "Yellow-billed loon", // Gulnebblom
    gavia_arctica : "Arctic loon", // Storlom
    gavia_immer : "Common loon", // Islom
    gavia_stellata : "Red-throated loon", // Smålom
    larus_argentatus : "Herring gull", // Gråmåke
    larus_canus : "Common gull", // Fiskemåke
    larus_fuscus : "Lesser black-backed gull", // Sildemåke
    larus_hyperboreus : "Glaucous gull", // Polarmåke
    larus_marinus : "Great black-backed gull", // Svartbak
    melanitta_fusca : "Velvet scoter", // Sjøorre
    melanitta_nigra : "Common scoter", // Svartand
    mergus_serrator : "Red-breasted merganser", // Siland
    morus_bassanus : "Northern gannet", // Havsule
    pagophila_eburnea : "Ivory gull", // Ismåke
    phalacrocorax_aristotelis : "European shag", // Toppskarv
    phalacrocorax_carbo : "Great cormorant", // Storskarv
    podiceps_grisegena : "Red-necked grebe", // Gråstrupedykker
    polysticta_stelleri : "Steller's eider", // Stellerand
    rissa_tridactyla : "Black-legged kittiwake", // Krykkje
    somateria_mollissima : "Common eider", // Ærfugl
    somateria_spectabilis : "King eider", // Praktærfugl
    stercorarius_longicaudus : "Long-tailed jaeger", // Fjelljo
    stercorarius_parasiticus : "Parasitic jaeger", // Tyvjo
    stercorarius_skua : "Great skua", // Storjo
    sterna_hirundo : "Common tern", // Makrellterne
    sterna_paradisaea : "Arctic tern", // Rødnebbterne
    uria_aalge : "Common guillemot", // Lomvi
    uria_lomvia : "Brünnich's guillemot", // Polarlomvi
    xema_sabini : "Sabine's gull" // Sabinemåke
};

/**
 * Global variable that holds localized Highslide strings / labels. 
 */
var HS_LABELS = {
    no : {
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
    },
    en : {
        loadingText :     'Loading...',
        loadingTitle :    'Click to cancel',
        focusTitle :      'Click to move forwrard',
        fullExpandText :  'Fullsize',
        fullExpandTitle : 'Expand to full size',
        creditsText :     'Powered by <i>Highslide JS</i>',
        creditsTitle :    'Go to the Highslide JS website',
        previousText :    'Previous',
        previousTitle :   'Previous (left arrow)',
        nextText :        'Next',
        nextTitle :       'Next (right arrow)',
        moveText :        'Move',
        moveTitle :       'Move',
        closeText :       'Close',
        closeTitle :      'Close (esc)',
        resizeTitle :     'Change size',
        playText :        'Play',
        playTitle :       'View slideshow (space)',
        pauseText :       'Pause',
        pauseTitle :      'Pause (space)',
        number :          'Image %1 of %2',
        restoreTitle :    'Click to close, click and drag to move. Use arrow keys for next / previous.'
    }
};

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
    'use strict';
    var defaultOptions = {
        delayIn: 300,
        delayOut: 300,
        handlerIn: function($element){ $element.addClass('intentional-hover'); },
        handlerOut: function($element){ $element.removeClass('intentional-hover'); }
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
    'use strict';
    setTimeout(
        function() {
            if(document.location.hash) {
                var hash = document.location.hash.substring(1); // Get fragment (without the leading # character)
                try {
                    $(".highlightable").css("background-color", "transparent");
                    $("#" + hash + ".highlightable").css("background-color", "#feff9f");
                    //alert (hash);
                } catch (ignore) {}
            }
            //else {
                //alert("No hash");
            //}
        },
        100
    );
}

/*
function highlightReference() {
    'use strict';
	if(document.location.hash) {
		var hash = document.location.hash.substring(1); // Get fragment (without the leading # character)
		try {
			document.getElementsByClassName("highlightable")
			document.getElementById(hash).style.backgroundColor = "#eef6fc";
			//alert (hash);
		} catch (jsErr) {}
	}
}
*/
/*
if ("onhashchange" in window) { // event supported?
    window.onhashchange = function () {
        hashChanged(window.location.hash);
    }
}
else { // event not supported:
    var storedHash = window.location.hash;
    window.setInterval(function () {
        if (window.location.hash != storedHash) {
            storedHash = window.location.hash;
            hashChanged(storedHash);
        }
    }, 100);
}
*/

/**
 * Helper function for browser sniffing.
 * Example result: 'Firefox 31'
 * See http://stackoverflow.com/questions/5916900/how-can-you-detect-the-version-of-a-browser
 */
navigator.sayswho = (function() {
    'use strict';
    var N = navigator.appName, ua = navigator.userAgent, tem;
    var M = ua.match(/(opera|chrome|safari|firefox|msie)\/?\s*(\.?\d+(\.\d+)*)/i);
    tem = ua.match(/version\/([\.\d]+)/i);
    if (M && tem !== null) M[2] = tem[1];
    M = M ? [M[1], M[2]] : [N, navigator.appVersion, '-?'];

    return M;
})();

/**
 * Calculates the width of the browser's scrollbar
 */
/*function getScrollbarWidth() {
    // Create a small div with a large div inside (will trigger scrollbar)
    var div = $("<div style=\"width:50px;height:50px;overflow:hidden;position:absolute;top:-200px;left:-200px;\"><div style=\"height:100px;\"></div></div>");
    // Append our div, do our calculation and then remove it
    $("body").append(div);
    var w1 = $("div", div).innerWidth();
    div.css("overflow-y", "scroll");
    var w2 = $("div", div).innerWidth();
    $(div).remove();
    return (w1 - w2);
}*/

/**
 * Returns true if the browser is IE8 (or an older IE version)
 */
function nonResIE() {
    'use strict';
    if (navigator.sayswho[0].match('MSIE')) { 
        var version = navigator.sayswho[1];
        version = version.substring(0, version.indexOf('.'));
        //console.log('Version is: "' + version + '"');
        if (version.length > 1) {
            return false;
        } 
        if (version < '9') {
            return true;
        }
    }
    return false;
}

/**
 * Checks if an element, identified by the given ID, contains any real content.
 * @param id The ID that identifies the element to check
 * @return True if the element is non-existing or the element doesn't contain any real content, false if not
 */
function emptyOrNonExistingElement(id) {
    'use strict';
    var el = document.getElementById(id); // Get the element
    if (!(el === null || el === undefined)) { // Check for non-exising element first
        var html = el.innerHTML; // Get the content inside the element
        if (html !== null) {
            html = html.replace(/(\r\n|\n|\r)/gm, ''); // Remove any and all linebreaks
            html = html.replace(/^\s+|\s+$/g, ''); // Remove empty spaces at front and end
            if (html === '') {
                return true; // The element didn't contain anything (except maybe whitespace and linebreaks)
            }
            return false; // The element contained something
        }
    }
    return true; // The element didn't exist
}
/*
function getVisibleWidth() {
    return $(window).width() + getScrollbarWidth();
}
*/
/**
 * Gets the small-screen breakpoint. Viewport widths equal to or below the 
 * returned value are considered "small screens".
 * @returns {Number} The small-screen breakpoint
 */
function getSmallScreenBreakpoint() {
    'use strict';
    return 800;
}
/**
 * Evaluates whether or not the current viewport is a "small screen" or not.
 * @returns {Boolean} True if the viewport width is < getSmallScreenBreakpoint()
 */
function isSmallScreen() {
    'use strict';
    return !isBigScreen();
    //return getVisibleWidth() <= getSmallScreenBreakpoint();
}
/**
 * Evaluates whether or not the current viewport is a "big screen" or not. 
 * Browsers without media query support will always get true in return.
 * @returns {Boolean|MediaQueryList.matches} True if the viewport width is >= getSmallScreenBreakpoint(), false if not
 */
function isBigScreen() {
    'use strict';
    var big = true;
    try {
        big = window.matchMedia('(min-width: ' + getSmallScreenBreakpoint() + 'px)').matches; // Update value for browsers supporting matchMedia
    } catch (ignore) {
        // No browser support (= likely IE8 or older) - retain default
    }
    return big;
}
/**
 * Initializes .toggleable accordians.
 */
function initToggleables() {
    'use strict';
    /*
    $('.toggleable.collapsed > .toggletarget').slideUp(1); // Hide normally-closed ("collapsed") accordion content		
    $('.toggleable.collapsed > .toggletrigger').prepend('<em class="icon-down-open-big"></em> '); // Append arrow icon to "show accordion content" triggers
    $('.toggleable.open > .toggletrigger').prepend('<em class="icon-up-open-big"></em> '); // Append arrow icon to "hide accordion content" triggers
    $('.toggleable > .toggletrigger').click(function() {
        $(this).next('.toggletarget').slideToggle(500); // Slide up/down the next toggle target ...
        $(this).children('em').first().toggleClass('icon-up-open-big icon-down-open-big'); // ... and toggle the icon class, so the arrows change corresponding to the slide up/down
    });
    */
    
    if (!Modernizr.csstransitions) {
        $('.toggleable.collapsed > .toggletarget').slideUp(1); // Hide normally-closed ("collapsed") accordion content
    }
    
    var container = $('.toggleable');
    
    var triggerForCollapsed = $('.toggleable.collapsed > .toggletrigger');
    var triggerForOpen = $('.toggleable.open > .toggletrigger');
    var trigger = $('.toggleable > .toggletrigger');
    var target = $('.toggleable > .toggletarget');
    
    triggerForCollapsed.prepend('<em class="icon-down-open-big"></em> '); // Append arrow icon to "show accordion content" triggers
    triggerForOpen.prepend('<em class="icon-up-open-big"></em> '); // Append arrow icon to "hide accordion content" triggers
    triggerForCollapsed.next('.toggletarget').addClass('toggletarget--closed');
    triggerForOpen.next('.toggletarget').addClass('toggletarget--open');
    
    
    // WAI ARIA attributes
    container.attr('aria-multiselectable', 'true');
    container.attr('role', 'tablist');
    trigger.attr('role', 'tab');
    target.attr('role', 'tabpanel');
    
    trigger.attr('aria-selected', 'false');
    triggerForCollapsed.attr('aria-expanded', 'false');
    triggerForOpen.attr('aria-expanded', 'true');
    trigger.focus( function(e) {
        $(this).attr('aria-selected', 'true');
    });
    trigger.blur( function(e) {
        $(this).attr('aria-selected', 'false');
    });
    
    // Click handler
    trigger.click( function(e) {
        e.preventDefault();
        
        // Update URL fragment
        var href = $(this).attr('href');
        try {
            if (href.substring(0,1) === '#') {
                history.replaceState({}, '', href);
            }
        } catch (ignore) {}
        
        var toggleTarget = $(this).next('.toggletarget');
        toggleTarget.toggleClass('toggletarget--open toggletarget--closed');
        $(this).children('em').first().toggleClass('icon-up-open-big icon-down-open-big'); // ... and toggle the icon class, so the arrows change corresponding to the slide up/down
        if (!Modernizr.csstransitions) {
            toggleTarget.slideToggle(500); // Slide up/down the next toggle target ...
        }
        // Track this UI interaction by sending an event to GA
        var triggerDidClose = toggleTarget.hasClass('toggletarget--closed');
        
        if (triggerDidClose) {
            // Update URL fragment
            var href = $(this).attr('href');
            try {
                history.replaceState("", document.title, window.location.pathname + window.location.search);
                //window.location.hash='';
            } catch (ignore) {}
        }
        
        $(this).attr('aria-expanded', triggerDidClose ? 'false' : 'true');
        
        try {
            ga('send', 'event', 'UI interactions', ((triggerDidClose ? 'collapsed' : 'expanded')+' accordion'), window.location.href + $(this).attr('href'), {nonInteraction: false});
        } catch (ignore) {}
    });
    
    // Update collapsed elements based on the URL fragment / hash
    $('.toggletarget--closed:target').prevAll('.toggletrigger').first().trigger('click');
}
/*
function showOutlines() {
    'use strict';
    try { 
        document.getElementById("_outlines").innerHTML="a:focus, input:focus, button:focus, select:focus { outline:thin dotted; outline:2px solid orange; }"; 
    } catch (err) { 
        return false; 
    }
    return true;
}
function hideOutlines() {
    'use strict';
    try { 
        document.getElementById("_outlines").innerHTML="a, a:focus, input:focus, select:focus { outline:none !important; } "; 
    } catch (err) { 
        return false; 
    } 
    return true;
}*/

/**
 * Creates a blurry background for the hero image, based on the hero image itself.
 * @param {String} jsUriStackBlur The URI to the StackBlur javascript.
 * @returns {Boolean} True if no error is thrown, false if not.
 */
function makeBlurryHeroBackground(jsUriStackBlur) {
    'use strict';
    var iPadClient = false; 
    try { iPadClient = navigator.userAgent.match(/iPad/i) !== null; } catch (ignore) {}

    try {
        //console.log('starting blurry hero background ...');
        //$(function() {
            if (isBigScreen() && !iPadClient) {
                if (!nonResIE()) {
                    if (Modernizr.cssfilters) {
                        // CSS approach
                        //console.log('cssfilter support detected ...');
                        $('.article-hero').append( $('.article-hero-content > figure > img').clone() );
                    } else {
                        //console.log('cssfilter support missing, using canvas ...');
                        // Canvas approach
                        $.getScript(jsUriStackBlur, function() {
                            $('.article-hero').append('<canvas class="article-hero-bg" id="hero-bg" width="200" height="200" data-canvas></canvas>');
                            //$('.article-hero').append('<canvas class="article-hero-bg" id="hero-bg" width="200" height="200" data-canvas></canvas><div id="hero-canvas-overlay"></div>');
                            // Change this value to adjust the amount of blur
                            var BLUR_RADIUS = 16;

                            var canvas = document.getElementById('hero-bg');//querySelector('[data-canvas]');
                            var canvasContext = canvas.getContext('2d');

                            var image = new Image();
                            image.src = $('.article-hero-content > figure > img').attr('src');// document.querySelector('[data-canvas-image]').src;

                            var drawBlur = function() {
                                var w = canvas.width;
                                var h = canvas.height;
                                canvasContext.drawImage(image, 0, 0, w, h);
                                stackBlurCanvasRGBA('hero-bg', 0, 0, w, h, BLUR_RADIUS);
                            };

                            image.onload = function() {
                                // draw the blurry image using stackblur
                                drawBlur();
                                // add top-to-bottom gradient, use the same color as
                                // the header
                                var linGrad = canvasContext.createLinearGradient(0, 0, 0, 30);
                                linGrad.addColorStop(0, 'rgba(14,19,31,1)');
                                linGrad.addColorStop(1, 'rgba(14,19,31,0)');
                                canvasContext.fillStyle = linGrad;
                                canvasContext.fillRect(0, 0, canvasContext.canvas.width, canvasContext.canvas.height);
                            };
                        });
                        //console.log('done with blurry hero background ...');
                    }
                } else { // css blur filter (ms-filter)
                    $('.article-hero').append( $('.article-hero-content > figure > img').clone() );
                }
            }
        //});
    } catch (err) {
        //console.log('error creating blurry hero background: ' + err);
        return false;
    }
    return true;
}

/**
 * Makes tables responsive.
 * @see http://zurb.com/playground/projects/responsive-tables
 * @returns {Boolean} True if no error is thrown, false if not.
 */
function makeResponsiveTables() {
    'use strict';
    
    function splitTable(original) {
        original.wrap("<div class='table-wrapper' />");
        var copy = original.clone();
        copy.find("td:not(:first-child), th:not(:first-child)").css("display","none");
        copy.removeClass("responsive");
        original.closest(".table-wrapper").append(copy);
        copy.wrap("<div class='pinned' />");
        original.wrap("<div class='scrollable' />");
    }
    
    function unsplitTable(original) {
        original.closest(".table-wrapper").find(".pinned").remove();
        original.unwrap();
        original.unwrap();
    }
    
    try {
	var switched=false;
        var updateTables = function() {
            if(($(window).width()<767) && !switched) {
                switched=true;
                $("table.responsive").each(function(i,element) {
                    splitTable($(element));
                });
                return true;
            } 
            if (switched && ($(window).width()>767)) {
                switched=false;
                $("table.responsive").each(function(i,element) {
                    unsplitTable($(element));
                });
            }
        };
        $(window).load(updateTables);
        $(window).bind("resize", updateTables);
    } catch (err) {
        return false;
    }
    return true;
}

/**
 * Makes tabbed content.
 * @returns {Boolean} True if no error is thrown, false if not.
 */
function makeTabs() {
    'use strict';
    try {
        // Set the default active tab (make it the first one)
        var firstTab = $('.tabbed .tab').first();
        var hash = window.location.hash.substring(1);
        if (!(hash === 'refs' || hash === 'links')) {
            firstTab.addClass('active-tab');
        }
        // set the height
        var height = firstTab.outerHeight();
        
        // Process each tabbed section
        $('.tabbed').each(function(e) {
            // calculate a more correct top offset for the tab content boxes
            var tabContentTopOffset =   $(this).children('.tabbed-heading').first().outerHeight() +              $(this).find('.tab-link').first().outerHeight();
            //console.log('heading: ' +   $(this).children('.tabbed-heading').first().outerHeight() + ', tab: ' +  $(this).find('.tab-link').first().outerHeight());
            
            // iterate all the tab content boxes
            $(this).find('.tab-content').each(function(e) {
                // find the tallest one
                var thisTabHeight = $(this).children().first().outerHeight();
                //console.log('tab content height is ' + thisTabHeight + '. new max? ' + (thisTabHeight > height));
                if (thisTabHeight > height) {
                    height = thisTabHeight;
                }
                
                // set the top offset (some browsers, e.g. chrome, need a little less than others, e.g. firefox)
                $(this).css({ top : (tabContentTopOffset-2)+'px' });
            });
            
            // set the height equal to the tallest one's height, plus a little extra (wrapper's padding etc.)
            $(this).css({ height : (height+125)+'px' });
        });
        
	$('.tabbed .tab .tab-link').click(function(e) {
            e.preventDefault();
            $('.tabbed .tab').removeClass('active-tab');
            $(this).parent('.tab').addClass('active-tab');
            
            /*var clone = $(this).next('.tab-content').clone();
            clone.attr('style', 'display:block; position:relative; left:-9999px; top:-9999px;');
            var tabContentHeight = clone.height();
            clone.remove();*/
            
            /*var tabContentHeight = $(this).next('.tab-content').children().first().height();
            console.log('setting tabbed height to ' + (tabContentHeight+90) + 'px');
            $(this).parents('.tabbed').first().attr('style', 'height:'+ (tabContentHeight+90) + 'px');*/
	});
    } catch (err) {
        return false;
    }
    return true;
}
/**
 * Makes tooltips on elements with data-tooltip or data-hoverbox attributes.
 * @param {String} cssUri The URI to the qTip css.
 * @param {String} jsUri The URI to the qTip javascript.
 * @returns {Boolean} True if no error is thrown, false if not.
 */
function makeTooltips(cssUri, jsUri) {
    'use strict';
    try {
        if ($('[data-tooltip]')[0] || $('[data-hoverbox]')[0]) {
            $('head').append('<link rel="stylesheet" href="' + cssUri + '" type="text/css" />');
            $.getScript(jsUri, function() {
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
            });
        }
    } catch (err) {
        return false;
    }
    return true;
}
/**
 * Makes an animated scroll-to effect for on-page links.
 * @returns {Boolean} True if no error is thrown, false if not.
 */
function makeScrollToSmooth() {
    'use strict';
    try {
        //$('a[href*=#]:not([href=#])').click(function() { // Apply to all on-page links
        $('.reflink,.scrollto').click(function() {
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
    } catch (err) {
        return false;
    }
    return true;
}

/**
 * Makes ready Highslide, by injecting the necessary css/js in the HTML head.
 * @param {String} cssUri The URI to the Highslide css.
 * @param {String} jsUri The URI to the Highslide javascript.
 * @param {String} lang The desired language.
 * @returns {Boolean} True if no error is thrown, false if not.
 */
function readyHighslide(cssUri, jsUri, lang) {
    'use strict';
    try {
        if ($(".highslide")[0]) {
            $('head').append('<link rel="stylesheet" type="text/css" href="' + cssUri + '" />');
            $.getScript(jsUri, function() {
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
                hs.lang = getHighslideLabels(lang);
            });
        }
    } catch (err) {
        return false;
    }
    return true;
}

/**
 * Define "keyboard optimized" styles in the style element with 
 * ID "__adaptive-styles".
 */
function keyFriendly() {
    'use strict';
    try { 
        document.getElementById("__adaptive-styles").innerHTML = "a:focus, input:focus, button:focus, select:focus { outline:thick solid #f44; outline-offset:4px; }";
                                                                //"a:focus, input:focus, button:focus, select:focus { outline:thin dotted; outline:3px solid #1f98f6; }"
    } catch (ignore) {}
}

/**
 * Define "mouse/touch optimized" styles in the style element with 
 * ID "__adaptive-styles".
 */
function mouseFriendly() {
    'use strict';
    try { 
        document.getElementById("__adaptive-styles").innerHTML = "a, a:focus, input:focus, select:focus { outline:none !important; }";
    } catch (ignore) {}
}

/**
 * Indicates whether or not the small screen global menu is currently visible.
 * @returns {Boolean} True if the small screen menu is visible, false if not.
 */
function smallScreenMenuIsVisible() {
    'use strict';
    return $('html').hasClass('navigating');
}

/**
 * Updates elements like the global search, global menu etc. to fit the current
 * viewport width.
 */
function layItOut() {
    'use strict';
    var menu = $('#nav');
    
    if (isBigScreen()) {
        // Remove class used only on the small-screen menu
        //menu.removeClass('nav-colorscheme-dark');
    } else {
        // Small-screen menu class
        //menu.addClass('nav-colorscheme-dark');
    }
}
/**
 * Opens or closes the small-screen menu.
 * 
 * This method will also manipulate the "tabindex" attribute of all links in
 * the menu, to prevent or enable the menu items from being keyboard (tab) 
 * accessible. (Prevents tabbing users from entering a closed menu.)
 */
function toggleMenuVisibility() {
    'use strict';
    var menu = $('#nav');
    var html = $('html');
    
    if (smallScreenMenuIsVisible()) { // = menu was already open at click time
        // About to open the menu: make its links NOT tab accessible
        menu.find('a').attr('tabindex', '-1');
    } else {
        // About to open the menu: make its links tab accessible
        menu.find('a').removeAttr('tabindex');
    }
    
    // Toggle the class that triggers the actual opening/closing of the 
    // menu.
    html.toggleClass('navigating');
}
/**
 * Initializes the user controls - menu/search (incl. togglers), outline style 
 * optimization, language switch, etc.
 */
function initUserControls() {
    'use strict';
    var menu = $('#nav');
    var html = $('html');
    
    // inject sub-navigation togglers (shows/hides children of a parent menu item)
    menu.find('li.has_sub').not('.inpath').addClass('hidden-sub');
    menu.find('li.has_sub.inpath').addClass('visible-sub');
    menu.find('li.has_sub > a').after('<a class="visible-sub-toggle" href="#"></a>');
    
    // handle click on sub-navigation toggler
    $('.visible-sub-toggle').click(function(e) {
        e.preventDefault();
        $(this).parent('li').toggleClass('visible-sub hidden-sub');
    });

    // handle click on menu toggler
    $('.nav-toggler').click(function(e) {
        e.preventDefault();
        toggleMenuVisibility();
    });

    // handle click somewhere on the page content when small-screen menu was open
    html.click(function(event) { 
        if (smallScreenMenuIsVisible()) {
            if (!($(event.target).closest('#nav').length || $(event.target).closest('#header').length)) {
                toggleMenuVisibility();
            }
        }
    });
    
    // handle focus transition "out from the bottom" of the open small-screen menu
    $('body *').focus(function(event) {
        if (smallScreenMenuIsVisible()) {
            if (!($(event.target).closest('#nav').length || $(event.target).closest('#header').length)) {
                toggleMenuVisibility();
            }
        }
    });

    // bugfix - the #wrap div is sometimes able to receive focus (even tho it has no tabindex)
    $('#wrap').attr('tabindex', '-1');
	
    // toggle "focus" class on menu items when appropriate
    menu.find('a').focus(function() {
        $(this).parents('li').addClass('infocus');
    });
    menu.find('a').blur(function() {
        $(this).parents('li').removeClass('infocus');
    });
    
    // hover delay handling for mouse users (usability bonus)
    if (!Modernizr.touch) {
        menu.find('li').hoverDelay({
            delayIn: 250,
            delayOut: 400,
            handlerIn: function($element)   { $element.addClass('infocus'); },
            handlerOut: function($element)  { $element.removeClass('infocus'); }
        });
        /*
        // use hoverintent to add usability bonus for mouse users
        $('#nav li').hoverIntent({
            over: mouseinMenuItem
            ,out: mouseoutMenuItem
            ,timeout:400
            ,interval:250
        });
        */
    } else {
        // Touch units will typically emulate these mouse events
        menu.find('li').mouseover(function()   { $(this).addClass('infocus'); });
        menu.find('li').mouseout(function()    { $(this).removeClass('infocus'); });
    }
    
    // inject "adaptive styles" (accessibility bonus)
    $('head').append('<style id="__adaptive-styles" />');
    $('body').bind('mousedown', function(e) {
        html.removeClass('tabbing');
        mouseFriendly();
    });
    $('body').bind('keydown', function(e) {
        html.addClass('tabbing');
        if (e.keyCode === 9) {
            keyFriendly();
        }
    });
    
    // handle click on search box toggler
    $('#toggle-search').click(function(e) {
        e.preventDefault();
        html.toggleClass('search-open');
        if (!html.hasClass('tabbing')) { // Don't auto-shift focus if the user is tabbing
            $('#query').focus();
        }
    });
    
    
    // Clone the language switch and put it in the menu
    if (!$('.language-switch-menu-item')[0]) { // do it only if necessary
        var clonedLangSwitch = $('.language-switch').clone().attr('class', 'language-switch-menu-item').attr('style', '');
        var liLangSwitch = $('<li/>').attr('style', 'border-top:1px solid orange').attr('class', 'smallscr-only').appendTo($('#nav_topmenu'));
        liLangSwitch.append(clonedLangSwitch.prepend('<i class="icon-cog" style="font-size:1.2em;"></i> '));
    }
    $('.language-switch').addClass('bigscr-only');
    
    // Make sure all links in the small-screen menu are initially NOT keyboard-accessible
    // (because the small-screen menu is initially hidden)
    if (!isBigScreen()) {
        menu.find('a').attr('tabindex', '-1');
    }
}

function toCommonName(scientificName) {
    'use strict';
    var cn = SPECIES[scientificName.toLowerCase().replace(/ /g,"_")];
    
    if (typeof cn === 'undefined' || cn.length <= 0) {
        return scientificName;
    }
    
    return cn;
}

function autoSpecies() {
    'use strict';
    var autoSpecies = $('.auto-species');
    if (autoSpecies[0]) {
        autoSpecies.each(function() {
            getSpeciesByColony($(this));
        });
    }
}

function getSpeciesByColony(/*jQuery*/container) {
    'use strict';
    var colony = container.attr('data-location');
    var apiUrl = 'https://api.npolar.no/tracking/seabird?filter-geometry.type=Point&size-facet=99&limit=0&facets=species&filter-colony=' + colony;
    var items = [];
    $.getJSON(apiUrl, function(data) {
        
        //var commonName = data.feed.entries[0].properties.object;
        
        //console.log("Common name: " + commonName);
        
        // Weak point: 'species' is currently always the first facet set when 
        // the URL uses "facets=species" - but that might change...
        $.each(data.feed.facets[0].species, function(key, val) {
            var mapUri = 'https://data.npolar.no/tracking/seabird?technology=gls&species=' + this.term + '&colony=' + colony;
            items.push('<li><a href="' + mapUri + '" target="_blank"><em>' + toCommonName(this.term) + ' (' + this.term + ')</em></a></li>');
        });
    }).done(function() {
        container.html('');
        //console.log('items.length is ' + items.length);
        if (items.length === 0) {
            items.push('<li><em>No species data for ' + colony + ' available yet</em></li>');
        }
        $('<ul/>', {
        "class": "auto-species-list",
        html: items.join("")
        }).appendTo(container);
    }).fail(function() {
        container.html('<em>Loading species list failed!</em>');
    });
}

function autoColonies() {
    'use strict';
    var autoColonies = $('.auto-colonies');
    if (autoColonies[0]) {
        autoColonies.each(function() {
            getColoniesBySpecies($(this));
        });
    }
}

function getColoniesBySpecies(/*jQuery*/container) {
    'use strict';
    var species = container.attr('data-species');
    //var apiUrl = 'https://api.npolar.no/tracking/seabird?filter-geometry.type=Point&size-facet=99&limit=1&facets=species&filter-colony=' + colony;
    var apiUrl = 'https://api.npolar.no/tracking/seabird?filter-geometry.type=Point&size-facet=99&limit=0&facets=colony&filter-species=' + species;
    //console.log('querying ' + apiUrl);
    var items = [];
    $.getJSON(apiUrl, function(data) {
        // Weak point: 'colony' is currently always the first facet set when 
        // the URL uses "facets=colony" - but that might change...
        $.each(data.feed.facets[0].colony, function(key, val) {
            var mapUri = 'https://data.npolar.no/tracking/seabird?technology=gls&colony=' + this.term + '&species=' + species;
            items.push('<li><a href="' + mapUri + '" target="_blank"><em>' + this.term + '</em></a></li>');
        });
    }).done(function() {
        container.html('');
        //console.log('items.length is ' + items.length);
        if (items.length === 0) {
            items.push('<li><em>No colony data for ' + toCommonName(species) + ' (' + species + ') available yet</em></li>');
        }
        $('<ul/>', {
        "class": "auto-colony-list",
        html: items.join("")
        }).appendTo(container);
    }).fail(function() {
        container.html('<em>Loading colony list failed!</em>');
    });
}

/**
 * Things to do when the document is ready
 */
$(document).ready( function() {
    'use strict';
    // responsive tables
    makeResponsiveTables();
    
    // tabbed content (enhancement - works with pure css but not optimal)
    //makeTabs();

    // qTip tooltips
    //makeTooltips();

    // Animated verical scrolling to on-page locations
    makeScrollToSmooth();
	
    // Add facebook-necessary attribute to the html element
    $("html").attr('xmlns:fb', 'http://ogp.me/ns/fb#"');
	
    // Fragment-based highlighting
    //$(".reflink").click(function() { highlightReference(); }); // On click 
    $("a").click(function() { highlightReference(); }); // On click (it's not sufficient to track only .reflink clicks - that will cause any previous highlighting to stick "forever")
    highlightReference(); // On page load
	
    // "Read more"-links
    $(".cta.more").append('<i class="icon-right-open-big"></i>');
	
    // Initialize accordions of type "toggleable"
    initToggleables();
    
    // Setup the user controls (global menu, global search etc.)
    initUserControls();
    
    // Invoke the layout handler
    layItOut();
    
    autoSpecies();
    autoColonies();
    
    enableModalDialog();

    // Invoke the layout handler again whenever the viewport width changes
    $(window).resize(function() {
        if ($(this).width() !== lastDetectedWidth) { // True => width changed during resize
            lastDetectedWidth = $(this).width();
            layItOut();
        }
    });
    
    // Try to responsify images that use heatmaps
    try {
        $("img[usemap]").rwdImageMaps();
    } catch (ignore) {}
});

/**
 * Enables the modal dialog.
 * 
 * @returns {undefined}
 */
function enableModalDialog() {
    var dialogId = 'overlay-dialog';
    // Add full-screen overlay container (initially hidden, see rules in base.css)
    $('body').append('<div class="overlay overlay--full-screen fadein">'
                        + '<div class="overlay-dialog fadein" id="'+dialogId+'">'
                            + '<p>Loading...</p>'
                        + '</div>'
                    + '</div>');
    $(document).click(function(event) {
	if ($(event.target).closest('.overlay--full-screen').length) {
            // => full-screen overlay was active when the click occured
            if ( !$(event.target).closest('#'+dialogId).length && !$(event.target).is('#'+dialogId)) {
                // click occured outside the dialog
                // => deactivate the overlay
                $('html').removeClass('overlay-open');   
            }
        }
    });
}

/**
 * Opens a modal overlay dialog.
 * 
 * @param {type} heading
 * @param {type} content
 * @returns {undefined}
 */
function showModal(/*String*/heading, /*String*/content) {
    $('#overlay-dialog').html('<h2 class="overlay-dialog_heading">' + heading + '</h2>' 
        + '<div class="overlay-dialog_content running-text">' + content + '</div>'
        + '<button class="overlay-dialog__close"><span class=\"hidden\">Close</span></button>');
    
    // adding this class makes the dialog appear
    $('html').addClass('overlay-open');
    
    // ToDo: Add routine that ensures tabbing is limited to the dialog only
    
    // Bind closers (X button and ESC key)
    $('.overlay-dialog__close').click(function() {
        hideModal();
    });
    $(document).keyup(function(e) {
        if (e.keyCode === 27) { // escape key
            hideModal();
        }
    });
}
/**
 * Hides a modal dialog.
 * 
 * @returns {undefined}
 */
function hideModal() {
    // removing this class makes the dialog disappear
    $('html').removeClass('overlay-open');
}

/**
 * Displays a location description in a modal container.
 * 
 * The location description must be on the same page and is identified by the
 * given location ID.
 * 
 * @param {type} locationId The ID attribute value (leading "#" is optional)
 * @returns {undefined}
 */
function showLocationModal(/*String*/locationId) {
    // Goal: Open location details (fetched from the same page) in an overlay 
    // when the user clicks a location on the SEATRACK locations map.
    if (locationId === 'undefined') {
        console.log("Attempted to show a location modal, but location ID was undefined.");
        return null;
    }
    if (locationId.substring(0,1) === '#') {
        locationId = locationId.substring(1);
    }
    // get jQuery objects for location heading and content (from elements on the current page)
    var locationContent = $('#' + locationId); // => e.g. $('#' + 'Alkefjellet')
    var locationHeading = locationContent.parent().find('.toggletrigger h2');
    
    // Show the location in a modal
    showModal(locationHeading.text(), locationContent.html());
}

/**
 * Creates and sets up SEATRACK's locations map, if necessary.
 * 
 * The interactive map requires a block element with ID "map--locations".
 * 
 * @returns {undefined}
 */
function setupMapForSEATRACK() {
    
    // OLD VERSION (map as .png image with link map)
    // When the user clicks on a linked area in the locations map, show that
    // location's details - fetched from the same page - in an overlay dialog
    if ($("#locations-linkmap area").length) {
        $("#locations-linkmap area").click(function(event) {
            event.preventDefault();
            showLocationModal($(event.target).attr('href'));
        });
    }
    
    // NEW VERSION
    // Interactive map
    var cartoMapId = 'map--locations';
    if ($('#'+cartoMapId).length) {
        $('head').append('<link rel="stylesheet" type="text/css" href="http://libs.cartocdn.com/cartodb.js/v3/3.15/themes/css/cartodb.css" />');
        $.getScript('http://libs.cartocdn.com/cartodb.js/v3/3.15/cartodb.js', function() {
            
            // Create map with initial view
            var map = new L.Map(cartoMapId, {
                center: [57, 4],
                zoom: 4,
                scrollWheelZoom: false
            });

            map.attributionControl.setPrefix('SEATRACK');

            // Add basemap
            L.tileLayer('http://geodata.npolar.no/arcgis/rest/services/Basisdata_Intern/NP_Verden_WMTS_53032/MapServer/tile/{z}/{y}/{x}').addTo(map);

            // Add the locations
            cartodb.createLayer(map, {
                user_name: 'seatrack',
                type: 'cartodb',
                sublayers: [{
                    sql: 'SELECT cartodb_id, ST_Transform(the_geom, 53032) AS the_geom_webmercator, colony, international_name FROM colonies',
                    cartocss: '#colony{ marker-fill-opacity: 1;marker-line-color: #000000;marker-line-width: 1.5;marker-line-opacity: 1;marker-placement: point;marker-type: ellipse;marker-width: 10;marker-fill: #F11810;marker-allow-overlap: true; }',
                    interactivity: "cartodb_id,colony,international_name"
                }]
            }).addTo(map).on('done', function(layer) {
                
                layer.setInteraction(true);

                layer.on('featureClick', function(evt, latlng, pos, data, layer) {
                    try { ga('send', 'event', 'Map interactions', 'clicked SEATRACK location', data.colony); } catch(ignore) {}
                    console.log('Map click on location [' + data.cartodb_id + ' ' + data.colony + ']');
                    var descrId = data.international_name.toLowerCase().replace(' and ', '-').replace(/ /g, '-');
                    descrId = descrId.replace('&', '-');
                    console.log('Opening modal, passing ID [' + descrId + '] - based on [' + data.cartodb_id + ' ' + data.international_name + ']');
                    showLocationModal(descrId);
                });
                
                layer.on('featureOver', function(e, latlng, pos, data, subLayerIndex) {
                    console.log("mouse over " + data.colony);
                    map.getContainer().style.cursor = 'pointer';
                    /*
                    //var tooltip = layer.getSubLayer(subLayerIndex).leafletMap.viz.addOverlay({
                    var tooltip = layer.leafletMap.viz.addOverlay({
                    //layer.getSubLayer(0).addOverlay({
                        layer: layer.getSubLayer(subLayerIndex),
                        type: 'tooltip',
                        template: '<p>Testing</p>',
                        //template: '<p>{{data.colony}}</p>',
                        width: 200,
                        position: top
                    });
                    $('body').append(tooltip.render().el);
                    //*/
                });
                
                // Change cursor to indicate interactivity
                layer.on('mouseover', function() {
                    map.getContainer().style.cursor = 'pointer';
                });

                layer.on('mouseout', function() {
                    map.getContainer().style.cursor = 'auto';
                });

            });
            
            
            // Toggle scroll wheel zooming, require clicked map
            map.on('click', function() {
                if (map.scrollWheelZoom.enabled()) {
                    map.scrollWheelZoom.disable();
                } else {
                    map.scrollWheelZoom.enable();
                }
            });
        });
    }
}


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

/**
 * Gets Highslide labels localized according to the given language.
 * 
 * @param {type} lang The desired language, e.g. 'en' or 'no'.
 * @returns {Object} Highslide labels localized according to the given language or, if that language isn't configured, in the default language.
 * @see HC_LABELS
 */
function getHighslideLabels(/*String*/lang) {
    'use strict';
    if (!(lang === 'en' || lang === 'no')) {
        // Non-supported language, fallback to default
        lang = 'en';
    }
    return HS_LABELS[lang];
}
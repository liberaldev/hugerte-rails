window.HugeRTERails = {
  configuration: {
    default: {}
  },

  initialize: function(config, options) {
    if (typeof hugeRTE != 'undefined') {
      // Merge the custom options with the given configuration
      var configuration = HugeRTERails.configuration[config || 'default'];
      configuration = HugeRTERails._merge(configuration, options);

      hugeRTE.init(configuration);
    } else {
      // Wait until HugeRTE is loaded
      setTimeout(function() {
        HugeRTERails.initialize(config, options);
      }, 50);
    }
  },

  setupTurbolinks: function() {
    // Remove all HugeRTE instances before rendering
    document.addEventListener('turbolinks:before-render', function() {
      hugeRTE.remove();
    });
  },

  _merge: function() {
    var result = {};

    for (var i = 0; i < arguments.length; ++i) {
      var source = arguments[i];

      for (var key in source) {
        if (Object.prototype.hasOwnProperty.call(source, key)) {
          if (Object.prototype.toString.call(source[key]) === '[object Object]') {
            result[key] = HugeRTERails._merge(result[key], source[key]);
          } else {
            result[key] = source[key];
          }
        }
      }
    }

    return result;
  }
};

if (typeof Turbolinks != 'undefined' && Turbolinks.supported) {
  HugeRTERails.setupTurbolinks();
}

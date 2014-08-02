define(function(require, exports, module) {
    var Engine  = require("famous/core/Engine");
    var Surface = require("famous/core/Surface");

    var mainContext = Engine.createContext(document.getElementById('field'));

    var surface = new Surface({
        size: [800, 600],
        content: "This is the tank field",
        classes: ["red-bg"],
        properties: {
            backgroundColor: "#99c999",
            lineHeight: "200px",
            textAlign: "center"
        }
    });

    mainContext.add(surface);
});

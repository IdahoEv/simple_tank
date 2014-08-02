define(function(require, exports, module) {
    var Engine  = require("famous/core/Engine");
    var Surface = require("famous/core/Surface");
    var StateModifier = require("famous/modifiers/StateModifier");
    var Transform = require("famous/core/Transform");
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

    var tank = new Surface({
      size: [16,16],
      properties: {
        backgroundColor: "#333333"
      }  
    });

    var tankPosition = new StateModifier({
      transform: Transform.translate(400,300,1)
    });

    mainContext.add(surface);
    mainContext.add(tankPosition).add(tank);
});

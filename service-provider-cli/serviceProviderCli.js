'use strict'

const program = require('commander')

const chalkAnimation = require('chalk-animation');

console.log("SN 234578 SERVICE PROVIDER NODE STARTED...")
const animation = chalkAnimation.neon("SCANNING FOR DEVICES...");
setTimeout(() => {
    animation.stop(); // Animation stops
    console.log("DEVICE WITH IP 85.183.197.59 FOUND")
}, 4000);




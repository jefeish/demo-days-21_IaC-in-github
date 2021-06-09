"use strict";
//------------------------------------------------------------------------------
// Description:
//  A hubot script that does things
//
// Configuration:
//  LIST_OF_ENV_VARS_TO_SET
//
// Commands:
//  hubot hello - <what the respond trigger does>
//  orly - <what the hear trigger does>
//  dilbert - <the dilbert of the day>
//
// Notes:
//  <optional notes required for the script>
//
// Author:
//   <jefeish@github.com>
//------------------------------------------------------------------------------

exports.__esModule = true;

function command(cmd, args) {

  const c = spawn(cmd, args)
  robot.logger('commando')
  c.stdout.on("data", data => {
    robot.logger.error(`stdout: ${data}`);
  });

  c.stderr.on("data", data => {
    robot.logger(`stderr: ${data}`);
  });

  c.on('error', (error) => {
    robot.logger(`error: ${error.message}`);
  });

  c.on("close", code => {
    robot.logger(`child process exited with code ${code}`);
  });

  return c.stdout
}

module.exports = function (robot) {
  const github = require('githubot')(robot)
  const exec = require('child_process');
  var http = require('http');
  var util = require('util');
  var { spawn } = require("child_process");

  robot.respond(/hello/, function (res) {
    robot.logger('response-hello')
    return res.reply("_hello!_");
  });

  robot.hear(/orly/, function (res) {
    return res.send("<http:#www.foo.com|This message *is* a link> :scream:");
  });

  robot.hear(/.ghes /, function (res) {
    robot.logger('response-hello')
    return res.send(command('terraform', ['version']))

  });

  robot.hear(/dilbert$/, function (res) {
    var today = new Date;
    var ms = today.getTime();
    var dd = today.getDate() - 1;
    var mm = today.getMonth() + 1;
    var _dd;
    var _mm;
    var yyyy = today.getFullYear();
    //for 2 digit dates
    if (dd < 10) {
      _dd = '0' + dd;
    }
    if (mm < 10) {
      _mm = '0' + mm;
    }
    return res.send("https:#dilbert.com/strip/" + yyyy + "-" + _mm + "-" + _dd + "?x=" + ms);
  });
};
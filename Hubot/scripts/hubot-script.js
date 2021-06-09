"use strict";
// ------------------------------------------------------------------------------
// Description:
//   A hubot script that does things
//
// Configuration:
//   LIST_OF_ENV_VARS_TO_SET
//
// Commands:
//   hubot hello - <what the respond trigger does>
//   orly - <what the hear trigger does>
//   dilbert - <the dilbert of the day>
//
// Notes:
//   <optional notes required for the script>
//
// Author:
//    <jefeish@github.com>
// ------------------------------------------------------------------------------

exports.__esModule = true;

module.exports = function (robot) {
    const github = require('githubot')(robot)
    var http = require('http');
    var util = require('util');
    var run_cmd = function (cmd, args, cb) {
        var spawn = require("child_process").spawn;
        var child = spawn(cmd, args);
        child.stdout.on("data", function (buffer) { return cb(buffer.toString()); });
        return child.stderr.on("data", function (buffer) { return cb(buffer.toString()); });
    };

    robot.respond(/hello/, function (res) { return res.reply("_hello!_"); });

    robot.hear(/orly/, function (res) { return res.send("<http://www.foo.com|This message *is* a link> :scream:"); });

    robot.hear(/.ghes/, function (res) {
        exec("./command.sh", (error, stdout, stderr) => {
            if (error) {
                console.log(`error: ${error.message}`);
                return;
            }
            if (stderr) {
                console.log(`stderr: ${stderr}`);
                return;
            }
            console.log(`stdout: ${stdout}`);
        });
    });

    robot.hear(/dilbert$/, function (res) {
        var today = new Date;
        var ms = today.getTime();
        var dd = today.getDate() - 1;
        var mm = today.getMonth() + 1;
        var _dd;
        var _mm;
        var yyyy = today.getFullYear();
        // for 2 digit dates
        if (dd < 10) {
            _dd = '0' + dd;
        }
        if (mm < 10) {
            _mm = '0' + mm;
        }
        return res.send("https://dilbert.com/strip/" + yyyy + "-" + _mm + "-" + _dd + "?x=" + ms);
    });
};
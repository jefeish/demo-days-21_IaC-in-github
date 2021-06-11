# Description:
#   Build out the services Engineering Demo stack using Hubot
#
# Dependencies:
#   None
#
# Configuration:
#
# Commands:
#   `hubot demo stack <build|destroy>` *OPTIONAL:* `ghes -v X.Y.Z` `-c <aws|azure>` - Builds/Destroys a GHES demo stack  *DEFAULTS:* -v 3.1.0 -c azure
#

#######################
# Launch the listener #
#######################
module.exports = (robot) ->

  ####################################################
  # Launch demo stack ################################
  ####################################################
  robot.respond /(demo stack|ds|demostack) (build|destroy)(?:\s)?(.*)?/i, (msg) ->

    userName = msg.message.user.name.toLowerCase()

    # set up args
    args = []
    options = null
    options_list = null

    # Get options if passed
    if msg.match[3]?
      options = msg.match[3].replace /^\s+|\s+$/g, ""
      options_list = options.split " "
      if options_list.length = 4
        for k, v of options_list
          args.push(v)
    else
      msg.send "no options"
      args.push("-v", "3.1.0", "-c", "azure")

    # translate 'build' to 'action'
    action =  msg.match[2]

    if action.match( "build" )
      action = "apply"

    # Pass the creators username as a option to the build script
    args.push("-a", "#{action}", "-o", "#{userName}")

    robot.logger.info "I am about to #{action} the GHES Demo-Stack for #{userName} with options:#{args}"
    msg.send "```\nI am about to #{action} the GHES Demo-Stack for #{userName} with options:#{args}\n```"
    
    # Start the job
    # instantiate child process to be able to create a subprocess
    {spawn} = require 'child_process'
    # create new subprocess and have it run the script
    cmd = spawn '/Users/jefeish/projects/demo-days-21_IaC-in-github/Hubot/scripts/iac-deploy.sh', args
    # catch stdout and output into hubot's log
    cmd.stdout.on 'data', (data) ->
      msg.send "#{data.toString()}"
      console.log data.toString().trim()
    # catch stderr and output into hubot's log
    cmd.stderr.on 'data', (data) ->
      console.log data.toString().trim()
      # msg.send "```\n#{data.toString()}\n```"

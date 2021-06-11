# Description:
#   Build out the services Engineering Demo stack using Hubot
#
# Dependencies:
#   None
#
# Configuration:
#
# Commands:
#   `hubot demo stack build ghes -v X.Y.Z -c <aws|azure>` - Builds out demo stack  *DEFAULTS:* --ghe=3.1.0 --cloud=azure
#   `hubot demo stack destroy ghes -v X.Y.Z -c <aws|azure>` - Destoys demo stack associated with you
#
# Author:
#   AdmiralAwkbar

###########
# Globals #
###########
generalRoom = "C6DEDBK8A"   # #genral slack channel
randomRoom = "C6CQLJVPA"    # #random slack channel

#######################
# Launch the listener #
#######################
module.exports = (robot) ->

  ####################################################
  # Launch demo stack ################################
  ####################################################
  robot.respond /(?:demo stack|ds|demostack) build (ghes)(?:\s)?(.*)?/i, (msg) ->
    userName = msg.message.user.name.toLowerCase()
    # set up args
    args = []
    options = null
    stackName = msg.match[1].replace /^\s+|\s+$/g, ""
    # Get options if passed
    if msg.match[2]?
      options = msg.match[2].replace /^\s+|\s+$/g, ""
    # robot.logger.info "Building Stack #{stackName} for #{userName} with options:#{options}"

    # Build the args
    options_list = options.split " "
    robot.logger.info "#{options_list} "
    # Pass the creators username as a option to the build script
    args.push("-a", "apply", "-o", "#{userName}")
    
    for k, v of options_list
      args.push(v)

    robot.logger.info "Building Stack #{stackName} for #{userName} with options:#{args}"
    msg.send "```\nBuilding Stack #{stackName} for #{userName} with options:#{args}\n```"

    # Start the job
    #msg.send "Generating Demo stack#{stackName} for #{userName}"
    # instantiate child process to be able to create a subprocess
    {spawn} = require 'child_process'
    # create new subprocess and have it run the script
    cmd = spawn('/Users/jefeish/projects/demo-days-21_IaC-in-github/Hubot/scripts/iac-deploy.sh', args)
    # catch stdout and output into hubot's log
    cmd.stdout.on 'data', (data) ->
      msg.send "#{data.toString()}"
      console.log data.toString().trim()
    # catch stderr and output into hubot's log
    cmd.stderr.on 'data', (data) ->
      console.log data.toString().trim()
      # msg.send "```\n#{data.toString()}\n```"
  ####################################################
  ############ END OF LOOP ###########################
  ####################################################

  ####################################################
  # Destroy demo stack ###############################
  ####################################################
  robot.respond /(?:demo stack|ds|demostack) destroy (ghes)(?:\s)?(.*)?/i, (msg) ->
    userName = msg.message.user.name.toLowerCase()
    # set up args
    args = []
    options = null
    stackName = msg.match[1].replace /^\s+|\s+$/g, ""
    # Get options if passed
    if msg.match[2]?
      options = msg.match[2].replace /^\s+|\s+$/g, ""
    # robot.logger.info "Building Stack #{stackName} for #{userName} with options:#{options}"

    # Build the args
    options_list = options.split " "
    robot.logger.info "#{options_list} "
    # Pass the creators username as a option to the build script
    args.push("-a", "destroy", "-o", "#{userName}")

    for k, v of options_list
      args.push(v)

    robot.logger.info "Destroying stack '#{stackName}' for #{userName} with options:#{args}"
    msg.send "Destroying stack '#{stackName}' for @#{userName} with options:#{args}"

    # Start the job
    #msg.send "Destroying Demo stack#{stackName} for #{userName}"
    # instantiate child process to be able to create a subprocess
    return
    {spawn} = require 'child_process'
    # create new subprocess and have it run the script
    cmd = spawn('~/projects/demo-days-21_IaC-in-github/Hubot/scripts/iac-deploy.sh', args)

    # catch stdout and output into hubot's log
    cmd.stdout.on 'data', (data) ->
      msg.send "#{data.toString()}"
      console.log data.toString().trim()
    # catch stderr and output into hubot's log
    cmd.stderr.on 'data', (data) ->
      console.log data.toString().trim()
      msg.send "```\n#{data.toString()}\n```"
  ####################################################
  ############ END OF LOOP ###########################
  ####################################################

# Description:
#   Build out the services Engineering Demo stack using Hubot
#
# Dependencies:
#   None
#
# Configuration:
#
# Commands:
#   `hubot demo stack build ` *OPTIONALS:*  `--ghe=X.Y.Z` `--cloud=<aws|azure>` ` - Builds out demo stack  *DEFAULTS:* --ghe=3.1.0 --cloud=azure
#   `hubot demo stack list` - Lists all demo stacks available to build
#   `hubot demo stack destroy` *OPTIONALS:* `--region=AWS-REGION` - Destoys demo stack associated with you DEFAULT Region: us-west-2
#   `hubot demo stack details|status` *OPTIONALS:* `--tail=LENGTH` `--user=USERNAME` - Gives details of current Demo stack Default: 15 lines and current user
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
  # List stacks details ##############################
  ####################################################
  robot.respond /(?:demo stack|ds|demostack) (?:details|status)(?:\s)?(.*)?/i, (msg) ->
    # Get the username from slack
    userName = msg.message.user.name.toLowerCase()
    # set up args
    args = []
    options = null
    # Get options if passed
    if msg.match[1]?
      options = msg.match[1].replace /^\s+|\s+$/g, ""
    # Debugger
    robot.logger.info "Getting Stack details with options:#{options}"

    # Build the args
    args.push('details' + "," + userName + "," + options)
    # instantiate child process to be able to create a subprocess
    {spawn} = require 'child_process'
    # create new subprocess and have it run the script
    cmd = spawn 'scripts/utilities/demo-stack-mgmt.sh', args
    # catch stdout and output into hubot's log
    cmd.stdout.on 'data', (data) ->
      msg.send "```\n#{data.toString()}\n```"
      console.log data.toString().trim()
    # catch stderr and output into hubot's log
    cmd.stderr.on 'data', (data) ->
      console.log data.toString().trim()
      msg.send "```\n#{data.toString()}\n```"
  ####################################################
  ############ END OF LOOP ###########################
  ####################################################


  ####################################################
  # Launch demo stack ################################
  ####################################################
  robot.respond /(?:demo stack|ds|demostack) build ([\w\.\-_]+)(?:\s)?(.*)?/i, (msg) ->
    userName = msg.message.user.name.toLowerCase()
    # set up args
    args = []
    options = null
    stackName = msg.match[1].replace /^\s+|\s+$/g, ""
    # Get options if passed
    if msg.match[2]?
      options = msg.match[2].replace /^\s+|\s+$/g, ""
    robot.logger.info "Building Stack #{stackName} for #{userName} with options:#{options}"

    # Build the args
    # Pass the creators username as a option to the build script
    args.push('build' + "," + stackName + "," + "-u=#{userName} #{options}")
    # Start the job
    #msg.send "Generating Demo stack#{stackName} for #{userName}"
    # instantiate child process to be able to create a subprocess
    {spawn} = require 'child_process'
    # create new subprocess and have it run the script
    cmd = spawn('scripts/utilities/demo-stack-mgmt.sh', args)
    # catch stdout and output into hubot's log
    cmd.stdout.on 'data', (data) ->
      msg.send "```\n#{data.toString()}\n```"
      console.log data.toString().trim()
    # catch stderr and output into hubot's log
    cmd.stderr.on 'data', (data) ->
      console.log data.toString().trim()
      msg.send "```\n#{data.toString()}\n```"
  ####################################################
  ############ END OF LOOP ###########################
  ####################################################

  ####################################################
  # Destroy demo stack ###############################
  ####################################################
  robot.respond /(?:demo stack|ds|demostack) destroy(?:\s)?(.*)?/i, (msg) ->
    userName = msg.message.user.name.toLowerCase()
    # set up args
    args = []
    options = null
    # Get options if passed
    if msg.match[1]?
      options = msg.match[1].replace /^\s+|\s+$/g, ""
    # Build the args
    # Pass the creators username as a option to the build script
    args.push('destroy' + "," + "placeholder" + "," + "-u=#{userName} #{options}")
    robot.logger.info "Destroying Stack for #{userName} with options:#{options}"
    # Start the job
    #msg.send "Destroying Demo stack for #{userName}"
    # instantiate child process to be able to create a subprocess
    {spawn} = require 'child_process'
    # create new subprocess and have it run the script
    cmd = spawn 'scripts/utilities/demo-stack-mgmt.sh', args
    # catch stdout and output into hubot's log
    cmd.stdout.on 'data', (data) ->
      msg.send "```\n#{data.toString()}\n```"
      console.log data.toString().trim()
    # catch stderr and output into hubot's log
    cmd.stderr.on 'data', (data) ->
      console.log data.toString().trim()
      msg.send "```\n#{data.toString()}\n```"
  ####################################################
  ############ END OF LOOP ###########################
  ####################################################

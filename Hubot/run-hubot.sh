#!/bin/bash
# export HUBOT_GITHUB_API=34.221.230.104
export HUBOT_ADAPTER=slack
export HUBOT_GITHUB_API=github.com
export HUBOT_GITHUB_TOKEN=aaa6a789e2ba4f89ca9f5cb1e6b4573c104f897f
export HUBOT_SLACK_TOKEN=xoxb-1481192959829-1514937920997-g6CK9UOMuPRoWmGAolU8X3JZ
export HUBOT_GITHUB_KEY=automation-demo-key.pem

docker run -d --name "hubot" \
--dns 8.8.8.8 \
-p 222:22 \
-e HUBOT_ADAPTER=$HUBOT_ADAPTER \
-e HUBOT_SLACK_TOKEN=$HUBOT_SLACK_TOKEN \
-e HUBOT_GITHUB_TOKEN=$HUBOT_GITHUB_TOKEN \
-e HUBOT_GITHUB_API=$HUBOT_GITHUB_API \
-e HUBOT_GITHUB_KEY=$HUBOT_GITHUB_KEY \
-v /Users/jefeish/projects/:/home/hubot/packages \
-v $(pwd)/scripts:/home/hubot/scripts -v /Users/jefeish/.ssh/:/.ssh/ \
hubot
FROM hashicorp/tfc-agent:latest
RUN mkdir /home/tfc-agent/.tfc-agent
ADD --chown=tfc-agent:tfc-agent hooks /home/tfc-agent/.tfc-agent/hooks

USER root

# Create a directory we will later save our identity token to
RUN mkdir /.aws-workload
RUN chown -R tfc-agent:tfc-agent /.aws-workload

USER tfc-agent

#!/bin/bash

echo "Preparing AWS provider auth..."

# Remove any previous identity tokens

rm -f /.aws-workload/token-file
 
echo $TFC_WORKLOAD_IDENTITY_TOKEN > /.aws-workload/token-file

mkdir ~/.aws

echo "[default]" >> ~/.aws/config
echo "role_arn=$TFC_AWS_RUN_ROLE_ARN" >> ~/.aws/config
echo "web_identity_token_file=/.aws-workload/token-file" >> ~/.aws/config
echo "role_session_name=$TFC_RUN_ID" >> ~/.aws/config

echo "AWS provider auth prepared"

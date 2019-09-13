#!/bin/bash

# THIS SCRIPT WAS DEVELOPED TO REORGANIZE TASKS ACROSS THE CLUSTER AFTER A SCALE IN OR OUT OF INSTANCES.
#
#  You must have an autoscaling group activated and working for you spot fleet
#  This script monitors the spot fleet status and if it's on "pending_fulfillment" or "pending_termination" status
# it will sleep 5 minutes so the spot request have enough time to launch new instances and then trigger your Jenkins'
# build and so redeploy all tasks according to you build.
#
#  As an alternative for triggering Jenkins or any other CI/CD tool it's possible to directly trigger the deploy by
# using AWS CLI just by changing curl command in deployApi function for the command as in the example.
# 
#  e.g.
#  aws ecs update-service --cluster <cluster-name> --service <service-name> --force-new-deployment --region <aws-region>
#
# JENKINS_USER=<jenkins-user>
# USER_API_KEY=<user-api-key>
# JENKINS_JOB_URL=http://<jenkins_server_url>/job/<your_jenkins_job_name>/build
# SPOT_FLEET_ID=<spot-fleet-id> # e.g sfr-79j584g1-5611-46n1-9cb5-39f0gh561236

deployApi() {
    JENKINS_USER=<jenkins-user>
    JENKINS_JOB_URL=http://<jenkins_server_url>/job/<your_jenkins_job_name>/build
    USER_API_KEY=<user-api-key>
    sleep 300
    curl -XPOST --user $JENKINS_USER:$USER_API_KEY $JENKINS_JOB_URL
}

deployWithoutJenkins() {
    CLUTER=<cluster-name>
    REGION=us-east-1 # set your cluster's region
    sleep 300 # 300 seconds is enough time for the spot instances to launch and be available
    aws ecs update-service --cluster $CLUSTER --service <service1-name> --force-new-deployment --region $REGION
    aws ecs update-service --cluster $CLUSTER --service <service2-name> --force-new-deployment --region $REGION
    aws ecs update-service --cluster $CLUSTER --service <service3-name> --force-new-deployment --region $REGION
}

SPOT_FLEET_ID=<spot-fleet-id>

while true; do
    STATUS=$(aws ec2 describe-spot-fleet-requests --spot-fleet-request-ids $SPOT_FLEET_ID \
    | grep -Po '"ActivityStatus":.*?[^\\]",' \
    | cut -d : -f2 \
    | sed 's/\"//g;s/\,//g;s/ //g')
    if [[ $STATUS = "pending_fulfillment" || [[ $STATUS = "pending_termination" ]]; then
        deployWithoutJenkins;
        # deployApi;
    fi
    sleep 5
done

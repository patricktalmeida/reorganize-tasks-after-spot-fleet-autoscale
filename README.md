# reorganize-tasks-after-spot-fleet-autoscale

 THIS SCRIPT WAS DEVELOPED TO REORGANIZE TASKS ACROSS THE CLUSTER AFTER A SCALE IN OR OUT OF INSTANCES.

  You must have an autoscaling group activated and working for you spot fleet
  This script monitors the spot fleet status and if it's on "pending_fulfillment" or "pending_termination" status
 it will sleep 5 minutes so the spot request have enough time to launch new instances and then trigger your Jenkins'
 build and so redeploy all tasks according to you build.

  As an alternative for triggering Jenkins or any other CI/CD tool it's possible to directly trigger the deploy by
 using AWS CLI just by changing curl command in deployApi function for the command as in the example.
 
 e.g.
 aws ecs update-service --cluster <cluster-name> --service <service-name> --force-new-deployment --region <aws-region>

JENKINS_USER=<jenkins-user>
 USER_API_KEY=<user-api-key>
 JENKINS_JOB_URL=http://<jenkins_server_url>/job/<your_jenkins_job_name>/build
 SPOT_FLEET_ID=<spot-fleet-id> # e.g sfr-79j584g1-5611-46n1-9cb5-39f0gh561236

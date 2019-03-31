# FarmIoT
Short excercise for a Agriculture IoT solution

# Architecture

## Architecture Image 



## Application Action Flow

- Iot Device data flows through stream analytics for processing any anomalies. Data is also transferred to Time Series Insights for dashboards. It uses storage accounts on the background, which means the data is also kept within the region (LRS / ZRS replication).
- Stream analytics detects anomalies and sends config changes to the configuration function app, which acts on the event accordingly. Validation of device ownership needs to be checked, as IoT hub does not yet allow for great user segregation. See Code remarks. 
- The Stream analytics also triggers email notifications from sendgrid / sms notifications via twilio using a function. This function fetches the correct user data from the customer databases.
- Dashboards are served to customers through time series API calls made from the web front end.

# Notes

## General

- This template deployment defaults to a small P1 redis cluster, which in itself costs 700€/month. Please destroy the resources when needed.
- Azure AD is assumed to exist already
- The templates only deploy one region of the application. Small tweaks will be needed for multiregion deployments. For example traffic manager & cosmosDB replication need to be adjusted.
- Telemetry from all functions & app service go to the Application insights instance in the region. It's worth considering either having a single instance in one region, or creating a central place for logs where all the app insights instances stream to (requires custom setup).
- App service needs to be at least a standard sku to allow for autoscaling. 
- Customer DB does not have autoscaling, but a primitive version could be implemented with Cosmonaut: https://chapsas.com/cosmosdb-action-level-autoscaling-with-cosmonaut/
- The parameters are mostly for example purposes only.
- Twilio is not in scope of the deployment.


## Code remarks
- IoT hub does not support autoscaling out of the box, but can be implemented via a function. Either node.js or .net SDKs can be used for this, but it has already been written in C#. Code for it can be found here: https://github.com/Azure-Samples/iot-hub-dotnet-autoscale
- IoT hub also does not support great user segregation. Current suggestion is to create a custom enforcement: https://github.com/Azure/azure-iot-sdk-csharp/issues/36
- Stream analytics could have at least the following 4 types of queries: absence of data from device, temperature threshold, humidity threshold, flow of water levels. These could be modified on customer basis by the device config functions.
- Enrollment groups for device provisioning service could be created as part of a new customer onboarding action (out of scope for this task)
- Web app can be written in node.js or C# for example. As it will be mostly calling for webhooks of the functions.
- Time series API only has a javascript client library, so the API functions would be easiest to create using that.
- Notification function can also be node or C#. Twilio and sendgrid support both.
 
## Deployment flow
- Base (Storage accounts, AppInsights, Databases)
- Device backend (IoT hub + scale function (+ still unimplemented role assingment))
- Stream processing (Sendgrid, notification function, Stream analytics)
- Config change (validation function, config + add functions)
- Dashboards (Time series insights, api function)
- Frontend + Secret management (webapp, keyvault, traffic manager)

# Improvements for future
- Breaking nested template structure to Azure DevOps pipelines, variable groups etc.
- Investigation whether some function apps need linux platform. Currently all are windows.
- Implementation of API Management as a reverse proxy for all the functions?
- Implement vnet between customer databases, using service endpoints. Just need a way to allow for notification function to query db.
- Redis cache firewall / virtual network tie-in. Schedule updates, Geo replication?
- Function template to copy loop through input for application settings for better reusability OR Automatic implementation of all endpoint information to functions via powershell.
- Inclusion of data saving to data lake / cosmosdb for long term storage, data processing, machine learning?
- App insights alerting
- Azure AD B2C could be considered as an identity option instead of B2B, but unfortunately I do not have much experience with it.
- CosmosDB database creation via powershell etc. No documentation available in ARM currently.
- Log Analytics + Adding IOT hub logs there.
- Determine required webapp sizing based on load testing (could use Azure DevOps for testing)
- Function name & apikey in stream analytics ouput is currently not set, it cannot be currently fetched in ARM and would require custom function to do so: https://medium.com/@mandur/get-azure-function-host-key-in-an-arm-deployment-template-1eb7ba03c083 
- Scale function contributor role assignment to IOT hub is not currently being done in the deployment
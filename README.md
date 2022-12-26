# azure-devops-repo-backup-clone
azure-devops-repo-backup-clone
## Cloning all repositories from Azure DevOps using Azure CLI

I use a lot of different computers and I have a thing for reimaging my computers way too often. All in all, this means that I find myself sitting in front of a newly installed computer quite often.

One thing that I always to on a fresh computer is to clone a bunch of repos from my personal organization in Azure DevOps that contains my notes and a selection of tools that I want available everywhere I go. Another scenario is when I get to a customer, they give me access to a bunc of projects in Azure DevOps with repos that I’m supposed to contribute to.

Im both of these scenarios I find my self copy-pasting urls and running git clone a few times. I know, doesn’t sound too hard, but I really dislike doing things more than once!

So what do to? Let’s use PowerShell ofcourse!

There’s an extension to Azure CLI for integrating with Azure DevOps which I’ve found really handy. I’m supprised by how many people I’ve met that isn’t aware of the vast amount of extensions available to the Azure CLI so I thought I’d share how I can use this to clone all Azure repositories I have access to in Azure DevOps.

I assume we already have Azure CLI installed, if not it’s time to Install the Azure CLI.

First we need to sign in. This is done by caling “az login”. If I don’t have access to any subscriptions in Azure I’ll have to add the parameter " –allow-no-subscriptions".

az login --allow-no-subscriptions

Then we need to make sure we have the right extension installed. Installed extensions can be listed with the command:

az extension list
If there are many extensions istalled this list can be a bit overwhelming. I could convert the output from JSON to objects using PowerShell and then filter the list as I would anything else in PowerShell. But, there’s a native way of filtering in the Azure CLI, so why not use that? The Azure CLI has a parameter called “–query” that takes a JMESPath expression. JMESPath is similar to XPath, but for JSON instead of XML, it is documented over at https://jmespath.org/.

The response I get from listing extensions is an array of extensions. To filter that I can use the following expression: ‘[?name == ‘‘azure-devops’'].name’. I can also tell the Azure CLI to output the result in a tab separated format instead of JSON by adding the parameter “-o tsv”. This suits me well here since I’ll just get one name back.

az extension list  --query '[?name == ''azure-devops''].name' -o tsv
If I get ‘azure-devops’ back I’m good to go! If I get nothing back, I need to install the devops extension. This is done by running:

az extension add --name 'azure-devops'
Now we’re ready to shoot some queries to Azure DevOps! To list repositories in Azure DevOps we need to supply the organization URL and the project name. Let’s store the organization name in a variable and use that to list all projects. Once again we use a query to get only the names back and choose to get output as tsv.

$Organization = 'https://dev.azure.com/SimonWahlin'
$Projects = az devops project list --organization $Organization --query 'value[].name' -o tsv
Now I’m ready to list all repositories in each project!

foreach ($Proj in $Projects) {
  az repos list --organization $Organization --project $Proj | ConvertFrom-Json
}
This will output an object for each repository. The path to clone using https if found in the property webUrl. Now if we combine this we get the following script:

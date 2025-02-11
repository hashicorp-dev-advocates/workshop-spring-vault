# Frequently Asked Questions

Below are a list of frequently asked questions from
workshop attendees for this session.

## Should I refactor my code to make API calls to Vault?
   
You can opt to use Vault agent or Vault Secrets Operator
for Kubernetes. This workshop focuses on refactoring a Spring Boot
application to retrieve secrets from Vault and reload when the secret
changes. Other application frameworks like .NET do support some kind
of live application reload but you may need to write additional
code for injection or refresh.

## My application doesn't use Spring Boot. How do I handle reloads?

You will need to write code that handles the following:

1. Authenticate to Vault
1. Get secrets
1. Use secrets in application
1. Retry to get new secrets
1. Reload objects that use secrets

## Why does this example use Java Records?

While the Spring development community still uses
JPA Repository, the latest Java version offer records.
As a result, this example shows the use of records.

## Previous Vault examples with transit secrets engine used `EntityListener`. Why doesn't this example show its use?

`EntityListener` requires JPA Repository, which is not a pattern used in
this example. EntityListener can help mutate the payload before the repository
writes it to the database.

## Why are you using Vault token authentication in this example?

This is to demonstrate the local development process. If you do not
want to use a live Vault server (whether a test instance or a dev server
you created locally), you can override attributes manually with a `local`
profile. There is no supported library for mocking Vault APIs. In production,
use an alternative authentication method supported by your Vault team.

## My application needs to immediately pick up changes to key-value secrets in Vault but the example shows a scheduled retry.

You can use Vault Enterprise event streams to subscribe to key-value changes and reload based on events. Event streams uses WebSockets.
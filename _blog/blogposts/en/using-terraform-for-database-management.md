---
title: Using Terraform for Database Management
description: Learn how Vonage's Site Reliability Engineers (SREs) are using Toil
  to improve the infrastructure of the APIs provided.
thumbnail: /content/blog/using-terraform-for-database-management/terraform_database-management_1200x600.png
author: avadhut-phatarpekar
published: true
published_at: 2021-06-03T14:20:57.468Z
updated_at: 2021-05-26T10:23:28.078Z
category: engineering
tags:
  - terraform
  - python
  - sql
comments: true
spotlight: false
redirect: ""
canonical: ""
outdated: false
replacement_url: ""
---
One of the most important journeys we are undertaking here at Vonage is to transform ourselves into an agile engineering organization using site reliability engineering (SRE) principles. And that means we are almost allergic to [toil](https://sre.google/sre-book/eliminating-toil/).

> Toil is the kind of work that tends to be manual, repetitive, automatable, tactical, devoid of enduring value, and scales linearly as a service grows.

We are constantly looking for ways to make regular toil actions more process-oriented using automation.

## Problem

One such class of toil activities that we engage in regularly is database changes—schema alterations, ad-hoc modification of records to fix issues, grants management, etc. SREs were the gatekeepers affecting these changes for different engineering teams directly on the databases in a world without automation. This situation posed two issues—SREs become the bottleneck, not allowing teams to move fast enough, and there is little in terms of audit trail of the actual queries running on the database.

To solve these problems, we needed to come up with automation that allowed

* engineers to specify and run SQL they wanted to run on databases (what we refer to as pushplans)
* run checks on the submitted pushplans that stop unsafe/malicious changes from going through
* maintain an audit trail of what is happening in a canonical source of truth, preferably some version control system (VCS)

## Approach

[Terraform](https://www.terraform.io/) was an excellent choice for us since we were already running it at scale to manage our cloud infrastructure. One of the often-overlooked aspects of Terraform is that it is excellent at managing the state. Using this functionality, we wanted to allow engineers to specify the desired changes in a declarative, idempotent manner and let the automation do the heavy lifting.

The other issue to address was access to data. For compliance reasons, engineers at Vonage are not in ready possession of database credentials. We store all our credentials in an encrypted manner using [AWS SecretsManager](https://aws.amazon.com/secrets-manager/). So, although our engineers did not have access to these, our automation could access the credentials.

Finally, we needed a runner to execute the engineer-specified pushplans safely. For the actual checks and executing pushplans we decided to use Python, which a lot of our tooling is widely used. And the entire package ran on Jenkins that allowed us to democratise access to perform database changes to the whole engineering organisation safely.

![An image as an overview of the lifecycle of a pushplan](/content/blog/using-terraform-for-database-management/db_pushplans-overview.png)

## Code

### SQL pushplans

For the actual SQL pushplans, we went with good old YAML. If someone wants to effect a change in the DB, they simply specify the name of the database cluster and the actual SQL they want to run like so:

```yaml
---
cluster: dblocal_wdc4
sql: |
    USE config;
    ALTER TABLE mt_routing ADD COLUMN routeToRoutingGroupId VARCHAR(50) NULL DEFAULT NULL AFTER routeToTargetGroupId;
```

We used Terraform’s [local-exec](https://www.terraform.io/docs/language/resources/provisioners/local-exec.html) functionality to run a Python script that would make the database changes:

```tf
resource "null_resource" "db_pushplan" {
  # This will rerun the pushplan if the file contents have been changed
  triggers = {
    hash = filebase64(var.pushplan_file)
  }

  provisioner "local-exec" {
    command = "pipenv run python ${path.module}/pushplan_executor.py -d ${var.db_host} -p ${var.db_port} -f ${var.pushplan_file}"

    environment = {
      db_username = var.db_username
      db_password = var.db_password
    }
  }
}
```

**Note:** It is important to pass credentials to the script as environment variables to avoid leaking them into logs or bash history.

### Python

The python script we used to run the actual pushplan does more than just execution. Initially, it performs a series of checks:

* Makes sure that the cluster specified in the pushplan is valid
* Using the Python [sqlparse](https://github.com/andialbrecht/sqlparse) library, checks to see if the SQL specified is valid.
* If the SQL contains any disallowed actions—SELECT, GRANT, SHOW—it fails fast informing the users of the reason/s.
* Executes the actual SQL statements safely:
  * If there are several updates, it will sleep between consecutive statements to not overload the database.
  * If there are ALTERs, it will use [gh-ost](https://github.com/github/gh-ost) to affect the changes safely.

## Conclusion

There are still several improvements that we’d like to fold into this tool. Such as

* Using [Terraform’s MySQL provider](https://www.terraform.io/docs/providers/mysql/index.html) to do grants management. This provider allows engineers to mint and use different database users for different applications faster.
* Incorporating [Flyway](https://flywaydb.org/) into the tool to ensure that this also serves as a canonical source of truth for all our schemas.
* Build in a promotion mechanism that will allow engineers to canary/test changes in non-prod first. If found running successfully, engineers can promote those changes to prod.

And there will be many more. However, it has now given us a good foundation to extend this automation to all other aspects of database management with the base mechanism set.



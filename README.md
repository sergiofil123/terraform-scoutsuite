# terraform-scoutsuite

## Overview

A fully automated **Infrastructure as Code (IaC)** solution on AWS that launches an EC2 instance to run a **ScoutSuite** security report.

## Description

[ScoutSuite](https://github.com/nccgroup/ScoutSuite) is an open-source, multi-cloud security auditing tool.

I’ve been using it to quickly check the security posture of my AWS account. Of course, you can (and should) use native AWS services like AWS Security Hub, but ScoutSuite generates a very readable and insightful report — especially useful if you're running a private AWS account as a tech enthusiast.

This project automates the process by launching an EC2 instance in a public subnet, running ScoutSuite, and exposing the generated report on port 80 of the instance’s public IP.

## Implementation Details

When you deploy this IaC project:
- It discovers your default VPC and the latest Ubuntu 22.04 AMI.
- It launches an EC2 instance, installs ScoutSuite, runs the report, and serves it via Apache HTTP Server.
  - The tofu output displays the public IP of the EC2 instance. Give it a few minutes for the setup and scan to complete, then visit the IP in your browser to view the report.
  - ⚠️ Note: The EC2 instance **may incur charges**, as it’s not using a free-tier eligible type.


## How to Run

This automation is designed to be run locally using **OpenTofu**, **AWS CLI**, and your **IAM credentials**.

```sh
cd src
tofu init
tofu plan
tofu apply
```

## Future Improvements

Potential improvements for this project:

- **Security Enhancements**: Currently, port 80 is open to all IP addresses. For improved security, consider restricting access to your own IP or placing the instance behind a Load Balancer in a private subnet.


---

💪 **Automate ScoutSuite and take control of your AWS account security!** 🚀


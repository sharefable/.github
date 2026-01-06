# Fable - Open-Source Interactive Demo Platform

<div align="center">

**Create, edit, and share interactive product demos without recording videos**

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

</div>

---

## What is Fable?

Fable is a complete platform for creating interactive product demonstrations by capturing real web applications and transforming them into editable, shareable demos. Unlike traditional screen recording tools, Fable captures the DOM structure of web pages, allowing you to edit content, customize themes, and create branching narratives—all after the initial capture.

### Key Capabilities

- **Intelligent Capture**: Browser extension records real user interactions and serializes complete DOM snapshots, including cross-origin iframes
- **Interactive Editing**: Modify text, images, and UI elements in captured demos without re-recording
- **AI-Powered Enhancement**: Claude AI integration for automatic demo generation, theme extraction, and content suggestions
- **Demo Hubs**: Organize multiple demos into customizable collections with branching paths
- **Analytics & Insights**: Track viewer engagement, lead capture, and conversion metrics
- **Custom Domains**: Support for vanity domains with SSL certificates
- **Enterprise Integrations**: Native connectors for HubSpot, Slack, Salesforce (via Cobalt), Zapier, and custom webhooks

### How It Works

1. **Capture**: Install the Chrome extension and record interactions on any web application
2. **Serialize**: Every click triggers DOM serialization across all frames (including cross-origin iframes), storing complete page state as JSON
3. **Reconcile**: Captured snapshots are merged, assets are proxied, and data is uploaded to S3
4. **Edit**: Use the React-based editor to modify content, add annotations, customize themes, and enhance with AI
5. **Publish**: Share demos via links, embed them in websites, or organize them into demo hubs
6. **Analyze**: Track viewer behavior, capture leads, and measure engagement through integrated analytics

---

## Architecture

Fable consists of three main components working together:

```
┌─────────────────────────────────────────────────────────────┐
│                     Browser Extension                        │
│          (Capture interactions, serialize DOM)              │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│                    Frontend Application                      │
│        (React/Redux - Demo editing & management)            │
│                    Port 3000 (dev)                          │
└────────────────────┬────────────────────────────────────────┘
                     │
        ┌────────────┴────────────┐
        ▼                         ▼
┌──────────────────┐    ┌──────────────────────┐
│   API Server     │    │    Jobs Service      │
│  (Spring Boot)   │◄───┤   (Node.js/Express)  │
│   Port 8080      │    │      Port 8081       │
└────┬─────────────┘    └──────────┬───────────┘
     │                             │
     │                   ┌─────────┴──────────┐
     │                   ▼                    │
     ├─────────┬──────────────────┼───────────┼──────────────┐
     ▼         ▼                  ▼           ▼              ▼
┌────────┐ ┌──────────┐    ┌───────────┐ ┌─────────┐  ┌──────────┐
│ MySQL  │ │PostgreSQL│    │  AWS SQS  │ │EventBridge│ │  AWS S3  │
│(Main DB)│ │(Analytics)│   │  (Queue)  │ │Scheduler │ │ (Assets) │
└────────┘ └──────────┘    └───────────┘ └─────────┘  └──────────┘
                                              │
                                              └─► Triggers scheduled
                                                  analytics jobs
```

### Component Overview

**Frontend (`app/`)** - React/TypeScript application
- Demo capture reconciliation and upload
- Interactive demo editor with real-time preview
- Demo hub management and publishing
- Analytics dashboards and lead management
- User authentication (Auth0)

**API Server (`api/`)** - Spring Boot/Java backend
- RESTful API for all CRUD operations
- OAuth2 authentication and authorization
- Subscription and billing management (Chargebee)
- Custom domain and SSL provisioning (AWS Amplify)
- Integration management (HubSpot, Cobalt, Zapier)

**Jobs Service (`jobs/`)** - Node.js event processor
- SQS message queue consumer
- AI-powered demo generation (Claude API)
- Media transcoding (AWS Elastic Transcoder)
- Text-to-speech generation (OpenAI)
- Analytics job execution triggered by EventBridge Scheduler (PostgreSQL)
- Third-party webhook delivery

**Browser Extension (`app/workspace/packages/ext-tour/`)** - Chrome extension
- Cross-origin frame detection and script injection
- DOM serialization and snapshot capture
- Screenshot and metadata collection
- Cookie and authentication state preservation

---

## Repository Structure

```
fable/
├── app/                      # Frontend monorepo (Yarn Workspaces)
│   └── workspace/packages/
│       ├── client/          # Main React application
│       ├── common/          # Shared TypeScript libraries
│       └── ext-tour/        # Chrome extension for recording
│
├── api/                     # Spring Boot API server
│   ├── src/main/java/      # Java source code
│   ├── schema/api/         # MySQL migrations (Flyway)
│   └── schema/analytics/   # PostgreSQL migrations
│
├── jobs/                    # Node.js jobs service
│   ├── src/                # TypeScript source
│   ├── src/http/llm-ops/  # Claude AI integrations
│   └── src/processors/     # SQS message handlers
│
└── .github/                # Documentation and infrastructure
    ├── profile/            # This README
    ├── terraform-fable.tf  # Infrastructure as code
    └── privacy/            # Privacy documentation
```

---

## Quick Start

### Local Development Setup

You can run **app** and **api** locally for core demo creation and editing functionality. Note that AI-powered features require the **jobs** service, which depends on AWS SQS.

For detailed setup instructions, refer to the component-specific READMEs:
- **[Frontend Setup](https://github.com/sharefable/app)** - Installation, configuration, and running the app
- **[API Setup](https://github.com/sharefable/api)** - Database setup, environment configuration, and running the server
- **[Jobs Setup](https://github.com/sharefable/jobs)** - SQS configuration and running the jobs service

### Limited Functionality Without Jobs

When running only **app** + **api**:
- ✅ Create and edit demos manually
- ✅ Upload and manage captured snapshots
- ✅ Publish demos and demo hubs
- ✅ View basic analytics
- ❌ AI-powered demo generation
- ❌ Automatic theme extraction
- ❌ Text-to-speech voiceovers
- ❌ Video/audio transcoding

---

## Deployment

### Infrastructure Setup

Fable uses AWS for production infrastructure. The Terraform configuration is provided but requires customization.

#### Customize Terraform Configuration

The `.github/terraform-fable.tf` file contains the complete infrastructure definition. Before using it, you must customize several placeholders:

```bash
cd .github
cp terraform-fable.tf terraform-fable-custom.tf
```

Edit `terraform-fable-custom.tf` and replace the following:

**1. AWS Account ID**
- Replace all instances of `TODO-AWS-ACC-ID-HERE` with your AWS account ID

**2. Domain Names**
- Replace `TODO-example-domain.com` with your actual domain
- Update all subdomain references (`app.`, `api.service.`, `jobs.service.`, etc.)

**3. S3 Bucket Names** (must be globally unique)
- `origin-scdna` → Choose a unique name for asset storage
- `app.production.todo-example-domain.com` → Your production frontend bucket
- `app.todo-example-domain.com` → Your staging frontend bucket
- `usr-events` → Analytics events bucket
- `ccd1.proxyfable.com` → Proxy cache bucket
- `origin.scdna.todo-example-domain.com` → Origin CDN bucket

**4. Configuration Values**
- Replace all `TODO:VALUE_HERE` placeholders with actual values:
  - Database passwords (`REPLACEME`)
  - API keys (Anthropic, OpenAI, Chargebee, HubSpot, etc.)
  - Auth0 configuration
  - Third-party integration credentials

**5. Network Configuration** (if needed)
- Update CIDR blocks for VPC and subnets
- Modify security group rules for your network policies
- Update `TODO-xxx.xxx.xxx.xxx/xx` with your IP ranges for SSH access

**6. SSL Certificates**
- Ensure ACM certificates are provisioned in the correct regions:
  - `us-east-1` for CloudFront distributions
  - `us-east-2` for Application Load Balancers

Once customized, initialize and apply.

For component-specific deployment steps (building images, pushing to ECR, updating ECS), refer to respective services.

---

## Technology Stack

| Component | Technologies |
|-----------|-------------|
| **Frontend** | React 18, TypeScript, Redux, Ant Design, Lexical, CodeMirror, Styled Components |
| **API Server** | Spring Boot 3, Java 17, MySQL 8, PostgreSQL 16, OAuth2, Flyway |
| **Jobs Service** | Node.js 18, TypeScript, Anthropic Claude, OpenAI, AWS SDK |
| **Extension** | TypeScript, Webpack 5, Chrome Extension APIs |
| **Infrastructure** | AWS (ECS, RDS, S3, SQS, CloudFront, ALB, EventBridge), Terraform |
| **Auth** | Auth0 (OAuth2 + JWT) |
| **Integrations** | Chargebee, HubSpot, Cobalt, Slack, Zapier, Sentry |

---

## Credits & License

### Credits

**All code in this repository was written by the Fable team.**

If you use, modify, or distribute this code, you must provide appropriate credit to Fable and the original authors.

### License

This project is licensed under the **Apache License 2.0**.

You are free to:
- ✅ Use the code commercially
- ✅ Modify and create derivatives
- ✅ Distribute and sublicense
- ✅ Use privately

**Requirements**:
- 📝 Include the original copyright notice and license
- 📝 State significant changes made to the code
- 📝 Provide attribution to the Fable team

See the LICENSE of each module for complete terms.

### Attribution Requirement

When using Fable code in your project, please include the following attribution:

```
Powered by Fable (https://github.com/sharefable)
Copyright © 2026 Fable. All rights reserved.
Licensed under Apache License 2.0
```

---

## Support & Contributing

### Getting Help

- **Documentation**: Check component-specific READMEs ([app](../app/README.md) • [api](../api/README.md) • [jobs](../jobs/README.md))
- **Issues**: [Open an issue](https://github.com/sharefable/app/issues)

### Acknowledgments

Fable uses many excellent open-source libraries. See the `package.json` files in each component for a complete list of dependencies.

---

**Built with ❤️ by the Fable team**

Copyright © 2026 Fable. All rights reserved.
